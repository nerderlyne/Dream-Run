# Dreamlooper implementation status

## Owner Unsplash batch curation — September 26, 2026

- Reviewed all 59 owner downloads by composition. Imported 20 as full DreamPlates, bringing the background library to 122. Source URLs, license URLs, hashes, tags and per-image decisions are in `data/dream_objects_intake.json`.
- Isolated and visually reviewed 22 photographs as transparent cutouts. Rebuilt all five vignettes and the atmospheric layer from them, then removed all 46 superseded generated collage PNGs and their metadata. Thirteen other photos remain source-only reserves. Four public-figure, brand, or scene-dependent images were held out.
- Untouched originals stay in ignored root `DreamObjects/`; optimized resources are bundled. No physical iPhone tests were performed.
- Verification: 18 focused Swift core tests passed (collage, atmosphere, scale and track art), the native simulator resource-load test passed, and the built app bundle contains 22 owner cutouts plus 122 plates with no superseded generated collage PNGs. `python3 tools/validate_spec.py` passed 56 checks. The full Swift suite was interrupted after it stalled; no full-suite result is claimed. Final on-screen simulator review remains untested because computer control of Simulator was denied and the CLI screenshot showed the home screen.

## Owner photo intake and rejected repost removal — September 26, 2026 (superseded by curation above)

- Created `Dream Again/Resources/DreamObjects/` for owner-selected source photos and source links. No new photos have been supplied yet, so no isolation, tagging or scene review has been completed.
- Removed the eight rejected fictional repost PNGs, their generator, metadata and runtime selection. Midnight Kitchen again uses its four original cutouts. The current catalog has 46 cutouts and 102 owner-curated plates. Recognizable repost parodies are pending owner references.
- Verification: `swift test --filter CollageTests` passed 8 tests; `python3 tools/validate_spec.py` passed 54 checks. Native simulator build and visual review have not been rerun for this removal.

## Run-start scene continuity — September 25, 2026

- Extended the first procedural track section behind the starting camera and
  gave its opening surface a readable checker pattern. The near edge no longer
  cuts across the bottom of the screen while the Ready panel is open.
- The paused/ready scene now refreshes when its viewport changes or an
  asynchronous collage texture finishes loading, so the background becomes
  visible before active play begins.
- Verified on the iPhone 16 Pro Max iOS 26.5 simulator: the focused UI test
  passed with a lower-screen contrast assertion; screenshot:
  `evidence/run-start-viewport-fixed.png`. `swift test --filter TrackArtTests`
  passed 3 tests; `python3 tools/validate_spec.py` passed 54 checks. Physical
  iPhone testing was not performed.

Native SwiftUI + non-AR RealityKit first playable, with a separate deterministic Swift core,
shared Xcode scheme, offline progression, save/share, suspend/resume, achievements and audio.
Exactly 42 procedural world families remain; pig is #42. Balloons buy cosmetics only.
Pigs now arrive every three active minutes with 1/3 lucky odds (1/6 after continue). The nonterminal three-hour evolution remains unchanged.

## Reposted dream fragments — September 22, 2026 (removed September 26)

The eight fictional forum cards were rejected and removed from code, resources, generator and review evidence. Recognizable parody references remain a separate design task.

## Floating stair progression — September 22, 2026

- Removed the fallen-column encounter, procedural hurdle mesh, Lab option and its
  rejected screenshot. Architectural columns remain scenery within the existing registry.
- Replaced column runs with detached ascending stair flights: 3 m gaps initially,
  widening to 4 m from 1,200 m. The other ascending variant adds two 3 m gaps from
  1,200 m, then three 4 m gaps from 4,500 m. Ordinary intact stairs stay automatic.
- Gaps end at raised landings, use real unsupported intervals, and retain 24 m action
  spacing and a recovery chunk. Edge markers now follow each landing's actual elevation.
- Progression tests cover 12 seeds, three difficulty tiers, four speeds and both grade
  extremes, including intentionally omitted jumps. Certification checks later flights
  without replacing them with empty track.
- PASS: `swift test -c release` — 89 tests, zero failures (303.3 s), including
  twenty six-hour traversals. The 300-chunk certified manifest retains 66 gaps,
  eight encounter kinds and zero fallbacks. Soak maxima: 13 chunks/13 hazards/4 pickup IDs.
  Evidence: `evidence/floating-stairs-core-tests.log`.
- PASS: `python3 tools/validate_spec.py` — 54 checks (`evidence/floating-stairs-spec.log`).
- Simulator command: `xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again'
  -configuration Debug -destination 'platform=iOS Simulator,id=80DBBEEC-A752-43F6-A60E-2419BAE5B77E'
  -derivedDataPath /tmp/dream-jump-build -resultBundlePath /tmp/dream-floating-stairs-tests.xcresult
  CODE_SIGNING_ALLOWED=NO test`, using `-only-testing:` for
  `Dream AgainTests/Dream_AgainTests/testFloatingStairGapMarkersFollowRaisedLanding` and
  `Dream AgainUITests/Dream_AgainUITests/testFloatingStairProgressionPreviews`.
  PASS: simulator build, native gap-marker test and UI progression preview test.
  Log: `evidence/floating-stairs-simulator-tests.log`; inspected early and late screenshots:
  `evidence/floating-stairs-screenshots/` (iPhone 16 Pro Max, iOS 26.5).
  XCTest logged a transient event-loop idle timeout during the first launch, then recovered
  and completed both captures without an assertion failure; this is not device performance evidence.
- PASS: `git diff --check`.
- No physical-device checks or additional profile reset.

## Required jump sequences — September 21, 2026 (column variant superseded above)

- Removed the wide automatic balloon drop from generation, route elevation, near/far
  surface rendering and automatic transition activation.
- Added seeded three-jump runs: full-width fallen columns, furniture/gap combinations,
  and raised staircase landings at 0.72 / 1.44 / 2.16 m. Jumps are 24 m apart
  (1.09 seconds at 22 m/s), followed by a recovery chunk. Mirror buffers and pig
  runway protections remain authoritative; ordinary stairs remain automatic.
- Shared staircase profiles are evaluated once per containing chunk, so rendering,
  collision and saved state agree. Fallen columns reuse registered family #10.
- Fixed below-rim landing snap and prevented certification retries from reducing
  normal gaps below 4 m. These gaps must require a jump even at capped speed.
- Current identities/configuration use G2/R2/C1. Old prerelease layouts are rejected;
  original G1/R1 RNG/seed/pig fixtures still verify the encoding and sampling algorithms.
- PASS: `python3 tools/validate_spec.py` — 54 data/reference checks (`evidence/jump-sequences-spec.log`).
- PASS: simulator column geometry matches its collision envelope; UI preview test captured
  ascending/column/mixed sequences on iPhone 16 Pro Max, iOS 26.5. All three PNGs were
  inspected; risers, barriers and the actual missing floor are visible from the close camera.
  Log: `evidence/jump-sequences-simulator-tests.log`; images/manifest:
  `evidence/jump-sequences-screenshots/`.
