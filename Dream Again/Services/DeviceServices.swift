import Foundation
import CoreMotion
import AVFAudio
import UIKit

@MainActor final class MotionInput {
    private let manager=CMMotionManager()
    private var reference=0.0
    private var calibrating=true
    private var lastSample=0.0
    var value=0.0
    var failed=false
    var available:Bool { manager.isDeviceMotionAvailable }
    private var startedAt=0.0
    func start() { guard manager.isDeviceMotionAvailable else { failed=true; return }; failed=false; calibrating=true; startedAt=ProcessInfo.processInfo.systemUptime; manager.deviceMotionUpdateInterval=1.0/60; manager.startDeviceMotionUpdates() }
    func stop() { manager.stopDeviceMotionUpdates(); value=0 }
    func calibrate() { calibrating=true }
    func sample(settings:Settings,now:Double,fullScaleDegrees:Double) -> Double? {
        guard let motion=manager.deviceMotion else { return ProcessInfo.processInfo.systemUptime-startedAt < 1 ? 0 : nil }
        let angle=atan2(motion.gravity.x,-motion.gravity.y)
        if calibrating { reference=angle; calibrating=false; lastSample=now }
        guard motion.timestamp > 0 else { return nil }
        if abs(ProcessInfo.processInfo.systemUptime-motion.timestamp) > 0.5 { failed=true; return nil }
        lastSample=now
        let degrees=(angle-reference)*180/Double.pi
        value=SteeringNormalizer.normalize(degrees:degrees,sensitivity:settings.sensitivity,deadzone:settings.deadzone,fullScaleDegrees:fullScaleDegrees); return value
    }
}
@MainActor final class DreamAudio {
    let engine=AVAudioEngine(), player=AVAudioPlayerNode(), effect=AVAudioPlayerNode()
    var running=false, palette = -1
    var lastFeedback=0.0
    init() {
        engine.attach(player); engine.attach(effect)
        engine.connect(effect,to:engine.mainMixerNode,format:AVAudioFormat(standardFormatWithSampleRate:22050,channels:1))
        engine.connect(player,to:engine.mainMixerNode,format:AVAudioFormat(standardFormatWithSampleRate:22050,channels:1))
        try? AVAudioSession.sharedInstance().setCategory(.ambient,mode:.default,options:[.mixWithOthers])
    }
    func update(active:Bool,palette:Int,settings:Settings) {
        guard active && settings.music else { player.pause(); running=false; return }
        if !engine.isRunning { do { try engine.start() } catch { return } }
        if self.palette != palette || !running {
            self.palette=palette; player.stop()
            let sampleRate=22050.0, count=Int(sampleRate*8), format=AVAudioFormat(standardFormatWithSampleRate:sampleRate,channels:1)!
            guard let buffer=AVAudioPCMBuffer(pcmFormat:format,frameCapacity:AVAudioFrameCount(count)), let channel=buffer.floatChannelData?[0] else { return }
            buffer.frameLength=AVAudioFrameCount(count)
            let base=palette == 5 ? 55.0 : palette >= 8 ? 73.5 : 110.0
            for i in 0..<count { let t=Double(i)/sampleRate, envelope=pow(sin(Double.pi*t/8),2); channel[i]=Float((sin(t*base*2*Double.pi)*0.04 + sin(t*base*3*Double.pi)*0.018 + sin(t*base*4*Double.pi)*0.012)*envelope*(palette == 5 ? 0.25 : 1)) }
            player.scheduleBuffer(buffer,at:nil,options:.loops); player.play(); running=true
        }
    }
    func feedback(_ event:GameEvent,settings:Settings) {
        let now=ProcessInfo.processInfo.systemUptime
        guard now-lastFeedback > 0.12 else { return }; lastFeedback=now
        if settings.haptics { UIImpactFeedbackGenerator(style:event == .clover ? .medium : .soft).impactOccurred(intensity:event == .stumble ? 0.65 : 0.3) }
        // Original short tone, bounded to one effect node at a time via the system sound-free engine.
        guard settings.effects else { return }; if !engine.isRunning { do { try engine.start() } catch { return } }
        let rate=22050.0, count=2205
        guard let format=AVAudioFormat(standardFormatWithSampleRate:rate,channels:1), let buffer=AVAudioPCMBuffer(pcmFormat:format,frameCapacity:AVAudioFrameCount(count)), let samples=buffer.floatChannelData?[0] else { return }
        buffer.frameLength=AVAudioFrameCount(count)
        let frequency=event == .clover ? 880.0 : event == .stumble ? 130.0 : 660.0
        for i in 0..<count { let t=Double(i)/rate, envelope=sin(Double.pi*Double(i)/Double(count))*exp(-t*25); samples[i]=Float(sin(2*Double.pi*frequency*t)*envelope*0.09) }
        effect.stop(); effect.scheduleBuffer(buffer); effect.play()
    }
    func stop() { player.pause(); effect.stop(); engine.pause(); running=false }
}
