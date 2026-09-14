# Known limitations

- Physical iPhone/iPad tilt, frame pacing, GPU memory, thermals and sustained rendering have not
  been measured in this pass. Simulator CPU timing is not device performance evidence; the
  native test process emitted CAMetalLayer drawable-allocation warnings despite passing assertions.
- The six-hour/20-seed core traversal oracle was not rerun in this pass. The bounded traversal,
  RNG, seed, pig, persistence and current renderer tests were run.
- Straw-doll structural reference images mentioned in the request were not supplied. The model
  follows the written reed/twine construction. Cloth and straw use articulated geometry, not physics.
- Selected runtime screenshots are visual evidence, not approval of every asset/material/LOD,
  seed, collision encounter, hat/action combination or small-phone/iPad layout. The remaining
  procedural world families vary in polish. Full reference-quality art acceptance remains open.
- Atmosphere is layered images, not volumetric clouds/water or true planar reflections.
  Oblique viewing can expose cards; ordinary gameplay uses the constrained third-person camera.
- Local StoreKit purchase-sheet scenarios, live sandbox purchases, real ads/consent, Game Center,
  Universal Links and cloud integration were not executed. Owner provisioning remains required;
  offline gameplay is independent. See `docs/OWNER_SETUP.md`.
- The wallet has checksums, atomic replacement, backup recovery and idempotent delivery. Actual
  disk-full/interruption tests and a cloud consumable-currency ledger remain outstanding.
- No backward compatibility is promised for discarded prerelease art versions or development saves.

Acceptance gaps: A03/A04 (complete screens/error states and device-size matrix), B03 (physical
tilt), C02–C06 (full silhouette/material/mood/semantic-contrast and render-budget review),
E09 (full gallery/share flow), G06/G07 (StoreKit and actual rewarded-ad scenarios), H01
(six-hour oracle not rerun), H02 (physical render soak), and H04 (device interruptions and
storage faults). The static contrast scene partly occludes the zebra behind the horse and
the pig behind a balloon; it is not complete moving-encounter visibility evidence.
No simulator screenshot establishes physical-device or store readiness.
