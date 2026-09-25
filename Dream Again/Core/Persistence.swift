import Foundation
public struct CosmeticDefinition: Codable, Identifiable, Sendable {
    public var id: String; public var name: String; public var slot: String; public var balloon_price: Int?; public var required_achievement: String?
}
public struct AchievementDefinition: Codable, Identifiable, Sendable {
    public var id: String; public var name: String; public var description: String; public var eligibility: String; public var hidden_before_unlock: Bool; public var cosmetic_reward: String?
}
public struct AssetDefinition: Codable, Identifiable, Sendable {
    public var number: Int; public var id: String; public var name: String; public var construction: String; public var role: String; public var pivot: String; public var lod0_triangle_target_max: Int
}
public struct PaletteDefinition: Codable, Identifiable, Sendable {
    public var id: String; public var name: String; public var phase: String; public var sky: String; public var fog: String; public var track_light: String; public var track_dark: String; public var accent_a: String; public var accent_b: String
}
public struct WalletLot: Codable, Sendable {
    public var id: String; public var source: String; public var granted: Int; public var remaining: Int; public var revoked = false
}
public struct WalletEntry: Codable, Sendable { public var id: String; public var delta: Int; public var allocations: [String:Int] }
public struct Bookmark: Codable, Identifiable, Sendable {
    public var id = UUID(); public var dreamID: String; public var title: String; public var favourite = false; public var created = Date(); public var ticks: UInt64; public var distance: Double; public var thumbnail: String?
    public init(run: RunState, title: String) { dreamID=run.identity.code; self.title=String(title.prefix(100)); ticks=run.activeTicks; distance=run.distance }
}
public struct ContinueGrant: Codable, Sendable { public var eventID: String; public var runID: UUID; public var consumed = false }
public struct Settings: Codable, Sendable {
    public var sensitivity = 1.0
    public var deadzone = 1.5
    public var reducedMotion = false
    public var reducedFlashes = true
    public var music = true
    public var effects = true
    public var haptics = true
    public var lowPower = false
    /// Nil means the player has not customized sound; theta always requires opting in.
    public var dreamAudio: DreamAudioPreferences?
    public var musicLevel: Double {
        get { dreamAudio?.musicLevel ?? 0.75 }
        set { var value=dreamAudio ?? .init(); value.musicLevel=newValue; dreamAudio=value }
    }
    public var effectsLevel: Double {
        get { dreamAudio?.effectsLevel ?? 0.7 }
        set { var value=dreamAudio ?? .init(); value.effectsLevel=newValue; dreamAudio=value }
    }
    public var thetaEnabled: Bool {
        get { dreamAudio?.thetaEnabled ?? false }
        set { var value=dreamAudio ?? .init(); value.thetaEnabled=newValue; dreamAudio=value }
    }
    public var thetaLevel: Double {
        get { dreamAudio?.thetaLevel ?? 0.35 }
        set { var value=dreamAudio ?? .init(); value.thetaLevel=newValue; dreamAudio=value }
    }
    public init() {}
}
public struct Profile: Codable, Sendable {
    public var schema = 1
    public var lots: [WalletLot] = []
    public var ledger: [WalletEntry] = []
    public var owned: Set<String> = ["bare_head", "bare_top", "plain_ribbon", "plain_bottom", "straw_skirt"]
    public var equipped: [String:String] = ["hat":"bare_head", "top":"bare_top", "bottom":"plain_bottom"]
    public var achievements: Set<String> = []
    public var settled: [String:Int] = [:]
    public var records: [String:UInt64] = [:]
    public var bookmarks: [Bookmark] = []
    public var grants: [ContinueGrant] = []
    public var snapshot: RunState?
    public var lastResult: RunState?
    public var reviewEligibleRunIDs: Set<UUID> = []
    public var reviewLastRequestRunCount = 0
    public var settings = Settings()
    public var balance: Int { lots.reduce(0) { $0+$1.remaining } }
    public init() {}
    public mutating func credit(id: String, amount: Int, source: String) {
        guard amount > 0, !lots.contains(where:{$0.id == id}) else { return }
        lots.append(WalletLot(id:id,source:source,granted:amount,remaining:amount)); ledger.append(WalletEntry(id:id,delta:amount,allocations:[:]))
    }
    public mutating func buy(_ item: CosmeticDefinition) throws {
        guard let price=item.balloon_price, price >= 0, item.required_achievement == nil, !owned.contains(item.id) else { throw DreamError.invalidItem }
        guard balance >= price else { throw DreamError.insufficientFunds }
        var remaining=price, allocations: [String:Int]=[:]
        let indices=lots.indices.sorted { a,b in
            let ap=lots[a].source == "purchase", bp=lots[b].source == "purchase"
            return ap == bp ? a < b : !ap
        }
        for i in indices where remaining > 0 { let amount=min(remaining,lots[i].remaining); lots[i].remaining -= amount; remaining -= amount; if amount > 0 { allocations[lots[i].id]=amount } }
        owned.insert(item.id); ledger.append(WalletEntry(id:"cosmetic:\(item.id)",delta:-price,allocations:allocations))
    }
    public mutating func revoke(_ transaction: String) {
        guard let index=lots.firstIndex(where:{$0.id == "purchase:\(transaction)"}), !lots[index].revoked else { return }
        let delta=lots[index].remaining; lots[index].remaining=0; lots[index].revoked=true
        ledger.append(WalletEntry(id:"refund:\(transaction)",delta:-delta,allocations:[lots[index].id:delta]))
    }
    public mutating func settle(_ run: RunState, finished: Bool, catalogue: [AchievementDefinition]) {
        guard run.mode.earns else { return }
        if finished && run.mode == .fresh {
            reviewEligibleRunIDs.insert(run.id)
        }
        let key=run.id.uuidString, previous=settled[key,default:0], delta=max(0,run.balloons-previous)
        if delta > 0 { credit(id:"run:\(key):settlement:\(run.balloons)",amount:delta,source:"earned"); settled[key]=run.balloons }
        var unlocks: Set<String> = []
        if finished { unlocks.insert("first_dream") }
        if run.mirrorCount > 0 { unlocks.insert("through_the_glass") }
        if run.dropCount > 0 { unlocks.insert("another_way_down") }
        if run.mode == .fresh {
            if !run.pigs.isEmpty { unlocks.insert("lucky_pig") }
            if finished && run.pigs.count == 3 { unlocks.insert("lucky_dream"); if run.unbroken { unlocks.insert("lucky_dream_unbroken") } }
            let clean=run.firstWakingTicks ?? (run.unbroken ? run.activeTicks : 0)
            records["unbroken"]=max(records["unbroken",default:0],clean)
            if run.continueCount > 0 { records["continued"]=max(records["continued",default:0],run.activeTicks) }
            if clean >= 18000 { unlocks.insert("five_minutes") }; if clean >= 108000 { unlocks.insert("long_dream") }; if clean >= 216000 { unlocks.insert("very_long_dream") }
            if clean >= 648000 { unlocks.insert("still_dreaming") }
            if run.unbroken && run.escapedVoid { unlocks.insert("empty_dream") }
        } else if run.mode == .revisit { records[run.identity.code]=max(records[run.identity.code,default:0],run.activeTicks) }
        for id in unlocks { unlock(id,catalogue:catalogue) }
        if finished { lastResult=run }
    }
    public mutating func claimReviewRequest() -> Bool {
        let completed=reviewEligibleRunIDs.count
        guard completed > reviewLastRequestRunCount, Self.isPrime(completed) else { return false }
        reviewLastRequestRunCount=completed
        return true
    }
    private static func isPrime(_ number:Int) -> Bool {
        guard number >= 2 else { return false }
        if number == 2 { return true }
        if number.isMultiple(of:2) { return false }
        var divisor=3
        while divisor <= number/divisor {
            if number.isMultiple(of:divisor) { return false }
            divisor += 2
        }
        return true
    }
    public mutating func unlock(_ id: String, catalogue: [AchievementDefinition]) {
        guard !achievements.contains(id) else { return }; achievements.insert(id)
        if id == "first_dream" { credit(id:"bonus:first_dream",amount:100,source:"bonus") }
        if let reward=catalogue.first(where:{$0.id == id})?.cosmetic_reward { owned.insert(reward) }
    }
    public mutating func grantContinue(eventID: String, run: RunState) -> Bool {
        guard [.waking,.finished].contains(run.phase), run.continueCount == 0, run.pigs.count < 3, !grants.contains(where:{$0.runID == run.id || $0.eventID == eventID}) else { return false }
        grants.append(ContinueGrant(eventID:eventID,runID:run.id)); return true
    }
    public mutating func consumeContinue(_ simulation: inout GameSimulation) -> Bool {
        guard let i=grants.firstIndex(where:{$0.runID == simulation.state.id && !$0.consumed}), simulation.continueRun() else { return false }
        grants[i].consumed=true; snapshot=simulation.state; return true
    }
}
public enum ProfileWriteError:Error,LocalizedError,Sendable {
    case backlogFull
    public var errorDescription:String? {"Saving is taking too long. Your dream is paused while earlier saves finish."}
}
/// A serialized copy-on-write transaction. The envelope, including wallet and snapshot,
/// is replaced atomically; in-memory state only changes after a successful durable write.
public final class ProfileStore: @unchecked Sendable {
    private let writer=DispatchQueue(label:"dream.profile-writer",qos:.utility)
    // Readers only copy the last durable value; they never wait for encoding/I/O.
    private let valueLock=NSLock()
    private let pendingLock=NSLock()
    private var pendingWrites=0
    public let url: URL
    private var value: Profile
    public private(set) var recoveredBackup = false
    struct Envelope: Codable { var checksum: UInt64; var payload: Data }
    public init(url: URL) throws {
        self.url=url
        try FileManager.default.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
        if FileManager.default.fileExists(atPath:url.path) {
            do { value=try Self.read(url) }
            catch {
                let quarantine=url.appendingPathExtension("corrupt-\(UUID().uuidString)")
                try FileManager.default.copyItem(at:url,to:quarantine)
                let backup=url.appendingPathExtension("backup")
                guard let profile=try? Self.read(backup) else { throw DreamError.corruptStore }
                value=profile; recoveredBackup=true
            }
        } else { value=Profile() }
    }
    private static func read(_ url: URL) throws -> Profile {
        let data=try Data(contentsOf:url)
        guard data.count < 32*1024*1024 else { throw DreamError.corruptStore }
        let envelope=try JSONDecoder().decode(Envelope.self,from:data)
        guard SplitMix64.fnv(envelope.payload.base64EncodedString()) == envelope.checksum else { throw DreamError.corruptStore }
        let p=try JSONDecoder().decode(Profile.self,from:envelope.payload)
        guard p.schema == 1, p.lots.allSatisfy({$0.remaining >= 0 && $0.remaining <= $0.granted}), Set(p.lots.map(\.id)).count == p.lots.count else { throw DreamError.corruptStore }
        if let snapshot=p.snapshot { _ = try GameSimulation(snapshot:snapshot) }; return p
    }
    private static func encode(_ p: Profile) throws -> Data {
        let encoder=JSONEncoder(); encoder.outputFormatting=[.sortedKeys]
        let payload=try encoder.encode(p)
        return try encoder.encode(Envelope(checksum:SplitMix64.fnv(payload.base64EncodedString()),payload:payload))
    }
    public var profile: Profile { valueLock.lock(); defer { valueLock.unlock() }; return value }
    public func transaction(_ body: (inout Profile) throws -> Void) throws {
        // Synchronous lifecycle/commerce transactions drain earlier checkpoints,
        // so an older queued snapshot can never overwrite a pause or final result.
        try writer.sync {try commit(body)}
    }
    public func transactionAsync(_ body:@escaping @Sendable (inout Profile)throws->Void,
                                 completion:@escaping @Sendable (Result<Void,Error>)->Void) {
        // Bound retained snapshots even if storage stops making progress. The
        // host pauses on rejection; accepted transactions still finish in order.
        pendingLock.lock()
        guard pendingWrites < 8 else {
            pendingLock.unlock();completion(.failure(ProfileWriteError.backlogFull));return
        }
        pendingWrites += 1
        pendingLock.unlock()
        writer.async { [self] in
            let result=Result {try commit(body)}
            pendingLock.lock();pendingWrites -= 1;pendingLock.unlock()
            completion(result)
        }
    }
    private func commit(_ body:(inout Profile)throws->Void) throws {
        let current=profile
        var next=current; try body(&next)
        let bytes=try Self.encode(next), previous=try Self.encode(current)
        try previous.write(to:url.appendingPathExtension("backup"),options:.atomic)
        try bytes.write(to:url,options:.atomic)
        valueLock.lock();value=next;valueLock.unlock()
    }
}