- Core command: `swift test -c release` (full suite including six-hour/20-seed traversal).
  PASS: 87 tests, zero failures (258.0 s), including all 20 six-hour seeds.
  Certified 300-chunk manifest retained 26 gaps and 8 encounter kinds with zero fallbacks.
  Soak maxima: 13 chunks, 13 hazards, 4 retained pickup IDs.
  Evidence: `evidence/jump-sequences-core-tests.log`.
- PASS: final simulator build (`evidence/jump-sequences-simulator-build.log`) and
  two native tests (`evidence/jump-sequences-final-simulator-tests.log`).
- PASS: `git diff --check`. Existing unrelated workspace changes were preserved.
- Native command: `xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again'
  -configuration Debug -destination 'platform=iOS Simulator,id=80DBBEEC-A752-43F6-A60E-2419BAE5B77E'
  -derivedDataPath /tmp/dream-jump-build CODE_SIGNING_ALLOWED=NO test`, narrowed with
  `-only-testing:` to the new column envelope, current identity, and jump preview tests.
- NOT RUN: human timing playtest, physical tilt and thermal checks. No physical iPhone used.

## Performance investigation and fixes — September 20, 2026

- The owner temporarily authorized physical testing, then ended it and requested static/local work. Two completed two-minute recordings on iPhone 17e (iOS 26.4.2), seed 42, optimized Debug (`-O`, whole-module optimization), used normal simulation and oracle input in an isolated nonrewarding profile. Further testing remains simulator-only.
- Measured callback gaps over 100 ms: **6 → 0**; over 50 ms: **192 → 2**; worst gap **163.634 → 82.224 ms**. Audio-update median **1.866 → 0.049 ms**. Baseline thermal state was fair; comparison state was serious and activated the existing reduced-detail mode. This is not a controlled graphics comparison, GPU FPS, or proof of stall-free play. Raw reports and summaries are in `evidence/performance-{baseline,audio}*.json`.
- Audio graph startup now occurs before gameplay advances. Silent player stops, effect-player stop/start churn, disabled-theta route queries, and motif restarts are avoided. Added engine-reuse and pause/resume checks. Existing sound tests had stale 25-buffer and 0.2-peak expectations after straw sounds were added; tests now require the exact cue set, retain ambient limits and channel separation, and apply the straw generator's documented 0.8 ceiling to those two transients.
- After device testing ended: prebuild reusable material maps and fixed-color gameplay prefabs during preparation; share hay and obstacle meshes across independent entity clones; use bounded incremental LRU eviction; sample Debug entity diagnostics once per second. Async checkpoints use a FIFO writer, short durable-value read lock, and an eight-write backlog cap; synchronous pause/end/commerce operations drain earlier writes. Queue rejection or write failure pauses play without publishing uncommitted profile changes.
- Added opt-in signposts, bounded frame capture with capture identity/date, automated nonrewarding runs and `tools/summarize_performance.py`. Release excludes the automation launch hook. See [PERFORMANCE.md](PERFORMANCE.md) for commands, interpretation and remaining coverage. Later caching/persistence refinements have **no device speedup measurement**.
- **PASS:** 54 specification checks; full Release core suite (80 tests, including 20 seeded six-hour simulations); final focused persistence/cache suite (6 tests, including blocked-reader behavior, FIFO draining, failed-write backup, bounded backlog and 10,000 cache inserts); native simulator suite (37 tests, all passed); Release simulator build with signing disabled. Logs: `evidence/performance-final-core-tests.log`, `performance-final-persistence-tests.log`, `performance-final-native-tests.log`, `performance-release-simulator-build.log`.
- **FAILED / corrected:** the initial native audio test run failed on stale bundled-audio expectations described above. Focused rerun passed. **Unavailable:** Instruments CLI attach/launch did not produce a usable device trace; no GPU or device-memory result is claimed. The full native suite emitted simulator drawable-allocation warnings despite passing. The separate final fresh-process smoke test passed (15-second automated capture, paused without save errors, screenshot inspected) with no drawable-allocation messages; its three audio regression tests also passed. Log: `evidence/performance-final-smoke-tests.log`; screenshot: `evidence/performance-smoke-attachments/859A7C63-78BD-491E-BBBB-BC47804E1F69.png`. This unoptimized simulator run checks function, not device performance. The final Release rebuild also succeeded without the earlier captured-self concurrency warning.

## Hay spawn balance and bounded rolling — September 19, 2026

- Hay candidates now require four certified moving sports balls before one is admitted; unused eligibility is reset after an offer. This counts actual accepted obstacle chunks, not rejected generator candidates. The budget persists with the run.
- Hay starts rolling only after the runner enters its empty support section, and its travel stops one metre inside that section. It cannot travel backward across earlier stairs, gaps, drops or static obstacle setups. Collapsing support is excluded. Shared active-time distance math now drives both sports balls and hay; collision and rendering use the same bounded position.
- Collection, banked straw and repair feedback remain. This is controlled route motion, not rigid-body ball-to-ball physics. Verification: 7 focused Release core tests passed (2.007 seconds), the Debug iOS Simulator build succeeded, and all 54 specification checks passed. Logs: `evidence/hay-routing-core.log`, `hay-routing-build.log`, `hay-routing-spec.log`. No simulator gameplay session, full-suite rerun or performance benchmark in this pass. No physical iPhone testing.

## Dreamlooper identity and icon prototype — September 17, 2026

- App display name, home title, alerts, share caption and unsupported-version copy now use Dreamlooper. Debug/Release bundle ID is the owner-confirmed signed explicit ID `dev.shivanshi.dream-run`; test IDs use `.tests` and `.uitests`. Import scheme is `dreamlooper`; seed document type is `dev.shivanshi.dream-run.seed`. Internal project/scheme/module filenames remain Dream Again / DreamAgain. Retry copy remains “dream again.”
- Original imagegen concept saved in `art/branding/dreamlooper-icon-prototype.png`; exact prompt and provenance are in that folder's README. Prototype only; existing bundled icon retained. No signing change, live products or physical-device testing.
- PASS: Debug generic iOS Simulator build with signing disabled. Built Info.plist readback confirms `CFBundleIdentifier=dev.shivanshi.dream-run`, `CFBundleDisplayName=Dreamlooper`, and URL scheme `dreamlooper`. A generic physical-iOS Release build also succeeded with automatic signing: app signature identifier `dev.shivanshi.dream-run`, Team `BZ2SH7NUDM`, Apple Development identity `Shivanshi Tyagi (RS52HCDR44)`, and Xcode wildcard development profile `BZ2SH7NUDM.*`. This verifies local development signing, not App Store distribution export. Specification validator passed 54 checks; `git diff --check` passed. Evidence: `evidence/dreamlooper-identity-build.log` and `evidence/dreamlooper-signed-build.log`. Swift seed golden-vector and invalid-ID tests passed: 2 tests, 0 failures (`swift test --filter 'CoreTests.testAllGoldenVectors|CoreTests.testIDsRejectBadInput'`); evidence: `evidence/dreamlooper-identity-tests.log`. Initial `Determinism` filter matched zero tests and was corrected. No simulator launch/UI test or App Store archive/export in this pass.

## Rolling hay and stored straw — September 17, 2026

