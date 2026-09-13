# Dream Again implementation evidence

Implemented native first-playable source, Xcode project, shared scheme, offline flows and independent deterministic core. This report does not certify all acceptance criteria or App Store readiness. See `KNOWN_LIMITATIONS.md` for remaining implementation and verification limits.

## Delivered

- SwiftUI + non-AR RealityKit close-camera runner, continuous touch/calibrated tilt adapters, jump/slide, swept collision, automatic stairs and streamed route.
- Exactly 42 original procedural world families, generated checker route geometry, eight material treatments, twelve palettes, three mesh detail levels, humanoid and catalogue cosmetics.
- Versioned deterministic seeds, golden-vector RNG, certified encounter witnesses and bounded fallback, mirrors, marked drops, exact pig/continue policy, white ending and nonterminal deep evolution.
- Serialized transactional wallet/ownership/settlements, last-good backup, suspend/resume, bookmarks and native share/import, achievements, generated audio/haptics, all menu flows and isolated Debug Lab.
- Real StoreKit adapter with local configuration, honest disabled rewarded ads plus optional SDK bridge, disabled Game Center/cloud integration seams and owner setup guide.

## Actual verification

Host: Apple Silicon macOS. Xcode **26.6 (17F113)**; Apple Swift **6.3.3**, swiftlang-6.3.3.1.3. iPhone Simulator SDK 26.5; minimum deployment iOS/iPadOS 18. Signing disabled for build checks. No device or simulator was launched.

Commands are reproduced in `README.md` and `scripts/verify.sh`. Raw outputs are in `evidence/`.

- **PASS:** `python3 tools/validate_spec.py` — 51 specification/reference consistency checks.
- **PASS:** `python3 scripts/release_preflight.py` — offline release guards, exact registry, contract parity and no mood images bundled.
- **PASS:** `swift test -c release --scratch-path .build` — **18 XCTest tests, 0 failures, 126.849 seconds**. The twenty-seed soak itself took **123.123 seconds**.
- **PASS:** Seeds 0...19 each reached **1,296,060 active ticks** (six hours plus one second), for **25,921,200 ticks** total. Maximum sampled live state: **13 chunks, 7 hazards, 8 pickup dedup IDs**. Each run crossed the second deep-stripping boundary, with 27 pig opportunities committed.
- **PASS:** A separate 300-chunk certified manifest retained five hazard encounter kinds and twenty gaps with **0 fallback replacements**; tutorial zebra retained. An intentionally incompatible gap/underpass pair was rejected.
- **PASS:** `xcodebuild ... -configuration Debug -destination 'generic/platform=iOS Simulator' ... build-for-testing` — **TEST BUILD SUCCEEDED**.
- **PASS:** `xcodebuild ... -configuration Release -destination 'generic/platform=iOS Simulator' ... build` — **BUILD SUCCEEDED**.
- **PASS:** final focused suite after the scenery-only curtain/ribbon recipe addition — **17 tests, 0 failures, 3.522 seconds**, excluding the unchanged long traversal. Output: `evidence/core-unit-tests.log`.


CoreSimulator discovery failed in the sandbox and the request for external access was denied. Generic SDK compilation succeeded independently. Native app/resource/UI tests were **compiled but NOT RUN**. No gameplay screenshot, physical tilt, GPU, memory, thermal or battery measurement is claimed.

During implementation, build errors in an environment-resource API were fixed against the installed SDK. Icon catalogue compilation required unavailable simulator access; original icon PNG is supplied through legacy bundle metadata, pending production rendition validation. An oracle regression exposed a moving ball entering an earlier underpass: rolling hazards now arm only inside a 60 m approach and certification samples early, middle and capped speeds. The final logs supersede earlier iterations.

## Acceptance ledger

PASS below means the named automated/source/build check was performed. NOT RUN means the **full criterion** remains unverified even where its implementation or partial core checks exist. D02/D04 retain a documented completeness limitation; no automated oracle is presented as human playtesting.

