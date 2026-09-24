# Owner setup and integration boundaries

The project pins Google Mobile Ads 13.9.0 and UMP 3.1.0 using the same package versions as Align&Reveal. Live Google ads and Release sales remain disabled. `Dream Again/Configuration/Services.example.json` records the supplied AdMob IDs and disabled state; it is a preflight input, not a switch that silently enables services.

## Signing and devices

The original Xcode team and bundle settings were retained, not provisioned or changed into invented credentials. Choose your owned identifier/team in Signing & Capabilities. Test a small phone, tall phone and iPad portrait, motion at multiple orientations, background/lock/call interruptions and headphones. Measure frame pacing and thermal behavior on a physical device. A build or headless oracle cannot certify these.

## StoreKit

The shared scheme's Run action references `Dream Again/Resources/DreamAgain.storekit`. Its 500/1,500/4,000 balloon products and dollar amounts are **local test fixtures**. Open Product → Scheme → Edit Scheme → Run → Options to confirm the file is selected. Use Xcode's transaction manager to test purchase approval, pending Ask to Buy, cancellation, duplicates, interruption and revocation. Only `Product.displayPrice` is shown in the purchase UI.

`BalloonStore` observes `Transaction.updates`; delivery accepts only verified, whitelisted transactions. It persists `purchase:<transaction.id>` before `finish()`. Refunds remove only the unspent portion of that purchased lot. Cosmetic debits consume earned/bonus lots before purchased lots, with allocation entries. No purchase path reaches pig or difficulty code.

Before enabling production sales:

1. Create the three consumables in your App Store Connect app and accept applicable agreements. No products were created by this implementation.
2. Replace example IDs in both the immutable product map and catalogue, update your preflight configuration, then deliberately change the Release enable flag in `BalloonStore`. Attach no local StoreKit file when testing real sandbox products.
3. Test interrupted deliveries, account/sandbox behavior and refund/revocation handling on the pinned SDK. Current local StoreKit UI flows have **not** been executed in this environment.
4. Supply valid support/privacy URLs and communicate local consumable-wallet recovery limitations, or implement/test a synchronized ledger before selling. The backup-transport protocol is not a cloud account or a finished cross-device wallet.

## Optional rewarded ads

`DisabledRewardProvider` is the default. Debug mocks are nonrewarding Lab attempts only. `OptionalGoogleAds.swift` supplies `GoogleRewardedProvider` with the pinned Google packages. The AdMob app ID is in `Configuration/Info.plist`; the rewarded unit ID is in `DreamAdConfiguration` and the example service file. The Debug Lab offers Google's test rewarded unit; it never grants a production continue. `DreamAdConfiguration.liveAdsEnabled` must remain false until consent setup and live serving are explicitly authorized.

The adapter follows the documented load/present/earned callback and full-screen delegate lifecycle. Consent is refreshed and required forms are shown before requesting ads. The owner must expose the privacy-options action when the adapter reports it required. Reward callbacks persist an entitlement immediately; dismissal only decides whether the result returns as earned or unearned. The host captures the offered run and uses `Profile.grantContinue` for it, then consumes it after dismissal. A pending unconsumed entitlement is recovered without another ad.

Before enabling live ads, configure AdMob Privacy & messaging consent using `https://dreamlooper.shivanshi.dev/privacy`, publish the policy at that URL, finish the privacy/data disclosures, and authorize live inventory. Settings already exposes UMP privacy options when required. Tracking permission and consent are separate requirements, and refusal must not block dreams. Before shipping, test no-fill, presentation failure, dismissal without reward, late callbacks, duplicates and interruption with the actual pinned SDK.

API references checked during implementation:

- [Google rewarded ads](https://developers.google.com/admob/ios/rewarded)
- [Google UMP consent setup](https://developers.google.com/admob/ios/privacy)

## Optional Game Center, links and cloud

`GameCenterPublisher` accepts actual separate unbroken/continued leaderboard IDs. Authentication is explicit. It filters out non-Fresh modes and never displays fabricated global ranks. No instance is created in the offline app. Configure your service IDs, entitlements, authentication UI and separate category submission tests before wiring it.

Custom scheme and `.dream` document import are registered in `Configuration/Info.plist`. For Universal Links, provide an owned HTTPS domain, associated-domain entitlement and apple-app-site-association file, then test all supported import versions. No functioning web domain is claimed.

`ProfileBackupTransport` is an extension seam. A real synchronized wallet requires transaction-ID/lot reconciliation and conflict handling, not naïve replacement or replaying purchases as new grants. No cloud credentials or account were created.

## Data, art and release

Current mechanics load and validate against the bundled data contract. This unreleased build has one G1/R1/C1 implementation; obsolete prerelease rule branches and saves are unsupported. The active-time speed curve runs from 12.25 to 22 m/s with ±0.9 m steering. The current development store is `profile.json`; discarded development stores are not migrated. All geometry, the procedural icon and synthesized tones are original code-generated assets. Six supplied mood images remain only in `references/` and are not bundled.

Run `python3 scripts/release_preflight.py [owner-config.json]`. This rejects enabled sales with example product IDs, enabled ads without IDs, non-HTTPS claimed URLs and bundled mood references. It does not replace actual StoreKit/ad/privacy, physical-device or App Store review testing.
