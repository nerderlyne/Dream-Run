# Known limitations and unmet acceptance criteria

This is an implemented native first-playable build, with automated core evidence. It is **not a claim that every acceptance criterion is complete** or that the game is App Store ready.

## Implementation limitations

- **D02 / D04: certification is bounded witness coverage, not an exhaustive reachability proof.** Each candidate is checked with the authoritative movement/collision engine over the previous two chunks, three entry offsets, ascending/descending grade bounds and early/mid/capped speeds. Incompatible sequences are retried up to eight times, then replaced with a safe breathing chunk. Normal encounters use a 48 m cadence with transition buffers. The oracle and an incompatible jump/slide regression test cover this implementation; arbitrary human reaction delays and every reachable airborne/unstable entry state are not exhaustively enumerated.
- **C04 / D03: aesthetic and visibility review is outstanding.** All 42 builders, eight material treatments, twelve palettes and three detail levels exist. Their silhouettes, checker filtering, close-camera framing, animal clearance and two-second *actually visible* warning distances have not been inspected in rendered simulator/device screenshots. Procedural geometry/materials are first-pass stylization; asset polish is not certified.
- **H02 / C06: rendering budgets are targets, not measurements.** Geometry/material caches and streamed chunks are bounded. Lab counts entities and generated geometry, but GPU draw calls, resident memory, restart latency, thermal behavior and sustained frame pacing are unmeasured. The 20-seed soak tests core state growth, not RealityKit memory or battery use.
- **A03 / E09:** menu actions, sharing, file import and bounded thumbnail generation are implemented, but native UI execution has not been observed. Result sharing supplies a scene snapshot when available plus a caption/card; its final composition needs visual review. Wardrobe and small-phone/iPad layouts likewise need UI review.
- **H04:** checksum validation, backup recovery, malformed import rejection and transaction rollback have automated coverage. Actual disk-full, interrupted atomic replacement, lock/call/headphone and motion-staleness behavior still need fault/device tests. Atomic local storage is not a server-backed antifraud system or guaranteed zero-loss storage.
- The optional Google adapter is conditionally compiled and follows current official API documentation, but the Google SDKs are not installed/pinned, so that branch has not been compiled or executed. The default ad path is honestly unavailable; the generic bridge and Debug mocks compile.
- App icon art is supplied as an original standalone PNG and registered via legacy bundle icon metadata. The asset compiler's icon-rendition step required unavailable CoreSimulator access. Production icon catalogue/store rendition validation remains open.

## Environment-unavailable verification

CoreSimulator discovery failed in the sandbox, and the request for external simulator access was denied. No alternative route was used to launch or control a simulator. Generic Simulator SDK builds and test-bundle compilation are separate from running a simulator.

**NOT RUN:** actual app/UI test execution, offline installation/launch, small/tall phone/iPad layout checks, all-asset/gallery screenshots, waking/white/mirror/drop screenshots, physical tilt/calibration, thermal/render soak, local StoreKit purchase sheet scenarios, live sandbox purchases, ads/consent, Game Center authentication and cloud/Universal Link integration.

No simulator screenshot or device-performance evidence is fabricated. `evidence/` contains compiler/test outputs rather than rendered gameplay screenshots.

## Owner provisioning

Signing identity, App Store Connect products, banking/storefront setup, ad/consent IDs, privacy/support URLs, Game Center IDs, an owned Universal Links domain and cloud accounts remain external. Release sales/ads and remote services are disabled by default. Offline gameplay does not depend on them. See `docs/OWNER_SETUP.md`.

The wallet survives normal local relaunches and supports idempotent verified delivery, delta settlement and lot-aware refunds. It does **not** promise cross-device/reinstall restoration of remaining consumable currency. A future cloud ledger needs explicit reconciliation and recovery testing.

The pause-loop follow-up caps simulation catch-up during rendering hitches instead of forcing a ready prompt. Sustained low frame rates can slow active gameplay time; no discarded wall time is credited to pig chances or records. Device profiling is still needed.

Current device controls are tilt-only; earlier notes about an optional touch fallback are superseded. Drag steering is confined to Simulator builds. A sensor interruption pauses for recalibration without offering a mode choice.
