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
    func testNineSkiesAndMirrorChange() {
        XCTAssertEqual(DreamCollageKit.assets.count,55)
        XCTAssertEqual(DreamCollageKit.assets.filter(\.isPlate).count,9)
        let id=DreamIdentity.current(seed:42)
        for section in 0..<50 {
            XCTAssertNotEqual(DreamCollageComposition.plate(identity:id,section:section),DreamCollageComposition.plate(identity:id,section:section,transition:1))
        }
    }
}
