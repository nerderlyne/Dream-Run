# Dream Again implementation evidence

Implemented native first-playable source, Xcode project, shared scheme, offline flows and independent deterministic core. This report does not certify all acceptance criteria or App Store readiness. See `KNOWN_LIMITATIONS.md` for remaining implementation and verification limits.

## Delivered

- SwiftUI + non-AR RealityKit close-camera runner, calibrated tilt on device and a Simulator-only drag adapter, jump/slide, swept collision, automatic stairs and streamed route.
- Exactly 42 original procedural world families, generated checker route geometry, ten PBR material treatments, twelve palettes, three mesh detail levels, humanoid and catalogue cosmetics.
- Versioned deterministic seeds, golden-vector RNG, certified encounter witnesses and bounded fallback, mirrors, marked drops, exact pig/continue policy, white ending and nonterminal deep evolution.
- Serialized transactional wallet/ownership/settlements, last-good backup, suspend/resume, bookmarks and native share/import, achievements, generated audio/haptics, all menu flows and isolated Debug Lab.
- Real StoreKit adapter with local configuration, honest disabled rewarded ads plus optional SDK bridge, disabled Game Center/cloud integration seams and owner setup guide.

## Actual verification

Host: Apple Silicon macOS. Xcode **26.6 (17F113)**; Apple Swift **6.3.3**, swiftlang-6.3.3.1.3. iPhone Simulator SDK 26.5; minimum deployment iOS/iPadOS 18. Signing disabled for build checks. These initial build checks did not launch a device or simulator; the later visual-pass section records actual simulator execution.

Commands are reproduced in `README.md` and `scripts/verify.sh`. Raw outputs are in `evidence/`.

- **PASS:** `python3 tools/validate_spec.py` — 51 specification/reference consistency checks.
- **PASS:** `python3 scripts/release_preflight.py` — offline release guards, exact registry, contract parity and no mood images bundled.
- **PASS:** `swift test -c release --scratch-path .build` — **18 XCTest tests, 0 failures, 126.849 seconds**. The twenty-seed soak itself took **123.123 seconds**.
- **PASS:** Seeds 0...19 each reached **1,296,060 active ticks** (six hours plus one second), for **25,921,200 ticks** total. Maximum sampled live state: **13 chunks, 7 hazards, 8 pickup dedup IDs**. Each run crossed the second deep-stripping boundary, with 27 pig opportunities committed.
- **PASS:** A separate 300-chunk certified manifest retained five hazard encounter kinds and twenty gaps with **0 fallback replacements**; tutorial zebra retained. An intentionally incompatible gap/underpass pair was rejected.
- **PASS:** `xcodebuild ... -configuration Debug -destination 'generic/platform=iOS Simulator' ... build-for-testing` — **TEST BUILD SUCCEEDED**.
- **PASS:** `xcodebuild ... -configuration Release -destination 'generic/platform=iOS Simulator' ... build` — **BUILD SUCCEEDED**.
- **PASS:** final focused suite after the scenery-only curtain/ribbon recipe addition — **17 tests, 0 failures, 3.522 seconds**, excluding the unchanged long traversal. Output: `evidence/core-unit-tests.log`.


At the initial milestone, CoreSimulator access was unavailable and native tests were compiled only. The visual pass below supersedes that limitation with approved simulator execution and actual screenshots. Physical-device/GPU/thermal measurements remain unperformed.

During implementation, build errors in an environment-resource API were fixed against the installed SDK. Icon catalogue compilation required unavailable simulator access; original icon PNG is supplied through legacy bundle metadata, pending production rendition validation. An oracle regression exposed a moving ball entering an earlier underpass: rolling hazards now arm only inside a 60 m approach and certification samples early, middle and capped speeds. The final logs supersede earlier iterations.

## Acceptance ledger

PASS below means the named automated/source/build check was performed. NOT RUN means the **full criterion** remains unverified even where its implementation or partial core checks exist. D02/D04 retain a documented completeness limitation; no automated oracle is presented as human playtesting.

| ID | Status | Evidence or outstanding check |
|---|---|---|
| A01 | PASS | Debug test-bundle and Release generic Simulator SDK builds; native SwiftUI/RealityKit sources and shared scheme. |
| A02 | NOT RUN | Offline service defaults implemented; fresh-install airplane-mode launch NOT RUN. |
| A03 | PARTIAL | Actual start, ready, uninterrupted play, pause and wardrobe UI flow passed in the visual pass; remaining flows/empty states still need execution. |
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
| C02 | PARTIAL | All 42 builders executed successfully in native tests; complete final-art silhouette gallery is outstanding. |
| C03 | NOT RUN | Eight materials, twelve palettes, three LODs implemented; perceptual comparison NOT RUN. |
| C04 | PARTIAL | Actual baseline and revised visual-slice screenshots reviewed; reference-level final art across all families is not achieved. |
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

