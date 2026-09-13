# Official implementation references

Checked: **13 September 2026**. The specification's feature decisions are design choices; these sources support the platform/service details, not commercial predictions or a guarantee of engine performance. The implementation must verify availability and signatures against its installed stable SDK. Some Apple API pages exposed only a title/summary in web extraction, so a link alone is not evidence that a particular method signature has been tested.

## S01 — Non-AR RealityKit and a controllable perspective camera
- Apple, `ARView.CameraMode.nonAR`: https://developer.apple.com/documentation/realitykit/arview/cameramode-swift.enum/nonar
- Apple, `PerspectiveCamera`: https://developer.apple.com/documentation/realitykit/perspectivecamera

Supports a fully virtual RealityKit scene and a custom viewpoint. The specified camera framing is original tuning, not an Apple recommendation.

## S02 — Runtime mesh resources
- Apple, `MeshResource`: https://developer.apple.com/documentation/realitykit/meshresource
- Apple, `MeshDescriptor`: https://developer.apple.com/documentation/realitykit/meshdescriptor

Implementation references for procedural geometry. Validate exact generation/material APIs in the actual SDK; do not assume special rendering effects are available just because a mood reference depicts them.

## S03 — Device-motion input
- Apple, Getting processed device-motion data: https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data
- Apple, `CMMotionManager`: https://developer.apple.com/documentation/coremotion/cmmotionmanager

Supports reading processed device motion. The tilt calibration, sensitivity and filtering values are game-design defaults.

## S04 — App review, digital purchases, currency and metadata
- Apple, App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

Relevant sections include 2.1/2.3 (complete functionality and accurate metadata), 3.1.1 (in-app purchase and non-expiring purchased currency) and 5.1 (privacy). Explain unusual game behaviour to review even when it remains mysterious to players. Recheck the live requirements before submission; this pack is not legal advice or an approval guarantee.

## S05 — Purchase transaction lifecycle and durable grants
- Apple, `Transaction`: https://developer.apple.com/documentation/storekit/transaction
- Apple, `Transaction.updates`: https://developer.apple.com/documentation/storekit/transaction/updates
- Apple, Persisting a purchase: https://developer.apple.com/documentation/storekit/persisting-a-purchase

References for verified transaction handling and finishing after delivery. The app still owns its wallet/spending ledger; do not promise automatic restoration of a consumable's remaining balance.

## S06 — Local purchase testing
- Apple, Setting up StoreKit Testing in Xcode: https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode

Use local configuration and test purchase states before configuring live products.

## S07 — Tracking/data-use requirements
- Apple, User Privacy and Data Use: https://developer.apple.com/app-store/user-privacy-and-data-use/

Tracking permission is distinct from ad-provider consent. Ordinary play must not be conditional on accepting tracking.

## S08 — Optional platform achievements and leaderboards
- Apple, GameKit: https://developer.apple.com/documentation/gamekit

GameKit is an optional service integration; local records do not automatically become authenticated global rankings.

## S09 — Native audio engine
- Apple, `AVAudioEngine`: https://developer.apple.com/documentation/avfaudio/avaudioengine

Reference for the audio service. The adaptive layers and sound design are original specification choices.

## S10 — Rewarded advertisement flow
- Google, iOS rewarded ads: https://developers.google.com/admob/ios/rewarded

Reference for opt-in presentation, earned-reward callback, lifecycle handling and use of test ad units. Grant the continue from the reward callback, not merely from dismissal.

## S11 — Ad privacy gating
- Google, Set up UMP SDK for iOS: https://developers.google.com/admob/ios/privacy

Reference for consent refresh/forms, privacy options and whether ads may be requested. Actual messages and identifiers require an owner-configured account.

## S12 — Codex project instructions
- OpenAI, Custom instructions with AGENTS.md: https://developers.openai.com/codex/guides/agents-md

The official entry redirected to https://learn.chatgpt.com/docs/agent-configuration/agents-md when checked. It describes instruction-file discovery and a default aggregate project-instruction limit of 32 KiB. This pack therefore uses a short root instruction file that explicitly points to the longer specification rather than placing the entire spec inside AGENTS.md.
