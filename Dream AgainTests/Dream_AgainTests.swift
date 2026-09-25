import XCTest
import RealityKit
import AVFAudio
@testable import DreamAgain
final class Dream_AgainTests:XCTestCase {
    func testCoreIdentityInApp() throws {XCTAssertEqual(try DreamIdentity.parse(DreamIdentity.current(seed:42).code).seed,42)}
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
        game.labDesign(theme:3,variant:2,sky:DreamCollageKit.skyIDs[1],pattern:.solid)
        game.labScale(.absurd,framing:.crownOnly)
        game.start()
        XCTAssertNil(r.art.collage.previewScale);XCTAssertNil(r.art.collage.previewFraming)
        XCTAssertNil(r.artPalette);XCTAssertNil(r.artPattern)
        XCTAssertNil(r.art.collage.previewPlate);XCTAssertNil(game.artEquipped)
    }
    func testRepresentationRegistryKeepsExactlyFortyTwoSemanticConcepts() throws {
        XCTAssertEqual(DreamRepresentationRegistry.concepts.count,42)
        XCTAssertEqual(Set(DreamRepresentationRegistry.concepts.map(\.semanticID)),Set(AssetID.allCases))
        XCTAssertFalse(DreamCollageKit.assets.contains{$0.orientation == "forumRepost"})
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
        XCTAssertLessThanOrEqual(renderer.art.collage.loadedTextureCount,DreamCollageKit.assets.filter{!$0.isPlate}.count+3)
        game.labCollage(index:0)
        renderer.render(game.run,equipped:game.profile.equipped)
        XCTAssertGreaterThan(renderer.art.collage.activeCardCount,5)
        XCTAssertGreaterThanOrEqual(renderer.art.collage.activeAtmosphereCount,1)
        XCTAssertEqual(renderer.art.collage.pooledCardCount,25)
        for _ in 0..<30 {renderer.render(game.run,equipped:game.profile.equipped)}
        XCTAssertLessThanOrEqual(renderer.art.collage.loadedTextureCount,DreamCollageKit.assets.filter{!$0.isPlate}.count+3)
        XCTAssertTrue(renderer.art.collage.root.children.allSatisfy{$0.components[CollisionComponent.self] == nil})
        for asset in DreamCollageKit.assets {
            XCTAssertNotNil(Bundle.main.url(forResource:asset.resource,withExtension:asset.resourceExtension))
        }
    }

    @MainActor func testCuratedPlateCacheRemainsBoundedAndPreservesAspect() async throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer),kit=r.art.collage
        await kit.waitForPreload()
        for plate in DreamPlateLibrary.assets.prefix(6) {
            kit.previewPlate=plate.id
            r.render(game.run,equipped:[:]);await kit.waitForPreload()
            game.simulation.state.activeTicks += 1800
            r.render(game.run,equipped:[:]);await kit.waitForPreload()
            r.render(game.run,equipped:[:])
            XCTAssertLessThanOrEqual(kit.residentPlateCount,3)
            XCTAssertLessThanOrEqual(kit.loadedTextureCount,57)
            for entity in kit.root.children where entity.name == "collage:\(plate.id)" {
                XCTAssertEqual(abs(entity.scale.x/entity.scale.y),plate.aspect,accuracy:0.001)
            }
        }
        XCTAssertEqual(kit.loadErrors,[])
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
            r.dress(["bottom":"straw_skirt","hat":hat])
            XCTAssertTrue(r.runner.findEntity(named:"straw-head") === head)
            XCTAssertEqual(r.legs.map{ObjectIdentifier($0)},hips)
            XCTAssertNotNil(r.runner.findEntity(named:"straw-skirt"))
        }
        r.dress([:]);XCTAssertNil(r.runner.findEntity(named:"straw-skirt"))
        r.dress(["bottom":"hawaiian_tutu"])
        XCTAssertTrue(r.runner.findEntity(named:"straw-head") === head)
        XCTAssertEqual(r.legs.map{ObjectIdentifier($0)},hips)
        XCTAssertNotNil(r.runner.findEntity(named:"hawaiian-tutu"))
        XCTAssertNotNil(r.runner.findEntity(named:"tutu-flowers"))
        XCTAssertNil(r.runner.findEntity(named:"straw-skirt"))
    }
    @MainActor func testWardrobeLayersCanBeCombinedAndRemoved() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        XCTAssertEqual(Profile().equipped["top"],"bare_top")
        let head=try XCTUnwrap(r.runner.findEntity(named:"straw-head"))
        let hips=r.legs.map(ObjectIdentifier.init)
        r.dress(["top":"plain_ribbon","bottom":"hawaiian_tutu"])
        XCTAssertNotNil(r.runner.findEntity(named:"top-ribbon"))
        r.dress(["top":"bare_top","bottom":"hawaiian_tutu"])
        XCTAssertNil(r.runner.findEntity(named:"top-ribbon"))
        XCTAssertNotNil(r.runner.findEntity(named:"hawaiian-tutu"))
        r.dress(["top":"coconut_top","bottom":"hawaiian_tutu","hat":"flower_crown"])
        XCTAssertNotNil(r.runner.findEntity(named:"coconut-shells"))
        XCTAssertNotNil(r.runner.findEntity(named:"coconut-straps"))
        XCTAssertNotNil(r.headAttachment.findEntity(named:"fitted-flower_crown"))
        XCTAssertNil(r.runner.findEntity(named:"top-ribbon"))
        r.dress(["top":"office_jacket","bottom":"tuxedo_pants"])
        XCTAssertNotNil(r.runner.findEntity(named:"office-jacket"))
        XCTAssertNotNil(r.runner.findEntity(named:"office-tie"))
        XCTAssertNotNil(r.runner.findEntity(named:"tuxedo-waist"))
        XCTAssertEqual(r.legs.filter{$0.findEntity(named:"outfit-tuxedo-upper-leg") != nil}.count,2)
        XCTAssertEqual(r.arms.filter{$0.findEntity(named:"outfit-office-upper-sleeve") != nil}.count,2)
        XCTAssertNil(r.runner.findEntity(named:"coconut-shells"))
        r.dress(["top":"bare_top","bottom":"plain_bottom"])
        XCTAssertNil(r.runner.findEntity(named:"office-jacket"))
        XCTAssertTrue(r.arms.allSatisfy{$0.findEntity(named:"outfit-office-upper-sleeve") == nil})
        XCTAssertTrue(r.legs.allSatisfy{$0.findEntity(named:"outfit-tuxedo-upper-leg") == nil})
        XCTAssertTrue(r.runner.findEntity(named:"straw-head") === head)
        XCTAssertEqual(r.legs.map(ObjectIdentifier.init),hips)
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
        for bottom in ["straw_skirt","plain_bottom","hawaiian_tutu"] {
            for item in game.catalogue where item.slot == "hat" {
                renderer.dress(["bottom":bottom,"hat":item.id])
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
                XCTAssertEqual(renderer.runner.findEntity(named:"straw-skirt") != nil,bottom == "straw_skirt")
                XCTAssertEqual(renderer.runner.findEntity(named:"hawaiian-tutu") != nil,bottom == "hawaiian_tutu")
            }
        }
        XCTAssertEqual(game.run.id,originalRun.id)
        XCTAssertEqual(game.run.distance,originalRun.distance)
        XCTAssertEqual(game.profile.balance,originalBalance)
        let lockedHat=try XCTUnwrap(game.catalogue.first(where:{$0.id == "paper_hat"}))
        XCTAssertFalse(game.profile.owned.contains(lockedHat.id))
        renderer.previewAvatar(equipped:["hat":lockedHat.id,"bottom":"straw_skirt"],wardrobe:true)
        XCTAssertNotNil(renderer.headAttachment.findEntity(named:"fitted-paper_hat"))
        XCTAssertNotNil(renderer.runner.findEntity(named:"straw-skirt"))
        XCTAssertFalse(game.profile.owned.contains(lockedHat.id),"Try-on must not grant an item")
        XCTAssertEqual(game.profile.balance,originalBalance,"Try-on must not spend balloons")
        var profile=Profile();profile.equipped["bottom"]="straw_skirt"
        let restored=try JSONDecoder().decode(Profile.self,from:JSONEncoder().encode(profile))
        XCTAssertEqual(restored.equipped["bottom"],"straw_skirt")
    }
}