- Replaced the static repair bale with a tangled straw ball rolling toward the runner at 8 m/s, activated within 72 metres. Rendering, spin and swept pickup collision share its saved active-time trajectory.
- Fixed full-body contact doing nothing: every ball now gives +1 hay, a visible popup, straw particles and pickup sound. Missing limbs consume that hay immediately; intact runners bank it in a visible reserve. Stored hay rebuilds a limb one second after damage. Reserve, pickup activation and consumed IDs suspend with the run; balloons remain the only currency.
- Verification: 5 focused Swift core tests passed (0.181 seconds), including incoming trajectory, full-body collection, reserve rebuilding and existing damage/repair rules. One native simulator renderer test passed (2.423 seconds); specification validator passed 54 checks. The final curved-strand art refinement received a successful simulator build and refreshed, visually inspected capture after that native test. Logs: `evidence/hay-core.log`, `hay-native.log`, `hay-spec.log`, `hay-build.log`; preview: `evidence/straw-3.png`.
- Simulator only. No full-suite rerun, physical-device testing or sustained performance/balance measurement in this pass.

## Quieter running — September 16, 2026

- Lowered ordinary, watery and stair running footfalls to 0.14 of their previous amplitude (approximately −17 dB). Original contact transients and surface timbres remain; jump/landing and other interaction levels are unchanged.
- Debug simulator build succeeded; `git diff --check` passed. Build log: `evidence/footfall-build.log`. No new tests for this gain-only adjustment; subjective headphone audibility remains to be assessed by the owner. No physical device testing.

## Adaptive dream soundtrack and theta — September 16, 2026

- Replaced the single runtime-generated ambient tone with six crossfading environment beds, a seed-selected three-note motif, a restrained pulse, and original movement/interaction sounds. Accepted jumps/slides/landings and distance-based footfalls use simulation state; pickups form a rate-limited phrase. Mirrors, safe drops, crowded hazards, void, Lucky Dream and three-hour stripping/rebuilding alter the mix. No gameplay RNG, rewards or timing changed.
- Added separate Music/Effects levels and an independent, persisted, default-off theta headphone option. Theta is a true 200 Hz left / 206 Hz right pair with its own gentle gain ramp; it bypasses reverb. Speaker/AirPlay/HFP routes and Mono Audio suppress it. Bluetooth headphone use requires the player's confirmation via the labeled opt-in. Pause/background/interruption stops audio; unplugging pauses gameplay; fatal lightning retains its strike without restarting music.
- Bundled 25 original synthesized WAVs (about 11 MB), reproducible with `tools/audio/generate_dream_audio.py`. Native graph has bounded one-shot voices, preloaded buffers and mix headroom. See `docs/DREAM_AUDIO.md` for architecture, settings and build/test commands; provenance is in `ASSET_LICENSES.md`.
- Verification: specification validator **54 checks passed**; full Release Swift core suite **68 tests passed** (104.028 seconds); final targeted core audio rerun **4 passed** (0.027 seconds). Debug simulator build-for-testing succeeded. On iPhone 16 Pro Max / iOS 26.5 simulator, **3 native audio tests passed** (2.556 seconds), checking all assets, theta channel amplitudes/crosstalk, independent music controls, pause/waking/Lucky Dream and thunder lifecycle. **1 settings UI test passed** (35.678 seconds), exercising opt-in, level adjustment and save/navigation. Initial UI test exposed duplicate slider accessibility labels; fixed before passing. Sandbox compiler/simulator/report access required escalated reruns. Logs: `evidence/audio-spec.log`, `audio-core.log`, `audio-core-final.log`, `audio-native.log`, `audio-ui.log`.
- Settings screenshot: `evidence/audio-settings.png`. No physical iPhone testing, subjective headphone listening, comfort study, sustained thermal/audio performance measurements, Release iOS build or full native/UI suite in this pass. Theta has no proven dream/hypnosis claim; Bluetooth A2DP cannot reliably distinguish headphones from speakers. Known limits are recorded separately.

## Straw body damage and hay repair — September 16, 2026

- Distinct sports-ball hits after contact immunity remove arms first, then legs, using impact side for the available limb. Three losses retain stumble/slow/knockback; the fourth unrepaired loss triggers a 2.4-second rising straw-burst wake-up. The previous second-hit death rule was replaced in the specification and acceptance criteria. Edge falls and fatal semantic hazards remain lethal; collision and input dimensions do not change with missing limbs.
- Initially, seeded tied hay bales restored one limb without currency (superseded by rolling, bankable hay above). They use reclaimed humanoid straw outside the 42 world-scenery families, appear only on hazard-free support without gaps/steps/drops, and originally were not consumed at full health; that behavior is fixed above. Live suspension serializes missing limbs and consumed pickup IDs. Continue rebuilds the avatar. No old-development-snapshot migration was added.
- Bounded reed bursts accompany damage/repair; the runner fades into a larger upward burst on the fourth hit. Added two original, reproducibly synthesized sound effects and DEBUG Lab damage/burst previews. Documentation and generation/capture commands: `docs/STRAW_DAMAGE.md`.
- Initial 72-test core run: 71 passed, one obsolete second-hit-death assertion failed. Updated that assertion; final focused run passed all 5 tests in 0.158 seconds, including four-hit progression, repair/no currency/dedup, suspend, continue, immunity, safe seeded placement and tutorial placement. Native simulator test passed in 3.354 seconds, verifying limb visibility/restoration, burst, bale geometry and bundled audio. Specification validation passed 54 checks. Final tutorial-placement, immediate damage/repair checkpoint, preview framing and delayed wake-overlay adjustments received a simulator rebuild; the native renderer test was not repeated after those changes.
- Visually inspected final simulator previews of the one-legged avatar with its repair bale and the unobscured full straw burst: `evidence/straw-gallery.html`.
- Evidence: `evidence/straw-core-initial.log`, `evidence/straw-core.log`, `evidence/straw-native.log`, `evidence/straw-build.log`, `evidence/straw-spec.log`. No physical-device testing or subjective sound/play-balance/performance claims.

## Obstacle/balloon color harmony and active storm — September 16, 2026

- Traversal obstacle PBR surfaces and collected balloons now use the same vivid palette as the track and register for budgeted, staggered palette evolution. Door/furniture/mace finishes remain; collapsing tiles and gap markers follow track roles. Sports balls (including stationary variants), zebra, nazar, rabbit and pig keep their authored colors. Lightning retains a threatening charcoal/electric treatment.
- Added breathing/rolling cloud transforms, one independently drifting translucent scud card sharing the existing texture, flickering electrical branches, charge-light pulses and stronger approach rain. No per-frame geometry or texture creation. Replaced translucent shade rings with an opaque irregular scorched footprint and dim ember fissures; nearby lightning chunks reinforce track opacity.
- Four targeted native simulator tests passed (7.798 seconds): obstacle geometry/strike timing, storm lighting restoration, storm motion/entity reuse/opaque char, and palette evolution for doors/balloons. Initial assertions compared RealityKit linear colors directly to sRGB; corrected to compare converted components. Specification: 54 checks passed. The final explicit stationary-ball color exclusion received an additional simulator build; tests were not rerun for that condition-only adjustment.
- Visually inspected final simulator captures `evidence/obstacle-lightning.png`, `evidence/obstacle-lightning-strike.png` and `evidence/obstacle-window.png`: the strike footprint is opaque, track remains legible and jail-door colors match the track.
- Logs: `evidence/harmony-native.log`, `evidence/harmony-build.log`, `evidence/harmony-spec.log`. Existing hazard timing/collisions, currency and rewards unchanged. No physical-device testing, full-suite rerun or sustained frame-rate/thermal measurement.