| ID | Status | Evidence or outstanding check |
|---|---|---|
| A01 | PASS | Debug test-bundle and Release generic Simulator SDK builds; native SwiftUI/RealityKit sources and shared scheme. |
| A02 | NOT RUN | Offline service defaults implemented; fresh-install airplane-mode launch NOT RUN. |
| A03 | NOT RUN | All requested flows implemented and native UI test compiled; controls/empty states not executed. |
| A04 | NOT RUN | No small/tall iPhone or iPad layout execution. |
| B01 | PASS | testMovementAndPauseSnapshot checks +1 steering convergence; continuous bounded integrator is used for all offsets. |
| B02 | NOT RUN | Angle normalization and shared InputFrame implemented/tested; full adapter trace parity not executed. |
| B03 | NOT RUN | No physical iPhone available/used. |
| B04 | NOT RUN | Six-hour oracle crosses analytic stairs and generated gaps; visible tread/support alignment not observed. |
| B05 | NOT RUN | Mid-jump replay covered; all buffer/coyote/grade boundary combinations not exhaustively tested. |
| B06 | NOT RUN | Core slide and indefinite-hold regression pass; visible equine clearance not observed. |
| B07 | PASS | testSoftFatalSlideAndDedup; one ball stumble, immunity and resolved-contact deduplication. |
| B08 | NOT RUN | Second distinct soft contact tested; all inclusive/exclusive boundary ticks not separately exercised. |
| B09 | NOT RUN | Fatal rabbit during immunity tested; nazar/off-track semantics implemented, complete visual/contact matrix not executed. |
| B10 | NOT RUN | Swept interval collision implemented; oracle exercises closing balls, but complete narrow-ledge/pickup sweep matrix outstanding. |
| B11 | NOT RUN | Cosmetics are renderer/profile only; all-item replay and camera-obstruction review outstanding. |
| C01 | PASS | testRegistryAndGeneration plus specification validator: exactly 42, pig ordinal 42. |
| C02 | NOT RUN | 42 procedural builders and native geometry test compile; silhouette gallery NOT RUN. |
| C03 | NOT RUN | Eight materials, twelve palettes, three LODs implemented; perceptual comparison NOT RUN. |
| C04 | NOT RUN | No rendered mood screenshots obtained. |
| C05 | NOT RUN | Semantic materials/roles implemented; all-palette visibility review NOT RUN. |
| C06 | NOT RUN | Bounded caches and Lab counts implemented; gallery/triangle/device profiling NOT RUN. |
| D01 | NOT RUN | Analytic shared route sockets and core soak checked; rendered gap/floor alignment NOT RUN. |
| D02 | FAIL | Bounded witness certifier and eight-attempt fallback implemented/tested; all reachable airborne/unstable entry states not exhaustively searched (see limitations). |
| D03 | NOT RUN | 60 m armed ball approach and scenery exclusion implemented; effective camera/crest/fog visibility NOT RUN. |
| D04 | FAIL | Incompatible gap/underpass regression passes; broad seeded soak passes; full arbitrary-entry reachability proof absent. |
| D05 | NOT RUN | Core mirror state and hazard buffer implemented; reflected-void presentation NOT RUN. |
| D06 | NOT RUN | Scripted validated 3 m drop, collectible cue and landing implemented; visual decision envelope NOT RUN. |
| D07 | NOT RUN | Gap waking implemented and oracle jumps gaps; ordinary missed-gap visual distinction NOT RUN. |
| D08 | NOT RUN | Cue geometry persists in void; rendered readability NOT RUN. |
| D09 | NOT RUN | Bounded history arrays and deterministic nonrepeat groups implemented; chapter palette history is derived rather than separately stored. |
| E01 | PASS | testAllGoldenVectors: all supplied SplitMix, FNV, seed-code and pig traces. |
| E02 | PASS | testIDsRejectBadInput: checksum, oversized/overflow, format/alphabet/version and normalization cases. |
| E03 | NOT RUN | FixedStepClock verifies 600 ticks at 30/60/120 Hz; complete adapter/manifest trace comparison not separately tested. |
| E04 | NOT RUN | Mid-jump snapshot and ending/grant recovery covered; full listed multi-phase snapshot matrix outstanding. |
| E05 | NOT RUN | Pause stops step advancement and preserves continue count; simulated-hour plus OS-background test not executed. |
| E06 | NOT RUN | Bookmark/Revisit and suspend/UUID paths implemented; native save/import/resume interaction NOT RUN. |
| E07 | PASS | testThirdPigContactFreezesAndResumeEnding plus idempotent profile settlement. |
| E08 | NOT RUN | Stateless keyed domains isolate core from renderer; reduced-LOD/full-scene comparison NOT RUN. |
| E09 | NOT RUN | All gallery/share/import controls implemented; native cross-profile round trip NOT RUN. |
| F01 | NOT RUN | 6-second first commitment boundary tested; all nominal encounter lead-in boundaries not separately tested. |
| F02 | PASS | testExactProbability exhaustively enumerates the twelve draw pairs. |
| F03 | NOT RUN | Pure keyed draw takes only identity/ordinal/continued; explicit long unlucky-history/hats metamorphic test not run. |
| F04 | PASS | testPigCommitAndDeepNonterminal preserves committed decision across continue; golden continued traces. |
| F05 | NOT RUN | Collectible and ordinary soft pig paths implemented; explicit see-three/miss-one scenario not automated. |
| F06 | NOT RUN | Third-contact freeze and ending-resume tests pass; white/faint/three-pig rendering and award UI NOT RUN. |
| F07 | NOT RUN | Exact fatal tie test passes; earlier-pickup variant not separately automated. |
| F08 | PASS | testExactProbability verifies 1/216, 23/648, 234 and 468 minute calculations. |
| F09 | NOT RUN | Nonterminal 10,800-second transition covered; complete mode/achievement eligibility table not separately automated. |
| F10 | NOT RUN | Six-hour core evolution covered; sparse focal density and beyond rendering NOT RUN. |
| G01 | NOT RUN | Balloon and debug settlement rules implemented; full first-dream bonus and pickup matrix not separately tested. |
| G02 | PASS | testWalletTransactionsRefundAndDebug: 100 then 150 settles only incremental 50; duplicate settlement ignored. |
| G03 | NOT RUN | Idempotent ledger tested; StoreKit interruption at every persistence boundary NOT RUN. |
| G04 | NOT RUN | Atomic spend/owned-item rejection and relaunch tested; full catalogue/achievement-only UI matrix NOT RUN. |
| G05 | PASS | testWalletTransactionsRefundAndDebug: purchased lot revocation twice, balance nonnegative and persisted. |
| G06 | NOT RUN | Local StoreKit file attached; purchase-sheet success/pending/cancel/duplicate execution NOT RUN. |
| G07 | NOT RUN | Disabled/default and Debug mocks plus callback seams compile; actual SDK lifecycle NOT RUN. |
| G08 | PASS | testContinueGrantSurvivesCrashAndCannotDuplicate: serialized grant, once-only consumption, frozen recovery clock. |
| G09 | NOT RUN | Debug isolation tested; complete Fresh/continued/Revisit prestige matrix not separately automated. |
| G10 | NOT RUN | Disabled service paths and preflight pass; offline native launch/consent execution NOT RUN. |
| H01 | PASS | testOracleSixHoursTwentySeeds: final result and bounds below; third-pig/deep transitions also tested separately. |
| H02 | NOT RUN | No physical rendering, thermal, battery or input soak. |
| H03 | NOT RUN | 192 m renderer origin rebase implemented; visual continuity across rebases NOT RUN. |
| H04 | NOT RUN | Transaction rollback/corrupt-primary backup tests pass; real disk-full/OS/audio/motion faults NOT RUN. |
| H05 | PASS | Release compilation excludes #if DEBUG Lab/mock paths; release preflight checks disabled services and bundled resources. |
| H06 | PASS | This report, raw evidence logs, owner setup and explicit unavailable checks. |

