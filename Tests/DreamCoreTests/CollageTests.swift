import XCTest
@testable import DreamCore

final class CollageTests:XCTestCase {
    func testKitCountsAndMetadata() {
        let kit=DreamCollageKit.assets
        XCTAssertEqual(kit.count,54+DreamPlateLibrary.assets.count);XCTAssertEqual(Set(kit.map(\.id )).count,kit.count)
        XCTAssertEqual(kit.filter(\.isPlate).count,DreamPlateLibrary.assets.count)
        for (concept,count) in [(AssetID.horse,5),(.tree,5),(.house,5),(.cloud,6),(.moon,3),(.arch,3),(.window,2)] {
            XCTAssertEqual(kit.filter{$0.concept == concept}.count,count)
        }
        for asset in kit {
            XCTAssertFalse(asset.interactive);XCTAssertTrue(asset.backgroundOnly)
            XCTAssertEqual(asset.alphaBounds.count,4);XCTAssertEqual(asset.pixelSize.count,2)
            XCTAssertFalse(asset.depths.contains(.gameplay))
            XCTAssertLessThanOrEqual(asset.pixelSize.max()!,asset.isPlate ? 2048:768)
            if !asset.isPlate {
                XCTAssertGreaterThan(asset.alphaBounds[0],0);XCTAssertGreaterThan(asset.alphaBounds[1],0)
                XCTAssertLessThan(asset.alphaBounds[2],asset.pixelSize[0]-1)
                XCTAssertLessThan(asset.alphaBounds[3],asset.pixelSize[1]-1)
            }
        }
        XCTAssertEqual(DreamRepresentationRegistry.concepts.count,42)
        XCTAssertTrue(DreamRepresentationRegistry.definition(for:.column).requiresGameplay3D)
    }
    func testFiveRecombinationsAreStableAndDifferent() {
        var conceptLayouts=Set<String>()
        let fingerprints=DreamCollageComposition.proofSeeds.map {seed in
            let identity=DreamIdentity.current(seed:seed)
            conceptLayouts.insert((0..<16).map{String(describing:DreamCollageComposition.placement(identity:identity,distance:60,slot:$0).representation.concept)}.joined(separator:"|"))
            return (0..<16).map {slot in
                let a=DreamCollageComposition.placement(identity:identity,distance:60,slot:slot)
                XCTAssertEqual(a,DreamCollageComposition.placement(identity:identity,distance:60,slot:slot))
                XCTAssertTrue(DreamCollageKit.assets.contains(a.representation))
                return "\(a.representation.id):\(a.lateral):\(a.height):\(a.mirrored)"
            }.joined(separator:"|")
        }
        XCTAssertEqual(Set(fingerprints).count,5)
        XCTAssertEqual(conceptLayouts.count,5,"Recombination must change the composition, not just reskin fixed concept slots")
    }
    func testCurrentSeedRoundTrips() throws {
        for seed:UInt64 in [0,42,999,UInt64.max] {
            let current=DreamIdentity.current(seed:seed)
            XCTAssertEqual(try DreamIdentity.parse(current.code),current)
            XCTAssertEqual(try JSONDecoder().decode(DreamIdentity.self,from:JSONEncoder().encode(current)),current)

        }
    }
    func testDensityIsNonterminalAndRebuilds() {
        XCTAssertEqual(DreamCollageComposition.density(seconds:10800,visual:.deepStripping,voidWeight:0),1)
        XCTAssertEqual(DreamCollageComposition.density(seconds:10920,visual:.deepStripping,voidWeight:0),0.5)
        XCTAssertEqual(DreamCollageComposition.density(seconds:11050,visual:.deepSparse,voidWeight:0),0)
        XCTAssertEqual(DreamCollageComposition.density(seconds:11250,visual:.deepRebuilding,voidWeight:0),0.5)
        XCTAssertEqual(DreamCollageComposition.density(seconds:11400,visual:.deepRebuilding,voidWeight:0),1)
    }
}


