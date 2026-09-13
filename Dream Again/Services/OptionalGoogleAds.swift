// Optional, owner-provisioned integration. Not linked or enabled in the offline build.
// API references: docs/OWNER_SETUP.md. Validate against the pinned SDK before enabling.
#if canImport(GoogleMobileAds) && canImport(UserMessagingPlatform)
import GoogleMobileAds
import UserMessagingPlatform
import UIKit

@MainActor final class GoogleRewardedProvider:NSObject,RewardedContinueProvider,FullScreenContentDelegate {
    private var ad:RewardedAd?
    private var continuation:CheckedContinuation<RewardOutcome,Never>?
    private var earnedEvent:String?
    private let unitID:String
    private let persistEarned:(String)->Void
    var label:String { "Continue this dream — watch an ad" }
    var available:Bool { ad != nil && ConsentInformation.shared.canRequestAds }
    var privacyOptionsRequired:Bool { ConsentInformation.shared.privacyOptionsRequirementStatus == .required }
    init(unitID:String,persistEarned:@escaping (String)->Void) { self.unitID=unitID; self.persistEarned=persistEarned }
    func prepare() async throws {
        try await withCheckedThrowingContinuation { (c:CheckedContinuation<Void,Error>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with:RequestParameters()) { error in
                if let error { c.resume(throwing:error) } else { c.resume() }
            }
        }
        try await ConsentForm.loadAndPresentIfRequired(from:nil)
        guard ConsentInformation.shared.canRequestAds else { return }
        await MobileAds.shared.start()
        ad=try await RewardedAd.load(with:unitID,request:Request()); ad?.fullScreenContentDelegate=self
    }
    func privacyOptions() async throws { try await ConsentForm.presentPrivacyOptionsForm(from:nil) }
    func present() async -> RewardOutcome {
        guard available, let ad, continuation == nil else { return .unavailable }
        // One identifier per presentation, persisted at the reward callback, never at dismissal.
        let event="google:\(UUID().uuidString)"; earnedEvent=nil
        return await withCheckedContinuation { c in
            continuation=c
            ad.present(from:nil) { [weak self] in
                guard let self, self.earnedEvent == nil else { return }
                self.earnedEvent=event; self.persistEarned(event)
            }
        }
    }
    func adDidDismissFullScreenContent(_ ad:FullScreenPresentingAd) { complete(earnedEvent.map(RewardOutcome.earned) ?? .dismissed) }
    func ad(_ ad:FullScreenPresentingAd,didFailToPresentFullScreenContentWithError error:Error) { complete(.failed(error.localizedDescription)) }
    private func complete(_ outcome:RewardOutcome) { ad=nil; let pending=continuation; continuation=nil; pending?.resume(returning:outcome) }
}
#endif
