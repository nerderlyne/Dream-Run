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

extension Dream_AgainTests {
    @MainActor func testSculptedSurfacesHaveFiniteUnitNormals() throws {
        var g=Geometry()
        g.sculpt([([0,0,0],[0.3,0.4,0.3]),([0,0.35,0],[0.2,0.2,0.2])],min:[-0.5,-0.5,-0.5],max:[0.5,0.7,0.5],step:0.06)
        XCTAssertGreaterThan(g.indices.count,300)
        for n in g.normals {XCTAssertTrue(n.x.isFinite && n.y.isFinite && n.z.isFinite);XCTAssertEqual(simd_length(n),1,accuracy:0.002)}
        for i in g.indices {XCTAssertLessThan(Int(i),g.positions.count)}
        XCTAssertNoThrow(try g.resource())
    }
    @MainActor func testMaterialVocabularyAndWhiteEndingRemainCompatible() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        let plaster=renderer.factory.material(.red,style:0),ceramic=renderer.factory.material(.red,style:1),metal=renderer.factory.material(.red,style:2)
        XCTAssertGreaterThan(plaster.roughness.scale,ceramic.roughness.scale)
        XCTAssertGreaterThan(metal.metallic.scale,plaster.metallic.scale)
        let model=ModelEntity(mesh:.generateSphere(radius:1),materials:[ceramic])
        renderer.whiten(model,amount:0.5)
        let first=try XCTUnwrap(model.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint
        renderer.whiten(model,amount:0.5)
        let second=try XCTUnwrap(model.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint
        XCTAssertEqual(first,second,"White ending must blend from the original, not accumulate each frame")
        renderer.whiten(model,amount:1)
        let actual=try XCTUnwrap((model.model?.materials.first as? PhysicallyBasedMaterial)?.baseColor.tint.artSRGB.cgColor.components)
        let expected=try XCTUnwrap(UIColor(hex:"#F4F3EF").artSRGB.cgColor.components)
        for i in 0..<3 {XCTAssertEqual(actual[i],expected[i],accuracy:0.0001)}
    }
    @MainActor func testAuthoredCharacterRejectsIncompleteArt() {
        XCTAssertThrowsError(try AuthoredDreamRunner(entity:Entity()))
        let e=Entity(),socket=Entity();socket.name="hat.socket";e.addChild(socket)
        XCTAssertThrowsError(try AuthoredDreamRunner(entity:e))
    }
    @MainActor func testArtPreviewCannotEarnOrPersistRewards() throws {
        let game=GameModel(),balance=game.profile.balance,snapshot=game.profile.snapshot
        game.labArt(theme:0,pose:"white")
        XCTAssertFalse(game.run.mode.earns)
        game.persist()
        XCTAssertEqual(game.profile.balance,balance)
        XCTAssertEqual(game.profile.snapshot?.id,snapshot?.id)
        XCTAssertEqual(game.run.pigs.count,3)
    }
}

extension Dream_AgainTests {
    @MainActor func testDisplayLinkDoesNotRetainDiscardedGame() {
        weak var released:GameModel?
        autoreleasepool {let game=GameModel();released=game}
        XCTAssertNil(released)
    }
}


extension Dream_AgainTests {
    @MainActor func testAllHatsFitBothCharactersWithoutChangingTheRun() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        let originalRun=game.run, originalBalance=game.profile.balance
        for character in ["girl","runner"] {
            for item in game.catalogue where item.slot == "hat" {
                renderer.dress(["character":character,"hat":item.id])
                XCTAssertEqual(renderer.legs.count,2)
                XCTAssertEqual(renderer.arms.count,2)
                XCTAssertEqual(renderer.headAttachment.position.y,1.73,accuracy:0.001)
                if item.id != "bare_head" {
                    let hat=try XCTUnwrap(renderer.headAttachment.findEntity(named:"fitted-\(item.id)"))
                    let bounds=hat.visualBounds(relativeTo:renderer.headAttachment)
                    XCTAssertLessThan(bounds.min.y,0.025,"Hat must meet the head fitting line: \(item.id)")
                    XCTAssertLessThan(bounds.extents.x,0.5,"Hat must stay head-sized: \(item.id)")
                    XCTAssertTrue(bounds.extents.y.isFinite)
                } else {XCTAssertTrue(renderer.headAttachment.children.isEmpty)}
                XCTAssertEqual(renderer.runner.findEntity(named:"ponytail") != nil,character == "girl")
            }
        }
        XCTAssertEqual(game.run.id,originalRun.id)
        XCTAssertEqual(game.run.distance,originalRun.distance)
        XCTAssertEqual(game.profile.balance,originalBalance)
        var profile=Profile();profile.equipped["character"]="girl"
        let restored=try JSONDecoder().decode(Profile.self,from:JSONEncoder().encode(profile))
        XCTAssertEqual(restored.equipped["character"],"girl")
    }
}
