import XCTest
@testable import DreamCore

final class TrackArtTests:XCTestCase {
    func testSurfaceVarietyIsStableAndUsuallyQuiet() {
        let id=DreamIdentity.current(seed:42)
        let patterns=(0..<1000).map {TrackArt.pattern(identity:id,distance:Double($0)*192)}
        XCTAssertEqual(Set(patterns),Set(TrackPattern.allCases))
        XCTAssertGreaterThan(patterns.filter{$0 == .solid}.count,450)
        for i in 0..<100 {XCTAssertEqual(TrackArt.pattern(identity:id,distance:Double(i)*192),TrackArt.pattern(identity:id,distance:Double(i)*192+191))}
    }
    func testCuratedSkiesAndMirrorChange() {
        XCTAssertEqual(DreamCollageKit.assets.count,54+DreamPlateLibrary.assets.count)
        XCTAssertEqual(DreamCollageKit.assets.filter(\.isPlate).count,DreamPlateLibrary.assets.count)
        let id=DreamIdentity.current(seed:42)
        for section in 0..<50 {
            XCTAssertNotEqual(DreamCollageComposition.plate(identity:id,section:section),DreamCollageComposition.plate(identity:id,section:section,transition:1))
        }
    }
    func testPlateDeckVisitsEveryPhotoWithoutRepeatingAtBoundaries() {
        let count=DreamPlateLibrary.assets.count
        XCTAssertGreaterThan(count,0)
        for seed:UInt64 in 0..<12 {
            let identity=DreamIdentity.current(seed:seed)
            let draws=(0..<(count*3)).map{DreamCollageComposition.plate(identity:identity,section:$0).id}
            for cycle in 0..<3 {XCTAssertEqual(Set(draws[(cycle*count)..<((cycle+1)*count)]).count,count)}
            for i in 1..<draws.count {XCTAssertNotEqual(draws[i],draws[i-1])}
        }
    }

}
