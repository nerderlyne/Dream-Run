import AVFAudio
import UIKit

/// Bounded, preloaded native audio graph. The stereo theta bus bypasses every
/// reverb/spatial effect. All synthesis is original, reproducible bundled PCM.
@MainActor final class DreamAudio: NSObject {
    let engine=AVAudioEngine()
    let thunder=AVAudioPlayerNode(), theta=AVAudioPlayerNode()
    private let musicBus=AVAudioMixerNode(), reverb=AVAudioUnitReverb()
    private let motif=AVAudioPlayerNode(), pulse=AVAudioPlayerNode()
    private var beds:[String:AVAudioPlayerNode]=[:]
    private let voices=(0..<4).map { _ in AVAudioPlayerNode() }
    private var voiceIndex=0
    private(set) var buffers:[String:AVAudioPCMBuffer]=[:]
    private(set) var thunderBuffer:AVAudioPCMBuffer?
    private(set) var running=false
    private var runID:UUID?
    private var variant = -1
    private var lastBalloonTick:UInt64?
    private var lastMenu=0.0
    private var pickupNote=0
    var musicIsPlaying:Bool { beds.values.contains(where:{$0.isPlaying}) || motif.isPlaying || pulse.isPlaying }
    static let bedNames=["air","water","uncanny","void","white","alien"]

