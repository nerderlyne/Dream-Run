# Dream Again

Native SwiftUI + non-AR RealityKit runner for iPhone and iPad, targeting iOS 18. The supplied specification and reference data remain at the repository root. Original procedural geometry and synthesized audio are implemented in the app; mood-reference images are not production resources.

## Run

1. Open `Dream Again.xcodeproj` in Xcode 26.6 or a compatible stable Xcode.
2. Select the shared **Dream Again** scheme and an installed iOS Simulator. Run. The scheme attaches `DreamAgain.storekit` for local purchase testing.
3. Tap **dream**, then **ready**. The first attempt is the introduction. Tilt left/right to steer and swipe up/down to jump/slide. On Simulator, drag left/right anywhere on the playfield. Jump and slide use vertical swipes only, with no action buttons. Tilt is the fixed device control; there is no steering-mode setting or gameplay slider. Drag input exists only in Simulator builds.
4. Pause for recalibration or **save & leave**. Resume keeps the attempt; a saved/imported dream starts from its beginning as **Revisit**.

The existing owner's bundle identifier and team settings have been preserved. No signing, provisioning, live products, advertisements, or publishing were performed. Generic simulator builds disable signing.

## Verify

```sh
python3 tools/validate_spec.py
python3 scripts/release_preflight.py
swift test -c release
xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again' \
  -configuration Debug -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing
xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again' \
  -configuration Release -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
```

To **execute** app/UI tests, select an available device in Xcode and use Product → Test, or replace the generic destination with an installed simulator's name and use `test`. Build-for-testing only compiles the test bundles. Actual execution evidence and limitations are in `IMPLEMENTATION_STATUS.md` and `KNOWN_LIMITATIONS.md`.

## Debug Lab

Debug Home → **Lab · developer previews**. All 42 assets are selectable in order. Cycle eight material treatments, twelve palettes and three mesh detail levels, or show role bounds. Paste a Dream ID for a world preview and step 24 logical metres. Event buttons expose rabbit/nazar/ball/animal contacts, mirror/drop, ordinary/clover pigs, Lucky Dream, three-hour stripping, sparse, beyond and waking. The ledger scenarios use an isolated in-memory profile. Ad scenarios say **Developer test reward**. Export diagnostics includes the logical run and versioned seed, not the wallet or account identifiers.

Every Lab gameplay override changes the run to Debug, which cannot settle currency, records or achievements. Release does not contain Lab entry points or mock rewards. Real input controls do not change eligibility.

## Source map

- `Dream Again/Core`: independently compiled Swift package target; RNG, Dream IDs, rules, generation, 60 Hz movement/collision, pig/visual states and transactional profile store.
- `Dream Again/Rendering`: original mesh builders, 42-family registry rendering, local-origin streamed route, perspective camera and humanoid/cosmetics.
- `Dream Again/Services`: lifecycle, Core Motion, synthesized audio/haptics, StoreKit and optional service seams.
- `Dream Again/Resources`: matching data contracts and local StoreKit configuration.
- `Tests/DreamCoreTests`: fixtures, mechanics, accounting, recovery and twenty-seed six-hour oracle soak.
- `Dream AgainTests`, `Dream AgainUITests`: native resource/geometry checks and UI smoke test, compiled separately from package tests.
- `docs/OWNER_SETUP.md`: signing, purchases, optional ads/services and release setup.

## Storage and identity

The serialized profile uses a checksummed JSON envelope with atomic replacement, a last-good backup and quarantine of damaged input. Wallet lots, ownership, grants, achievements, settlements and the suspended snapshot participate in one serialized transaction. This is the equivalent-store implementation permitted by the specification; the supplied SQLite schema remains a reference. The wallet is not stored in UserDefaults.

Snapshots occur every 15 active seconds and on pause, rare-event commitment/collection and endpoint changes. Abrupt termination can lose progress since the last successful snapshot. Purchases finish only after the grant is persisted. Consumable balances are local data, not automatically reconstructed from StoreKit history.

