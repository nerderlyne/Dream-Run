import Foundation

public extension PickupDescription {
    /// Cosmetic motion and collision share this active-time trajectory. No extra RNG draws.
    var floatsHigh:Bool {distance>100 && !id.hasPrefix("drop-balloon:") && SplitMix64.fnv(id)%4==0}
    func balloonPosition(at tick:UInt64)->(lateral:Double,height:Double,roll:Double) {
        let phase=Double(SplitMix64.fnv(id)%1024)/1024*2*Double.pi
        let t=Double(tick)/60
        let bob=sin(t*1.8+phase)
        let lift=floatsHigh ? 1.25+0.55*sin(t*0.85+phase) : 0
        return (lateral+0.14*sin(t*1.25+phase),height+lift+0.12*bob,0.09*sin(t*1.25+phase))
    }
}