## Follow-up: swipe-only jump and slide

Removed both gameplay action buttons. The existing playfield gesture handles swipe up for jump and swipe down for slide; tutorial prompts now explicitly teach those gestures. Tilt remains the only device steering control. This supersedes earlier notes about action buttons. Build output: `evidence/swipe-only-build.log`. No physical gesture execution claimed.

PASS: Debug generic iOS Simulator build after action-button removal.

## Follow-up: faster opening pace (R2)

New dreams start at 12.25 m/s, 1.75× the original 7 m/s, and approach the existing 16 m/s cap with the same 300-second time constant. Versioned R1 codes/suspensions retain their original rules; R2 codes and snapshots use the faster start. Pig intervals/odds, jump/slide physics and rewards are unchanged. The bundled and source configuration both declare R2.

Verification: `evidence/faster-start-tests.log` covers speed ratio, R1/R2 save compatibility, golden R1 fixtures, and twelve R2 seeds through their first three minutes plus each tutorial. `evidence/faster-start-spec.log`, `evidence/faster-start-preflight.log` and `evidence/faster-start-build.log` record contract checks and Debug test-bundle compilation. Physical play feel remains untested.

PASS: 20 focused Swift tests, zero failures, 5.529 seconds; 51 specification checks; release preflight; Debug Simulator test-bundle build. The six-hour soak was not repeated for this opening-speed change; the new R2 test covers twelve three-minute runs and twelve tutorials.

## Follow-up: narrower and quicker steering (R3)

New dreams constrain the avatar to ±0.9 m instead of ±1.25 m, reducing the effective playable span from 2.5 m to 1.8 m (28%). Lateral movement cap is 6 m/s; smoothing is 40 ms; default full-scale tilt is 12 degrees. R1/R2 saved rules remain supported. The certifier now keys and simulates its witnesses by rules version and uses that version's entry bounds. R3 pig runway placement is offset 0.18 m to retain a bypass corridor with the existing pickup radius.

Regression coverage: bounded movement/edge reversal within half a second, tighter snapshot validation, old-rule compatibility, collection versus bypass of a real scheduled clover pig, and twelve R3 three-minute openings plus tutorials. Logs: `evidence/narrow-steering-tests.log`, `evidence/narrow-steering-spec.log`, `evidence/narrow-steering-preflight.log`, `evidence/narrow-steering-build.log`. Physical tilt feel remains untested.

PASS: 22 focused Swift tests, zero failures, 7.546 seconds; 51 specification checks; release preflight; Debug Simulator test-bundle compilation. No six-hour R3 soak or physical-device gesture test was run for this tuning change.

## Follow-up: perceptible obstacle hits

The existing 25% speed drop and one-second recovery now drive a coordinated avatar stagger: forward pitch, body dip, braced arms, uneven leg pose and a brief “stumbled” cue. The five-second instability/second-hit waking rule remains. Football lateral contact now reaches its mesh tips (0.65 m half-width) instead of using the smaller spherical-ball width; the certification cache distinguishes that geometry. Stumble/clover feedback takes priority over balloon feedback.

PASS: 24 focused Swift tests, zero failures, 8.460 seconds (`evidence/stumble-tests.log`). Tests directly hit all four sports balls, verify distance actually slows, verify once-only hits and snapshot recovery, test football-tip contact and retain the twelve-seed R3 opening checks. Native animation and haptic feel still require device execution. Build output: `evidence/stumble-build.log`.

PASS: Debug app and native test-bundle compilation after the final feedback-priority change.

## Follow-up: fast incoming rolling balls (R4)

New dreams use R4: rolling encounters move toward the runner at 8 m/s instead of 4 m/s. Sports-ball meshes rotate about their centres using authoritative travelled distance divided by rolling radius; footballs rotate about their long lateral axis. Dormant encounters are hidden until their 60 m approach begins, removing the parked-ball presentation. At the 16 m/s player cap, the worst ordinary-ball closing speed is 24 m/s; the initial contact margin still exceeds two seconds. Earlier saved rule versions keep their original ball speed.

