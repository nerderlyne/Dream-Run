import Foundation

public struct SplitMix64: Codable, Sendable {
    public var state: UInt64
    public init(_ state: UInt64) { self.state = state }
    public mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
    public mutating func below(_ bound: UInt64) -> UInt64 {
        precondition(bound > 0)
        let threshold = (0 &- bound) % bound
        while true { let n = next(); if n >= threshold { return n % bound } }
    }
    public static func fnv(_ string: String) -> UInt64 {
        string.utf8.reduce(14695981039346656037) { ($0 ^ UInt64($1)) &* 1099511628211 }
    }
}
public enum DreamError: Error, LocalizedError {
    case invalidCode, unsupportedVersion, insufficientFunds, unavailable, corruptStore, invalidItem
    public var errorDescription: String? {
        switch self {
        case .invalidCode: "This dream code is damaged or malformed. Check the complete code."
        case .unsupportedVersion: "This dream needs a different version of Dream Again. Your saved dream is preserved."
        case .insufficientFunds: "You need more balloons for this cosmetic."
        case .unavailable: "This service is unavailable. Offline dreams are still available."
        case .corruptStore: "The saved profile could not be validated. Your data has been preserved; retry before playing."
        case .invalidItem: "This item is already owned or can only be earned through an achievement."
        }
    }
}
public struct DreamIdentity: Codable, Hashable, Sendable {
    public var generatorVersion: UInt16 = 1
    public var rulesVersion: UInt16 = 1
    public var contentVersion: UInt16 = 1
    public var seed: UInt64
    public init(seed: UInt64) { self.seed = seed }
    public static func current(seed:UInt64) -> Self {Self(seed:seed)}
    public var supported: Bool { generatorVersion == 1 && rulesVersion == 1 && contentVersion == 1 }
    public func stream(_ domain: String, _ index: Int) -> SplitMix64 {
        SplitMix64(SplitMix64.fnv("DR1|G\(generatorVersion)|R\(rulesVersion)|C\(contentVersion)|\(String(format: "%016llX", seed))|\(domain)|\(index)"))
    }
    private static let alphabet = Array("0123456789ABCDEFGHJKMNPQRSTVWXYZ")
    static func base32(_ n: UInt64, count: Int) -> String {
        var n = n, chars = [Character](repeating: "0", count: count)
        for i in (0..<count).reversed() { chars[i] = alphabet[Int(n & 31)]; n >>= 5 }
        return String(chars)
    }
    public static func crc(_ text: String) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in text.utf8 { crc ^= UInt32(byte); for _ in 0..<8 { crc = (crc >> 1) ^ ((crc & 1) == 1 ? 0xEDB88320 : 0) } }
        return crc ^ 0xFFFFFFFF
    }
    public var code: String {
        let prefix = "DR1-G\(generatorVersion)-R\(rulesVersion)-C\(contentVersion)-\(Self.base32(seed, count: 13))"
        return prefix + "-" + Self.base32(UInt64(Self.crc(prefix) & 0xFFFFF), count: 4)
    }
    public static func parse(_ text: String, requireSupported: Bool = true) throws -> Self {
        guard text.utf8.count <= 128 else { throw DreamError.invalidCode }
        let p = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased().split(separator: "-", omittingEmptySubsequences: false).map(String.init)
        guard p.count == 6, p[0] == "DR1" else { throw DreamError.invalidCode }
        func version(_ value: String, _ prefix: Character) throws -> UInt16 {
            guard value.first == prefix, value.count > 1, value.dropFirst().allSatisfy({ $0.isASCII && $0.isNumber }), let n = UInt16(value.dropFirst()), n > 0, String(n) == String(value.dropFirst()) else { throw DreamError.invalidCode }; return n
        }
        func normalize(_ s: String) -> String { s.replacingOccurrences(of: "O", with: "0").replacingOccurrences(of: "I", with: "1").replacingOccurrences(of: "L", with: "1") }
        func decode(_ s: String, _ count: Int) throws -> UInt64 {
            guard s.count == count else { throw DreamError.invalidCode }; var n: UInt64 = 0
            for c in s { guard let i = alphabet.firstIndex(of: c), n <= (UInt64.max - UInt64(i)) / 32 else { throw DreamError.invalidCode }; n = n * 32 + UInt64(i) }; return n
        }
        var id = DreamIdentity(seed: try decode(normalize(p[4]), 13))
        id.generatorVersion = try version(p[1], "G"); id.rulesVersion = try version(p[2], "R"); id.contentVersion = try version(p[3], "C")
        let canonical = id.code.split(separator: "-").last!
        guard normalize(p[5]) == canonical else { throw DreamError.invalidCode }
        if requireSupported && !id.supported { throw DreamError.unsupportedVersion }; return id
    }
    enum CodingKeys: String, CodingKey { case generatorVersion, rulesVersion, contentVersion, seed }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        generatorVersion = try c.decode(UInt16.self, forKey: .generatorVersion); rulesVersion = try c.decode(UInt16.self, forKey: .rulesVersion); contentVersion = try c.decode(UInt16.self, forKey: .contentVersion)
        guard let n = UInt64(try c.decode(String.self, forKey: .seed)) else { throw DreamError.invalidCode }; seed = n
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self); try c.encode(generatorVersion, forKey: .generatorVersion); try c.encode(rulesVersion, forKey: .rulesVersion); try c.encode(contentVersion, forKey: .contentVersion); try c.encode(String(seed), forKey: .seed)
    }
}
public struct DreamFile: Codable, Sendable {
    public var format = 1
    public var dreamID: String
    public init(_ id: DreamIdentity) { dreamID = id.code }
    public static func read(_ data: Data) throws -> DreamIdentity {
        guard data.count <= 32768, let object = try JSONSerialization.jsonObject(with: data) as? [String: Any], Set(object.keys) == Set(["format", "dreamID"]) else { throw DreamError.invalidCode }
        let file = try JSONDecoder().decode(Self.self, from: data)
        guard file.format == 1 else { throw DreamError.unsupportedVersion }; return try .parse(file.dreamID)
    }
}
public struct PigDecision: Codable, Equatable, Sendable {
    public let ordinal: Int
    public let cloverDraw: UInt64
    public let continued: Bool
    public var present: Bool { true }
    public var clover: Bool { cloverDraw < (continued ? 1 : 2) }
    public init(identity: DreamIdentity, ordinal: Int, continued: Bool) {
        var c = identity.stream("pigClover", ordinal)
        self.ordinal = ordinal; cloverDraw = c.below(6); self.continued = continued
    }
    public init(ordinal: Int, clover: UInt64, continued: Bool) { self.ordinal = ordinal; cloverDraw = clover; self.continued = continued }
    public static func probabilityAtLeastThree(_ probabilities: [Double]) -> Double {
        var distribution = [1.0, 0, 0, 0]
        for p in probabilities { distribution = [distribution[0]*(1-p), distribution[1]*(1-p)+distribution[0]*p, distribution[2]*(1-p)+distribution[1]*p, distribution[3]+distribution[2]*p] }
        return distribution[3]
    }
}
