# Dream Again implementation status

Native SwiftUI + non-AR RealityKit first playable, with a separate deterministic Swift core,
shared Xcode scheme, offline progression, save/share, suspend/resume, achievements and audio.
Exactly 42 procedural world families remain; pig is #42. Balloons buy cosmetics only.
Pigs now arrive every three active minutes with 1/3 lucky odds (1/6 after continue). The nonterminal three-hour evolution remains unchanged.

## Quieter running — September 16, 2026

- Lowered ordinary, watery and stair running footfalls to 0.14 of their previous amplitude (approximately −17 dB). Original contact transients and surface timbres remain; jump/landing and other interaction levels are unchanged.
- Debug simulator build succeeded; `git diff --check` passed. Build log: `evidence/footfall-build.log`. No new tests for this gain-only adjustment; subjective headphone audibility remains to be assessed by the owner. No physical device testing.

## Adaptive dream soundtrack and theta — September 16, 2026

- Replaced the single runtime-generated ambient tone with six crossfading environment beds, a seed-selected three-note motif, a restrained pulse, and original movement/interaction sounds. Accepted jumps/slides/landings and distance-based footfalls use simulation state; pickups form a rate-limited phrase. Mirrors, safe drops, crowded hazards, void, Lucky Dream and three-hour stripping/rebuilding alter the mix. No gameplay RNG, rewards or timing changed.
- Added separate Music/Effects levels and an independent, persisted, default-off theta headphone option. Theta is a true 200 Hz left / 206 Hz right pair with its own gentle gain ramp; it bypasses reverb. Speaker/AirPlay/HFP routes and Mono Audio suppress it. Bluetooth headphone use requires the player's confirmation via the labeled opt-in. Pause/background/interruption stops audio; unplugging pauses gameplay; fatal lightning retains its strike without restarting music.
- Bundled 25 original synthesized WAVs (about 11 MB), reproducible with `tools/audio/generate_dream_audio.py`. Native graph has bounded one-shot voices, preloaded buffers and mix headroom. See `docs/DREAM_AUDIO.md` for architecture, settings and build/test commands; provenance is in `ASSET_LICENSES.md`.
- Verification: specification validator **54 checks passed**; full Release Swift core suite **68 tests passed** (104.028 seconds); final targeted core audio rerun **4 passed** (0.027 seconds). Debug simulator build-for-testing succeeded. On iPhone 16 Pro Max / iOS 26.5 simulator, **3 native audio tests passed** (2.556 seconds), checking all assets, theta channel amplitudes/crosstalk, independent music controls, pause/waking/Lucky Dream and thunder lifecycle. **1 settings UI test passed** (35.678 seconds), exercising opt-in, level adjustment and save/navigation. Initial UI test exposed duplicate slider accessibility labels; fixed before passing. Sandbox compiler/simulator/report access required escalated reruns. Logs: `evidence/audio-spec.log`, `audio-core.log`, `audio-core-final.log`, `audio-native.log`, `audio-ui.log`.
- Settings screenshot: `evidence/audio-settings.png`. No physical iPhone testing, subjective headphone listening, comfort study, sustained thermal/audio performance measurements, Release iOS build or full native/UI suite in this pass. Theta has no proven dream/hypnosis claim; Bluetooth A2DP cannot reliably distinguish headphones from speakers. Known limits are recorded separately.

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

- One current collage renderer and one Swift catalog: 46 transparent ingredients, nine skies (55 images total).
- Six additional atmosphere plates: space, underwater, aurora, mirage, lavender mist, opal dawn.
- Slim reed/twine straw doll, one articulated rig, modular ribbons, skirt/apron/lace and fitted hats.
- Rear run, tucked jump and back slide; five DEBUG cosmetic review looks.
- Twelve vivid track palette pairs; lacquer material, dominant checkerboard, occasional stripes/solids.
- Rectangular black mirror interior fitted inside a gold frame.
- Retained object pool and staggered palette updates; no whole-world rebuild at ordinary boundaries.
- Removed obsolete sky dome, cloud/horizon renderer, generic mannequin, unused USDZ adapter,
  old presentation-version branches, duplicate manifest, quarantined experiments and historic reviews.
- DEBUG reviews and tests use isolated temporary profiles; no production rewards.

## Background variety pilot

- Twenty original, independently layerable PNGs: six sea creatures, four cultural apparitions,
  and ten domestic/natural ingredients. Exact generation prompts and provenance:
  `docs/COLLAGE_PILOT.json`; runtime metadata: `DreamPilotKit.swift`.
- Five seeded compositions: Whale Cottage, Jelly Garden, Inverted Procession, Floating Bedroom,
  Midnight Kitchen. Four separate cards per composition, world-space parallax and bounded drift,
  bob, rotation or pulse. Reduced Motion disables local animation; Low Power omits story cards.
- Every five 640 m cells visit all five compositions. The kitchen occurs once per 3,200 m;
  cultural apparitions are excluded from ordinary scenery selection. Per-slot shuffled decks
  prevent immediate repetition and expose all eligible images before repeating a deck.
- Exactly 42 families: curved/straight stairs share #4, mountains share rock #22, freeing #5
  for sea creatures and #23 for cultural apparitions. Pig remains #42; no compatibility aliases.
- Fixed 22-card pool including two skies. All 55 textures preload; no new background colliders.
- Twenty PNGs add 4,942,083 bytes, 20 MiB decoded RGBA / estimated 26.67 MiB with full mipmaps.
  These are arithmetic budgets, not measured resident GPU memory. All alpha audits passed,
  with transparent margins and zero occupied edge pixels (`evidence/pilot-alpha.jsonl`).
- Five actual simulator screenshots and a moving capture: `evidence/pilot-gallery.html`.
  DEBUG Lab exposes each composition and cannot grant production rewards.

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
