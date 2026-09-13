import Foundation
/// Version-one defaults are also decoded from the bundled contract by the app.
/// Keep these immutable for G1/R1/C1 compatibility; a tuned release needs a new rules version.
public struct RunRules:Codable,Equatable,Sendable {
    public var baseSpeed=7.0,maximumSpeed=16.0,speedTimeConstant=300.0
    public var lateralLimit=1.25,lateralSpeed=4.5,smoothing=0.075
    public var jumpVelocity=8.0,gravity=22.0
    public var slideTicks=51
    public init() {}
    public init(configData:Data) throws {
        self.init()
        guard let root=try JSONSerialization.jsonObject(with:configData) as? [String:Any],let simulation=root["simulation"] as? [String:Any],let movement=root["movement"] as? [String:Any],let pigs=root["pigs"] as? [String:Any],let deep=root["deep_dream"] as? [String:Any] else {throw DreamError.corruptStore}
        func number(_ object:[String:Any],_ key:String)throws->Double {guard let number=object[key] as? NSNumber,number.doubleValue.isFinite else {throw DreamError.corruptStore};return number.doubleValue}
        guard try number(pigs,"checkpoint_seconds") == 780,try number(pigs,"presence_denominator") == 2,try number(pigs,"clover_given_pig_denominator") == 3,try number(pigs,"after_continue_clover_given_pig_denominator") == 6,pigs["pity_system"] as? Bool == false,deep["end_run"] as? Bool == false else {throw DreamError.unsupportedVersion}
        baseSpeed=try number(simulation,"base_speed_mps");maximumSpeed=try number(simulation,"max_speed_mps");speedTimeConstant=try number(simulation,"speed_time_constant_seconds")
        lateralLimit=try number(movement,"max_lateral_offset_m");lateralSpeed=try number(movement,"max_lateral_speed_mps");smoothing=try number(movement,"tilt_smoothing_seconds")
        jumpVelocity=try number(movement,"jump_velocity_mps");gravity=try number(movement,"gravity_mps2");slideTicks=Int((try number(movement,"slide_seconds")*60).rounded())
        guard self == RunRules() else {throw DreamError.unsupportedVersion}
    }
}

public struct FixedStepClock:Sendable {
    public private(set) var remainder=0.0
    public init() {}
    /// nil asks the host to pause. No excess time is silently converted to score.
    public mutating func consume(_ seconds:Double)->Int? {
        guard seconds.isFinite,seconds >= 0,seconds <= 0.25 else {remainder=0;return nil}
        remainder += seconds
        let ticks=Int(floor(remainder*60+1e-9))
        guard ticks <= 4 else {remainder=0;return nil}
        remainder=max(0,remainder-Double(ticks)/60)
        return ticks
    }
    public mutating func reset() {remainder=0}
}