## Timed realities and translucent traversal — September 15, 2026

- Photo evolution now begins at 20 active seconds and repeats at independently seeded 30–90-second start-to-start intervals. Overlaps occupy 80% of each interval, capped at 48 seconds; one third linger in the mixed state. Active time replaces distance, so stumbles/speed do not postpone changes. Existing two-card overlap, standby preload, three-photo cache, mirror/drop buffers and deep-void rules remain.
- Completed the preceding track pass: translucent base tiles, stronger pattern tiles, opaque rims/risers and reinforced nearby critical footing. Removed the opaque underside; distant geometry dissolves further while retaining boundaries. Alpha changes do not rebuild meshes. See `docs/TRACK_TRANSLUCENCY.md` and simulator captures `evidence/track-alpha-water.png`, `evidence/track-alpha-space.png`.
- Final verification: 3 Release core tests passed (28.562 seconds), covering 100 seeds × 200 transition intervals and track hierarchy. Debug simulator build and 3 targeted native tests passed (4.590 seconds), proving the twenty-second change without travel, simultaneous visible realities, failed-photo continuity, bounded photo cache and retained track geometry. Specification validation: 54 checks passed. Logs: `evidence/cadence-core.log`, `evidence/cadence-native.log`, `evidence/cadence-spec.log`.
- Before the owner prohibited further device testing, the preceding track pass had completed one material test and one screenshot smoke test on a connected iPhone. A later device rerun was stopped; it is not counted as successful verification. All cadence verification used the simulator/local Swift core. Future physical iPhone testing is prohibited and recorded in AGENTS.md.
- No sustained FPS/thermal benchmark, full-suite rerun or exhaustive photograph/hazard readability review. RealityKit simulator resource warnings occurred despite passing tests. Timing details: `docs/DREAM_TRANSITION_CADENCE.md`.

## Storm threat and post-death label — September 15, 2026

- Corrected the requested scope: only the post-death restart button says **Dream On**. The title, app display name, share text and seed description remain Dream Again; the interrupted broader rename was reverted before this build.
- Replaced the lightning encounter's toy cloud with an original 1536 × 1024 transparent photographic storm sprite, preloaded once and shared between instances. Preserves its 3:2 aspect. Added local animated rain, soft low-opacity ground shade, approach-based daylight/fill reduction and a strike point light. Dim broken ground fissures replace the bright warning ring; existing strike timing and thunder remain.
- Two targeted native simulator tests passed (5.576 seconds), covering lightning animation, loaded cloud texture, local lighting and restoration. Final Debug simulator build succeeded after the aspect-ratio correction; tests were not repeated for that fixed transform change. Specification validation passed 54 checks. Logs: `evidence/storm-native.log`, `evidence/storm-build.log`, `evidence/storm-spec.log`.
- Visually inspected actual approach and strike captures: `evidence/obstacle-lightning.png`, `evidence/obstacle-lightning-strike.png`. Capture script: `tools/capture_storm.py`. Image-generation tool, exact prompt and resource path: `docs/STORM_VFX.md`.
- This is a photographic card with local VFX, not volumetric weather. Physical-device realism/readability and transparency performance remain untested. Simulator render-pipeline warnings occurred; no full native/UI/Release iOS or core rerun in this renderer-only pass.

## Protect visual reality and earned void — September 15, 2026

- Fixed black palette selection erasing the entire ordinary background. Before 30 minutes, ordinary plates stay fully visible and palette black cannot suppress collage density. Later ordinary darkness retains at least 18% plate visibility and some imagery. Existing three-hour stripping, sparse void and rebuilding remain; lucky white is separate.
- Replaced the black error/startup fallback with a non-black lavender field, restored every frame after leaving void. Its brightness follows only the protected progression, so legitimate deep void remains black.
- The current opaque photo stays behind its incoming replacement. Standard overlaps use smooth 24-second alpha; one third of section choices linger for 48 seconds with both realities visible. Mirror/drop overlap remains 1.8 seconds. No fade-through-black.
- Stable scenes asynchronously preload their next deterministic photo, with cached selection and the existing maximum three-photo cache. Missing/failed plates are excluded for the session and a deterministic valid alternative is requested. Current imagery remains visible through failures. DEBUG-only fault injection does not affect production rewards.
- Final Release core checks: 15 tests passed, 0.427 seconds. Final Debug iPhone 16 Pro Max simulator build/test: two targeted tests passed, 9.205 seconds, including injected missing-photo recovery with no empty frame and eventual replacement, cache bounds and aspect ratio. Specification: 54 checks passed. Logs: `evidence/reality-core.log`, `evidence/reality-native.log`, `evidence/reality-spec.log`.
- Initial build caught a Float/CGFloat conversion, corrected before passing verification. Simulator emitted CAMetalLayer warnings; no physical-device loading/performance, full native suite, Release iOS or UI-automation pass. Transitions use alpha rather than spatial masks. The last-resort field is intentionally simple.
- Early black-palette DEBUG capture: `evidence/reality-black-palette.png`, reproducible using `tools/capture_reality.py`.

## Toy zebra, jail door and mace — September 15, 2026

- Replaced zebra hoop stripes with smooth, flush black/ivory surface bands, a rounded glossy toy silhouette, stout striped legs, hooves, muzzle, eyes, ears, upright mane and tufted tail. The open belly retains slide clearance. Removed the rejected zebra geometry.
- Descending window obstacle now renders as a barred jail door with crossbars, hinges, lock plate and keyhole. Lowest edge remains 0.85 m; descent and slide timing are unchanged.
- Swinging obstacle now renders as a glossy latex-red fourteen-spike mace with dark collar and alternating chain links. Tips fit inside the existing 0.38 m collision radius; the chain follows the existing swing. Updated visible Lab and death labels. No additional registered family or collision rule.
- DEBUG animals preview now exposes the zebra; `--obstacle-close` supports inspecting the models without rewards. Actual close simulator captures are in `evidence/models-gallery.html` and reproduce with `tools/capture_models.py`.
- Two targeted native tests passed (9.840 seconds): all 42 assets build with finite bounds, jail clearance, mace radius and obstacle animation. Nine Release obstacle tests passed (15.706 seconds). Specification validation passed 54 checks. Final Debug simulator build succeeded after deleting unreachable old zebra code; tests were not repeated for that cleanup. Logs: `evidence/models-native.log`, `evidence/models-core.log`, `evidence/models-spec.log`, `evidence/models-build.log`.
- Initial compile caught a malformed numeric literal; corrected before all successful checks. Simulator emitted render-pipeline warnings despite passing assertions. No physical-device/performance or full UI test pass; visual inspection used static simulator previews.

## Lightning impact audio — September 15, 2026

