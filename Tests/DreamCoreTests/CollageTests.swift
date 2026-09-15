import XCTest
@testable import DreamCore

final class CollageTests:XCTestCase {
    func testKitCountsAndMetadata() {
        let kit=DreamCollageKit.assets
        XCTAssertEqual(kit.count,46+DreamPlateLibrary.assets.count);XCTAssertEqual(Set(kit.map(\.id )).count,kit.count)
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
