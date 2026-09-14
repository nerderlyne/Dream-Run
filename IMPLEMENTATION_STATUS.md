# Dream Again implementation status

Native SwiftUI + non-AR RealityKit first playable, with a separate deterministic Swift core,
shared Xcode scheme, offline progression, save/share, suspend/resume, achievements and audio.
Exactly 42 procedural world families remain; pig is #42. Balloons buy cosmetics only.
The locked pig/continue probabilities and nonterminal three-hour evolution are unchanged.

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
