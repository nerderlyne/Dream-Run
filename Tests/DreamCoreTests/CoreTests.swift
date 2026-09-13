import XCTest
@testable import DreamCore
final class CoreTests: XCTestCase {
    func testFramePacingAndStall() {
        for rate in [30,60,120] {var clock=FixedStepClock(),ticks=0;for _ in 0..<rate*10 {ticks += clock.consume(1/Double(rate)) ?? 0};XCTAssertEqual(ticks,600)}
        var clock=FixedStepClock();XCTAssertEqual(clock.consume(0.1),4);XCTAssertEqual(clock.consume(0.3),0);XCTAssertEqual(clock.consume(1.0/60),1)
    }
    func testRenderingHitchesDoNotPauseOrBankTime() {
        var clock=FixedStepClock(),simulation=safe()
        for delta in [0.1,0.08,0.4,1.2,0.07,0.2] {
            let ticks=clock.consume(delta)
            XCTAssertNotNil(ticks);XCTAssertLessThanOrEqual(ticks ?? 0,4)
            for _ in 0..<(ticks ?? 0) {_=simulation.step()}
            XCTAssertEqual(simulation.state.phase,.running)
        }
        XCTAssertEqual(simulation.state.activeTicks,16)
        XCTAssertEqual(clock.consume(1.0/60),1)
        XCTAssertNil(clock.consume(.nan))
    }
    func testHeldSlideCannotRemainLowForever() {
        var simulation=safe(),standing=0
        for _ in 0..<240 {_=simulation.step(InputFrame(slide:true));if simulation.state.player.slideTicks == 0 {standing += 1}}
        XCTAssertGreaterThan(standing,20)
    }
    func testMotionNormalization() {
        XCTAssertEqual(SteeringNormalizer.normalize(degrees:0),0);XCTAssertEqual(SteeringNormalizer.normalize(degrees:1),0)
        XCTAssertEqual(SteeringNormalizer.normalize(degrees:18),1);XCTAssertEqual(SteeringNormalizer.normalize(degrees:-100),-1)
        XCTAssertEqual(SteeringNormalizer.normalize(degrees:.nan),0)
    }
    func fixtures() throws -> [String:Any] { try JSONSerialization.jsonObject(with:Data(contentsOf:Bundle.module.url(forResource:"conformance_vectors",withExtension:"json")!)) as! [String:Any] }
    func testAllGoldenVectors() throws {
        let f=try fixtures(); var rng=SplitMix64(0)
        for hex in f["splitmix64_initial_zero_first_10_hex"] as! [String] { XCTAssertEqual(String(format:"%016llX",rng.next()),hex) }
        for v in f["fnv1a64_vectors"] as! [[String:String]] { XCTAssertEqual(String(format:"%016llX",SplitMix64.fnv(v["ascii"]!)),v["hex"]) }
        for v in f["dream_ids"] as! [[String:String]] { let id=DreamIdentity(seed:UInt64(v["seed_decimal_string"]!)!); XCTAssertEqual(id.code,v["code"]); XCTAssertEqual(try DreamIdentity.parse(id.code.lowercased()),id) }
        for trace in f["pig_traces"] as! [[String:Any]] {
            let id=DreamIdentity(seed:UInt64(trace["seed_decimal_string"] as! String)!)
            for row in trace["checkpoints"] as! [[String:Any]] {
                let k=row["checkpoint"] as! Int, a=PigDecision(identity:id,ordinal:k,continued:false), b=PigDecision(identity:id,ordinal:k,continued:true)
                XCTAssertEqual(a.presenceDraw,UInt64(row["presence_draw"] as! Int)); XCTAssertEqual(a.cloverDraw,UInt64(row["clover_draw"] as! Int)); XCTAssertEqual(a.clover,row["has_clover"] as! Bool); XCTAssertEqual(b.clover,row["continued_has_clover"] as! Bool)
            }
        }
    }
    func testIDsRejectBadInput() throws {
        for s in ["",String(repeating:"0",count:200),"DR2-G1-R1-C1-000000000001A-460B","DR1-G1-R1-C1-ZZZZZZZZZZZZZ-580X","DR1-G0-R1-C1-000000000001A-460B","DR1-G1-R1-C1-000000000001A-460C"] { XCTAssertThrowsError(try DreamIdentity.parse(s)) }
        XCTAssertEqual(try DreamIdentity.parse("  dr1-g1-r1-c1-OOOOOOOOOOO1a-46Ob  ").seed,42)
        var future=DreamIdentity(seed:42); future.rulesVersion=4; XCTAssertThrowsError(try DreamIdentity.parse(future.code)); XCTAssertEqual(try DreamIdentity.parse(future.code,requireSupported:false),future)
        XCTAssertThrowsError(try DreamFile.read(Data("{\"format\":1,\"dreamID\":\"a\",\"url\":\"x\"}".utf8)))
    }
    func testFasterRulesPreserveSavedDreams() throws {
        let old=GameSimulation(identity:DreamIdentity(seed:42))
        let current=GameSimulation(identity:DreamIdentity.current(seed:42))
        XCTAssertEqual(current.state.speed,old.state.speed*1.75,accuracy:1e-12)
        XCTAssertEqual(current.state.rules.maximumSpeed,old.state.rules.maximumSpeed)
        XCTAssertEqual(try DreamIdentity.parse(current.state.identity.code),current.state.identity)
        for original in [old,current] {
            let saved=try JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(original.state))
            XCTAssertEqual(try GameSimulation(snapshot:saved).state.speed,original.state.speed)
        }
        var mismatched=current.state;mismatched.rules=RunRules(version:1)
        XCTAssertThrowsError(try GameSimulation(snapshot:mismatched))
    }
    func testNarrowFastSteeringAndSnapshotBounds() throws {
        var simulation=GameSimulation(identity:DreamIdentity.current(seed:7));simulation.resume()
        XCTAssertEqual(simulation.state.rules.lateralLimit/RunRules().lateralLimit,0.72,accuracy:1e-12)
        XCTAssertEqual(SteeringNormalizer.normalize(degrees:12,fullScaleDegrees:simulation.state.rules.tiltFullScaleDegrees),1)
        simulation.state.player.lateral = -0.9
        for _ in 0..<30 {
            let previous=simulation.state.player.lateral
            _=simulation.step(InputFrame(steering:1))
            XCTAssertLessThanOrEqual(abs(simulation.state.player.lateral-previous),0.100001)
            XCTAssertLessThanOrEqual(abs(simulation.state.player.lateral),0.9)
        }
        XCTAssertEqual(simulation.state.player.lateral,0.9,accuracy:0.002)
        for _ in 0..<30 {_=simulation.step(InputFrame(steering:-1))}
        XCTAssertEqual(simulation.state.player.lateral,-0.9,accuracy:0.002)
        var invalid=simulation.state;invalid.player.lateral=1.1
        XCTAssertThrowsError(try GameSimulation(snapshot:invalid))
        var legacy=DreamIdentity(seed:7);legacy.rulesVersion=2
        XCTAssertEqual(GameSimulation(identity:legacy).state.rules.lateralLimit,1.25)
    }
    func testNarrowRunCanBypassScheduledClover() {
        var simulation=GameSimulation(identity:DreamIdentity.current(seed:0));simulation.resume()
        // Locate a real deterministic clover, then commit its normal scheduled runway.
        let ordinal=(1...100).first{PigDecision(identity:simulation.state.identity,ordinal:$0,continued:false).clover}!
        simulation.state.activeTicks=UInt64(ordinal*46800-361)
        _=simulation.step()
        let pig=simulation.state.hazards.first{$0.pig?.clover == true}!
        simulation.state.distance=pig.distance-0.1;simulation.state.player.lateral = -0.9
        var collecting=simulation;collecting.state.player.lateral=pig.lateral
        _=simulation.step(InputFrame(steering:-1));XCTAssertEqual(simulation.state.pigs.count,0)
        _=collecting.step(InputFrame(steering:pig.lateral/0.9));XCTAssertEqual(collecting.state.pigs.count,1)
    }
    func testExactProbability() {
        var present=0, clean=0, continued=0
        for p in 0..<2 { for c in 0..<6 { let a=PigDecision(ordinal:1,presence:UInt64(p),clover:UInt64(c),continued:false), b=PigDecision(ordinal:1,presence:UInt64(p),clover:UInt64(c),continued:true); present += a.present ? 1 : 0; clean += a.clover ? 1 : 0; continued += b.clover ? 1 : 0 } }
        XCTAssertEqual(present,6); XCTAssertEqual(clean,2); XCTAssertEqual(continued,1)
        XCTAssertEqual(PigDecision.probabilityAtLeastThree(Array(repeating:1.0/6,count:3)),1.0/216,accuracy:1e-12)
        XCTAssertEqual(PigDecision.probabilityAtLeastThree(Array(repeating:1.0/6,count:5)),23.0/648,accuracy:1e-12)
        XCTAssertEqual(3/(1.0/6)*13,234); XCTAssertEqual(3/(1.0/12)*13,468)
    }
    func safe() -> GameSimulation { var s=GameSimulation(identity:DreamIdentity(seed:42)); s.state.phase = .running; s.state.safeUntilDistance=1e9; return s }
    func testMovementAndPauseSnapshot() throws {
        var s=safe(); for _ in 0..<90 { _=s.step(InputFrame(steering:1)) }; XCTAssertEqual(s.state.player.lateral,1.25,accuracy:0.0001)
        _=s.step(InputFrame(jump:true)); XCTAssertGreaterThan(s.state.player.height,0)
        let bytes=try JSONEncoder().encode(s.state), restored=try JSONDecoder().decode(RunState.self,from:bytes)
        var r=try GameSimulation(snapshot:restored)
        for _ in 0..<20 { _=s.step(); _=r.step() }; XCTAssertEqual(s.state.distance,r.state.distance); XCTAssertEqual(s.state.player,r.state.player)
        s.pause(); let ticks=s.state.activeTicks; for _ in 0..<3600 { _=s.step() }; XCTAssertEqual(ticks,s.state.activeTicks)
        s.resume(); XCTAssertEqual(s.state.continueCount,0)
    }
    func testSoftFatalSlideAndDedup() {
        var s=safe(); s.state.safeUntilDistance=0
        func hazard(_ id: String,_ asset: AssetID,_ encounter: Encounter = .rolling) -> HazardDescription { HazardDescription(id:id,asset:asset,encounter:encounter,distance:s.state.distance+0.1,lateral:0,radius:0.45,height:1) }
        s.state.hazards=[hazard("one",.soccer)]; XCTAssertTrue(s.step().contains(.stumble)); XCTAssertEqual(s.state.phase,.running)
        for _ in 0..<49 { _=s.step() }; s.state.hazards=[hazard("two",.softball)]; XCTAssertTrue(s.step().contains(.waking))
        s=safe(); s.state.safeUntilDistance=0; s.state.softImmunityUntil=100; s.state.hazards=[hazard("rabbit",.rabbit,.dodge)]; XCTAssertTrue(s.step().contains(.waking))
        s=safe(); s.state.safeUntilDistance=0; s.state.hazards=[hazard("zebra",.zebra,.slide)]; _=s.step(InputFrame(slide:true)); XCTAssertEqual(s.state.phase,.running)
        for _ in 0..<65 { _=s.step() }; XCTAssertEqual(s.state.player.slideTicks,0)
    }
    func testEverySportsBallStumblesSlowsAndRecovers() throws {
        for asset:AssetID in [.soccer,.eightBall,.softball,.americanFootball] {
            var simulation=GameSimulation(identity:DreamIdentity.current(seed:42));simulation.resume()
            simulation.state.hazards=[HazardDescription(id:"contact",asset:asset,encounter:.rolling,distance:2,lateral:0,radius:0.45,height:0.9,speed:4)]
            var hits=0
            for _ in 0..<20 {
                let events=simulation.step();hits += events.filter{$0 == .stumble}.count
                if hits > 0 {break}
            }
            XCTAssertEqual(hits,1,"\(asset)");XCTAssertEqual(simulation.state.phase,.running)
            XCTAssertEqual(simulation.state.stumbleWeight,1)
            XCTAssertEqual(simulation.state.speed/simulation.state.unhinderedSpeed,0.75,accuracy:1e-12)
            let previousDistance=simulation.state.distance
            _=simulation.step()
            XCTAssertEqual(simulation.state.distance-previousDistance,simulation.state.speed/60,accuracy:1e-10)
            var restored=try GameSimulation(snapshot:JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(simulation.state)))
            XCTAssertEqual(restored.state.stumbleWeight,simulation.state.stumbleWeight)
            for _ in 0..<59 {XCTAssertFalse(restored.step().contains(.stumble))}
            XCTAssertEqual(restored.state.stumbleWeight,0);XCTAssertEqual(restored.state.speed,restored.state.unhinderedSpeed)
        }
    }
    func testVisibleFootballTipMakesContact() {
        var simulation=GameSimulation(identity:DreamIdentity.current(seed:42));simulation.resume()
        simulation.state.hazards=[HazardDescription(id:"tip",asset:.americanFootball,encounter:.rolling,distance:0.1,lateral:0.8,radius:0.45,height:0.9)]
        XCTAssertTrue(simulation.step().contains(.stumble))
        XCTAssertEqual(simulation.state.instabilityUntil-simulation.state.activeTicks,300)
    }
    func testPigCommitAndDeepNonterminal() throws {
        var s=safe(); s.state.activeTicks=46439; _=s.step(); XCTAssertEqual(s.state.pendingPig?.ordinal,1)
        let p=s.state.pendingPig; s.wake("test"); XCTAssertTrue(s.continueRun()); XCTAssertEqual(s.state.pendingPig,p)
        s.state.phase = .running; s.state.activeTicks=647999; _=s.step(); XCTAssertEqual(s.state.visual,.deepStripping); XCTAssertNotEqual(s.state.phase,.finished)
        XCTAssertEqual(VisualPhase.at(seconds:11050),.deepSparse); XCTAssertEqual(VisualPhase.at(seconds:11200),.deepRebuilding); XCTAssertEqual(VisualPhase.at(seconds:12000),.beyond); XCTAssertEqual(VisualPhase.at(seconds:21600),.deepStripping)
    }
    func testRegistryAndGeneration() {
        XCTAssertEqual(AssetID.allCases.count,42); XCTAssertEqual(AssetID.pig.rawValue,42)
        for seed in 0..<20 { let g=WorldGenerator(DreamIdentity(seed:UInt64(seed))); for i in 0..<1000 { let c=g.chunk(i); XCTAssertTrue(FairnessValidator.validate(c)); XCTAssertEqual(c,g.chunk(i)); XCTAssertTrue(g.sample(c.end).y.isFinite) } }
    }
    func testWalletTransactionsRefundAndDebug() throws {
        let url=FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("profile.json")
        let store=try ProfileStore(url:url)
        var run=safe().state; run.balloons=100
        try store.transaction { $0.settle(run,finished:false,catalogue:[]) }; try store.transaction { $0.settle(run,finished:false,catalogue:[]) }; XCTAssertEqual(store.profile.balance,100)
        run.continueCount=1; run.balloons=150; try store.transaction { $0.settle(run,finished:false,catalogue:[]); $0.credit(id:"purchase:1",amount:500,source:"purchase"); $0.credit(id:"purchase:1",amount:500,source:"purchase") }; XCTAssertEqual(store.profile.balance,650)
        let item=CosmeticDefinition(id:"paper_hat",name:"Paper",slot:"hat",balloon_price:150)
        try store.transaction { try $0.buy(item) }; XCTAssertThrowsError(try store.transaction { try $0.buy(item) }); XCTAssertEqual(store.profile.balance,500)
        try store.transaction { $0.revoke("1"); $0.revoke("1") }; XCTAssertEqual(store.profile.balance,0)
        run.mode = .debug; run.balloons=999; try store.transaction { $0.settle(run,finished:true,catalogue:[]) }; XCTAssertEqual(store.profile.balance,0)
        XCTAssertEqual(try ProfileStore(url:url).profile.balance,0)
        XCTAssertThrowsError(try store.transaction { $0.credit(id:"bad",amount:50,source:"earned"); throw DreamError.unavailable }); XCTAssertEqual(store.profile.balance,0)
    }
}
