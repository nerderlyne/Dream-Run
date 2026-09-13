# Dream Again

Native SwiftUI + non-AR RealityKit runner for iPhone and iPad, targeting iOS 18. The supplied specification and reference data remain at the repository root. Original procedural geometry and synthesized audio are implemented in the app; mood-reference images are not production resources.

## Run

1. Open `Dream Again.xcodeproj` in Xcode 26.6 or a compatible stable Xcode.
2. Select the shared **Dream Again** scheme and an installed iOS Simulator. Run. The scheme attaches `DreamAgain.storekit` for local purchase testing.
3. Tap **dream**, then **ready**. The first attempt is the introduction. Tilt left/right to steer and swipe up/down to jump/slide. On Simulator, drag left/right anywhere on the playfield; **jump ↑ / slide ↓** buttons remain available. Tilt is the fixed device control; there is no steering-mode setting or gameplay slider. Drag input exists only in Simulator builds.
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

Original app icon art is supplied in `Dream Again/Resources/DreamAgainIcon.png` with legacy bundle metadata. Production asset-catalogue renditions require validation after simulator access is available.
