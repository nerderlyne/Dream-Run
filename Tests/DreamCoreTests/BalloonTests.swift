import XCTest
@testable import DreamCore

final class BalloonTests:XCTestCase {
    func testMotionIsBoundedRepeatableAndSafeDropsStayLow() {
        for i in 0..<100 {
            let p=PickupDescription(id:"b:10:\(i)",distance:250,lateral:0)
            for t in stride(from:UInt64(0),through:3600,by:37) {
                let a=p.balloonPosition(at:t),b=p.balloonPosition(at:t)
                XCTAssertEqual(a.height,b.height);XCTAssertEqual(a.lateral,b.lateral)
                XCTAssertLessThanOrEqual(abs(a.lateral),0.14);XCTAssertGreaterThan(a.height,0.7)
                XCTAssertLessThan(a.height,2.83)
            }
        }
        XCTAssertFalse(PickupDescription(id:"drop-balloon:12:0",distance:300,lateral:0).floatsHigh)
    }
    func testHighBalloonRequiresJumpAndOnlyPaysOnce() {
        let p=(0..<100).map{PickupDescription(id:"b:10:\($0)",distance:250,lateral:0)}.first{$0.floatsHigh}!
        let tick=(1..<3600).map{UInt64($0)}.first{p.balloonPosition(at:$0).height>2.5}!
        func run(height:Double)->GameSimulation {
            var s=GameSimulation(identity:DreamIdentity.current(seed:42),mode:.debug)
            s.state.distance=249.7;s.state.activeTicks=tick;s.state.phase = .running
            s.state.safeUntilDistance=1000
            s.state.chunks=[ChunkDescription(id:10,routeFamily:.trackStraight,start:240,hazards:[],pickups:[p],scenery:[],recipe:0)]
            s.state.player.height=height;s.state.player.grounded=height==0
            return s
        }
        var ground=run(height:0);_ = ground.step(.init());XCTAssertEqual(ground.state.balloons,0)
        var jump=run(height:1.2);_ = jump.step(.init());XCTAssertEqual(jump.state.balloons,1)
        _ = jump.step(.init());XCTAssertEqual(jump.state.balloons,1)
    }
}