- Replaced the quiet 0.6-second synthesized tone with an original precomputed 3.6-second thunder strike: fast broadband crack, low impact, scattered echoes and decaying rumble. `tools/synthesize_thunder.py` reproduces the mono 22.05 kHz PCM resource; peak amplitude is bounded at 0.88.
- Preloads once into a dedicated thunder player. Lightning bypasses ordinary feedback debounce and cannot be cut off by balloons or stumble effects. Fatal lightning preserves the strike through the death transition; pause stops all audio. Effects, haptics, system volume and silent mode remain respected. Heavy strike haptic accompanies enabled haptics.
- Debug iPhone 16 Pro Max simulator build/test succeeded. One targeted native playback/resource test passed (0.246 seconds); nine Release core obstacle tests passed (35.370 seconds); specification validator passed 54 checks. Evidence: `evidence/thunder-native.log`, `evidence/thunder-core.log`, `evidence/thunder-spec.log`.
- No physical-device listening or subjective loudness assessment was performed. No full native suite, UI test, Release iOS build or performance soak in this audio-only pass.

## Curated DreamPlates — September 15, 2026

- Replaced all nine generated sky plates with **102 unique owner-curated backgrounds**, imported from 103 files (one exact duplicate). Reviewed all five contact sheets. Original source files remain untouched and outside the app bundle; optimized JPEGs, source hashes and generated catalog are included.
- Importer applies orientation, caps the longest side at 2048 pixels and deduplicates by full source SHA-256. Current optimized resources total approximately 97 MiB. Later arrivals require rerunning the importer and rebuilding; the current source hashes exactly match the manifest.
- Seeded shuffled selection visits the entire library before repeating, including no adjacent repeat across deck boundaries. Ordinary 24-second and mirror/drop 1.8-second crossfades remain. The 46 cutouts, independent atmospheric layers, clean gameplay corridor and void behavior remain.
- Photos load asynchronously on demand with at most three resident cached photo textures. Retired sky materials release their texture references. Aspect-fill uses each photo's true dimensions instead of stretching it. The 25-card pool is unchanged.
- Final targeted Release core suite: **13 tests passed**, zero failures, 1.028 seconds. Final Debug iPhone 16 Pro Max / iOS 26.5 simulator suite: **24 tests passed**, zero failures, 92.022 seconds; Xcode reported TEST SUCCEEDED. Specification validator: **54 checks passed**. Logs: `evidence/plates-core.log`, `evidence/plates-native.log`, `evidence/plates-spec.log`.
- Simulator still emitted CAMetalLayer allocation warnings. Tests establish bounded application cache and geometry behavior, not GPU memory, frame rate or device thermal performance. No physical-device, iPad, Release iOS or UI-automation test in this pass.
- Captured and visually inspected four actual simulator views: clouds, underwater, architecture and space. Gallery uses DEBUG previews with no rewards; these are static captures, not an endurance run.
- Import/build instructions and provenance limits: `docs/DREAM_PLATES.md`. Current background review: `evidence/plates-gallery.html`.

## Three-minute pigs — September 15, 2026

- Creator override: a pig is guaranteed every 180 active seconds. Lucky chance is exactly 1/3, reduced to 1/6 for future uncommitted events after a continue. Removed the presence RNG draw; retained the independent six-outcome clover stream, no lucky pity, three-collected-pig ending and nonterminal three-hour evolution.
- Updated runtime/config guards, DEBUG clock indexing, source and bundled contracts, all three golden fixture copies, Python reference/validator, acceptance criteria and authoring instructions. Existing six-second commitment/runway lead remains, with pause/restore and dedup regression coverage. Current prerelease rules replace the old tuning; no legacy gameplay branch was added.
- Exact probabilities: earliest nominal ending nine minutes (1/27 under ideal survival/collection); expected clean nominal time 27 minutes, all-reduced-odds time 54 minutes. These are not practical player win-rate claims.
- Full Release core suite: 58 tests executed in 181.763 seconds; 57 passed and one stale old-timestamp assertion failed. Corrected that assertion, then all 19 CoreTests passed in 0.873 seconds. The other 39 tests already passed unchanged. An accidentally broad second rerun was stopped before repeating the completed soak; it is not counted as a completed suite.
- Completed six-hour logical traversal for 20 seeds: 120 pig checkpoints per seed; bounded maxima 13 chunks / 13 hazards / 6 pickup-dedup entries. This is simulated logic, not physical-device or GPU endurance.
- Debug iPhone 16 Pro Max simulator build and all 23 native tests passed (73.640 seconds). Specification validator: 51 checks passed. Evidence: `evidence/pigs-core-initial.log`, `evidence/pigs-core-final.log`, `evidence/pigs-native.log`, `evidence/pigs-spec.log`.
- No physical-device timing, Release iOS build or UI automation in this pass. Existing simulator CAMetalLayer warnings remain.

## Ribbon trail removal — September 15, 2026

- Removed the purchasable Ribbon trail from source and bundled cosmetic catalogues. The renderer no longer draws it, including from an existing equipped selection.
- Added Wardrobe → No trail, which transactionally clears the trail slot and immediately refreshes the avatar. The separate achievement-only Void ribbon remains available.
- Specification validation: 51 checks passed. Debug iPhone 16 Pro Max simulator build passed (`evidence/trail-build.log`). No device or UI automation pass for this small removal.

## Composition hierarchy refinement — September 15, 2026

- Analyzed the owner's successful `app_target_01.jpeg`: cropped architecture, sky/stone superposition, tiny context and a quiet route. Full reasoning and limitations: `docs/COMPOSITION_REVIEW.md`.
- Four deterministic atmospheric arrangements now coordinate primary, opposing secondary and veil roles. Large atmospheric imagery and semantic scale diversity remain separate. No additional cards/textures/assets; existing staggered lifetimes and fades remain.
- Track surfaces favor solid fields where dense atmospheric silhouettes provide complexity. Pattern selection remains stable within 192 m surface segments.
- Verification: 16 targeted Release package tests passed, covering atmosphere, semantic scale, collage and track stability (0.640 seconds). 23 native simulator tests passed (72.915 seconds). A subsequent final Debug simulator build passed after the review palette correction and surface-boundary stabilization. Native suite was not repeated after those small corrections; the core suite covers surface stability and final captures exercise the review palette correction.
- Eight consecutive DEBUG seeds 0–7 at 60 m are recorded in `evidence/composition-gallery.html`; no hand-selected plates, palettes, track patterns or scale events. These static samples do not prove preference, moving-scene readability or device performance. Existing CAMetalLayer warnings remain.
- Specification validation: 51 checks passed. Test/build logs are under `evidence/composition-*.log`. No full core soak, UI automation, Release iOS build or physical-device performance pass for this visual change.

## Swipe response correction — September 15, 2026

