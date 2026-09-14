import XCTest
@testable import DreamCore
final class TraversalTests:XCTestCase {
    func testHorizonRejectsIncompatibleGapAndUnderpass() {
        let before=ChunkDescription(id:0,routeFamily:.trackBroken,start:0,hazards:[],pickups:[],scenery:[],recipe:0,gap:20...24)
        var next=ChunkDescription(id:1,routeFamily:.trackStraight,start:24,hazards:[HazardDescription(id:"bad",asset:.zebra,encounter:.slide,distance:24.3,lateral:0,radius:2,height:2.4)],pickups:[],scenery:[],recipe:0)
        XCTAssertFalse(HorizonCertification.validate(history:[before],candidate:next))
        next.hazards=[]
        XCTAssertTrue(HorizonCertification.validate(history:[before],candidate:next))
    }
    func testCertifiedManifestRetainsEncountersAndTutorial() {
        var simulation=GameSimulation(identity:DreamIdentity(seed:4))
        var encounters=Set<Encounter>(),fallbacks=0,gaps=0
        for index in 0..<300 {
            simulation.state.distance=Double(index)*24;simulation.streamChunks()
            let c=simulation.state.chunks.first{$0.id == index}!
            encounters.formUnion(c.hazards.map(\.encounter));if c.gap != nil {gaps += 1};if c.fallbackReason != nil {fallbacks += 1}
        }
        XCTAssertTrue(encounters.isSuperset(of:[.dodge,.rolling,.slide,.jump,.mirror]));XCTAssertGreaterThan(gaps,5);XCTAssertLessThan(fallbacks,30)
        let tutorial=GameSimulation(identity:DreamIdentity(seed:4),mode:.tutorial)
        XCTAssertTrue(tutorial.state.hazards.contains{$0.id == "tutorial:slide"})
        print("CERTIFIED manifest: \(encounters.count) encounter kinds, \(gaps) gaps, \(fallbacks)/300 fallbacks")
    }
    func oracle(_ s:RunState)->InputFrame {EncounterOracle.input(s)}
    func testFastNarrowOpeningTwelveSeeds() {
        for seed in 0..<12 {
            var simulation=GameSimulation(identity:DreamIdentity.current(seed:UInt64(seed)));simulation.resume()
            for _ in 0..<(180*60) {_=simulation.step(oracle(simulation.state));guard [.running,.safeDrop,.mirrorCrossing].contains(simulation.state.phase) else {return XCTFail("Current seed \(seed) failed at \(simulation.state.seconds): \(simulation.state.cause)")}}
            XCTAssertGreaterThan(simulation.state.dropCount,0)
            var tutorial=GameSimulation(identity:DreamIdentity.current(seed:UInt64(seed)),mode:.tutorial);tutorial.resume()
            for _ in 0..<(55*60) {_=tutorial.step(oracle(tutorial.state))}
            XCTAssertEqual(tutorial.state.cause,"tutorial complete")
        }
    }
    func testOracleSixHoursTwentySeeds() throws {
        var maximumChunks=0,maximumHazards=0,maximumPickups=0
        for seed in 0..<20 {
            var simulation=GameSimulation(identity:DreamIdentity(seed:UInt64(seed))); simulation.resume()
            while simulation.state.activeTicks < 21601*60 {
                _=simulation.step(oracle(simulation.state))
                if ![RunPhase.running,.safeDrop,.mirrorCrossing].contains(simulation.state.phase) {
                    XCTFail("Oracle failed seed \(seed) at \(simulation.state.seconds)s / \(simulation.state.distance)m: \(simulation.state.cause), next \(simulation.state.hazards.filter{!$0.resolved}.prefix(2))"); return
                }
                if simulation.state.activeTicks%3600 == 0 {
                    maximumChunks=max(maximumChunks,simulation.state.chunks.count); maximumHazards=max(maximumHazards,simulation.state.hazards.count); maximumPickups=max(maximumPickups,simulation.state.collectedIDs.count)
                    XCTAssertTrue(simulation.state.distance.isFinite); XCTAssertLessThanOrEqual(simulation.state.chunks.count,16)
                }
            }
            XCTAssertEqual(simulation.state.visual,.deepStripping)
            print("SOAK seed \(seed): \(simulation.state.activeTicks) ticks, \(Int(simulation.state.distance))m, pigs committed \(simulation.state.lastPigOrdinal)")
        }
        print("SOAK maxima: chunks=\(maximumChunks), hazards=\(maximumHazards), pickup dedup=\(maximumPickups)")
    }
    func testThirdPigContactFreezesAndResumeEnding() throws {
        var s=GameSimulation(identity:DreamIdentity(seed:5)); s.resume(); s.state.pigs=[CollectedPig(ordinal:1,hue:0),CollectedPig(ordinal:2,hue:1)]
        let pig=PigDecision(ordinal:3,clover:0,continued:false)
        s.state.hazards=[HazardDescription(id:"third",asset:.pig,encounter:.dodge,distance:0.1,lateral:0,radius:0.65,height:0.65,pig:pig)]
        _=s.step(); XCTAssertEqual(s.state.pigs.count,3); XCTAssertEqual(s.state.phase,.luckyTransition)
        let ticks=s.state.activeTicks; for _ in 0..<100 { _=s.step() }; XCTAssertEqual(s.state.activeTicks,ticks)
        var r=try GameSimulation(snapshot:JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(s.state)))
        for _ in 0..<580 { _=r.presentationStep(0.1) }; XCTAssertEqual(r.state.phase,.finished); XCTAssertEqual(r.state.activeTicks,ticks)
        XCTAssertFalse(r.continueRun())
    }
    func testFatalTieBeatsThirdPig() {
        var s=GameSimulation(identity:DreamIdentity(seed:2));s.resume();s.state.pigs=[CollectedPig(ordinal:1,hue:0),CollectedPig(ordinal:2,hue:0)]
        s.state.hazards=[HazardDescription(id:"pig",asset:.pig,encounter:.dodge,distance:0.1,lateral:0,radius:0.65,height:0.7,pig:PigDecision(ordinal:3,clover:0,continued:false)),HazardDescription(id:"rabbit",asset:.rabbit,encounter:.dodge,distance:0.1,lateral:0,radius:0.65,height:0.7)]
        _=s.step();XCTAssertEqual(s.state.phase,.waking);XCTAssertEqual(s.state.pigs.count,2)
    }
    func testContinueGrantSurvivesCrashAndCannotDuplicate() throws {
        var s=GameSimulation(identity:DreamIdentity(seed:2));s.resume();s.wake("test")
        var p=Profile(); XCTAssertTrue(p.grantContinue(eventID:"event",run:s.state));XCTAssertFalse(p.grantContinue(eventID:"event",run:s.state))
        p=try JSONDecoder().decode(Profile.self,from:JSONEncoder().encode(p))
        XCTAssertTrue(p.consumeContinue(&s));XCTAssertFalse(p.consumeContinue(&s));XCTAssertEqual(s.state.continueCount,1)
        let t=s.state.activeTicks;for _ in 0..<120 {_=s.presentationStep(1.0/60);_=s.step()};XCTAssertLessThanOrEqual(s.state.activeTicks,t+1)
    }
    func testFailedWritePreservesMemoryAndBackupRecovery() throws {
        let dir=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let url=dir.appendingPathComponent("profile")
        let store=try ProfileStore(url:url);try store.transaction{$0.credit(id:"earned",amount:12,source:"earned")};try store.transaction{$0.credit(id:"second",amount:3,source:"earned")}
        try Data("corrupt".utf8).write(to:url)
        let recovered=try ProfileStore(url:url);XCTAssertTrue(recovered.recoveredBackup);XCTAssertEqual(recovered.profile.balance,12)
    }
}
