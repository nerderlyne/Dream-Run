import XCTest
@testable import DreamCore

final class CollageTests:XCTestCase {
    func testKitCountsAndMetadata() {
        let kit=DreamCollageKit.assets
        XCTAssertEqual(kit.count,29);XCTAssertEqual(Set(kit.map(\.id)).count,29)
        XCTAssertEqual(kit.filter(\.isPlate).count,3)
        for (concept,count) in [(AssetID.horse,5),(.tree,5),(.house,4),(.cloud,5),(.moon,3),(.arch,3),(.window,1)] {
            XCTAssertEqual(kit.filter{$0.concept == concept}.count,count)
        }
        for asset in kit {
            XCTAssertFalse(asset.interactive);XCTAssertTrue(asset.backgroundOnly)
            XCTAssertEqual(asset.alphaBounds.count,4);XCTAssertEqual(asset.pixelSize.count,2)
            XCTAssertFalse(asset.depths.contains(.gameplay))
            XCTAssertLessThanOrEqual(asset.pixelSize.max()!,asset.isPlate ? 1024:768)
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
    func testC2PreservesGameplayAndRoundTrips() throws {
        for seed:UInt64 in [0,42,999,UInt64.max] {
            let current=DreamIdentity.current(seed:seed)
            var old=current;old.contentVersion=1
            XCTAssertEqual(try DreamIdentity.parse(current.code),current)
            XCTAssertEqual(try JSONDecoder().decode(DreamIdentity.self,from:JSONEncoder().encode(current)),current)
            for i in 0..<100 {
                XCTAssertEqual(WorldGenerator(old).chunk(i),WorldGenerator(current).chunk(i))
                var a=old.stream("pig",i),b=current.stream("pig",i)
                XCTAssertEqual(a.next(),b.next())
            }
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
