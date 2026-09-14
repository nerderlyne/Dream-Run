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
    @MainActor func testMirrorVoidCoversFrameOpening() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        let mirror=r.factory.build(.mirror)
        let panel=try XCTUnwrap(mirror.children.compactMap{$0 as? ModelEntity}.first{
            $0.model?.materials.first is UnlitMaterial
        })
        let bounds=panel.visualBounds(relativeTo:mirror)
        XCTAssertLessThan(bounds.min.x,-2.1);XCTAssertGreaterThan(bounds.max.x,2.1)
        XCTAssertLessThan(bounds.min.y,0.075);XCTAssertGreaterThan(bounds.max.y,5.075)
    }
    @MainActor func testNormalDreamClearsVisualReviewOverrides() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labDesign(theme:3,variant:2,sky:"sky_underwater",pattern:.solid)
        game.labScale(.absurd,framing:.crownOnly)
        game.start()
        XCTAssertNil(r.art.collage.previewScale);XCTAssertNil(r.art.collage.previewFraming)
        XCTAssertNil(r.artPalette);XCTAssertNil(r.artPattern)
        XCTAssertNil(r.art.collage.previewPlate);XCTAssertNil(game.artEquipped)
    }
    func testRepresentationRegistryKeepsExactlyFortyTwoSemanticConcepts() throws {
        XCTAssertEqual(DreamRepresentationRegistry.concepts.count,42)
        XCTAssertEqual(Set(DreamRepresentationRegistry.concepts.map(\.semanticID)),Set(AssetID.allCases))
        XCTAssertEqual(DreamMemeLibrary.entries.count,4)
        for concept in DreamRepresentationRegistry.concepts {
            XCTAssertFalse(concept.proceduralRepresentationID.isEmpty)
            XCTAssertTrue(concept.representations.allSatisfy{$0.concept == concept.semanticID})
        }
        XCTAssertTrue(DreamRepresentationRegistry.definition(for:.horse).requiresGameplay3D)
        XCTAssertTrue(DreamRepresentationRegistry.definition(for:.rabbit).requiresGameplay3D)
        XCTAssertFalse(DreamRepresentationRegistry.definition(for:.rock).requiresGameplay3D)
    }

    func testCollageSelectionIsDeterministicAndPresentationOnly() throws {
        let identity=DreamIdentity(seed:42)
        let a=DreamCollageComposition.plate(identity:identity,section:7)
        let b=DreamCollageComposition.plate(identity:identity,section:7)
        XCTAssertEqual(a,b)
        XCTAssertEqual(DreamCollageComposition.density(seconds:11100,visual:.deepSparse,voidWeight:0),0)
    }

    @MainActor func testHybridCollageLoadsOnceAndStaysBounded() async throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        await renderer.art.collage.waitForPreload()
        XCTAssertEqual(renderer.art.collage.loadErrors,[])
        XCTAssertEqual(renderer.art.collage.loadedTextureCount,55)
        game.labCollage(index:0)
        renderer.render(game.run,equipped:game.profile.equipped)
        XCTAssertGreaterThan(renderer.art.collage.activeCardCount,5)
        XCTAssertGreaterThanOrEqual(renderer.art.collage.activeAtmosphereCount,1)
        XCTAssertEqual(renderer.art.collage.pooledCardCount,25)
        for _ in 0..<30 {renderer.render(game.run,equipped:game.profile.equipped)}
        XCTAssertEqual(renderer.art.collage.loadedTextureCount,55)
        XCTAssertTrue(renderer.art.collage.root.children.allSatisfy{$0.components[CollisionComponent.self] == nil})
        for asset in DreamCollageKit.assets {
            XCTAssertNotNil(Bundle.main.url(forResource:asset.resource,withExtension:"png"))
        }
    }

    @MainActor func testCollageRebaseTransitionsAndCPUProfile() async throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer),kit=r.art.collage
        await kit.waitForPreload()
        XCTAssertTrue(kit.ready,"\(kit.loadErrors)")
        game.labCollage(index:0)
        game.simulation.state.distance=191.9;game.simulation.streamChunks()
        r.render(game.run,equipped:game.profile.equipped)
        kit.reducedMotion=true;r.render(game.run,equipped:game.profile.equipped)
        let positions=kit.cardPositions
        let oldOrigin=WorldGenerator(game.run.identity).sample(0),newOrigin=WorldGenerator(game.run.identity).sample(192)
        let shift=SIMD3<Float>(Float(oldOrigin.x-newOrigin.x),Float(oldOrigin.y-newOrigin.y),Float(oldOrigin.z-newOrigin.z))
        game.simulation.state.distance=192.1;game.simulation.streamChunks()
        r.render(game.run,equipped:game.profile.equipped)
        // Slot 1 is not crossing its staggered lifetime boundary here.
        XCTAssertLessThan(simd_length(kit.cardPositions[1]-(positions[1]+shift)),0.001)
        kit.reducedMotion=false
        let identities=kit.root.children.map{ObjectIdentifier($0)}
        for n in 0..<20 {
            game.simulation.state.distance=Double(n*1600+60)
            game.simulation.state.activeTicks += 60
            game.simulation.streamChunks();r.render(game.run,equipped:game.profile.equipped)
            XCTAssertEqual(kit.root.children.map{ObjectIdentifier($0)},identities)
            XCTAssertLessThanOrEqual(kit.activeCardCount,25)
        }
        do {
            game.labCollage(index:0)
            game.simulation.state.id=UUID()
            var timings:[Double]=[]
            for tick in 0..<720 {
                game.simulation.state.distance=400+Double(tick)*12.25/60
                game.simulation.state.activeTicks=UInt64(1800+tick)
                game.simulation.streamChunks()
                let start=CFAbsoluteTimeGetCurrent()
                r.render(game.run,equipped:game.profile.equipped)
                if tick>=60 {timings.append((CFAbsoluteTimeGetCurrent()-start)*1000)}
            }
            timings.sort()
            print("DREAM_RENDER_CPU samples=\(timings.count) median_ms=\(timings[timings.count/2]) p95_ms=\(timings[Int(Double(timings.count)*0.95)]) max_ms=\(timings.last!) entities=\(r.renderEntities) cards=\(kit.activeCardCount)")
        }
    }
    @MainActor func testCollageReviewClearsInitialGapsAndCannotEarn() throws {
        let game=GameModel()
        game.labCollage(index:2)
        let wallet=game.profile.balance
        for _ in 0..<1200 {_=game.simulation.step(.init())}
        XCTAssertEqual(game.run.phase,.running)
        XCTAssertGreaterThan(game.run.distance,290)
        XCTAssertEqual(game.run.mode,.debug)
        XCTAssertFalse(game.run.mode.earns)
        XCTAssertEqual(game.profile.balance,wallet)
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
    @MainActor func testStrawCostumesRetainTheSameRig() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        r.dress([:])
        let head=try XCTUnwrap(r.runner.findEntity(named:"straw-head"))
        let hips=r.legs.map{ObjectIdentifier($0)}
        for hat in ["bow","nightcap","moon_hat","beyond_crown"] {
            r.dress(["character":"girl","hat":hat])
            XCTAssertTrue(r.runner.findEntity(named:"straw-head") === head)
            XCTAssertEqual(r.legs.map{ObjectIdentifier($0)},hips)
            XCTAssertNotNil(r.runner.findEntity(named:"straw-skirt"))
        }
        r.dress([:]);XCTAssertNil(r.runner.findEntity(named:"straw-skirt"))
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
                    if item.id == "paper_hat" {
                        let face=try XCTUnwrap(hat.findEntity(named:"red-smiley-back"))
                        XCTAssertGreaterThan(face.visualBounds(relativeTo:hat).min.z,0.15)
                        XCTAssertLessThan(bounds.min.y,-0.23)
                        XCTAssertGreaterThan(bounds.max.y,0.15)
                    }
                } else {XCTAssertTrue(renderer.headAttachment.children.isEmpty)}
                XCTAssertNotNil(renderer.runner.findEntity(named:"straw-head"))
                XCTAssertEqual(renderer.runner.findEntity(named:"straw-skirt") != nil,character == "girl")
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

