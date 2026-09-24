import XCTest
import RealityKit
@testable import DreamAgain

final class PerformanceResourceTests: XCTestCase {
    @MainActor func testReusableObstaclesKeepIndependentTransformsAndSharedMeshes() throws {
        let game=GameModel()
        let renderer=try XCTUnwrap(game.renderer)
        renderer.prepareGameplay()
        let first=renderer.strawBall(),second=renderer.strawBall()
        let a=try XCTUnwrap(first.children.first as? ModelEntity)
        let b=try XCTUnwrap(second.children.first as? ModelEntity)
        XCTAssertFalse(first === second)
        XCTAssertTrue(try XCTUnwrap(a.model).mesh === XCTUnwrap(b.model).mesh)
        first.position.x=10
        XCTAssertEqual(second.position.x,0)
        for (asset,encounter) in [(AssetID.moon,Encounter.swing),(.window,.slide),(.bed,.jump)] {
            let hazard=HazardDescription(id:"test",asset:asset,encounter:encounter,distance:0,lateral:0,radius:0.5,height:1)
            let first=try XCTUnwrap(renderer.obstacleModel(hazard))
            let second=try XCTUnwrap(renderer.obstacleModel(hazard))
            let a=try XCTUnwrap(first.children.first as? ModelEntity)
            let b=try XCTUnwrap(second.children.first as? ModelEntity)
            XCTAssertFalse(first === second)
            XCTAssertTrue(try XCTUnwrap(a.model).mesh === XCTUnwrap(b.model).mesh)
            first.children.first?.isEnabled=false
            XCTAssertTrue(second.children.first?.isEnabled == true)
        }
    }

    @MainActor func testSemanticAssetsReuseMeshesAcrossPalettes() throws {
        let game=GameModel()
        let factory=try XCTUnwrap(game.renderer).factory
        for id in PrefabFactory.fixedPaletteAssets {
            let first=factory.build(id,palette:0)
            let second=factory.build(id,palette:6)
            let a=try XCTUnwrap(first.children.first as? ModelEntity)
            let b=try XCTUnwrap(second.children.first as? ModelEntity)
            XCTAssertTrue(try XCTUnwrap(a.model).mesh === XCTUnwrap(b.model).mesh,"\(id)")
            XCTAssertEqual(first.visualBounds(relativeTo:first).extents,second.visualBounds(relativeTo:second).extents)
        }
    }
}