Verification outputs: `evidence/rolling-balls-tests.log`, `evidence/rolling-balls-spec.log`, `evidence/rolling-balls-preflight.log`, `evidence/rolling-balls-build.log`. Tests cover movement/spin/start visibility and preview time, plus twelve R4 three-minute runs and tutorials through the authoritative certifier. Physical/simulator visual execution remains unrun.

PASS: 25 focused Swift tests, zero failures, 8.424 seconds; 51 specification checks; release preflight; Debug Simulator test-bundle build. No six-hour R4 soak was performed.

## Follow-up: path to the horizon

Added a render-only route continuation roughly 6.1 km ahead, beyond the existing detailed gameplay window, and extended camera far clipping to 8 km. The continuation follows the same analytic curves/helical stairs and omits generated gaps/marked-drop spans. Four-metre samples and cached 384 m sections keep geometry bounded; distant checker detail becomes an averaged surface color and the far end blends into the sky. Rebase/palette/run changes reset the cache. No extra world family, hazard, pickup or simulation RNG state is introduced.

Build evidence: `evidence/horizon-build.log`. Actual horizon composition, transition appearance and device performance remain unverified without simulator/device execution.

PASS: Debug generic iOS Simulator build, including the distant-path white-ending fade. No new core tests were needed for this renderer-only change.

## Follow-up: back slide and running gait

The slide now rotates the avatar face-up with feet leading and the head behind, centred low over the slide hitbox. Replaced rigid limbs with articulated knees/elbows. Running now has a forward lean, stronger hip swing, rear-leg recovery, bent-elbow arm pumping and a small vertical bounce. Gait phase follows distance travelled (six metres per full stride), so the initial 12.25 m/s run gives roughly four footfalls per second and stumbling naturally slows cadence. Wardrobe resets every joint. Gameplay speed, slide duration and collision dimensions are unchanged.

Build evidence: `evidence/avatar-motion-build.log`. Visual animation and underpass clearance still need device execution; no live screenshot evidence is claimed.

PASS: Debug generic iOS Simulator build after the final pose update. This is a renderer-only change; core tests were not repeated.

## Visual art direction pass — 2026-09-13

This pass supersedes the earlier environment-unavailable notes for **simulator execution**. External CoreSimulator access was approved for this visual review. Physical iPhone/iPad measurements remain unavailable.

Implemented a representative cloud/window/stair slice and propagated shared PBR materials, smooth geometry, sky/environment light, shadows, distance haze and a bounded seeded horizon landscape through the renderer. Near scenery inherits coherent cloud, aqua-courtyard or dark-world composition. The horizon uses the existing 42 families at architectural and landscape scales, with density tied to the nonterminal visual evolution. Gameplay controls, speeds, collision semantics, seed versions, pig decisions and economy contracts were not changed.

The runner now has a tailored, longer-legged silhouette, articulated clothing and a stable hat socket. It remains an improved procedural stand-in. A validated optional local USDZ/animation adapter is implemented; no authored character asset is fabricated or claimed as delivered. The rabbit has a joined implicit surface. Other animals and several furniture/rock forms remain provisional. See `docs/VISUAL_ART_DIRECTION.md` for the art and replacement contracts.

Real render review caught and corrected cloud/camera overlap, over-tall stair risers, sky detail lost in environment filtering, horizon elements outside the portrait camera, and cloud-card border artifacts. Native testing caught slow per-pixel texture drawing and a display-link retain cycle; direct texture buffers and a weak display target address these. Color blending now converts PBR colors into a common sRGB space before the white ending.

Evidence:

- `evidence/art-before.png`: actual baseline simulator screenshot.
- `evidence/art-cloud-review.png`: current full-frame cloud composition. `art-slice-01/02/03.png` are explicitly superseded intermediate renders, including the rejected cloud-overlap iteration.
- `evidence/art-core-tests.log`: **25 XCTest tests, 0 failures, 26.184 seconds**. The unchanged six-hour/twenty-seed core soak was excluded from this focused renderer regression run; its earlier results above are historical evidence, not a new run.
- `evidence/art-spec-validation.log`: **51 specification checks passed**.
- `evidence/art-release-preflight.log`: **offline release/registry/resource guards passed**.
- `evidence/art-native-tests.log`: first native run; one color-space assertion failed, while offline UI flow passed. It is retained as diagnostic history and superseded by the final run.
- Final native, Release and screenshot evidence is recorded below.