- Fixed jump/slide waiting for finger release and silently rejecting gestures lasting over 450 ms. Recognition now commits while moving at 24 points with 1.2× vertical dominance, once per contact. Cancellation, completion and phase changes clear gesture state; simulator steering still resets on release.
- Added independently testable RunnerSwipe intent recognition. Jump physics, buffering, difficulty and hazard generation are unchanged. Updated the source/bundled input contract and specification to match.
- Verification: five targeted Release Swift package tests passed (four swipe regressions plus opening/capped-speed obstacle survival). Debug iPhone 16 Pro Max simulator build and all 23 native tests passed, 68.921 seconds. Logs: `evidence/swipe-core-tests.log`, `evidence/swipe-native-tests.log`, `evidence/swipe-spec.log`.
- Specification validator: 51 checks passed. Corrected reference validation to check the six required filenames, allowing additional owner reference images. The extra `references/app_target_01.jpeg` is untouched.
- No physical-device touch latency measurement, UI automation, full core soak or Release iOS build in this pass. Existing simulator CAMetalLayer allocation warnings remain; native test success is not a GPU-performance claim.

## Atmospheric scale correction — September 15, 2026

- Restored an independent three-slot atmospheric collage over the sky canvas: enormous
  translucent architecture/windows, ghost trees/organic forms and cloud/fabric/fog fragments.
  These do not consume the rare semantic scale event. Small props, inverse scale, underfoot
  scenery and partial landmark framing remain intact.
- Density supports 1–3 layers with gradual opacity ramps; void removes them and Low Power
  limits them to one. World-space motion, staggered replacement and 96 m fades retain continuity.
  Shared resources: 25 pooled cards, the same 55 textures and exactly 42 registered families.
- 13 targeted core tests passed after correcting an asset-selection closure that drew RNG
  repeatedly during lookup. 23 native simulator tests passed (42.593 s), including texture/pool
  retention, atmosphere presence and existing geometry/offline model checks. Debug build and
  51 specification checks passed. No new UI suite, full core soak or Release build ran.
- Simulator CPU sample: 660 submissions, median 0.477 ms, p95 0.502 ms, maximum 6.911 ms;
  separate palette-boundary sample 16.855 ms. This excludes GPU work and is not frame-rate proof.
  CAMetalLayer warnings remain in the simulator test log.
- Current visual evidence: `evidence/atmosphere-gallery.html`. The previous scale-only gallery
  documents the overcorrection and is not the current atmospheric appearance. Test logs:
  `evidence/atmosphere-core-tests.log`, `evidence/atmosphere-native-tests.log`.

## Smiley paper bag — September 14, 2026

The paper-hat cosmetic is now a fitted brown kraft bag covering the straw head, with an open
bottom, irregular folded edges and a crude red marker smile on the +Z rear face visible to the
chase camera. Shop name: Smiley paper bag; cosmetic ID and 150-balloon price remain unchanged.
Debug simulator build and the all-hats/both-characters fit test passed, including rear-face
placement and head coverage assertions (one native test, 0.928 s). Specification: 51 checks pass.
Evidence: `evidence/paper-bag-test.log` and rear gameplay capture `evidence/paper-bag.png`.
No new full core/UI suite, Release build or physical-device checks ran for this cosmetic edit.

## Relative scale composition — September 14, 2026

- One seeded scale-event budget per 768 m scene; only slot zero can become monumental/absurd.
  Selection: 60% no anomaly, 15% miniature, 19% oversized, 5% monumental, 1% absurd.
- Twelve small context slots, six ordinary slots and at most one modest oversized support.
  Monumental/absurd events suppress that extra oversized support. All four vignette ingredients
  obey this hierarchy. Scene subjects include horse, moon, chair, house, tree, window and arch.
- Roughly a third of supporting scenery sits below route level. Large landmarks can be framed
  whole, beneath the player, as crowns entering from below or as roots hanging from overhead.
  Partial objects extend beyond the frame rather than always displaying their full silhouette.
- Aspect/depth-aware sizes, smaller motion for small props and smooth approach fading stop
  ordinary cards becoming accidental giants. Cards retain world-space perspective and their
  assigned size until staggered replacement; no whole-scene resize at a boundary.
- DEBUG Lab provides all five scale cases and normal play clears the override. No new assets,
  textures or entities were added; 42 semantic families, gameplay, balloons and pig odds unchanged.
- 11 scale/collage package tests passed, including 10,000 seeded scene selections, one-landmark
  contrast budgets, inverse scale, approach fade and lower/partial framing. 23 native tests passed
  before final tuning; two targeted native tests passed after the final scale/framing changes.
  Debug simulator build and 51 specification checks passed. Tests recorded in
  `evidence/scale-core-tests.log`, `evidence/scale-native-tests.log`, `evidence/scale-final-native.log`, `evidence/scale-spec.log`.
- Matched simulator previews: `evidence/scale-gallery.html`. This is the current scale evidence;
  earlier pilot/balloon galleries document their respective earlier changes.
  No new Release build, complete core soak, UI suite or physical-device performance test ran.

## Moving balloon collection — September 14, 2026

- Balloon bodies bob, sway and gently rise on a deterministic active-time trajectory. About
  one quarter of ordinary pickups above 100 m float higher; a jump is needed when above reach.
  Safe-drop guide balloons stay low. All balloons have a tied neck and thin curved string;
  the bottom circle is removed.
- The renderer and swept three-axis pickup collision share the same motion. Contact must reach
  the balloon body, including while sliding/jumping; collection remains exactly once per ID.
- Collection replaces the balloon with seven fading fragments for 0.4 active seconds and a soft
  synthesized pop. At most 12 bursts live at once; repeated frames cannot replay the reward.
- The HUD shows a rising, fading +1 receipt at the balloon total and a small counter pulse.
  Rapid collections combine; Reduced Motion removes the travel/pulse. No extra XP currency/bar.
- 46 optimized core tests passed (96.842 s), including the 20-seed six-hour oracle, motion bounds,
  jump-only collection and duplicate protection. Native simulator suite: 22 passed; a subsequent
  targeted effects test passed after the final effects/audio changes. Debug simulator build passed.
  Specification validator: 51 passed. Logs: `evidence/balloon-core-tests.log`,
  `evidence/balloon-native-tests.log`, `evidence/balloon-effects-test.log`.
  Runtime motion and pop/counter evidence: `evidence/balloon-motion.mp4` and
  `evidence/balloon-collection.png`. The final counter receipt has a fixed intrinsic width
  after visual review caught its text being clipped by the narrow total.
- No new Release build, UI suite or physical-device performance tests ran for this change.

## Soccer ball correction — September 14, 2026

The soccer prefab now uses a spherical truncated-icosahedron panel layout: 12 black pentagons,
20 white hexagons and recessed seams. All LODs retain the pattern; its opaque black-and-white
material is independent of dream palette/style. The LOD0 mesh has 3,456 triangles, below its
3,500-triangle catalog target. Rolling behavior and collision rules are unchanged.
The Debug simulator build and two targeted native tests passed (all 42 prefab builders,
plus panel counts, spherical positions, outward winding across all three LODs and a rendered
preview). Specification validator: 51 checks passed. Evidence: `evidence/soccer-tests.log`
and visually inspected `evidence/soccer-preview.png`. No new physical-device or Release tests
were run for this isolated mesh correction.

## Current visual implementation

