import XCTest
import RealityKit
@testable import DreamAgain
final class Dream_AgainTests:XCTestCase {
    func testCoreIdentityInApp() throws {XCTAssertEqual(try DreamIdentity.parse("DR1-G1-R1-C1-000000000001A-460B").seed,42)}
    @MainActor func testEveryAssetBuildsAndBoundsAreFinite() throws {
        let game=GameModel();XCTAssertNil(game.error);XCTAssertEqual(game.assets.count,42)
        guard let renderer=game.renderer else {return XCTFail("Renderer unavailable")}
        for id in AssetID.allCases {let entity=renderer.factory.build(id);XCTAssertFalse(entity.children.isEmpty);let b=entity.visualBounds(relativeTo:entity);XCTAssertTrue(b.extents.x.isFinite);XCTAssertGreaterThan(b.extents.y,0)}
    }
}
