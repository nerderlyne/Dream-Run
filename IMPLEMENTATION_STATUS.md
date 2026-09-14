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

## Checks run on September 14, 2026

- Specification validator: **51 checks passed** (`evidence/design-spec.log`).
- Swift package: **31 tests passed, zero failures** (`evidence/design-core-tests.log`).
  The six-hour/20-seed traversal oracle was excluded from this run.
- iPhone 16 Pro Max / iOS 26.5 Simulator: **19 native tests and 3 UI tests passed**
  (`evidence/design-native-final-tests.log`). Tests cover all 42 builders, retained transitions,
  texture loading/pooling, shared cosmetic rig, debug isolation and offline start/pause/wardrobe.
- Renderer CPU sample: 660 measured updates, median 0.234 ms, p95 0.308 ms, maximum 6.654 ms.
  This is CPU submission time, not GPU time or frame rate. Simulator allocation warnings occurred.
- Initial native attempt failed because the simulator contained a removed art-version save.
  Removed the obsolete development install and isolated review/test profiles, then reran successfully.

- Release generic iOS Simulator build: **BUILD SUCCEEDED** (`evidence/design-release-build.log`).
- Offline release preflight: **PASS** (`evidence/design-preflight.log`).
- 21 current runtime captures: `evidence/design-gallery.html`; review notes in `evidence/design-review.md`.
Use `README.md` for building and `docs/OWNER_SETUP.md` for external service configuration.
See `KNOWN_LIMITATIONS.md` for unverified acceptance criteria; this is not App Store certification.