- One collage renderer and one Swift catalog: 22 owner-photo transparent objects and 122 owner-curated background plates. The earlier generated collage art and pilot review outputs were removed.
- Slim reed/twine straw doll, one articulated rig, modular outfits and fitted hats.
- Rear run, tucked jump and back slide; DEBUG cosmetic review looks.
- Track palette pairs, lacquer material and checkerboard/stripe/solid variations.
- Retained 25-card object pool and staggered palette updates; no whole-world rebuild at ordinary boundaries.
- Five photo-object vignettes, with source records in `data/dream_objects_intake.json`.
- DEBUG reviews and tests use isolated temporary profiles; no production rewards.

## Current difficulty and obstacle implementation

- Active-time speed curve: 12.25 → 16 at two minutes → 19 at five → 22 m/s at ten; then capped.
- Deterministic encounters become denser after 1,200 m and reach the hardest tier after 4,500 m.
- Oversized stair jumps, fatal floor gaps, exposed bridges, descending window underpasses,
  swinging moons, collapsing tiles, sleeping furniture, rolling volleys and dodgeable lightning.
- Lightning fixes a visible warning circle at least two active seconds before its 24-tick strike;
  the clock survives suspension and pauses with the run. Synthesized thunder respects effects settings.
- Ball contacts slow the runner and apply outward knockback; falling off an exposed edge is fatal.
  Continues clear both hazards and the recovery surface. Ordinary stairs and marked safe drops remain.
- Shared motion/collision trajectories, bounded horizon certification and off-display-thread lookahead
  warmup. Animated obstacles reuse entities; terrain changes only when its physical description changes.
- DEBUG Lab can run, freeze and replay every obstacle without currency or achievement grants.
- One current prerelease ruleset and development store; discarded rules and saves are unsupported.

## Checks run on September 14, 2026

- Specification validator: **51 checks passed** (`evidence/design-spec.log`).
- Optimized Swift package: **44 tests passed, zero failures**, 93.799 seconds
  (`evidence/design-core-tests.log`). Golden RNG, seed and pig fixtures pass unchanged.
- The full six-hour-plus-one-second oracle ran for **20 seeds / 25,921,200 ticks**.
  Every seed survived to 473,017 m and 27 pig commitments; maxima: 13 chunks, 13 hazards,
  six pickup deduplication IDs. H01 core soak executed; this is not a rendered/device soak.
- Eight additional seeds traversed twenty minutes across all speed stages. A 300-chunk
  certified manifest retained eight encounter kinds and 28 gaps with **zero fallbacks**.
- iPhone 16 Pro Max / iOS 26.5 Simulator: **21 native tests and 3 UI tests passed**
  (`evidence/design-native-final-tests.log`). Includes obstacle geometry, warning/strike visibility,
  retained animation entities, reward isolation, all 42 builders and offline flows.
- Renderer CPU sample: 660 submissions, median 0.529 ms, p95 0.601 ms, maximum 10.354 ms.
  Separate palette-boundary CPU sample: 32.783 ms. These exclude GPU work and do not establish frame rate.
  CAMetalLayer allocation warnings occurred in the test host despite passing assertions.
- Pilot regression tests cover deterministic scene selection, rare apparition cadence, shuffled
  deck coverage, bounded/reduced motion, all 55 texture loads and the retained 22-card pool.
  A stale 35-image test assertion was corrected; the complete package rerun passed.
- DEBUG simulator build: **BUILD SUCCEEDED**. Release simulator build: **BUILD SUCCEEDED**
  (`evidence/design-release-build.log`).
- Offline release preflight: **PASS** (`evidence/design-preflight.log`).
- Runtime captures: ten obstacle previews in `evidence/obstacle-gallery.html`; retained current
  art/wardrobe review in `evidence/design-gallery.html`. Capture scripts use isolated DEBUG profiles.

Use `README.md` for building and `docs/OWNER_SETUP.md` for external service configuration.
See `KNOWN_LIMITATIONS.md` for unverified acceptance criteria; this is not App Store certification.

The G2/R2 prerelease uses a fresh `profile-g2-r2.json` development profile. The previous
`profile.json` stays on disk unchanged; its wallet, settings and bookmarks are not migrated.

## Wardrobe preview and categories — September 24, 2026

- The wardrobe displays the existing RealityKit straw doll as the try-on model. Tapping any catalogue item temporarily dresses that model without a wallet transaction or ownership grant; Buy and Equip remain explicit actions.
- Items are grouped under Head, Top and Bottom. The former body selection is now a free skirt in Bottom; Top colors tint the ribbon and sash. The shared straw rig never changes for an outfit.
- Specification validation: 54 checks passed. iOS Simulator Debug build: succeeded. Focused wardrobe UI test: passed. Two straw-doll renderer tests: passed. Focused Swift wallet test: passed. The older combined gameplay/menu UI test failed before reaching the wardrobe because the run ended before its pause assertion.
# Review request (2026-09-24)

- The results screen waits two seconds and requests Apple's standard review sheet after a prime-numbered completed Fresh run (2, 3, 5, 7, 11, …). The most recent requested run count is persisted so a reopened result cannot trigger another request. Tutorial, Revisit and Debug runs do not count. Apple controls whether a sheet appears; no rating or review is rewarded or required.
- The focused prime-run review test and `python3 tools/validate_spec.py` passed; a Debug arm64 iOS Simulator build was checked. Actual review-sheet display was not exercised; StoreKit may suppress it. Ad-removal product behavior remains a product decision because the current only ad is an optional rewarded continue.

### AdMob rewarded continue integration (2026-09-24)

- Reused Align&Reveal's pinned Google Mobile Ads 13.9.0 and UMP 3.1.0 Swift packages. The owner's AdMob app ID is in `Configuration/Info.plist`; the rewarded unit ID is in `DreamAdConfiguration` and the disabled example service configuration.
- The Google adapter refreshes consent, loads a rewarded ad, records an earned callback against the run that offered it, and reloads after dismissal. Settings exposes UMP privacy options when required.
- The Debug Lab can request Google's test rewarded unit without granting a production continue. Live inventory stays disabled pending owner consent setup and explicit authorization.
- `python3 tools/validate_spec.py`, plist lint, and Debug and Release arm64 iOS Simulator builds passed. No live ad or on-device test was performed.

## Wardrobe rotation and lighting — September 25, 2026

- The wardrobe now reserves a fixed try-on stage beneath its header. Horizontal dragging rotates the same RealityKit straw doll; Turn left, Turn right and Reset view are accessible alternatives. Trying on another item preserves the chosen viewing angle.
- The preview uses brighter front and fill lights, a lighter background, and a subtle procedural halo behind the doll. These presentation elements are disabled during gameplay and the asset lab.
- A simulator Debug build and the focused wardrobe UI test passed. The test exercised both turn buttons, drag rotation and an unpurchased hat preview. The screenshot is `evidence/wardrobe-rotation-preview.png`; it shows clear header spacing and a side view after dragging. No physical-device test was performed.

## Wardrobe halo refinement — September 25, 2026

- Replaced concentric halo meshes with one procedural alpha-gradient card behind the straw looper and centered the wardrobe camera to remove perspective parallax.
- The focused wardrobe UI test passed on the iPhone 16 Pro Max simulator; `evidence/wardrobe-rotation-preview.png` was refreshed from that run and visually checked for centering and soft falloff.