## Owner work

See `docs/OWNER_SETUP.md` for signing, actual StoreKit product IDs, local and sandbox purchase testing, optional pinned Google/UMP SDK integration and consent UI, Game Center categories, owned Universal Link domain and cloud reconciliation. No live credentials/products/accounts were created, no money spent, no ads served and nothing published.

## Follow-up: pause loop and steering controls

Fixed the host timing policy that opened a modal pause whenever a frame required more than four simulation steps (about 67 ms). Slow presentation frames now advance at most four fixed steps; stalls beyond 250 ms discard elapsed time without opening a modal or banking score. Explicit pause/background/interruption-began still suspend. This supersedes the earlier stall-to-pause policy.

Removed the gameplay slider. Device defaults and legacy slider settings migrate to calibrated tilt; Simulator/unavailable motion uses drag steering. Vertical swipes jump/slide; existing action buttons remain accessible. Motion gets a one-second startup grace, then falls back to drag if unavailable. Audio interruption-ended notifications no longer pause again.

PASS: focused Swift suite, 19 tests, zero failures, 4.399 seconds (`evidence/input-pause-tests.log`). Includes hitch recovery and legacy settings decoding. Debug app/UI test bundle compilation is recorded in `evidence/input-pause-build.log`. The UI regression checks eight seconds without an unexpected ready prompt and no gameplay slider; it is compiled, not executed because simulator access remains unavailable. Physical tilt/gesture feel remains unverified.

## Follow-up: one player steering control

Removed steering-mode switches from both pause/onboarding and Settings. Physical iPhone/iPad builds always use calibrated tilt; horizontal drag is a compile-time Simulator input adapter only. Removed persisted steering preferences, so older saved drag choices cannot override device controls. Existing JSON settings remain decodable because obsolete keys are ignored. A genuine motion interruption offers recalibration rather than changing steering modes. Vertical jump/slide gestures and the frame-hitch fix remain.

Verification outputs: `evidence/tilt-only-tests.log` (focused package suite), `evidence/tilt-only-build.log` (Simulator test-bundle compilation), `evidence/tilt-only-device-build.log` (unsigned generic iOS Release compilation). No physical-device execution claimed.

PASS: 18 focused Swift tests, zero failures, 4.558 seconds. PASS: Debug Simulator test-bundle build and unsigned generic iOS Release build. UI assertions were compiled but not executed.
