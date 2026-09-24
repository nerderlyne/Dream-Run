import Foundation
import QuartzCore
import UIKit
import os

/// Inert unless explicitly enabled by the development profiling harness.
/// Signposts measure CPU work, not GPU completion or screen presentation.
@MainActor enum PerformanceTrace {
    static let log = OSLog(subsystem: "dev.shivanshi.dream-run", category: "Performance")
    static var recorder: FrameRecorder?

    static func measure<T>(_ name: StaticString, _ work: () throws -> T) rethrows -> T {
        guard let recorder else { return try work() }
        let start = CACurrentMediaTime()
        let id = OSSignpostID(log: log)
        os_signpost(.begin, log: log, name: name, signpostID: id)
        defer {
            recorder.stageMilliseconds[String(describing: name), default: 0] += (CACurrentMediaTime() - start) * 1000
            os_signpost(.end, log: log, name: name, signpostID: id)
        }
        return try work()
    }
}

@MainActor final class FrameRecorder {
    struct Sample: Codable, Sendable {
        var elapsed: Double
        var intervalMS: Double
        var workMS: Double
        var tick: UInt64
        var distance: Double
        var seed: String
        var phase: String
        var entities: Int
        var thermal: Int
        var stages: [String: Double]
    }
    struct Report: Codable, Sendable {
        var format = 1
        var captureID = UUID()
        var recordedAt = Date()
        var device: String
        var os: String
        var duration: Double
        var requestedSeconds: Double
        var framesDroppedFromRecording: Int
        var note = "Development harness; automated oracle inputs; isolated nonrewarding profile. Record compiler optimization flags alongside this report. Intervals are display-link callbacks, not measured GPU presentation. Includes cold and warm frames."
        var samples: [Sample]
    }
    let duration: Double
    let seed: UInt64
    private(set) var complete = false
    private var started: Double?
    private var previous: Double?
    private var frameStart = 0.0
    private var interval = 0.0
    private var samples: [Sample] = []
    private var discarded = 0
    var stageMilliseconds: [String: Double] = [:]

    init(duration: Double, seed: UInt64) {
        self.duration = duration.isFinite ? max(15, min(600, duration)) : 120
        self.seed = seed
        samples.reserveCapacity(36_100)
    }

    func begin() {
        frameStart = CACurrentMediaTime()
        if started == nil { started = frameStart }
        interval = previous.map { (frameStart - $0) * 1000 } ?? 0
        previous = frameStart
        stageMilliseconds.removeAll(keepingCapacity: true)
    }

    func end(run: RunState, entities: Int) {
        guard !complete, let started else { return }
        let now = CACurrentMediaTime()
        let sample = Sample(elapsed: now-started, intervalMS: interval,
                            workMS: (now-frameStart)*1000, tick: run.activeTicks,
                            distance: run.distance, seed: String(run.identity.seed),
                            phase: run.phase.rawValue, entities: entities,
                            thermal: ProcessInfo.processInfo.thermalState.rawValue,
                            stages: stageMilliseconds)
        if samples.count < 36_100 { samples.append(sample) } else { discarded += 1 }
        if now-started >= duration { complete = true }
    }

    func export() {
        let report = Report(device: UIDevice.current.model, os: UIDevice.current.systemVersion,
                            duration: samples.last?.elapsed ?? 0, requestedSeconds: duration,
                            framesDroppedFromRecording: discarded, samples: samples)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("performance-last.json")
        Task.detached(priority: .utility) {
            do {
                let encoder = JSONEncoder()
                let bytes = try encoder.encode(report)
                try bytes.write(to: url, options: .atomic)
                print("PERFORMANCE_REPORT_READY \(url.lastPathComponent) \(report.samples.count) frames")
            } catch { print("PERFORMANCE_REPORT_FAILED \(error)") }
        }
    }
}
