# Dream Again implementation status

Native SwiftUI + non-AR RealityKit first playable, with a separate deterministic Swift core,
shared Xcode scheme, offline progression, save/share, suspend/resume, achievements and audio.
Exactly 42 procedural world families remain; pig is #42. Balloons buy cosmetics only.
The locked pig/continue probabilities and nonterminal three-hour evolution are unchanged.

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