extension Dream_AgainTests {
    @MainActor func testCameraDriftRespectsReducedMotionInRenderer() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        var run=game.run
        run.mode = .tutorial
        run.phase = .running
        run.activeTicks=600
        renderer.art.collage.reducedMotion=false
        renderer.render(run,equipped:game.profile.equipped)
        let drifting=renderer.camera.position
        renderer.art.collage.reducedMotion=true
        renderer.render(run,equipped:game.profile.equipped)
        let steady=renderer.camera.position
        XCTAssertGreaterThan(simd_distance(drifting,steady),0.0001)
        renderer.render(run,equipped:game.profile.equipped)
        XCTAssertEqual(renderer.camera.position,steady)
    }

    @MainActor func testSteadyRendererFrameCost() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        game.labArt(theme:0)
        var run=game.run
        let equipped=["bottom":"straw_skirt","hat":"bare_head"]
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
                if hazard.asset == .window {
                    XCTAssertEqual(bounds.min.y,0.85,accuracy:0.02)
                    XCTAssertNotNil(entity.findEntity(named:"jail-door-bars"))
                }
                if hazard.encounter == .swing {
                    let spikes=try XCTUnwrap(entity.findEntity(named:"mace-spikes"))
                    let b=spikes.visualBounds(relativeTo:entity)
                    XCTAssertLessThanOrEqual(max(abs(b.min.x),abs(b.max.x)),Float(hazard.radius)+0.001)
                    XCTAssertNotNil(entity.findEntity(named:"mace-chain"))
                }
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