extension Dream_AgainTests {
    @MainActor func testSteadyRendererFrameCost() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        game.labArt(theme:0)
        var run=game.run
        let equipped=["character":"girl","hat":"bare_head"]
        renderer.render(run,equipped:equipped)
        var times:[Double]=[]
        for _ in 0..<120 {
            run.distance += 12.25/60
            let start=CFAbsoluteTimeGetCurrent()
            renderer.render(run,equipped:equipped)
            times.append((CFAbsoluteTimeGetCurrent()-start)*1000)
        }
        times.sort()
        print("RENDER_CPU_MS median=\(times[60]) p95=\(times[114]) max=\(times.last!)")
    }
}

extension Dream_AgainTests {
    @MainActor func testRenderingRetainsResourcesAcrossFramesAndRebase() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labArt(theme:0,distance:191.9)
        let run=game.run,equipped=game.profile.equipped
        let applications=r.art.environmentApplications
        let oldChunks=r.chunks
        let oldPositions=oldChunks.mapValues{$0.position}
        let far=r.distantPath.root.children.dropFirst().first
        for _ in 0..<5 {r.render(run,equipped:equipped)}
        XCTAssertEqual(r.art.environmentApplications,applications)
        let leg=r.legs[0]
        var hat=equipped;hat["hat"]="bucket_hat";r.dress(hat)
        XCTAssertTrue(r.legs[0] === leg,"Changing a hat must not rebuild the character")
        game.simulation.state.distance=192.1;game.simulation.streamChunks()
        r.render(game.run,equipped:hat)
        let generator=WorldGenerator(run.identity)
        let shift=r.local(generator.sample(0),origin:generator.sample(192))
        let retained=Set(oldChunks.keys).intersection(r.chunks.keys)
        XCTAssertFalse(retained.isEmpty)
        for id in retained {
            XCTAssertTrue(r.chunks[id] === oldChunks[id],"Rebasing must retain track meshes")
            XCTAssertLessThan(simd_distance(r.chunks[id]!.position,oldPositions[id]!+shift),0.001)
        }
        XCTAssertTrue(r.distantPath.root.children.contains{$0 === far})
        XCTAssertEqual(r.art.environmentApplications,applications)
    }
}

