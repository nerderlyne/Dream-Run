import XCTest
@testable import DreamCore

final class ScaleCompositionTests:XCTestCase {
    func testSceneHierarchyHasOnlyOnePossibleLandmark() {
        let identity=DreamIdentity.current(seed:42)
        for event in DreamScaleEvent.allCases {
            let placements=(0..<20).map{DreamCollageComposition.placement(identity:identity,distance:200,slot:$0,scaleEvent:event)}
            let extents=placements.map{$0.height*max(1,$0.representation.aspect)/$0.depth}
            XCTAssertGreaterThanOrEqual(placements.filter{$0.scaleRole == .tiny}.count,12)
            XCTAssertLessThanOrEqual(placements.filter{$0.scaleRole == .monumental || $0.scaleRole == .absurd}.count,1)
            if event == .monumental || event == .absurd {
                XCTAssertGreaterThan(extents[0],extents.dropFirst().max()!*6)
                XCTAssertEqual(placements[0].representation.concept,DreamScaleComposition.plan(identity:identity,distance:200,override:event).concept)
            }
            if event == .miniature {XCTAssertLessThan(extents[0],extents.dropFirst().min()!/2)}
            XCTAssertEqual(placements,(0..<20).map{DreamCollageComposition.placement(identity:identity,distance:200,slot:$0,scaleEvent:event)})
        }
    }
    func testUnderfootLayersAndPartialLandmarkFraming() {
        let identity=DreamIdentity.current(seed:42)
        let context=(1..<20).map{DreamCollageComposition.placement(identity:identity,distance:200,slot:$0,scaleEvent:.absurd)}
        XCTAssertGreaterThanOrEqual(context.filter{$0.elevation<0}.count,6)
        let crown=DreamCollageComposition.placement(identity:identity,distance:200,slot:0,scaleEvent:.absurd,framing:.crownOnly)
        let roots=DreamCollageComposition.placement(identity:identity,distance:200,slot:0,scaleEvent:.absurd,framing:.rootsOnly)
        XCTAssertLessThan(crown.elevation+crown.height/2,0)
        XCTAssertGreaterThan(roots.elevation-roots.height/2,0)
        XCTAssertEqual(crown.height,roots.height)
        XCTAssertTrue(context.allSatisfy{$0.representation.backgroundOnly})
    }
    func testEventFrequencyAndStableSceneSelection() {
        var counts=[DreamScaleEvent:Int]()
        for seed:UInt64 in 0..<100 {
            let identity=DreamIdentity.current(seed:seed)
            for cell in 0..<100 {
                let distance=Double(cell)*768
                let a=DreamScaleComposition.plan(identity:identity,distance:distance)
                XCTAssertEqual(a,DreamScaleComposition.plan(identity:identity,distance:distance+767))
                counts[a.event,default:0] += 1
            }
        }
        XCTAssertTrue((5700...6300).contains(counts[.none,default:0]))
        XCTAssertTrue((1200...1800).contains(counts[.miniature,default:0]))
        XCTAssertTrue((1600...2200).contains(counts[.oversized,default:0]))
        XCTAssertTrue((350...650).contains(counts[.monumental,default:0]))
        XCTAssertTrue((50...160).contains(counts[.absurd,default:0]))
    }
    func testApproachingSceneryFadesBeforeExceedingRoleBudget() {
        for role in [DreamScaleRole.tiny,.ordinary,.oversized,.miniature,.monumental,.absurd] {
            let limit=DreamScaleComposition.ceiling(role)
            XCTAssertEqual(DreamScaleComposition.visibility(extent:limit*0.7,role:role),1)
            XCTAssertGreaterThan(DreamScaleComposition.visibility(extent:limit*0.9,role:role),0)
            XCTAssertEqual(DreamScaleComposition.visibility(extent:limit,role:role),0)
        }
    }
}
