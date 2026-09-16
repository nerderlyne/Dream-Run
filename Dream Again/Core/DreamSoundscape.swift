import Foundation

public struct DreamAudioPreferences: Codable, Sendable {
    public var musicLevel=0.75
    public var effectsLevel=0.7
    public var thetaEnabled=false
    public var thetaLevel=0.35
    public init() {}
}

/// Presentation-only mapping. Never consumes the gameplay random streams.
public struct DreamSoundscape: Sendable {
    public let bed: String
    public let bedGain: Double
    public let motifGain: Double
    public let pulseGain: Double
    public let thetaGain: Double
    public let motifVariant: Int
    public static func level(_ value: Double) -> Double { value.isFinite ? min(1,max(0,value)) : 0 }
    public static func thetaAllowed(settings: Settings, headphones: Bool, mono: Bool) -> Bool {
        settings.thetaEnabled && headphones && !mono
    }
    public init(run: RunState) {
        let palette=run.paletteIndex
        bed = palette == 7 ? "white" : palette >= 8 ? "alien" : palette == 5 ? "void" : palette == 1 ? "water" : [2,4,6].contains(palette) ? "uncanny" : "air"
        var rng=run.identity.stream("audio",0)
        motifVariant=Int(rng.below(3))
        let ending = [.luckyTransition,.whiteEnding].contains(run.phase)
        let endingGain=ending ? max(0,1-run.endingElapsed/57) : 1
        var density=1.0
        let elapsed=run.seconds.truncatingRemainder(dividingBy:10800)
        switch run.visual {
        case .deepStripping: density=max(0.12,1-elapsed/240)
        case .deepSparse: density=0.12
        case .deepRebuilding: density=0.12+0.88*min(1,max(0,(elapsed-300)/300))
        default: break
        }
        let busy=run.hazards.filter { !$0.resolved && $0.distance>run.distance && $0.distance-run.distance<run.speed*2 }.count
        let clarity=busy>1 ? 0.55 : 1.0
        let crossing=run.phase == .mirrorCrossing ? 0.08 : run.phase == .safeDrop ? 0.45 : 1
        let slide=run.player.slideTicks>0 ? 0.65 : 1
        bedGain=density*endingGain*crossing*slide*(palette == 5 ? 0.4 : 1)
        let lift = !run.player.grounded && run.player.velocityY>0 ? 0.12 : 0
        motifGain=density*endingGain*clarity*crossing*(palette == 5 ? 0.12 : 0.7+lift)
        pulseGain=ending ? 0 : density*clarity*crossing*(palette == 5 ? 0.05 : 0.45)*(1-run.stumbleWeight*0.8)
        thetaGain=endingGain
    }
}

public enum DreamSoundCue: String, CaseIterable, Sendable {
    case strawBreak, strawRepair, step, waterStep, stoneStep, jump, land, slide, balloon, clover, stumble, mirror, drop, menu
}

/// Called at simulation tick boundaries: accepted actions, not raw swipe attempts.
public struct DreamMovementAudio: Sendable {
    public init() {}
    public func cues(before: RunState, after: RunState) -> [DreamSoundCue] {
        guard before.id == after.id, after.activeTicks>before.activeTicks,
              [.running,.mirrorCrossing,.safeDrop].contains(after.phase) else { return [] }
        if after.phase == .safeDrop { return before.phase == .safeDrop ? [] : [.slide] }
        if before.player.grounded && !after.player.grounded && after.player.velocityY>0 { return [.jump] }
        if !before.player.grounded && after.player.grounded { return [.land] }
        if before.player.slideTicks == 0 && after.player.slideTicks>0 { return [.slide] }
        // Same six-metre gait as the renderer: two contacts per stride.
        if after.player.grounded && after.player.slideTicks == 0 &&
            floor(before.distance/3) != floor(after.distance/3) {
            let stairs=after.chunks.contains { $0.start<=after.distance && $0.end>after.distance && $0.step != nil }
            return [stairs ? .stoneStep : after.paletteIndex == 1 ? .waterStep : .step]
        }
        return []
    }
}