extension Dream_AgainTests {
    @MainActor func testThunderSurvivesPickupAndFatalStrikeButStopsOnPause() throws {
        let audio=DreamAudio(),buffer=try XCTUnwrap(audio.thunderBuffer)
        XCTAssertEqual(buffer.format.sampleRate,22050)
        XCTAssertEqual(Double(buffer.frameLength)/buffer.format.sampleRate,3.6,accuracy:0.001)
        let samples=try XCTUnwrap(buffer.floatChannelData?[0])
        let peak=(0..<Int(buffer.frameLength)).map{abs(samples[$0])}.max()!
        XCTAssertGreaterThan(peak,0.8);XCTAssertLessThan(peak,0.9)
        var settings=Settings();settings.effects=true;settings.haptics=false
        audio.feedback(.balloon,settings:settings)
        audio.feedback(.thunder,settings:settings)
        XCTAssertTrue(audio.thunder.isPlaying,"Pickup debounce must not suppress the strike")
        audio.feedback(.stumble,settings:settings)
        XCTAssertTrue(audio.thunder.isPlaying,"Other effects must not interrupt thunder")
        audio.stop(preserveThunder:true)
        XCTAssertTrue(audio.thunder.isPlaying,"Fatal lightning must retain its impact sound")
        audio.stop();XCTAssertFalse(audio.thunder.isPlaying)
        settings.effects=false
        audio.feedback(.thunder,settings:settings)
        XCTAssertFalse(audio.thunder.isPlaying)
    }
}

extension Dream_AgainTests {
    @MainActor func testMissingPlateKeepsRealityAndRecoversDeterministically() async throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer),kit=renderer.art.collage
        game.labCollage(index:0)
        let first=DreamPlateLibrary.assets[0].id,bad=DreamPlateLibrary.assets[1].id
        kit.unavailablePlateIDs=[bad];kit.previewPlate=first
        for _ in 0..<3 {renderer.render(game.run,equipped:[:]);await kit.waitForPreload()}
        game.simulation.state.activeTicks += 3600
        renderer.render(game.run,equipped:[:])
        XCTAssertFalse(kit.visiblePlateIDs.isEmpty)
        kit.unavailablePlateIDs=[bad];kit.previewPlate=bad
        for _ in 0..<5 {
            renderer.render(game.run,equipped:[:]);await kit.waitForPreload()
            XCTAssertFalse(kit.visiblePlateIDs.isEmpty,"Loading/failure must preserve visible reality")
            game.simulation.state.activeTicks += 1800
        }
        renderer.render(game.run,equipped:[:])
        XCTAssertFalse(kit.visiblePlateIDs.contains(bad))
        XCTAssertFalse(kit.visiblePlateIDs.contains(first),"A valid replacement must eventually take over")
        XCTAssertTrue(kit.loadErrors.contains("Missing plate \(bad)"))
        XCTAssertLessThanOrEqual(kit.residentPlateCount,3)
    }
}