extension Dream_AgainTests {
    func testPaletteScheduleIsStaggeredAndUsesActiveTime() {
        let t=PaletteTransition(from:0,to:1,started:100,accelerated:false)
        XCTAssertEqual(t.fraction(at:100,order:0),0)
        XCTAssertGreaterThan(t.fraction(at:105,order:0),0)
        XCTAssertEqual(t.fraction(at:105,order:11),0)
        XCTAssertEqual(t.fraction(at:120,order:11),1)
        let mirror=PaletteTransition(from:0,to:2,started:100,accelerated:true)
        XCTAssertLessThan(mirror.fraction(at:100.3,order:0),1)
        XCTAssertEqual(mirror.fraction(at:102,order:11),1)
    }
    @MainActor func testPaletteBoundaryRetainsWorldAndChangesObjectsGradually() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labArt(theme:0,distance:431.9)
        let equipped=game.profile.equipped
        for _ in 0..<30 {r.render(game.run,equipped:equipped)}
        let chunks=r.chunks,cards=r.art.collage.root.children.map{ObjectIdentifier($0)}
        let chunk=try XCTUnwrap(chunks[18])
        let track=try XCTUnwrap(chunk.children.first(where:{$0.name == "palette:light"}) as? ModelEntity)
        let before=try XCTUnwrap(track.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint
        let apps=r.art.environmentApplications
        r.artPalette=1
        game.simulation.state.distance=432.1;game.simulation.streamChunks()
        let start=game.run.activeTicks
        let boundaryStart=CFAbsoluteTimeGetCurrent()
        r.render(game.run,equipped:equipped)
        print("PALETTE_BOUNDARY_CPU_MS \((CFAbsoluteTimeGetCurrent()-boundaryStart)*1000)")
        XCTAssertEqual(r.art.environmentApplications,apps)
        XCTAssertEqual(r.art.collage.root.children.map{ObjectIdentifier($0)},cards)
        for id in Set(chunks.keys).intersection(r.chunks.keys) {XCTAssertTrue(r.chunks[id] === chunks[id])}
        XCTAssertEqual((track.model?.materials.first as? PhysicallyBasedMaterial)?.baseColor.tint,before)
        for tick in 1...1500 {
            game.simulation.state.activeTicks=start+UInt64(tick)
            r.render(game.run,equipped:equipped)
            XCTAssertLessThanOrEqual(r.evolution.updatesLastFrame,4)
        }
        let after=try XCTUnwrap(track.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint
        XCTAssertNotEqual(before,after)
        XCTAssertEqual(r.art.environmentApplications,apps,"Palette animation must not regenerate the environment")
        XCTAssertEqual(r.art.collage.root.children.map{ObjectIdentifier($0)},cards)
        game.simulation.state.phase = .mirrorCrossing;r.artPalette=2
        r.render(game.run,equipped:equipped)
        XCTAssertEqual(r.evolution.transition?.accelerated,true)
        XCTAssertTrue(r.chunks[18] === chunk)
    }
}

extension Dream_AgainTests {
    @MainActor func testObstacleGeometryAndLightningAnimation() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        for kind in DreamObstacle.allCases {
            game.labObstacle(kind)
            XCTAssertEqual(game.run.mode,.debug)
            for hazard in game.run.hazards {
                guard let entity=renderer.obstacleModel(hazard),hazard.encounter != .step else {continue}
                let bounds=entity.visualBounds(relativeTo:entity)
                XCTAssertTrue(bounds.extents.x.isFinite);XCTAssertGreaterThan(bounds.extents.y,0)
                if hazard.asset == .window {XCTAssertEqual(bounds.min.y,0.85,accuracy:0.02)}
                if hazard.encounter == .lightning {
                    let bolt=try XCTUnwrap(entity.findEntity(named:"lightning-bolt"))
                    let warning=try XCTUnwrap(entity.findEntity(named:"strike-warning"))
                    renderer.animateObstacle(entity,h:hazard,run:game.run)
                    XCTAssertFalse(bolt.isEnabled);XCTAssertTrue(warning.isEnabled)
                    var strike=game.run;strike.activeTicks=hazard.strikeTick
                    renderer.animateObstacle(entity,h:hazard,run:strike)
                    XCTAssertTrue(bolt.isEnabled)
                    strike.activeTicks += 24
                    renderer.animateObstacle(entity,h:hazard,run:strike)
                    XCTAssertFalse(bolt.isEnabled);XCTAssertFalse(warning.isEnabled)
                }
            }
        }
    }
    @MainActor func testObstacleAnimationReusesEntitiesAndRewardsStayDisabled() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        game.labObstacle(.collapse)
        let wallet=game.profile.balance
        let roots=renderer.chunks.mapValues{ObjectIdentifier($0)}
        for _ in 0..<20 {
            game.simulation.state.distance += 0.1
            renderer.render(game.run,equipped:game.profile.equipped)
        }
        for (id,root) in roots {XCTAssertEqual(renderer.chunks[id].map{ObjectIdentifier($0)},root)}
        XCTAssertEqual(game.profile.balance,wallet)
        XCTAssertFalse(game.run.unbroken)
    }
}

