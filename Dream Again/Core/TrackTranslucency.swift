import Foundation

public struct TrackOpacity:Equatable,Sendable {
    public let base:Float
    public var pattern:Float {min(0.98,max(0.86,base+0.18))}
    public var edge:Float {1}
}
public enum TrackTranslucency {
    /// Smooth deterministic composition between long chapters; never consumes simulation RNG.
    public static func opacity(identity:DreamIdentity,distance:Double,seconds:Double,visual:VisualPhase,transitions:Int,ahead:Double,critical:Bool=false)->TrackOpacity {
        let phase=max(0,distance)/768,chapter=Int(phase),t=phase-Double(chapter)
        func value(_ index:Int)->Double {
            var rng=identity.stream("track-translucency",index+transitions*7919)
            let kind=rng.below(100),v=Double(rng.below(1000))/1000
            return kind<8 ? 0.39+v*0.16:kind<43 ? 0.57+v*0.19:0.75+v*0.18
        }
        let blend=t*t*(3-2*t)
        var base=value(chapter)*(1-blend)+value(chapter+1)*blend
        switch visual {
        case .deepSparse:base=0.94
        case .deepStripping:base += (0.94-base)*min(1,seconds.truncatingRemainder(dividingBy:10800)/240)
        case .deepRebuilding:base=0.62
        case .luckyWhite:base=0.76
        default:break
        }
        let near=max(0,1-max(0,ahead)/36),far=min(1,max(0,ahead-36)/200)
        base=min(0.96,base+near*0.12-far*0.09)
        if near>0 {base=max(base,critical ? 0.86:0.64)}
        return TrackOpacity(base:Float(max(0.3,base)))
    }
}
