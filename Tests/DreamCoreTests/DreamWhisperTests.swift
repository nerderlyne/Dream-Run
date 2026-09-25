import XCTest
@testable import DreamCore

final class DreamWhisperTests:XCTestCase {
    func testTutorialInstructionsStayContextual() {
        var run=RunState(identity:.current(seed:42),mode:.tutorial)
        run.phase = .running
        run.distance=20
        XCTAssertTrue(DreamWhispers.message(for:run)?.contains("tilt for balloons") == true)
        run.distance=120
        XCTAssertTrue(DreamWhispers.message(for:run)?.contains("swipe up") == true)
        run.distance=230
        XCTAssertTrue(DreamWhispers.message(for:run)?.contains("swipe down") == true)
        run.distance=320
        XCTAssertTrue(DreamWhispers.message(for:run)?.contains("don't touch the rabbit") == true)
        run.phase = .paused
        XCTAssertNil(DreamWhispers.message(for:run))
    }

    func testLaterWhispersAreSparseDeterministicAndStateBased() {
        var run=RunState(identity:.current(seed:73),mode:.revisit)
        run.phase = .running
        run.activeTicks=24*60
        XCTAssertNil(DreamWhispers.message(for:run))
        run.activeTicks=120*60
        XCTAssertEqual(DreamWhispers.message(for:run),DreamWhispers.message(for:run))
        XCTAssertNotNil(DreamWhispers.message(for:run))
        run.activeTicks=125*60
        XCTAssertNil(DreamWhispers.message(for:run))
        var seen=Set<String>()
        for slot in 0..<100 {
            run.activeTicks=UInt64((25+45*slot)*60)
            if let message=DreamWhispers.message(for:run) {seen.insert(message)}
        }
        XCTAssertTrue(seen.contains("do u remember?"))
        run.pigs=[CollectedPig(ordinal:1,hue:0)]
        seen.removeAll()
        for slot in 0..<100 {
            run.activeTicks=UInt64((25+45*slot)*60)
            if let message=DreamWhispers.message(for:run) {seen.insert(message)}
        }
        XCTAssertTrue(seen.contains("i love pigs <3"))
        run.mode = .debug
        XCTAssertNil(DreamWhispers.message(for:run))
    }

    func testGeneralLinesAppearOnlyInFourMinuteWindows() {
        var run=RunState(identity:.current(seed:7),mode:.fresh)
        run.phase = .running
        for second in 0...600 {
            run.activeTicks=UInt64(second*60)
            XCTAssertEqual(DreamWhispers.message(for:run) != nil,
                           [120,360,600].contains(where:{second >= $0 && second < $0+4}),
                           "Unexpected general whisper at \(second)s")
        }
    }

    func testHazardWhispersAreStableOneInFiveOpportunities() {
        var run=RunState(identity:.current(seed:41),mode:.fresh)
        run.phase = .running
        var rabbits=0,luckyPigs=0
        for index in 0..<200 {
            run.hazards=[HazardDescription(id:"rabbit:\(index)",asset:.rabbit,encounter:.dodge,distance:30,lateral:0,radius:0.5,height:0.5)]
            let first=DreamWhispers.message(for:run)
            run.activeTicks=60
            XCTAssertEqual(DreamWhispers.message(for:run),first)
            run.activeTicks=0
            if first != nil {rabbits += 1}
            var pig=HazardDescription(id:"pig:\(index)",asset:.pig,encounter:.dodge,distance:30,lateral:0,radius:0.5,height:0.5)
            pig.pig=PigDecision(ordinal:index,clover:0,continued:false)
            run.hazards=[pig]
            if DreamWhispers.message(for:run) != nil {luckyPigs += 1}
        }
        XCTAssertGreaterThan(rabbits,20)
        XCTAssertLessThan(rabbits,60)
        XCTAssertGreaterThan(luckyPigs,20)
        XCTAssertLessThan(luckyPigs,60)
        run.hazards=[HazardDescription(id:"ordinary pig",asset:.pig,encounter:.dodge,distance:30,lateral:0,radius:0.5,height:0.5)]
        XCTAssertNil(DreamWhispers.message(for:run))
    }
}
