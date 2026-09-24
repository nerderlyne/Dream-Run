// Live inventory remains disabled until the owner provisions consent and authorizes serving.
enum DreamAdConfiguration {
    static let liveAdsEnabled = false
    static let rewardedUnitID = "ca-app-pub-8817570052706911/7963477779"
    static let testRewardedUnitID = "ca-app-pub-3940256099942544/1712485313"
}
#if canImport(GoogleMobileAds) && canImport(UserMessagingPlatform)
import GoogleMobileAds
import UserMessagingPlatform
import UIKit

@MainActor final class GoogleRewardedProvider:NSObject,RewardedContinueProvider,FullScreenContentDelegate {
    private var ad:RewardedAd?
    private var continuation:CheckedContinuation<RewardOutcome,Never>?
    private var earnedEvent:String?
    private var rewardSaveFailed=false
    private let unitID:String
    private let currentRun:()->RunState
    private let persistEarned:(String,RunState)->Bool
    private let availabilityChanged:()->Void
    var label:String { "Continue this dream — watch an ad" }
    var available:Bool { ad != nil && ConsentInformation.shared.canRequestAds }
    var privacyOptionsRequired:Bool { ConsentInformation.shared.privacyOptionsRequirementStatus == .required }
    init(unitID:String,currentRun:@escaping ()->RunState,persistEarned:@escaping (String,RunState)->Bool,availabilityChanged:@escaping ()->Void = {}) {
        self.unitID=unitID; self.currentRun=currentRun; self.persistEarned=persistEarned; self.availabilityChanged=availabilityChanged
    }
    func prepare() async throws {
        try await withCheckedThrowingContinuation { (c:CheckedContinuation<Void,Error>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with:RequestParameters()) { error in
                if let error { c.resume(throwing:error) } else { c.resume() }
            }
        }
        try await ConsentForm.loadAndPresentIfRequired(from:nil)
        guard ConsentInformation.shared.canRequestAds else { return }
        await MobileAds.shared.start()
        try await loadAd()
    }
    private func loadAd() async throws {
        guard ConsentInformation.shared.canRequestAds else { return }
        ad=try await RewardedAd.load(with:unitID,request:Request())
        ad?.fullScreenContentDelegate=self
        availabilityChanged()
    }
    func privacyOptions() async throws { try await ConsentForm.presentPrivacyOptionsForm(from:nil) }
    func present() async -> RewardOutcome {
        guard available, let ad, continuation == nil else { return .unavailable }
        // One identifier per presentation, persisted at the reward callback, never at dismissal.
        let event="google:\(UUID().uuidString)"; let offeredRun=currentRun(); earnedEvent=nil; rewardSaveFailed=false
        return await withCheckedContinuation { c in
            continuation=c
            ad.present(from:nil) { [weak self] in
                guard let self, self.earnedEvent == nil else { return }
                if self.persistEarned(event,offeredRun) { self.earnedEvent=event }
                else { self.rewardSaveFailed=true }
            }
        }
    }
    func adDidDismissFullScreenContent(_ ad:FullScreenPresentingAd) { complete(earnedEvent.map(RewardOutcome.earned) ?? (rewardSaveFailed ? .failed("Could not save the ad reward. Please retry.") : .dismissed)) }
    func ad(_ ad:FullScreenPresentingAd,didFailToPresentFullScreenContentWithError error:Error) { complete(.failed(error.localizedDescription)) }
    private func complete(_ outcome:RewardOutcome) {
        ad=nil; availabilityChanged()
        let pending=continuation; continuation=nil; pending?.resume(returning:outcome)
        Task { try? await loadAd() }
    }
}
#endif
