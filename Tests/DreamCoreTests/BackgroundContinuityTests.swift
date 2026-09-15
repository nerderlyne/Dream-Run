import XCTest
@testable import DreamCore

final class BackgroundContinuityTests:XCTestCase {
    func testBlackPaletteCannotEraseEarlyReality() {
        for seconds in stride(from:0.0,to:1800,by:7) {
            XCTAssertEqual(DreamCollageComposition.plateVisibility(seconds:seconds,visual:.ordinary,voidWeight:1),1)
            XCTAssertGreaterThan(DreamCollageComposition.density(seconds:seconds,visual:.ordinary,voidWeight:1),0.27)
        }
        XCTAssertGreaterThan(DreamCollageComposition.plateVisibility(seconds:3600,visual:.ordinary,voidWeight:1),0)
        XCTAssertEqual(DreamCollageComposition.plateVisibility(seconds:11050,visual:.deepSparse,voidWeight:1),0)
        XCTAssertEqual(DreamCollageComposition.plateVisibility(seconds:11400,visual:.deepRebuilding,voidWeight:1),1)
    }
    func testBleedIsContinuousAndLingersWithoutDroppingUnderlyingReality() {
        for linger in [false,true] {
            var last:Float=0
            for i in 0...480 {
                let value=DreamCollageComposition.plateBlend(elapsed:Double(i)/10,duration:48,lingering:linger)
                XCTAssertGreaterThanOrEqual(value,last);XCTAssertLessThanOrEqual(value,1)
                XCTAssertLessThan(value-last,0.02);last=value
                // A fully visible base stays underneath the incoming alpha.
                XCTAssertEqual(value+(1-value)*1,1,accuracy:0.00001)
            }
            XCTAssertEqual(last,1,accuracy:0.00001)
        }
        let middle=DreamCollageComposition.plateBlend(elapsed:30,duration:48,lingering:true)
        XCTAssertTrue((0.4...0.7).contains(middle))
    }
}
