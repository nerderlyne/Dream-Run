import XCTest
@testable import DreamCore

final class AtmosphereTests:XCTestCase {
    func testLargeTranslucentLayersDoNotChangeSemanticScaleEvents() {
        for seed:UInt64 in 0..<100 {
            let identity=DreamIdentity.current(seed:seed)
            for distance in stride(from:0.0,to:10000,by:257) {
                let event=DreamScaleComposition.plan(identity:identity,distance:distance)
                for slot in 0..<3 {
                    let p=DreamAtmosphere.placement(identity:identity,distance:distance,slot:slot)
                    XCTAssertEqual(p,DreamAtmosphere.placement(identity:identity,distance:distance,slot:slot))
                    XCTAssertTrue(p.representation.backgroundOnly);XCTAssertFalse(p.representation.interactive)
                    XCTAssertGreaterThan(p.height*max(1,p.representation.aspect)/p.depth,0.6)
                    XCTAssertTrue((0.08...0.33).contains(p.opacity))
                    XCTAssertFalse([AssetID.horse,.moon,.chair,.rabbit,.pig].contains(p.representation.concept!))
                }
                XCTAssertEqual(event,DreamScaleComposition.plan(identity:identity,distance:distance))
            }
        }
    }
    func testOpeningCompositionHasHierarchyCounterweightAndVariety() {
        var arrangements=Set<Int>(),anchors=Set<String>(),patterns=Set<String>()
        var solid=0
        for seed:UInt64 in 0..<400 {
            let id=DreamIdentity.current(seed:seed)
            let plan=DreamAtmosphericComposition.plan(identity:id,distance:0)
            arrangements.insert(plan.arrangement.rawValue)
            let cards=(0..<3).map{DreamAtmosphere.placement(identity:id,distance:0,slot:$0)}
            anchors.insert(cards[0].representation.id)
            XCTAssertGreaterThan(cards[0].opacity,cards[1].opacity*2)
            XCTAssertLessThan(cards[0].lateral*cards[1].lateral,0)
            let pattern=TrackArt.pattern(identity:id,distance:0)
            patterns.insert(pattern.rawValue)
            if pattern == .solid {solid+=1}
            // Changing distance within each card's cell must never reposition live imagery.
            for slot in 0..<3 {XCTAssertEqual(cards[slot],DreamAtmosphere.placement(identity:id,distance:5,slot:slot))}
        }
        XCTAssertEqual(arrangements.count,4)
        XCTAssertGreaterThan(anchors.count,10)
        XCTAssertEqual(patterns.count,3)
        XCTAssertGreaterThan(solid,180);XCTAssertLessThan(solid,300)
    }
    func testDensityControlsAtmosphereIndependentlyAndVoidIsEmpty() {
        func count(_ density:Float,_ lowPower:Bool=false)->Int {(0..<3).filter{DreamAtmosphere.weight(density:density,slot:$0,lowPower:lowPower)>0}.count}
        XCTAssertEqual(count(1),3);XCTAssertEqual(count(0.55),2);XCTAssertEqual(count(0.2),1)
        XCTAssertEqual(count(0),0);XCTAssertEqual(count(1,true),1)
        for slot in 0..<3 {
            XCTAssertEqual(DreamAtmosphere.weight(density:0,slot:slot),0)
            XCTAssertNotEqual(DreamAtmosphere.offset(slot:slot),0)
        }
    }
}
