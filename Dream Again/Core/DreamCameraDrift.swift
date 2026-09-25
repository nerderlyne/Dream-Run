import Foundation

/// Presentation-only camera motion. It never changes the route or collision state.
public struct DreamCameraDrift: Equatable, Sendable {
    public let side:Float
    public let height:Float
    public let aim:Float
    public let roll:Float

    public static let still=DreamCameraDrift(side:0,height:0,aim:0,roll:0)

    public static func sample(run:RunState,reducedMotion:Bool)->DreamCameraDrift {
        guard !reducedMotion,
              [.fresh,.revisit,.tutorial].contains(run.mode),
              [.running,.safeDrop,.mirrorCrossing].contains(run.phase) else {return .still}

        let t=run.seconds
        let phase=Double(run.identity.seed & 0xFFFF)/65535 * 2 * Double.pi
        let entrance=min(1,t/2)
        let mirrorAhead=run.hazards.filter{$0.encounter == .mirror && !$0.resolved}.map {hazard in
            let ahead=hazard.distance-run.distance
            return ahead >= 0 ? max(0,min(1,(32-ahead)/32)) : 0
        }.max() ?? 0
        let mirrorAfter:Double
        if run.phase == .mirrorCrossing {mirrorAfter=1}
        else if run.mirrorUntilTick > 0 && run.activeTicks >= run.mirrorUntilTick {
            mirrorAfter=max(0,1-Double(run.activeTicks-run.mirrorUntilTick)/180)
        } else {mirrorAfter=0}
        let stumble=run.instabilityUntil > run.activeTicks ? min(1,Double(run.instabilityUntil-run.activeTicks)/300) : 0
        let strength=entrance*(1+0.55*max(mirrorAhead,mirrorAfter,stumble))

        return DreamCameraDrift(
            side:Float(strength*0.025*(0.65*sin(t*0.88+phase)+0.35*sin(t*1.51+phase*1.7))),
            height:Float(strength*(0.012*sin(t*1.2+phase*0.6)+0.005*sin(t*3.9+phase))),
            aim:Float(strength*0.024*sin(t*0.74+phase*1.3)),
            roll:Float(strength*(0.0035*sin(t*0.94+phase)+0.0015*sin(t*1.73+phase*0.4)))
        )
    }
}
