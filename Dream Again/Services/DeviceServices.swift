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
