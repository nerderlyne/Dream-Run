import XCTest
@testable import DreamCore
final class DreamTransitionCadenceTests: XCTestCase {
    func testEarlyTransitionAndBoundedIndependentIntervals() {
        var intervals=Set<Double>()
        for seed:UInt64 in 0..<100 {
            let identity=DreamIdentity.current(seed:seed)
            XCTAssertEqual(DreamTransitionCadence.at(identity:identity,seconds:19.999).index,0)
            var state=DreamTransitionCadence.at(identity:identity,seconds:20)
            XCTAssertEqual(state.index,1); XCTAssertEqual(state.start,20)
            for index in 1...200 {
                XCTAssertEqual(state.index,index)
                let interval=state.next-state.start
                XCTAssertTrue((30...90).contains(interval)); intervals.insert(interval)
                XCTAssertTrue((24...48).contains(state.overlapDuration))
                XCTAssertLessThan(state.overlapDuration,interval)
                XCTAssertEqual(state,DreamTransitionCadence.at(identity:identity,seconds:state.start))
                XCTAssertEqual(state,DreamTransitionCadence.at(identity:identity,seconds:state.next-0.001))
                state=DreamTransitionCadence.at(identity:identity,seconds:state.next)
            }
        }
        XCTAssertEqual(intervals.count,61)
    }
}
