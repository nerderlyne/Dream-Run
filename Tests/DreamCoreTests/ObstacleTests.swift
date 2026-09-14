import XCTest
@testable import DreamCore

final class ObstacleTests:XCTestCase {
    func scenario(_ kind:DreamObstacle,seconds:Double=0)->GameSimulation {
        let id=DreamIdentity.current(seed:17)
        var state=RunState(identity:id,mode:.debug)
        state.phase = .running;state.activeTicks=UInt64(seconds*60);state.lastPigOrdinal=1000
        let c=WorldGenerator(id).encounterChunk(0,kind:kind,tier:2)
        state.chunks=[c];state.hazards=c.hazards.map { original in
            var h=original;h.spawnTick=state.activeTicks
            if h.speed>0 {h.distance += 12;h.spawnTick=UInt64.max}
            if h.encounter == .lightning {h.strikeTick=state.activeTicks+UInt64(12/state.speed*60)}
            return h
        }
        return GameSimulation(certification:state,slope:0)
    }
    func testEveryObstacleHasASurvivalWitnessAtOpeningAndCap() {
        for kind in DreamObstacle.allCases {
            for seconds in [0.0,600] {
                var s=scenario(kind,seconds:seconds)
                for _ in 0..<400 where s.state.distance<38 {
                    _=s.step(EncounterOracle.input(s.state))
                    if s.state.phase != .running {break}
                }
                XCTAssertEqual(s.state.phase,.running,"\(kind) at \(seconds): \(s.state.cause)")
                XCTAssertGreaterThan(s.state.distance,38,"\(kind)")
            }
        }
    }
    func testMissedRequiredActionsAreFatal() {
        for kind:DreamObstacle in [.stairs,.brokenFloor,.window,.collapse,.furniture,.lightning] {
            var s=scenario(kind)
            for _ in 0..<300 {_=s.step()}
            XCTAssertEqual(s.state.phase,.waking,"\(kind) must require action")
        }
    }
    func testCornerBallKnocksOffExposedBridgeButCentreCanRecover() {
        for (width,lateral,fatal) in [(1.2,0.88,true),(1.2,0.0,false),(2.0,0.88,false)] {
            var s=scenario(.exposedBridge)
            s.state.chunks[0].halfWidth=width;s.state.player.lateral=lateral
            s.state.hazards=[.init(id:"ball",asset:.soccer,encounter:.rolling,distance:0.1,lateral:lateral-0.1,radius:0.45,height:0.9)]
            let events=s.step(.init(steering:lateral/0.9))
            XCTAssertTrue(events.contains(.stumble))
            XCTAssertEqual(s.state.phase == .waking,fatal)
            if fatal {XCTAssertEqual(s.state.cause,"fell from edge")}
            else {for _ in 0..<60 {_=s.step()};XCTAssertEqual(s.state.phase,.running)}
        }
    }
    func testLightningWarningCannotHitAndStrikeSurvivesSuspend() throws {
        var s=scenario(.lightning)
        s.state.hazards[0].distance=0.1;s.state.hazards[0].strikeTick=120
        XCTAssertFalse(s.step().contains(.waking))
        s.pause();let tick=s.state.activeTicks
        for _ in 0..<180 {_=s.step()}
        XCTAssertEqual(s.state.activeTicks,tick)
        let copy=try JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(s.state))
        var restored=try GameSimulation(snapshot:copy)
        XCTAssertEqual(restored.state.hazards[0].strikeTick,120)
        restored.resume();restored.state.activeTicks=119;restored.state.hazards[0].distance=restored.state.distance+0.1
        let events=restored.step();XCTAssertTrue(events.contains(.thunder));XCTAssertTrue(events.contains(.waking))
        XCTAssertEqual(restored.state.cause,"lightning")
    }
    func testContinueClearsTheWholeRecoverySurface() {
        var s=scenario(.collapse)
        s.state.distance=11;s.wake("fell")
        XCTAssertTrue(s.continueRun())
        XCTAssertTrue(s.state.chunks.allSatisfy{$0.gap == nil && $0.step == nil && !$0.collapsing && $0.halfWidth == 2})
        XCTAssertEqual(s.state.player.knockbackVelocity,0)
    }
    func testOrdinaryPigRemainsASoftObstacle() {
        var s=scenario(.animals)
        s.state.hazards=[.init(id:"ordinary-pig",asset:.pig,encounter:.dodge,distance:0.1,lateral:0,radius:0.65,height:0.65,pig:PigDecision(ordinal:1,presence:0,clover:2,continued:false))]
        XCTAssertTrue(s.step().contains(.stumble));XCTAssertEqual(s.state.pigs.count,0)
    }
    func testSwingUsesContinuousSharedTrajectory() {
        var h=HazardDescription(id:"moon",asset:.moon,encounter:.swing,distance:10,lateral:0,radius:0.38,height:2)
        h.motionPhase=0.7
        for tick:UInt64 in 1...300 {
            XCTAssertLessThanOrEqual(abs(h.lateral(at:tick)),0.95)
            XCTAssertLessThan(abs(h.lateral(at:tick)-h.lateral(at:tick-1)),0.036)
        }
        XCTAssertEqual(AssetID.allCases.count,42)
    }
    func testDensityIncreasesAndAllConceptsAppear() {
        let g=WorldGenerator(.current(seed:42))
        func count(_ range:Range<Int>)->Int {range.map{g.chunk($0)}.reduce(0){$0+$1.hazards.count+($1.gap == nil ? 0:1)}}
        XCTAssertGreaterThan(count(250..<290),count(4..<44))
        let chunks=(4..<500).map{g.chunk($0)}
        XCTAssertTrue(chunks.contains{$0.step != nil});XCTAssertTrue(chunks.contains{$0.collapsing})
        XCTAssertTrue(chunks.contains{$0.halfWidth<2})
        for encounter:Encounter in [.swing,.lightning,.jump,.slide,.rolling] {XCTAssertTrue(chunks.contains{$0.hazards.contains{$0.encounter == encounter}})}
    }
    func testTwentyMinuteProgressionEightSeeds() {
        for seed:UInt64 in 0..<8 {
            var s=GameSimulation(identity:.current(seed:seed));s.resume()
            for _ in 0..<(1200*60) {
                _=s.step(EncounterOracle.input(s.state))
                if ![.running,.mirrorCrossing,.safeDrop].contains(s.state.phase) {
                    return XCTFail("seed \(seed), \(s.state.seconds)s: \(s.state.cause), d=\(s.state.distance), x=\(s.state.player.lateral), nearby=\(s.state.hazards.filter{abs($0.position(at:s.state.activeTicks)-s.state.distance)<12})")
                }
            }
            XCTAssertEqual(s.state.unhinderedSpeed,22)
        }
    }
}