## Wardrobe halo falloff — September 25, 2026

- Reduced the procedural halo's peak opacity, increased its spread, moved its tint closer to the preview background, and used fine dither to prevent visible alpha bands or a circular cutoff.
- The focused wardrobe UI test passed on the iPhone 16 Pro Max simulator. `evidence/wardrobe-rotation-preview.png` is the updated screenshot reviewed for the softer fade.

## Dream whispers — September 25, 2026

- Replaced the tutorial capsule toast with a centered, lower top-of-screen Marker Felt scrawl: white lettering, thin black outline and a soft shadow. The overlay does not intercept gameplay gestures. The tutorial prompts pair a short instruction with dreamlike copy.
- Fresh and Revisit runs now receive brief, deterministic whispers after the tutorial. Selection can reflect a nearby rabbit, a prior visit or mirror, collected pigs, missing straw, a continue or the later visual phase. The separate seed stream does not alter world generation or rewards. Rabbit eyes now match the red-eyed warning.
- Focused Swift core tests: 2 passed. Focused iPhone 16 Pro Max simulator UI test: 1 passed. `python3 tools/validate_spec.py`: 54 checks passed. `git diff --check`: passed. The UI capture `evidence/dream-whisper-tutorial.png` was inspected for complete two-line text and contrast. The later timed whispers were verified in core tests, not a long rendered simulator run; no physical-device test was performed.
- Refined the scrawl to blend its fill from the active palette's accent and track light, with a dark plum tint drawn from the palette's track dark. It now rises and fades in, then lifts and fades out; Reduced Motion uses a short fade only. The focused iPhone 16 Pro Max simulator UI test passed again, and `evidence/dream-whisper-tutorial.png` was refreshed from the pale citrus scene. The animation path is implemented but was not captured as video.
- Replaced the Marker Felt lettering after visual review with Baskerville SemiBold in lowercase. A narrow palette-plum edge and close soft shadow keep the blush text readable over changing collage backgrounds without the former heavy black outline. The focused simulator UI test passed; `evidence/dream-whisper-tutorial.png` shows the revised type over a noisy dark-green scene. A dark-ink-only version and an unedged pale italic version were rejected after simulator captures because each lost contrast in one scene.

## Camera drift prototype — September 25, 2026

- Gameplay's close third-person camera now has small, slow, seed-stable lateral/vertical drift and a slight roll. Motion gently grows near a mirror or after a soft stumble, then settles. It does not change the player route, collision state, or camera framing target beyond a small aim offset.
- The camera remains steady in menus, Debug review and with Reduced Motion enabled. Pure core tests passed for bounds, frame-to-frame continuity, mirror emphasis and disabled states. A focused iPhone 16 Pro Max simulator renderer test passed for the enabled/reduced-motion camera positions, and the Debug iOS Simulator build succeeded. `python3 tools/validate_spec.py` passed 54 checks. No physical-device comfort test or recorded motion comparison was performed.

## Stitched storm redesign — September 25, 2026

- Replaced the photographic charcoal `storm-threat.png` with the original transparent `storm-stitched.png`: layered lavender/rose thundercloud with a muted plum underside, pearl-cyan charge and fine gold seams. The rejected source art was removed. This remains the registered cloud family; no new world asset was added.
- Kept the thunder sound, deterministic strike timing, collision and route warning. Retuned local rain and the ground char toward the scene's lilac palette. Lightning instances attach directly to the scene so an asynchronous texture load can fill an already visible hazard.
- The Debug iOS Simulator build and two focused native storm tests passed. The 22-meter warning view and approach/close/strike captures were visually reviewed; `evidence/storm-rework-warning.png` shows the final scale. The gallery's earlier lightning screenshots were replaced. No physical-device or sustained performance test was performed.
- A separate clean Debug iOS Simulator build also succeeded after deleting the rejected image. Its app bundle contains `storm-stitched.png` and no `storm-threat.png`. `python3 tools/validate_spec.py` passed 54 checks and `git diff --check` passed.

## Hawaiian tutu bottom — September 25, 2026

- Added a 700-balloon Hawaiian tutu to the Bottom wardrobe category. It can be tried on before purchase; buying and equipping remain separate.
- The original straw rig now wears open seafoam raffia fringe, a woven waistband and small coral flowers for this item. The plain bottom and straw skirt retain their own looks.
- Focused renderer and wardrobe UI tests passed on the iPhone 16 Pro Max simulator. The preview screenshot was visually checked and saved as `evidence/hawaiian-tutu-preview.png`. `python3 tools/validate_spec.py` passed 54 checks, and `git diff --check` passed. No physical-device test was performed.

## Dream narrator copy and cadence — September 25, 2026

- Tutorial prompts use the user's playful wording while retaining tilt, swipe and rabbit safety instructions. General lines mix genuine encouragement with a sweet, possessive wish for the looper to stay in the dream.
- General whispers have a four-second window at 2 minutes, then every 4 minutes. State-dependent lines have a one-in-five deterministic opportunity every 45 seconds. Nearby rabbit and lucky clover-pig lines each get a stable one-in-five roll per encounter, so frame-by-frame evaluation cannot make them inevitable.
- Four focused Swift core tests passed, including cadence and encounter-gating checks. A Debug iOS Simulator build succeeded. `python3 tools/validate_spec.py` passed 54 checks and `git diff --check` passed. No physical-device test was performed.
- The user revised four general narrator lines to: “u can do this. stay.”, “u will make it. go! go! go!”, “i will always be here”, and “i'm rooting for u. always. promise”. The four focused Swift tests and `git diff --check` passed again after this copy edit.

## Coordinated wardrobe outfits — September 25, 2026

- Added a free No ribbon top and made bare straw the default top for new profiles. Ribbon choices remain wearable, but their sash and bow no longer appear under the coconut bra or office jacket. The straw skirt's apron now uses its own neutral color.
- Added a coconut bra top, a fitted flower crown, an ink-plum office tuxedo jacket, and matching tuxedo pants with shoes. Garment sleeves and pant legs attach to the existing articulated straw limbs; no body shape or gender option was added.
- Wardrobe selections now persist across Head, Top and Bottom during a try-on, so users can assemble whole outfits without buying any piece. The selected item in each category stays highlighted, and the preview's accessibility value names all three pieces.
- Focused native and UI simulator tests passed for ribbon removal, garment switching, hat fit and unpaid cross-category combinations. The combined tutu look and office look were visually reviewed in `evidence/wardrobe-island-outfit.png` and `evidence/wardrobe-office-outfit.png`. A final Debug iOS Simulator build succeeded. `python3 tools/validate_spec.py` passed 54 checks; the two cosmetics catalogs match and `git diff --check` passed. No physical-device test was performed.

## Background cutout sourcing audit — September 26, 2026

- Added `docs/BACKGROUND_ASSET_REPLACEMENT.md` to distinguish the 102 owner-curated full-frame photos from the 54 generated transparent collage cutouts and to prioritize the large atmospheric silhouettes for owner sourcing.
- Checked the manifest count (102), cross-checked all 54 cutout IDs against the sourcing list, and ran `git diff --check`. This is a sourcing guide only; no runtime imagery was replaced in this pass.
