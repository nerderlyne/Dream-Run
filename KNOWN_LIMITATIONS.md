# Known limitations and unmet acceptance criteria

This is an implemented native first-playable build, with automated core evidence. It is **not a claim that every acceptance criterion is complete** or that the game is App Store ready.

## Implementation limitations

- **D02 / D04: certification is bounded witness coverage, not an exhaustive reachability proof.** Each candidate is checked with the authoritative movement/collision engine over the previous two chunks, three entry offsets, ascending/descending grade bounds and early/mid/capped speeds. Incompatible sequences are retried up to eight times, then replaced with a safe breathing chunk. Normal encounters use a 48 m cadence with transition buffers. The oracle and an incompatible jump/slide regression test cover this implementation; arbitrary human reaction delays and every reachable airborne/unstable entry state are not exhaustively enumerated.
- **C04 / D03: visual quality and visibility review is partial.** Actual cloud-slice simulator renders were inspected and iterated. Shared materials, atmosphere, near/horizon composition and a tailored runner stand-in are implemented. Reference-level final art is not achieved across all 42 families; horse/zebra/pig and several furniture/rock builders remain provisional. The selected scene has a clear track corridor, but all-seed, all-palette, crest/drop and two-second visible-warning coverage is not certified. Cloud impostors are not volumetric; water has procedural normals and environment reflections, not planar scene reflections or fluid simulation.
- **H02 / C06: rendering budgets are targets, not measurements.** Geometry/material caches and streamed chunks are bounded. Lab counts entities and generated geometry, but GPU draw calls, resident memory, restart latency, thermal behavior and sustained frame pacing are unmeasured. The 20-seed soak tests core state growth, not RealityKit memory or battery use.
- **A03 / E09:** the native start/ready/play/pause/wardrobe UI test now executes successfully. Sharing, import and all empty/error states still require broader UI execution. Result sharing supplies a scene snapshot when available plus a caption/card; its final composition needs visual review. Wardrobe and small-phone/iPad layouts likewise need UI review.
- **H04:** checksum validation, backup recovery, malformed import rejection and transaction rollback have automated coverage. Actual disk-full, interrupted atomic replacement, lock/call/headphone and motion-staleness behavior still need fault/device tests. Atomic local storage is not a server-backed antifraud system or guaranteed zero-loss storage.
- The optional Google adapter is conditionally compiled and follows current official API documentation, but the Google SDKs are not installed/pinned, so that branch has not been compiled or executed. The default ad path is honestly unavailable; the generic bridge and Debug mocks compile.
- App icon art is supplied as an original standalone PNG and registered via legacy bundle icon metadata. The asset compiler's icon-rendition step required unavailable CoreSimulator access. Production icon catalogue/store rendition validation remains open.

## Verification limits after the visual pass

Approved CoreSimulator access allowed actual installation, launch, screenshots and native renderer/UI tests on **iPhone 16 Pro Max / iOS 26.5**. Earlier reports of unavailable simulator execution are historical and superseded. `IMPLEMENTATION_STATUS.md` records the exact final results; `evidence/art-native-tests.log` retains an initial failed color-space assertion, followed by corrected renderer verification in `art-renderer-final.log`. An initial ready-button hit-area failure in `art-native-final.log` is superseded by two passing UI repetitions in `art-ui-recheck.log`.

**Still not run:** physical tilt/calibration, small-phone/iPad layout matrix, sustained thermal/render soak, GPU/draw-call/resident-memory budgets, full asset/material/LOD screenshot matrix, complete mirror/drop hazard visibility matrix, local StoreKit purchase-sheet scenarios, live sandbox purchases, real ads/consent, Game Center authentication and cloud/Universal Link integration.

Screenshots prove selected simulator presentations only. They do not prove smooth performance on target iPhones or final art acceptance. The optional authored character adapter compiles and rejects incomplete art in tests; no production USDZ/animation set is supplied or exercised.

## Owner provisioning

Signing identity, App Store Connect products, banking/storefront setup, ad/consent IDs, privacy/support URLs, Game Center IDs, an owned Universal Links domain and cloud accounts remain external. Release sales/ads and remote services are disabled by default. Offline gameplay does not depend on them. See `docs/OWNER_SETUP.md`.

The wallet survives normal local relaunches and supports idempotent verified delivery, delta settlement and lot-aware refunds. It does **not** promise cross-device/reinstall restoration of remaining consumable currency. A future cloud ledger needs explicit reconciliation and recovery testing.

The pause-loop follow-up caps simulation catch-up during rendering hitches instead of forcing a ready prompt. Sustained low frame rates can slow active gameplay time; no discarded wall time is credited to pig chances or records. Device profiling is still needed.

Current device controls are tilt-only; earlier notes about an optional touch fallback are superseded. Drag steering is confined to Simulator builds. A sensor interruption pauses for recalibration without offering a mode choice.

### Wardrobe fit revision — September 13, 2026
The procedural character now offers a free girl/dress/ponytail look and a trousers/separate-top look. Clothing is articulated geometry, not simulated cloth; the skirt has no cloth collision simulation. Physical-device appearance and the complete hat-by-action visual matrix remain untested. An optional authored USDZ must supply equivalent outfit variants before it can replace both procedural looks. Hat fitting now uses a 1.73 m brow/crown attachment line rather than the former 1.84 m top-of-head socket; authored assets must use that fitting convention.

### Renderer performance correction — September 14, 2026
Simulator CPU measurements now exercise 120 renderer updates after warm-up. They do not measure GPU presentation time, sustained device frame rate, thermal behaviour, or every palette transition. Initial material/sky generation and new scenery streaming still do work on the main actor. The measured periodic all-scenery haze burst was replaced with a four-model-per-frame budget; unchanged lighting resources and retained route meshes are reused. Device validation remains outstanding.

### Gradual palette evolution
Sky evolution tints the retained procedural sky texture; it does not regenerate volumetric clouds or interpolate two full environment-lighting maps. Ordinary object colour changes take up to approximately 19 seconds, subject to the bounded material-update queue. Newly encountered scenery can still require synchronous mesh construction; the simulator boundary probe measured 33 ms including streaming, so a strict 60 FPS/device thermal guarantee remains unmet. The mirror's existing crossing presentation is retained; this change blends colours faster there rather than introducing a loading pause. Physical-device transition pacing and the full palette-pair visual matrix remain untested.

### Hybrid collage library

The corrected proof library contains exactly 29 ingredients, covering six of the 42 concepts with alternative 2D representations; all 42 retain procedural 3D implementations. The library must not expand until the proof is accepted. The 3D gameplay horse/rabbit/player and other provisional close assets are unchanged. No meme image ships. Cutout clouds have soft alpha but are not volumetric; camera-facing cards do not reveal new sides as the camera turns. Base skies aspect-fill a camera-relative far plane rather than an equirectangular skybox. Physical-device GPU time, thermal behaviour, measured texture residency, long-duration running, and the complete palette/aspect-ratio matrix remain untested. Simulator CPU measurements do not establish device FPS. Exact alpha audits and runtime capture evidence are separate from subjective art approval.

The native collage tests logged Metal drawable-allocation warnings while exercising multiple
renderers. Their passing CPU/pool assertions are not a GPU or memory acceptance result.
The complete original game's physical-device and long-session acceptance criteria remain open;
this pass verifies the bounded 29-ingredient composition proof only.