extension CollageTests {
    func testPilotScenesAreLayerableAndApparitionsStayRare() {
        XCTAssertEqual(DreamPilotKit.assets.count,20)
        XCTAssertEqual(DreamRepostKit.assets.count,8)
        XCTAssertEqual(DreamPilotKit.assets.filter{$0.concept == .seaCreatures}.count,6)
        for seed:UInt64 in 0..<20 {
            let identity=DreamIdentity.current(seed:seed)
            for block in 0..<20 {
                let scenes=(block*5..<block*5+5).map{DreamVignette.selected(identity:identity,cell:$0)}
                XCTAssertEqual(Set(scenes).count,5)
                XCTAssertEqual(scenes.filter{$0 == .midnightKitchen}.count,1)
            }
            for scene in DreamVignette.allCases {
                for part in 0..<4 {
                    let a=scene.placement(identity:identity,distance:150,part:part)
                    XCTAssertTrue(a.representation.backgroundOnly);XCTAssertFalse(a.representation.interactive)
                    XCTAssertTrue(a.elevation.isFinite)
                    XCTAssertEqual(a,scene.placement(identity:identity,distance:150,part:part))
                }
            }
        }
    }
    func testMidnightKitchenMixesOriginalObjectsWithSeededReposts() {
        let repostIDs=Set(DreamRepostKit.assets.map(\.id))
        var seen=Set<String>()
        for seed:UInt64 in 0..<20 {
            let identity=DreamIdentity.current(seed:seed)
            for cell in 0..<20 {
                let ids=DreamVignette.midnightKitchen.ingredients(identity:identity,cell:cell)
                XCTAssertEqual(ids.count,4)
                XCTAssertEqual(ids.filter{repostIDs.contains($0)}.count,2)
                XCTAssertEqual(Set(ids).count,4)
                XCTAssertEqual(ids,DreamVignette.midnightKitchen.ingredients(identity:identity,cell:cell))
                seen.formUnion(ids.filter{repostIDs.contains($0)})
                let scale=DreamScaleComposition.plan(identity:identity,distance:Double(cell)*640)
                let repostExtents=ids.enumerated().filter{repostIDs.contains($0.element)}.map{DreamScaleComposition.extent(scale.role(slot:16+$0.offset))}
                let allExtents=(0..<4).map{DreamScaleComposition.extent(scale.role(slot:16+$0))}.sorted(by:>)
                XCTAssertEqual(repostExtents.sorted(by:>),Array(allExtents.prefix(2)))
                let posts=(0..<4).map{DreamVignette.midnightKitchen.placement(identity:identity,distance:Double(cell)*640+150,part:$0)}.filter{$0.representation.orientation == "forumRepost"}
                XCTAssertEqual(posts.count,2)
                XCTAssertLessThan(posts[0].lateral*posts[1].lateral,0)
                XCTAssertTrue(posts.allSatisfy{$0.elevation>0 && !$0.mirrored})
            }
        }
        XCTAssertEqual(seen,repostIDs)
        for asset in DreamRepostKit.assets {
            XCTAssertEqual(asset.concept,.culturalApparitions)
            XCTAssertEqual(asset.orientation,"forumRepost")
            XCTAssertTrue(asset.backgroundOnly);XCTAssertFalse(asset.interactive)
        }
    }
    func testSceneryDeckAvoidsImmediateRepetitionAndCoversNewFamilies() {
        var seen=Set<String>()
        let identity=DreamIdentity.current(seed:2026)
        for slot in 1..<16 {
            var previous=""
            for cell in 1..<100 {
                let distance=Double(cell)*DreamCollageComposition.period(slot:slot)
                let p=DreamCollageComposition.placement(identity:identity,distance:distance,slot:slot)
                XCTAssertNotEqual(p.representation.id,previous);previous=p.representation.id
                XCTAssertNotEqual(p.representation.concept,.culturalApparitions)
                seen.insert(previous)
            }
        }
        for asset in DreamPilotKit.assets where asset.concept != .culturalApparitions {XCTAssertTrue(seen.contains(asset.id),asset.id)}
    }
    func testBackgroundMotionIsBoundedDeterministicAndCanBeDisabled() {
        for asset in DreamPilotKit.assets {
            let frozen=DreamScenicMotion.sample(id:asset.id,seconds:123,slot:3,reduced:true)
            XCTAssertEqual(frozen.offset,.zero);XCTAssertEqual(frozen.roll,0);XCTAssertEqual(frozen.scale,1)
            for time in stride(from:0.0,to:21600,by:137) {
                let a=DreamScenicMotion.sample(id:asset.id,seconds:time,slot:3)
                XCTAssertEqual(a,DreamScenicMotion.sample(id:asset.id,seconds:time,slot:3))
                XCTAssertLessThanOrEqual(abs(a.offset.x),9);XCTAssertLessThanOrEqual(abs(a.offset.y),6)
                XCTAssertLessThanOrEqual(abs(a.roll),0.05)
            }
        }
    }
}