extension Dream_AgainTests {
    @MainActor func testSoccerPanelTopologyAndPreview() async throws {
        let faces=SoccerPanels.faces
        XCTAssertEqual(faces.filter{$0.count==5}.count,12)
        XCTAssertEqual(faces.filter{$0.count==6}.count,20)
        for lod in 0...2 {
            let panels=SoccerPanels.make(lod:lod)
            for g in [panels.white,panels.black] {
                for p in g.positions {XCTAssertEqual(simd_length(p-[0,0.45,0]),0.45,accuracy:0.00001)}
                for i in stride(from:0,to:g.indices.count,by:3) {
                    let a=g.positions[Int(g.indices[i])],b=g.positions[Int(g.indices[i+1])],c=g.positions[Int(g.indices[i+2])]
                    XCTAssertGreaterThan(simd_dot(simd_cross(b-a,c-a),a-[0,0.45,0]),0)
                }
            }
        }
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        game.screen="lab"
        let scene=try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let window=UIWindow(windowScene:scene),controller=UIViewController()
        controller.view=renderer.view;window.rootViewController=controller;window.makeKeyAndVisible()
        defer {window.isHidden=true}
        renderer.view.frame=window.bounds
        renderer.preview(.soccer,palette:0,style:5,lod:0)
        let ready=expectation(description:"render soccer preview")
        DispatchQueue.main.asyncAfter(deadline:.now()+2) {ready.fulfill()}
        await fulfillment(of:[ready],timeout:5)
        let captured=expectation(description:"snapshot")
        renderer.snapshot {image in
            if let image,let png=image.pngData() {
                try? png.write(to:URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("soccer-preview.png"))
                let attachment=XCTAttachment(image:image);attachment.lifetime = .keepAlways;self.add(attachment)
            } else {XCTFail("Soccer preview capture unavailable")}
            captured.fulfill()
        }
        await fulfillment(of:[captured],timeout:15)
    }
}

extension Dream_AgainTests {
    @MainActor func testBalloonsMoveWithoutRebuildingAndPopEffectsExpire() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labCollage(index:0)
        let id=try XCTUnwrap(r.pickups.keys.first),entity=try XCTUnwrap(r.pickups[id])
        let before=entity.position
        game.simulation.state.activeTicks += 30
        r.render(game.run,equipped:[:])
        XCTAssertTrue(r.pickups[id] === entity);XCTAssertNotEqual(before,entity.position)
        game.simulation.state.collectedIDs.insert(id);game.simulation.state.balloons += 1
        r.render(game.run,equipped:[:])
        XCTAssertNil(r.pickups[id]);XCTAssertEqual(r.balloonPops.activeCount,1)
        r.render(game.run,equipped:[:]);XCTAssertEqual(r.balloonPops.activeCount,1)
        game.simulation.state.activeTicks += 24;r.render(game.run,equipped:[:])
        XCTAssertEqual(r.balloonPops.activeCount,0)
        for _ in 0..<30 {r.balloonPops.spawn(at:.zero,world:r.world,tick:0)}
        XCTAssertEqual(r.balloonPops.activeCount,12);r.balloonPops.reset();XCTAssertEqual(r.balloonPops.activeCount,0)
    }
}
