# Dream Again implementation status

Native SwiftUI + non-AR RealityKit first playable, with a separate deterministic Swift core,
shared Xcode scheme, offline progression, save/share, suspend/resume, achievements and audio.
Exactly 42 procedural world families remain; pig is #42. Balloons buy cosmetics only.
The locked pig/continue probabilities and nonterminal three-hour evolution are unchanged.

## Current visual implementation

- One current collage renderer and one Swift catalog: 26 transparent ingredients, nine skies.
- Six additional atmosphere plates: space, underwater, aurora, mirage, lavender mist, opal dawn.
- Slim reed/twine straw doll, one articulated rig, modular ribbons, skirt/apron/lace and fitted hats.
- Rear run, tucked jump and back slide; five DEBUG cosmetic review looks.
- Twelve vivid track palette pairs; lacquer material, dominant checkerboard, occasional stripes/solids.
- Rectangular black mirror interior fitted inside a gold frame.
- Retained object pool and staggered palette updates; no whole-world rebuild at ordinary boundaries.
- Removed obsolete sky dome, cloud/horizon renderer, generic mannequin, unused USDZ adapter,
  old presentation-version branches, duplicate manifest, quarantined experiments and historic reviews.
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
- Optimized Swift package: **41 tests passed, zero failures**, 91.251 seconds
  (`evidence/design-core-tests.log`). Golden RNG, seed and pig fixtures pass unchanged.
- The full six-hour-plus-one-second oracle ran for **20 seeds / 25,921,200 ticks**.
  Every seed survived to 473,017 m and 27 pig commitments; maxima: 13 chunks, 13 hazards,
  six pickup deduplication IDs. H01 core soak executed; this is not a rendered/device soak.
- Eight additional seeds traversed twenty minutes across all speed stages. A 300-chunk
  certified manifest retained eight encounter kinds and 28 gaps with **zero fallbacks**.
- iPhone 16 Pro Max / iOS 26.5 Simulator: **21 native tests and 3 UI tests passed**
  (`evidence/design-native-final-tests.log`). Includes obstacle geometry, warning/strike visibility,
  retained animation entities, reward isolation, all 42 builders and offline flows.
- Renderer CPU sample: 660 submissions, median 0.235 ms, p95 0.256 ms, maximum 8.404 ms.
  Separate palette-boundary sample: 19.514 ms. These exclude GPU work and do not establish frame rate.
  CAMetalLayer allocation warnings occurred in the test host despite passing assertions.
- Test-driven fixes: moon oracle changed direction too soon during a trailing sweep; corrected it
  and passed the full soak. A Lab proof selected the intentional void palette after old rules were
  removed; fixed the preview selection and reran native/UI tests. Runtime review also corrected
  a back-facing stair riser and an occluded lightning warning ring.
- DEBUG simulator build: **BUILD SUCCEEDED**. Release simulator build: **BUILD SUCCEEDED**
  (`evidence/design-release-build.log`).
- Offline release preflight: **PASS** (`evidence/design-preflight.log`).
- Runtime captures: ten obstacle previews in `evidence/obstacle-gallery.html`; retained current
  art/wardrobe review in `evidence/design-gallery.html`. Capture scripts use isolated DEBUG profiles.

Use `README.md` for building and `docs/OWNER_SETUP.md` for external service configuration.
See `KNOWN_LIMITATIONS.md` for unverified acceptance criteria; this is not App Store certification.