**Not certified:** reference-level finished art across all 42 assets, authored character/animal animation quality, all-seed hazard visibility, physical tilt, iPad/small-phone layouts, sustained device frame pacing, GPU/memory/thermal/battery budgets, live services or App Store readiness. D02/D04's pre-existing exhaustive-certification limitations remain unchanged.

### Final UI verification

`evidence/art-ui-recheck.log` reports **TEST SUCCEEDED**, with the complete offline start/ready/play/pause/wardrobe flow passing twice (**32.927 s**, **27.766 s**). Each run asserts that ready disappears after one tap, no slider/mode switch is present, and ready does not return during eight seconds of play. The earlier `art-native-final.log` UI failure was an unaccepted initial ready-button tap, confirmed from its screen recording—not a resumed run pausing. The button label now owns the full rounded hit area and the decorative border cannot intercept touches. The same earlier run's seven renderer tests and both light/dark launch checks passed; the UI failure is retained and superseded by the repeated recheck.

Current screenshots on iPhone 16 Pro Max / iOS 26.5: cloud, aqua courtyard, void, slide and the three-pig white ending (`evidence/art-*-review.png`). These are Debug, reward-ineligible, frozen review states, not device-performance captures. All 42 builders execute in native tests. Smoothness settings for oversized distant geometry and the fainting root offset were refined after screenshot review; final renderer results follow.

### Final renderer verification

- **PASS:** `evidence/art-renderer-final.log` — **7 native XCTest tests, 0 failures, 12.190 seconds**, actually executed on iPhone 16 Pro Max / iOS 26.5. Covers all 42 resource builders and finite bounds; sculpted normals/indices; distinct PBR properties and nonaccumulating white-ending tint; rejection of incomplete authored art; reward/snapshot isolation in art previews; and display-link lifetime.
- **PASS:** the focused Swift package suite remains **25 tests / 0 failures**; no core files changed in this visual pass.
- **PASS:** repeated offline UI recheck as above; the two launch/appearance checks also executed successfully. Broader device/layout/commerce UI matrices remain untested.
- **PASS:** `evidence/art-slice-build.log` — final Debug simulator build, including white-ending HUD contrast.
- **PASS:** `evidence/art-release-build.log` — final Release generic Simulator build (**BUILD SUCCEEDED**). Signing is disabled; no live services were provisioned or charged.

The visual pass is a tested implementation increment toward the references. It is **not** a claim that the reference-level final-art acceptance bar or physical-device performance target has been achieved. The remaining art limitations are explicit in `KNOWN_LIMITATIONS.md` and `docs/VISUAL_ART_DIRECTION.md`.

## Wardrobe and character revision — September 13, 2026

- Implemented free, transactionally saved Girl · dress and Runner · trousers options in Wardrobe. The girl wears a rose A-line dress, waist sash and ponytail; the other look uses a mint top with separate charcoal trousers. Existing garment colour cosmetics work on either. Default is No hat; the old brim-like hair silhouette is removed.
- Replaced all hat world-prefab scaling with purpose-built wearable geometry: fitted paper crown, ribbon band/bow, draped nightcap, circular bucket brim, beret, badge caps and circlets. Existing item IDs, prices, ownership and achievement locks remain intact. Bands intersect the 1.73 m head fitting line; novelty details are reduced to head-sized ornaments. No world-family or deterministic gameplay change.
- Wardrobe has dedicated front lighting and framing. Character changes happen before animation posing. DEBUG wardrobe captures are isolated from persisted equipment and real rewards.
- `evidence/wardrobe-tests-final.log`: actual iPhone 16 Pro Max / iOS 26.5 simulator execution; **8 tests, 0 failures, 10.987 seconds**. Includes all hats on both characters, attachment/bounds checks, profile round-trip and existing renderer/asset/reward-isolation checks. Final studio light/framing refinement was subsequently built and UI-tested.
- `evidence/wardrobe-spec.log`: 51 contract checks pass. `evidence/wardrobe-preflight.log`: release preflight passes. Core package suite was not rerun for this renderer/UI-only change; earlier results remain historical evidence.
- Limitations: procedural character art, rigid skirt without cloth simulation, no physical-device/performance validation or exhaustive hat-by-action screenshot matrix. No authored USDZ outfit variants supplied.
- Final wardrobe UI flow: **1 test, 0 failures, 35.381 seconds** (`evidence/wardrobe-ui-final.log`), including the persisted girl selection. Debug and Release simulator builds pass. Subsequent trouser-waist and dress stride geometry/pose refinements were rebuilt and visually reviewed; tests were not repeated for these numeric art adjustments.
