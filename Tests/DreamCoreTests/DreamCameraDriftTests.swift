import XCTest
@testable import DreamCore

final class DreamCameraDriftTests:XCTestCase {
    func testDriftIsSmallContinuousAndVisualOnly() {
        var run=RunState(identity:.current(seed:42),mode:.fresh)
        run.phase = .running
        run.activeTicks=600
        let before=run
        let sample=DreamCameraDrift.sample(run:run,reducedMotion:false)
        XCTAssertEqual(sample,DreamCameraDrift.sample(run:run,reducedMotion:false))
        XCTAssertLessThan(abs(sample.side),0.04)
        XCTAssertLessThan(abs(sample.height),0.03)
        XCTAssertLessThan(abs(sample.aim),0.04)
        XCTAssertLessThan(abs(sample.roll),0.009)
        XCTAssertEqual(run.activeTicks,before.activeTicks)
        XCTAssertEqual(run.distance,before.distance)

        run.activeTicks += 1
        let next=DreamCameraDrift.sample(run:run,reducedMotion:false)
        XCTAssertLessThan(abs(next.side-sample.side),0.002)
        XCTAssertLessThan(abs(next.roll-sample.roll),0.001)
    }

    func testMirrorSwellsAndReducedMotionStopsDrift() {
        var run=RunState(identity:.current(seed:73),mode:.tutorial)
        run.phase = .running
        run.activeTicks=600
        let ordinary=DreamCameraDrift.sample(run:run,reducedMotion:false)
        run.phase = .mirrorCrossing
        let mirror=DreamCameraDrift.sample(run:run,reducedMotion:false)
        XCTAssertEqual(mirror.side,ordinary.side*1.55,accuracy:0.00001)
        XCTAssertEqual(DreamCameraDrift.sample(run:run,reducedMotion:true),.still)
        run.phase = .paused
        XCTAssertEqual(DreamCameraDrift.sample(run:run,reducedMotion:false),.still)
        run.mode = .debug
        run.phase = .running
        XCTAssertEqual(DreamCameraDrift.sample(run:run,reducedMotion:false),.still)
    }
}