A `.dream` file contains only `format` and `dreamID`, is limited to 32 KiB and always imports as Revisit. The custom URL is `dreamagain://dream/<code>`; no owned HTTPS domain or universal association is claimed.

Current running speed starts at **12.25 m/s**, rising to **16 m/s at two minutes, 19 m/s at five minutes, and a 22 m/s cap at ten minutes**. Steering spans **±0.9 m**,
with 6 m/s lateral movement, 40 ms smoothing and 12° calibrated full-scale tilt.

Dreams use the current 55-image collage pipeline, a straw doll runner and vivid track materials. Balls approach at **8 m/s**, with **10 m/s** volleys in the hardest tier and rotate with their travelled distance. There is no alternate legacy art renderer.

For the collage proof, open the DEBUG Lab and choose collage 1–5. Use run/freeze to inspect world-space motion. Simulator launch arguments are `--art-review --collage-scene 0` (0–4), optionally `--collage-moving`. All proof runs are DEBUG-only and earn no rewards. Details and exact kit contents: [collage pipeline](docs/HYBRID_COLLAGE_PIPELINE.md).

The visible path continues roughly 6.1 km ahead using simplified distant geometry that blends into the sky. Detailed scenery and gameplay remain streamed nearby.

### Current visual review

See [visual direction](docs/VISUAL_ART_DIRECTION.md) and [current captures](evidence/design-review.md).
The straw doll, six new atmosphere plates, mirror and track palette comparisons are captured
from the actual simulator renderer. Historical art branches and superseded review files are removed.


## Difficulty and obstacles

New runs use one current ruleset and a fresh `profile.json` development store. Old prerelease
rules/saves are unsupported; no compatibility implementation is retained.
The deterministic generator mixes oversized stair jumps, broken floors, exposed bridges,
low windows, swinging moons, collapsing tiles, sleeping furniture, ball volleys and the
existing animal hazards. Ordinary stairs remain automatic. Amber broken-edge marks identify
fatal gaps; the established white double marks identify safe drops. Ball hits slow and push
the runner sideways, so contact near an exposed bridge edge can end the run.

Lightning marks a fixed circle at least two active seconds before a short strike. Tilt clear
of that circle; jumping does not avoid lightning. Pausing also pauses its warning clock.
Patterns become denser after 1,200 metres and reach their hardest tier after 4,500 metres.
The speed cap does not end the run or change pig probabilities.

In DEBUG, open **Lab** and select any obstacle. Use **run**, **freeze**, and **again** to
practice its actual collision behavior without earning rewards. For a static lightning
strike preview, launch with `--art-review --design-review --obstacle lightning --strike`.

The background pilot adds 20 transparent ingredients and five animated compositions. In DEBUG Lab,
select Whale Cottage, Jelly Garden, Inverted Procession, Floating Bedroom or Midnight Kitchen.
Launch a specific one with `--art-review --design-review --vignette 0` (0–4), optionally
`--collage-moving`. See [runtime gallery and motion clip](evidence/pilot-gallery.html) and
[exact prompts and provenance](docs/COLLAGE_PILOT.json). These previews earn no rewards.

Relative scale previews: DEBUG Lab → Quiet scale / Miniature / Oversized / Monumental / Absurd.
Use `--art-review --design-review --scale-event 0` (0–4) for matched captures.
[Current scale comparison](evidence/scale-gallery.html) shows the same seed with each event forced.

Vertical framing previews are also in DEBUG Lab: World below / Crown from below / Roots overhead.
Use `--scale-event 4 --scale-framing 2` with the art-review flags for the crown-from-below case.

The current atmosphere uses independent large translucent layers over sky plates, alongside
semantic scale diversity. [Current atmospheric comparison](evidence/atmosphere-gallery.html)
shows normal seeded dreams and a scene with a separate rare landmark.
