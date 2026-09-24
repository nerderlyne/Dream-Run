import XCTest
@testable import DreamCore

final class ResourceCacheTests: XCTestCase {
    func testEvictionRetainsRecentlyUsedResources() {
        var cache = BoundedLRUCache<String, Int>(capacity: 3)
        cache.insert(1, forKey: "a"); cache.insert(2, forKey: "b"); cache.insert(3, forKey: "c")
        XCTAssertEqual(cache.value(forKey: "a"), 1)
        XCTAssertEqual(cache.insert(4, forKey: "d"), "b")
        XCTAssertEqual(cache.count, 3)
        XCTAssertNil(cache.value(forKey: "b"))
        XCTAssertEqual(cache.value(forKey: "a"), 1)
        XCTAssertEqual(cache.value(forKey: "c"), 3)
        XCTAssertEqual(cache.value(forKey: "d"), 4)
    }

    func testReplacementDoesNotEvictAndLongStreamsStayBounded() {
        var cache = BoundedLRUCache<Int, Int>(capacity: 8)
        for key in 0..<8 { cache.insert(key, forKey: key) }
        XCTAssertNil(cache.insert(100, forKey: 0))
        for key in 8..<10_000 {
            XCTAssertEqual(cache.value(forKey: 0), 100)
            XCTAssertNotEqual(cache.insert(key, forKey: key), 0)
            XCTAssertEqual(cache.count, 8)
        }
    }
}
