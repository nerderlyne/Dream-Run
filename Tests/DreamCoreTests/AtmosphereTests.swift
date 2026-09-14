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
                    XCTAssertTrue((0.15...0.3).contains(p.opacity))
                    XCTAssertFalse([AssetID.horse,.moon,.chair,.rabbit,.pig].contains(p.representation.concept!))
                }
                XCTAssertEqual(event,DreamScaleComposition.plan(identity:identity,distance:distance))
            }
        }
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