    override init() {
        super.init()
        func read(_ name:String)->AVAudioPCMBuffer? {
            guard let url=Bundle.main.url(forResource:name,withExtension:"wav"),
                  let file=try? AVAudioFile(forReading:url),
                  let buffer=AVAudioPCMBuffer(pcmFormat:file.processingFormat,frameCapacity:AVAudioFrameCount(file.length)) else { return nil }
            do { try file.read(into:buffer); return buffer } catch { return nil }
        }
        let names=Self.bedNames+["motif-0","motif-1","motif-2","pulse","theta","balloon-1","balloon-2"]+DreamSoundCue.allCases.map(\.rawValue)
        for name in names { buffers[name]=read("dream-"+name) }
        thunderBuffer=read("thunder-strike")
        let mono=AVAudioFormat(standardFormatWithSampleRate:22050,channels:1)!
        let stereo=AVAudioFormat(standardFormatWithSampleRate:44100,channels:2)!
        engine.attach(musicBus); engine.attach(reverb)
        reverb.loadFactoryPreset(.largeHall); reverb.wetDryMix=23
        engine.connect(musicBus,to:reverb,format:stereo)
        engine.connect(reverb,to:engine.mainMixerNode,format:stereo)
        for name in Self.bedNames {
            let node=AVAudioPlayerNode(); beds[name]=node; engine.attach(node)
            engine.connect(node,to:musicBus,format:mono); node.volume=0
        }
        for node in [motif,pulse] {
            engine.attach(node); engine.connect(node,to:musicBus,format:mono); node.volume=0
        }
        for node in voices+[thunder] {
            engine.attach(node); engine.connect(node,to:engine.mainMixerNode,format:mono)
        }
        engine.attach(theta); engine.connect(theta,to:engine.mainMixerNode,format:stereo); theta.volume=0
        engine.mainMixerNode.outputVolume=0.6 // Headroom for concurrent effects and thunder.
        try? AVAudioSession.sharedInstance().setCategory(.ambient,mode:.default,options:[.mixWithOthers])
        NotificationCenter.default.addObserver(self,selector:#selector(routeChanged),name:AVAudioSession.routeChangeNotification,object:nil)
        NotificationCenter.default.addObserver(self,selector:#selector(routeChanged),name:UIAccessibility.monoAudioStatusDidChangeNotification,object:nil)
    }
    var stereoHeadphoneRoute:Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains {
            [.headphones,.bluetoothA2DP,.bluetoothLE].contains($0.portType)
        }
    }
    @objc private func routeChanged() {
        // Stop immediately on a route change; the next game update re-evaluates
        // eligibility. Phone speakers, AirPlay and mono accessibility never play it.
        theta.stop(); theta.volume=0
    }
    private func startEngine()->Bool {
        if !engine.isRunning { do { try engine.start() } catch { return false } }
        return true
    }
    private func loop(_ node:AVAudioPlayerNode,_ name:String,target:Float,amount:Float) {
        guard let buffer=buffers[name] else { return }
        if target>0 && !node.isPlaying {
            node.volume=0; node.scheduleBuffer(buffer,at:nil,options:.loops); node.play()
        }
        node.volume += (target-node.volume)*amount
        if target == 0 && node.volume<0.0001 { node.stop(); node.volume=0 }
    }
    func update(run:RunState,settings:Settings,delta:Double) {
        guard [.running,.safeDrop,.mirrorCrossing,.luckyTransition,.whiteEnding].contains(run.phase) else { return }
        if runID != run.id {
            stop(); runID=run.id; variant = -1; lastBalloonTick=nil; pickupNote=0
        }
        guard settings.music || settings.effects || settings.thetaEnabled else { stop(); return }
        guard startEngine() else { return }
        running=true
        let scene=DreamSoundscape(run:run)
        let dt=max(0,min(0.1,delta.isFinite ? delta : 0))
        let amount=Float(1-exp(-dt/(run.phase == .mirrorCrossing ? 0.018 : 1.8)))
        let space:Float=scene.bed == "water" ? 32 : scene.bed == "void" ? 8 : 23
        reverb.wetDryMix += (space-reverb.wetDryMix)*amount
        let music=Float(settings.music ? DreamSoundscape.level(settings.musicLevel) : 0)
        for (name,node) in beds {
            loop(node,name,target:name == scene.bed ? Float(scene.bedGain)*music : 0,amount:amount)
        }
        if variant != scene.motifVariant { motif.stop(); variant=scene.motifVariant }
        loop(motif,"motif-\(variant)",target:Float(scene.motifGain)*music,amount:amount)
        loop(pulse,"pulse",target:Float(scene.pulseGain)*music,amount:amount)
        let eligible=DreamSoundscape.thetaAllowed(settings:settings,headphones:stereoHeadphoneRoute,mono:UIAccessibility.isMonoAudioEnabled)
        if eligible {
            loop(theta,"theta",target:Float(DreamSoundscape.level(settings.thetaLevel)*scene.thetaGain),amount:Float(1-exp(-dt/2)))
        } else { theta.stop(); theta.volume=0 }
        if !settings.effects { for node in voices { node.stop() }; thunder.stop() }
    }
    func movement(before:RunState,after:RunState,settings:Settings) {
        for cue in DreamMovementAudio().cues(before:before,after:after) { play(cue,settings:settings) }
    }
    func play(_ cue:DreamSoundCue,settings:Settings) {
        let name=cue == .balloon && pickupNote%3 != 0 ? "balloon-\(pickupNote%3)" : cue.rawValue
        guard settings.effects,let buffer=buffers[name],startEngine() else { return }
        if cue == .balloon { pickupNote=(pickupNote+1)%3 }
        // Four reusable one-shot voices prevent footfalls from cutting off jumps.
        let node=voices.first(where:{!$0.isPlaying}) ?? voices[voiceIndex]
        voiceIndex=(voiceIndex+1)%voices.count
        // Running stays just perceptible beneath the score. Preserve the contact
        // transient and surface timbre, but attenuate every footfall by ~17 dB.
        let cueGain:Float = [.step,.waterStep,.stoneStep].contains(cue) ? 0.14 : 1
        node.stop(); node.volume=Float(DreamSoundscape.level(settings.effectsLevel))*cueGain
        node.scheduleBuffer(buffer); node.play()
    }
    func feedback(_ event:GameEvent,settings:Settings,tick:UInt64?=nil) {
        if event == .thunder {
            if settings.haptics { UIImpactFeedbackGenerator(style:.heavy).impactOccurred(intensity:1) }
            guard settings.effects,let buffer=thunderBuffer,startEngine() else { return }
            thunder.stop(); thunder.volume=Float(DreamSoundscape.level(settings.effectsLevel))
            thunder.scheduleBuffer(buffer); thunder.play(); return
        }
        if event == .balloon,let tick {
            if let last=lastBalloonTick,tick>=last,tick-last<8 { return }
            lastBalloonTick=tick
        }
        let cue:DreamSoundCue
        switch event {
        case .balloon: cue = .balloon
        case .clover: cue = .clover
        case .stumble: cue = .stumble
        case .mirror: cue = .mirror
        case .drop: cue = .drop
        default: return
        }
        if settings.haptics && [.balloon,.clover,.stumble].contains(event) {
            UIImpactFeedbackGenerator(style:event == .clover ? .medium : .soft).impactOccurred(intensity:event == .stumble ? 0.65 : 0.3)
        }
        play(cue,settings:settings)
    }
    func menuFeedback(settings:Settings) {
        let now=ProcessInfo.processInfo.systemUptime
        guard now-lastMenu>0.1 else { return }; lastMenu=now
        play(.menu,settings:settings)
    }
    func stop(preserveThunder:Bool=false) {
        for node in Array(beds.values)+[motif,pulse,theta] { node.stop(); node.volume=0 }
        for node in voices { node.stop() }
        running=false
        if !preserveThunder || !thunder.isPlaying { thunder.stop(); engine.pause() }
    }
}
