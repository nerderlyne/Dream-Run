import Foundation

/// Active run time only: speed, stumbles and frame rate cannot postpone a reality change.
public struct DreamTransitionCadence: Equatable, Sendable {
    public let index: Int
    public let start: Double
    public let next: Double
    public var overlapDuration: Double { min(48, (next-start)*0.8) }
    public static func at(identity: DreamIdentity, seconds: Double) -> Self {
        var index=0, start=0.0, next=20.0
        while seconds >= next {
            index += 1; start=next
            var rng=identity.stream("dream-transition-cadence",index)
            next=start+30+Double(rng.below(61))
        }
        return .init(index:index,start:start,next:next)
    }
}
