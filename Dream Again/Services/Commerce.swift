import Foundation
import Combine
import StoreKit
import UIKit

@MainActor final class BalloonStore: ObservableObject {
    @Published var products:[Product]=[]
    @Published var status="Purchases unavailable until products load."
    let store:ProfileStore
    var observer:Task<Void,Never>?
    static let quantities=["com.example.dreamagain.balloons.500":500,"com.example.dreamagain.balloons.1500":1500,"com.example.dreamagain.balloons.4000":4000]
    static var enabled:Bool {
        #if DEBUG
        true
        #else
        false
        #endif
    }
    init(store:ProfileStore) {
        self.store=store
        if Self.enabled { observer=Task { [weak self] in for await result in Transaction.updates { guard let self else { return }; await self.deliver(result) } } }
    }
    func load() async {
        guard Self.enabled else { status="Balloon packs are unavailable in this offline build."; return }
        do { products=try await Product.products(for:Array(Self.quantities.keys).sorted()); status=products.isEmpty ? "No products available. Use the local StoreKit scheme in Xcode." : "Balloons buy cosmetics only." } catch { status=error.localizedDescription }
    }
    func purchase(_ product:Product) async {
        do { switch try await product.purchase() {
        case .success(let result): await deliver(result)
        case .pending: status="Purchase pending. Balloons arrive after approval."
        case .userCancelled: status="Purchase cancelled. No balloons were charged here."
        @unknown default: status="Purchase status unavailable."
        } } catch { status=error.localizedDescription }
    }
    private func deliver(_ result:VerificationResult<Transaction>) async {
        guard case .verified(let transaction)=result, let amount=Self.quantities[transaction.productID] else { status="Purchase could not be verified. No balloons granted."; return }
        do {
            try store.transaction { profile in
                if transaction.revocationDate != nil { profile.revoke(String(transaction.id)) }
                else { profile.credit(id:"purchase:\(transaction.id)",amount:amount,source:"purchase") }
            }
            await transaction.finish(); status="Purchase recorded."
        } catch { status="Could not save purchase. It will be retried: \(error.localizedDescription)" }
    }
    func reconcile() async {
        do { try await AppStore.sync(); status="Store reconciliation requested. Consumable wallet balances remain local to this device." } catch { status=error.localizedDescription }
    }
}
public enum RewardOutcome { case earned(String), dismissed, unavailable, failed(String) }
@MainActor protocol RewardedContinueProvider { var available:Bool { get }; var label:String { get }; func present() async -> RewardOutcome }
@MainActor struct DisabledRewardProvider:RewardedContinueProvider {
    var available:Bool { false }; var label:String { "Rewarded continue unavailable" }; func present() async -> RewardOutcome { .unavailable }
}
#if DEBUG
@MainActor struct MockRewardProvider:RewardedContinueProvider {
    var outcome:RewardOutcome
    var available:Bool { true }; var label:String { "Developer test reward" }
    func present() async -> RewardOutcome { outcome }
}
#endif
/// Host-owned optional provider seam. Consent is checked before loading/presenting;
/// only the SDK's earned-reward callback may invoke `earned`.
@MainActor final class LiveRewardProvider:RewardedContinueProvider {
    let canRequestAds:()->Bool
    let presentSDK: (@escaping (RewardOutcome)->Void)->Void
    var available:Bool { canRequestAds() }
    var label:String { "Continue this dream — watch an ad" }
    init(canRequestAds:@escaping ()->Bool,presentSDK:@escaping (@escaping (RewardOutcome)->Void)->Void) { self.canRequestAds=canRequestAds; self.presentSDK=presentSDK }
    func present() async -> RewardOutcome {
        guard available else { return .unavailable }
        return await withCheckedContinuation { continuation in
            var delivered=false
            presentSDK { outcome in guard !delivered else { return }; delivered=true; continuation.resume(returning:outcome) }
        }
    }
}