extension Dream_AgainTests {
    @MainActor func testStitchedStormThreatAndLightingRecovery() async throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labObstacle(.lightning)
        let h=try XCTUnwrap(game.run.hazards.first),e=try XCTUnwrap(r.hazards[h.id])
        await r.storm.waitUntilReady();XCTAssertNil(r.storm.loadError)
        XCTAssertNotNil(e.findEntity(named:"storm-silk"))
        XCTAssertNotNil(e.findEntity(named:"storm-rain"))
        XCTAssertNil(e.findEntity(named:"storm-photo"))
        XCTAssertNil(e.findEntity(named:"strike-outline"))
        game.simulation.state.distance=h.distance-10;r.render(game.run,equipped:[:])
        XCTAssertLessThan(r.daylight.light.intensity,2000)
        var strike=game.run;strike.activeTicks=h.strikeTick
        r.animateObstacle(e,h:h,run:strike)
        XCTAssertGreaterThan(try XCTUnwrap(e.findEntity(named:"storm-flash") as? PointLight).light.intensity,0)
        game.simulation.state.hazards=[];r.render(game.run,equipped:[:])
        XCTAssertEqual(r.daylight.light.intensity,4200)
        XCTAssertEqual(r.ambientFill.light.intensity,750)
    }
}

extension Dream_AgainTests {
    @MainActor func testTrackOpacityKeepsPatternAndBoundariesStronger() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labDesign(theme:1,pattern:.checker)
        for c in game.run.chunks {
            let root=try XCTUnwrap(r.chunks[c.id])
            guard let base=root.findEntity(named:"palette:dark"),let pattern=root.findEntity(named:"palette:light") else {continue}
            let a=try XCTUnwrap(base.components[OpacityComponent.self]).opacity
            let b=try XCTUnwrap(pattern.components[OpacityComponent.self]).opacity
            XCTAssertLessThan(a,1);XCTAssertGreaterThanOrEqual(b,a)
            XCTAssertNil(root.findEntity(named:"palette:rim")?.components[OpacityComponent.self])
            let ids=root.children.map{ObjectIdentifier($0)}
            game.simulation.state.distance += 0.01;r.render(game.run,equipped:[:])
            XCTAssertEqual(root.children.map{ObjectIdentifier($0)},ids)
        }
    }
}

extension Dream_AgainTests {
    @MainActor func testTimedRealityBeginsAtTwentySecondsWithoutTravel() async throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer),kit=r.art.collage
        game.labCollage(index:0);kit.previewPlate=nil
        game.simulation.state.activeTicks=0
        for _ in 0..<3 {r.render(game.run,equipped:[:]);await kit.waitForPreload()}
        let original=DreamCollageComposition.plate(identity:game.run.identity,section:0).id
        let incoming=DreamCollageComposition.plate(identity:game.run.identity,section:1).id
        XCTAssertTrue(kit.visiblePlateIDs.contains(original))
        game.simulation.state.activeTicks=1199;r.render(game.run,equipped:[:])
        XCTAssertFalse(kit.visiblePlateIDs.contains(incoming))
        game.simulation.state.activeTicks=1200
        for _ in 0..<3 {r.render(game.run,equipped:[:]);await kit.waitForPreload()}
        game.simulation.state.activeTicks=1800;r.render(game.run,equipped:[:])
        XCTAssertTrue(kit.visiblePlateIDs.contains(original))
        XCTAssertTrue(kit.visiblePlateIDs.contains(incoming),"Both realities should remain visible during the slow blend")
        XCTAssertLessThanOrEqual(kit.residentPlateCount,3)
    }
}


