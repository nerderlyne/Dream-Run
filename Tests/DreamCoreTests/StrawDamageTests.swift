import XCTest
@testable import DreamCore
final class StrawDamageTests:XCTestCase {
    func clean()->GameSimulation {
        var s=GameSimulation(identity:.current(seed:42));s.resume();s.state.hazards=[]
        for i in s.state.chunks.indices {s.state.chunks[i].hazards=[];s.state.chunks[i].pickups=[];s.state.chunks[i].gap=nil;s.state.chunks[i].step=nil;s.state.chunks[i].halfWidth=2}
        return s
    }
    func hit(_ s:inout GameSimulation)->[GameEvent] {
        s.state.player.lateral=0;s.state.player.knockbackVelocity=0;s.state.softImmunityUntil=0
        s.state.hazards=[HazardDescription(id:UUID().uuidString,asset:.soccer,encounter:.rolling,distance:s.state.distance+0.2,lateral:0,radius:0.45,height:0.9)]
        return s.step()
    }
    func testFourBallHitsLoseArmsThenLegsAndWake() throws {
        var s=clean()
        for n in 1...4 {
            XCTAssertTrue(hit(&s).contains(.strawBreak));XCTAssertEqual(s.state.player.missingLimbs.count,n)
            XCTAssertEqual(s.state.phase,n == 4 ? .waking:.running)
        }
        XCTAssertEqual(Set(s.state.player.missingLimbs.prefix(2)),Set([.leftArm,.rightArm]))
        XCTAssertEqual(s.state.cause,"unravelled")
        for _ in 0..<20 {_=s.presentationStep(0.1)}
        XCTAssertEqual(s.state.phase,.waking)
        for _ in 0..<5 {_=s.presentationStep(0.1)}
        XCTAssertEqual(s.state.phase,.finished)
        XCTAssertTrue(s.continueRun());XCTAssertTrue(s.state.player.missingLimbs.isEmpty)
    }
    func testHayRepairsOneLimbWithoutCurrencyAndCannotReplay() throws {
        var s=clean();_=hit(&s);_=hit(&s)
        s.state.hazards=[];s.state.player.lateral=0;s.state.player.knockbackVelocity=0
        let bale=PickupDescription(id:"straw:test",distance:s.state.distance+0.2,lateral:0,height:0.45,kind:.straw)
        s.state.chunks[0].pickups=[bale]
        XCTAssertTrue(s.step().contains(.strawRepair));XCTAssertEqual(s.state.player.missingLimbs.count,1);XCTAssertEqual(s.state.balloons,0)
        XCTAssertFalse(s.step().contains(.strawRepair))
        let decoded=try JSONDecoder().decode(RunState.self,from:JSONEncoder().encode(s.state))
        let restored=try GameSimulation(snapshot:decoded)
        XCTAssertEqual(restored.state.player.missingLimbs,s.state.player.missingLimbs)
        XCTAssertTrue(restored.state.collectedIDs.contains(bale.id))
    }
    func testBalesUseSafeSupportAndDedicatedDeterministicStream() {
        let g=WorldGenerator(.current(seed:42))
        let chunks=(0..<200).map{g.chunk($0)}
        let bales=chunks.filter{$0.pickups.contains{$0.kind == .straw}}
        XCTAssertFalse(bales.isEmpty)
        for c in bales {XCTAssertNil(c.gap);XCTAssertNil(c.step);XCTAssertNil(c.drop);XCTAssertTrue(c.hazards.isEmpty);XCTAssertEqual(c,g.chunk(c.id))}
        for i in 0..<25 {let c=g.chunk(i,tutorial:true);if c.pickups.contains(where:{$0.kind == .straw}) {XCTAssertNil(c.gap);XCTAssertTrue(c.hazards.isEmpty)}}
    }
    func testSingleBallImmunityAndFullBodyDoesNotConsumeHay() {
        var s=clean();_=hit(&s)
        s.state.hazards=[HazardDescription(id:"other",asset:.soccer,encounter:.rolling,distance:s.state.distance+0.1,lateral:0,radius:0.45,height:0.9)]
        XCTAssertFalse(s.step().contains(.strawBreak));XCTAssertEqual(s.state.player.missingLimbs.count,1)
        s=clean();s.state.chunks[0].pickups=[PickupDescription(id:"straw:full",distance:0.2,lateral:0,height:0.45,kind:.straw)]
        XCTAssertFalse(s.step().contains(.strawRepair));XCTAssertFalse(s.state.collectedIDs.contains("straw:full"))
    }
}
