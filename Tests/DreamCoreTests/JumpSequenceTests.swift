import XCTest
@testable import DreamCore

final class JumpSequenceTests:XCTestCase {
    func testSupersededLayoutCannotResumeOrSilentlyReplay() throws {
        var old=DreamIdentity.current(seed:42);old.generatorVersion=1;old.rulesVersion=1
        XCTAssertThrowsError(try DreamIdentity.parse(old.code))
        XCTAssertEqual(try DreamIdentity.parse(old.code,requireSupported:false),old)
        XCTAssertThrowsError(try GameSimulation(snapshot:RunState(identity:old,mode:.debug)))
        XCTAssertEqual(try DreamIdentity.parse(DreamIdentity.current(seed:42).code),.current(seed:42))
    }
    private func sequence(seed:UInt64,seconds:Double,slope:Double,first:Int=4)->GameSimulation {
        let id=DreamIdentity.current(seed:seed),g=WorldGenerator(id)
        var state=RunState(identity:id,mode:.debug)
        state.phase = .running;state.distance=Double(first)*24;state.activeTicks=UInt64(seconds*60);state.lastPigOrdinal=1000
        state.chunks=(first...first+3).compactMap {g.jumpSequenceChunk($0)}
        state.hazards=state.chunks.flatMap(\.hazards)
        return GameSimulation(certification:state,slope:slope)
    }
    func testThreeSeparateJumpsSurviveEveryVariantAndGrade() {
        var variants=Set<String>()
        for seed:UInt64 in 0..<12 {
            for seconds in [0.0,120,300,600] {
                for slope in [-0.08,0.0,0.08] {
                    var s=sequence(seed:seed,seconds:seconds,slope:slope),jumps=0
                    variants.insert(s.state.chunks[0].step != nil ? (s.state.chunks[0].gap == nil ? "stairs":"floating") : "mixed")
                    while s.state.distance<192 && s.state.phase == .running {
                        let before=s.state.player.grounded
                        _=s.step(EncounterOracle.input(s.state))
                        if before && !s.state.player.grounded && s.state.player.velocityY>0 {jumps += 1}
                    }
                    XCTAssertEqual(s.state.phase,.running,"seed \(seed), speed \(seconds), slope \(slope): \(s.state.cause)")
                    XCTAssertEqual(jumps,3,"Every obstacle must need a separate jump")
                }
            }
        }
        XCTAssertEqual(variants.count,3)
    }
    func testSkippingAnyJumpFailsEvenAtMaximumLateralOffset() {
        for seed:UInt64 in 0..<12 {
            for seconds in [0.0,600] {
                for missed in 0..<3 {
                    for side in [-1.0,0,1] {
                      for slope in [-0.08,0.0,0.08] {
                        var s=sequence(seed:seed,seconds:seconds,slope:slope)
                        let skippedStart=96+Double(missed)*24
                        while s.state.distance<192 && s.state.phase == .running {
                            var input=EncounterOracle.input(s.state);input.steering=side
                            if s.state.distance>=skippedStart && s.state.distance<skippedStart+24 {input.jump=false}
                            _=s.step(input)
                        }
                        XCTAssertEqual(s.state.phase,.waking,"seed \(seed), missed \(missed), time \(seconds), lateral \(side), slope \(slope)")
                      }
                    }
                }
            }
        }
    }
    func testAscendingLandingsAreSharedWithoutStackingAndPersist() throws {
        let s=(0..<12).map{sequence(seed:UInt64($0),seconds:0,slope:0)}.first{$0.state.chunks[0].step != nil}!
        for (distance,height) in [(107.9,0.0),(108.0,0.72),(131.9,0.72),(132.0,1.44),(156.0,2.16),(180.0,1.08),(192.0,0)] {
            XCTAssertEqual(s.state.floorHeight(at:distance),height,accuracy:0.00001)
        }
        let restored=try JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(s.state))
        XCTAssertEqual(restored.chunks,s.state.chunks)
    }
    func testGeneratedSequencesAreCertifiedAndDoNotBecomeEmptyScenery() {
        for seed:UInt64 in 0..<6 {
            var simulation=GameSimulation(identity:.current(seed:seed))
            for index in 4..<80 {
                simulation.state.distance=Double(index)*24;simulation.streamChunks()
                let expected=WorldGenerator(simulation.state.identity).chunk(index)
                guard expected.step?.ascendingRun == true || expected.hazards.contains(where:{$0.requiresJump}) else {continue}
                let actual=simulation.state.chunks.first{$0.id == index}!
                XCTAssertNil(actual.fallbackReason,"seed \(seed), chunk \(index)")
                XCTAssertEqual(actual.hazards,expected.hazards)
            }
        }
    }
    func testStairGapsProgressAndLateSequencesRequireEveryJump() {
        for first in [4,52,196] {
            let tier=DreamDifficulty.tier(distance:Double(first)*24)
            for seed:UInt64 in 0..<12 {
                let g=WorldGenerator(.current(seed:seed))
                let chunks=(first...first+2).compactMap{g.jumpSequenceChunk($0)}
                guard chunks.first?.step != nil else {continue}
                let gaps=chunks.compactMap(\.gap)
                if tier == 0 {XCTAssertTrue(gaps.count == 0 || gaps.count == 3)}
                if tier == 1 {XCTAssertGreaterThanOrEqual(gaps.count,2)}
                if tier == 2 {XCTAssertEqual(gaps.count,3)}
                for c in chunks {
                    if let gap=c.gap {
                        XCTAssertEqual(gap.upperBound,c.start+12)
                        XCTAssertEqual(gap.upperBound-gap.lowerBound,tier == 2 ? 4 : gaps.count == 3 && tier == 1 ? 4:3)
                        XCTAssertGreaterThan(c.step!.height(at:gap.upperBound),c.step!.height(at:gap.lowerBound))
                    }
                    XCTAssertFalse(c.hazards.contains{$0.asset == .column})
                }
                for seconds in [0.0,120,300,600] {
                    for slope in [-0.08,0.08] {
                        // -1 means the complete intended input trace; 0...2 omit a jump.
                        for missed in -1...2 {
                            var simulation=sequence(seed:seed,seconds:seconds,slope:slope,first:first)
                            while simulation.state.distance<Double(first+4)*24 && simulation.state.phase == .running {
                                var input=EncounterOracle.input(simulation.state)
                                if missed>=0 && Int(simulation.state.distance/24) == first+missed {input.jump=false}
                                _=simulation.step(input)
                            }
                            XCTAssertEqual(simulation.state.phase,missed<0 ? .running:.waking,"first \(first), seed \(seed), missed \(missed), speed \(seconds), slope \(slope): \(simulation.state.cause)")
                        }
                    }
                }
            }
        }
    }

    func testLateStairFlightsSurviveCertificationIntact() {
        for seed:UInt64 in 0..<6 {
            let g=WorldGenerator(.current(seed:seed))
            for first in [52,196] {
                var history:[ChunkDescription]=[]
                for index in first-2...first+3 {
                    let chunk=g.chunk(index)
                    XCTAssertTrue(HorizonCertification.validate(history:history,candidate:chunk),"seed \(seed), chunk \(index)")
                    history.append(chunk)
                }
            }
        }
        let g=WorldGenerator(.current(seed:42))
        XCTAssertFalse((4..<400).flatMap{g.chunk($0).hazards}.contains{$0.asset == .column})
    }

    func testBalloonDropIsNotGeneratedOrActivated() {
        let g=WorldGenerator(.current(seed:42))
        for index in 0..<300 {
            let chunk=g.chunk(index)
            XCTAssertNil(chunk.drop)
            XCTAssertFalse(chunk.pickups.contains{$0.id.hasPrefix("drop-balloon:")})
        }
        var state=RunState(identity:.current(seed:42),mode:.debug)
        state.phase = .running;state.distance=896;state.lastPigOrdinal=1000
        var s=GameSimulation(certification:state,slope:0)
        while s.state.distance<920 {
            XCTAssertFalse(s.step().contains(.drop));XCTAssertEqual(s.state.phase,.running)
        }
    }
}
