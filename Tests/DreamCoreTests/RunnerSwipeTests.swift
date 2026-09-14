import XCTest
@testable import DreamCore

final class RunnerSwipeTests:XCTestCase {
    func testJumpCommitsBeforeReleaseAndNeverRepeatsDuringContact() {
        var swipe=RunnerSwipe()
        XCTAssertNil(swipe.update(x:2,y:-8))
        XCTAssertEqual(swipe.update(x:8,y:-24),.jump)
        for y in [-40.0,-100,60,0] {XCTAssertNil(swipe.update(x:0,y:y))}
    }
    func testSlideAndNextContact() {
        var swipe=RunnerSwipe()
        XCTAssertEqual(swipe.update(x:0,y:24),.slide)
        swipe=RunnerSwipe()
        XCTAssertEqual(swipe.update(x:0,y:-24),.jump)
    }
    func testSteeringJitterAndInvalidSamplesDoNotCommit() {
        var swipe=RunnerSwipe()
        for (x,y) in [(0.0,-23),(100,-40),(Double.nan,-40),(0,Double.infinity)] {
            XCTAssertNil(swipe.update(x:x,y:y))
        }
        XCTAssertEqual(swipe.update(x:15,y:-30),.jump)
    }
    func testRecognizedSwipeStartsJumpOnNextSimulationTick() {
        var simulation=GameSimulation(identity:.current(seed:17))
        simulation.resume()
        var swipe=RunnerSwipe()
        let action=swipe.update(x:0,y:-24)
        _=simulation.step(.init(jump:action == .jump))
        XCTAssertGreaterThan(simulation.state.player.height,0)
        XCTAssertGreaterThan(simulation.state.player.velocityY,0)
    }
}