extension Dream_AgainTests {
    @MainActor func testTraversalAndBalloonsFollowPaletteEvolution() throws {
        func assertColor(_ actual:UIColor,_ expected:UIColor,file:StaticString=#filePath,line:UInt=#line) {
            let a=actual.artSRGB.cgColor.components!,b=expected.artSRGB.cgColor.components!
            for i in 0..<3 {XCTAssertEqual(a[i],b[i],accuracy:0.002,file:file,line:line)}
        }
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labObstacle(.window)
        let door=try XCTUnwrap(r.hazards.values.first)
        let frame=try XCTUnwrap(door.findEntity(named:"jail-door-frame") as? ModelEntity)
        let original=try XCTUnwrap(frame.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint
        assertColor(original,UIColor(hex:r.vividPalettes[r.palette].track_dark))
        let balloon=r.factory.build(.balloon,palette:r.palette,style:1,lod:0)
        r.world.addChild(balloon);r.coordinatePalette(balloon,definition:r.vividPalettes[r.palette],balloon:true)
        let body=try XCTUnwrap(balloon.children.first as? ModelEntity)
        assertColor(try XCTUnwrap(body.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint,UIColor(hex:r.vividPalettes[r.palette].accent_a))
        r.evolution.register(balloon,palette:r.palette,palettes:r.vividPalettes,art:r.art,allSurfaces:true)
        let target=(r.palette+1)%7
        r.evolution.request(target,seconds:0,accelerated:false,palettes:r.vividPalettes,art:r.art)
        for _ in 0..<500 {r.evolution.update(seconds:60,palettes:r.vividPalettes,art:r.art)}
        assertColor(try XCTUnwrap(frame.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint,UIColor(hex:r.vividPalettes[target].track_dark))
        assertColor(try XCTUnwrap(body.model?.materials.first as? PhysicallyBasedMaterial).baseColor.tint,UIColor(hex:r.vividPalettes[target].accent_a))
    }
    @MainActor func testStormMovesWithoutRebuildingAndHasOpaqueScorch() async throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        await r.storm.waitUntilReady()
        game.labObstacle(.lightning)
        let h=try XCTUnwrap(game.run.hazards.first),e=try XCTUnwrap(r.hazards[h.id])
        let cloud=try XCTUnwrap(e.findEntity(named:"storm-cloud"))
        let char=try XCTUnwrap(e.findEntity(named:"storm-char"))
        XCTAssertNil(char.components[OpacityComponent.self]);XCTAssertNotNil(e.findEntity(named:"storm-charge"))
        XCTAssertNotNil(e.findEntity(named:"storm-silk"));XCTAssertNil(e.findEntity(named:"storm-scud"))
        let before=cloud.transform,ids=e.children.map(ObjectIdentifier.init)
        var later=game.run;later.activeTicks += 11;r.animateObstacle(e,h:h,run:later)
        XCTAssertNotEqual(before,cloud.transform);XCTAssertEqual(ids,e.children.map(ObjectIdentifier.init))
    }
}

extension Dream_AgainTests {
    @MainActor func testStrawLossRepairAndBurstRendering() throws {
        let game=GameModel(),r=try XCTUnwrap(game.renderer)
        game.labCollage(index:0)
        game.simulation.state.player.missingLimbs=[.leftArm,.rightArm,.leftLeg]
        r.render(game.run,equipped:[:])
        XCTAssertFalse(r.arms[0].isEnabled);XCTAssertFalse(r.arms[1].isEnabled)
        XCTAssertFalse(r.legs[0].isEnabled);XCTAssertTrue(r.legs[1].isEnabled)
        game.simulation.state.player.missingLimbs.removeLast();r.render(game.run,equipped:[:])
        XCTAssertTrue(r.legs[0].isEnabled)
        game.simulation.state.player.missingLimbs=StrawLimb.allCases;game.simulation.wake("unravelled")
        r.render(game.run,equipped:[:]);game.simulation.state.endingElapsed=0.6;r.render(game.run,equipped:[:])
        XCTAssertEqual(r.runner.components[OpacityComponent.self]?.opacity,0)
        XCTAssertNotNil(r.world.children.first{$0.name == "straw-fragments"})
        let bale=r.strawBall();XCTAssertEqual(bale.name,"rolling-hay-ball");XCTAssertGreaterThan(bale.visualBounds(relativeTo:bale).extents.x,0.5)
        XCTAssertNotNil(game.audio.buffers["strawBreak"]);XCTAssertNotNil(game.audio.buffers["strawRepair"])
        XCTAssertFalse(game.run.mode.earns)
    }
}

extension Dream_AgainTests {
    @MainActor func testFloatingStairGapMarkersFollowRaisedLanding() throws {
        let game=GameModel(),renderer=try XCTUnwrap(game.renderer)
        let generator=WorldGenerator(DreamIdentity.current(seed:42))
        let chunk=generator.encounterChunk(4,kind:.floatingStairs,tier:2)
        let root=Entity(),origin=generator.sample(chunk.start)
        renderer.terrainDecorations(chunk,root:root,generator:generator,origin:origin,palette:game.palettes[0])
        let marks=try XCTUnwrap(root.findEntity(named:"palette:rim"))
        let bounds=marks.visualBounds(relativeTo:root)
        let landing=try XCTUnwrap(chunk.gap).upperBound+0.4
        let expected=generator.sample(landing).y-origin.y+chunk.step!.height(at:landing)+0.045
        XCTAssertEqual(Double(bounds.max.y),expected,accuracy:0.001)
        XCTAssertEqual(chunk.gap!.upperBound,chunk.step!.start)
    }
}
