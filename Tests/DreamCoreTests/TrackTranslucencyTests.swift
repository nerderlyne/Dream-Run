import XCTest
@testable import DreamCore
final class TrackTranslucencyTests:XCTestCase {
    func testHierarchyAndNearFootingAcrossSeedsAndStates() {
        var low:Float=1,high:Float=0
        for seed:UInt64 in 0..<200 {
            let id=DreamIdentity.current(seed:seed)
            for distance in stride(from:0.0,to:4000,by:191) {
                let near=TrackTranslucency.opacity(identity:id,distance:distance,seconds:100,visual:.ordinary,transitions:0,ahead:0)
                let far=TrackTranslucency.opacity(identity:id,distance:distance,seconds:100,visual:.ordinary,transitions:0,ahead:240)
                let edge=TrackTranslucency.opacity(identity:id,distance:distance,seconds:100,visual:.ordinary,transitions:0,ahead:0,critical:true)
                XCTAssertGreaterThanOrEqual(near.base,0.64);XCTAssertGreaterThanOrEqual(edge.base,0.86)
                XCTAssertGreaterThanOrEqual(near.base,far.base);XCTAssertGreaterThanOrEqual(far.pattern,far.base)
                XCTAssertEqual(near.edge,1);XCTAssertTrue((0.3...0.96).contains(far.base))
                XCTAssertEqual(far,TrackTranslucency.opacity(identity:id,distance:distance,seconds:100,visual:.ordinary,transitions:0,ahead:240))
                low=min(low,far.base);high=max(high,far.base)
            }
        }
        XCTAssertLessThan(low,0.5);XCTAssertGreaterThan(high,0.8)
    }
    func testChapterBoundaryIsSmoothAndVoidIsConcrete() {
        let id=DreamIdentity.current(seed:42)
        func opacity(_ d:Double,_ v:VisualPhase)->Float {TrackTranslucency.opacity(identity:id,distance:d,seconds:11050,visual:v,transitions:0,ahead:100).base}
        XCTAssertEqual(opacity(768-0.001,.ordinary),opacity(768+0.001,.ordinary),accuracy:0.001)
        XCTAssertGreaterThan(opacity(100,.deepSparse),0.9)
    }
}
