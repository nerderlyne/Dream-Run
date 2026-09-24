/// Small resource cache with incremental eviction. No full-cache purge at capacity.
/// The owner supplies synchronization (render resources are owned by MainActor).
public struct BoundedLRUCache<Key: Hashable, Value> {
    public let capacity: Int
    private var values: [Key: Value] = [:]
    private var recency: [Key] = []
    public var count: Int { values.count }

    public init(capacity: Int) {
        precondition(capacity > 0)
        self.capacity = capacity
        recency.reserveCapacity(capacity)
    }

    public mutating func value(forKey key: Key) -> Value? {
        guard let value = values[key] else { return nil }
        touch(key)
        return value
    }

    /// Returns the one evicted key so parallel diagnostic metadata can be retired.
    @discardableResult public mutating func insert(_ value: Value, forKey key: Key) -> Key? {
        var evicted: Key?
        if values[key] == nil && values.count == capacity {
            let oldest = recency.removeFirst()
            values.removeValue(forKey: oldest)
            evicted = oldest
        }
        values[key] = value
        touch(key)
        return evicted
    }

    private mutating func touch(_ key: Key) {
        if let index = recency.firstIndex(of: key) { recency.remove(at: index) }
        recency.append(key)
    }
}
