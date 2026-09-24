# Known limitations

## Rolling hay reserve — September 17, 2026

Hay rolls along the certified route rather than using rigid-body physics. It is confined to its empty track section and stops at that section’s boundary if missed; it does not bounce off other balls. Live spawning now requires four certified sports balls per hay offer. The golden tangled sphere is procedural straw geometry. Reserve straw automatically repairs one limb per second after damage; frequency and reserve balance still need subjective play evaluation. No physical-device testing is authorized.

## Straw damage and repair — September 16, 2026

The one-leg state uses the existing running articulation with a small hop; missing limbs do not change physics or jump/slide clearance. Straw bursts are bounded procedural reeds, not simulated fibre breakage. Hay frequency and the two synthesized sound effects have not received subjective play/listening evaluation. Old unreleased snapshots are not migrated. Verification uses the simulator only.

## Color harmony and storm motion — September 16, 2026

The cloud remains animated photographic cards with procedural electrical branches/rain, not volumetric fluid simulation. Its extra translucent scud card reuses the existing texture; sustained transparency cost is unmeasured. Obstacle and balloon colors follow the track palette, not automatic color extraction from each photo. Material animation and strike behavior were tested in the simulator only.

## Adaptive audio and theta — September 16, 2026

The procedural score is implemented, but perceived musical quality, headphone comfort, safe listening level at a particular system-volume setting, Bluetooth latency and physical-device routing remain untested. No claim of hypnosis, sleep induction or neurological benefit is made. Theta is off by default and requires an eligible stereo headphone/Bluetooth route with Mono Audio off. Bluetooth A2DP can also represent a speaker; the player must honor the stereo-headphone instruction. The score follows gameplay palettes rather than identifying individual photograph contents. Bundled loops repeat in combinations; this is not an unlimited generated composition. Normal pause restarts loop playback on resume while preserving gameplay state. No physical iPhone was used. Details and reproduction: `docs/DREAM_AUDIO.md`.

## Track translucency and timed realities — September 15, 2026

Transparency uses non-overlapping base/pattern meshes with opaque rims and stair faces. The water and space simulator captures demonstrate plate bleed-through, but every photo/hazard combination and sustained transparency frame pacing remain unverified. Timed photo changes use active seconds; an unavailable texture can delay a transition while the existing reality stays visible. Scenic props retain independent staggered replacement. Physical iPhone testing is prohibited by the owner; use the simulator for further verification.

## Storm threat presentation — September 15, 2026

The storm is a photographic alpha VFX card with procedural rain, local shade and lighting, not a volumetric weather simulation. Physical-device transparency cost, reduced-visibility dodge readability and subjective realism/threat remain unverified. The original generated PNG and complete prompt are recorded in `docs/STORM_VFX.md`.

## Background continuity — September 15, 2026

The last-resort background is a non-black lavender field when no valid photograph has loaded. It prevents black error flashes but is not a photographic substitute. Plate transitions use alpha overlap rather than image masks. Device loading latency, thermal behavior and every source-photo crop remain unverified; simulated missing-photo recovery is tested separately.

## Zebra, jail door and mace — September 15, 2026

These are original procedural toy/stylized models, not scanned or rigged photoreal assets. Verified close simulator previews and geometry bounds; physical-device frame pacing and moving-scene visual preference remain untested in this pass. The existing window and moon families supply the new interactive door/mace representations; no family is added.

## Lightning audio — September 15, 2026

The original synthesized 3.6-second strike is preloaded and amplitude-bounded. Simulator tests verify playback lifecycle, not perceived loudness or fright. Listening on physical iPhone speakers and headphones remains unverified; system volume, silent mode and the Effects setting still apply.

## Curated background integration — September 15, 2026

- Current batch includes 102 unique images from the 103 source files present at verification. Later copied photos require rerunning `swift tools/import_dream_plates.swift` and rebuilding. Originals are untouched.
- Optimized backgrounds add approximately 97 MiB of JPEG resources. The runtime cache holds at most three photos, but device GPU memory, frame pacing and thermal behavior have not been measured in this pass.
- Aspect fill deliberately crops wide images on portrait screens. Backgrounds are photographic cards, so perspective inside a source photograph does not change with the runner; existing foreground/collage layers provide motion and depth.
- Source filenames and hashes are recorded. Per-photo Unsplash URLs and photographer credits were not supplied.
- This pass does not establish physical tilt, iPad visual quality, Release-device performance or App Store readiness.

- Three-minute pig schedule: nominal encounters retain the existing six-second visible approach/runway reservation; timing is active simulation time. Physical-device encounter timing has not been measured in this pass. Current prerelease pig tuning replaces the old policy.

- Composition refinement: eight fixed-distance simulator samples do not establish a measured improvement in player preference. Color matching and silhouette visibility on route bends are not image-aware; some combinations remain weaker. No new physical-device performance measurements.

- Swipe timing fix (September 15): deterministic tests verify recognition before release and next-tick jump onset. Actual finger-to-display latency and feel on a physical iPhone have not been measured; main-thread rendering stalls could still delay touch processing.

- Large translucent atmospheric cards increase overdraw; physical-device GPU cost and sustained
  frame pacing remain unmeasured. Route-overlap attenuation is broad, not a per-pixel mask;
  four simulator compositions do not establish visibility for every seed and device size.
- Scale-event probabilities are seeded per scene, not guaranteed screen appearances: camera
  framing, density/void phases and approach fading can hide a selected subject. The matched
  simulator gallery covers eight scale/framing cases; broader seed/device visual review remains outstanding.
- Rising-balloon jump timing and collection feedback need physical-device playtesting. Simulator
  captures and deterministic collision tests do not establish human timing or frame pacing.
- Physical iPhone/iPad tilt, frame pacing, GPU memory, thermals and sustained rendering have not
  been measured in this pass. Simulator CPU timing is not device performance evidence; the
  native test process emitted CAMetalLayer drawable-allocation warnings despite passing assertions.
- The six-hour/20-seed core oracle passed. It establishes safe simulated trajectories, not human
  reaction-time/playability approval. The new difficulty curve needs physical-device playtesting.
- Horizon warmup reduces cold certification work on the display thread; a cache miss still uses
  synchronous validation. The current 660-submission CPU sample peaked at 10.354 ms; a separate palette-boundary
  sample reached 32.783 ms. Hitch-free physical
  gameplay is not yet verified.
- Straw-doll structural reference images mentioned in the request were not supplied. The model
  follows the written reed/twine construction. Cloth and straw use articulated geometry, not physics.
- Selected runtime screenshots are visual evidence, not approval of every asset/material/LOD,
  seed, collision encounter, hat/action combination or small-phone/iPad layout. The remaining
  procedural world families vary in polish. Full reference-quality art acceptance remains open.
- The original pilot now includes eight small, locally generated repost cards in addition to its
  20 cutouts. All 54 transparent textures currently preload. Measure physical-device memory and implement a bounded texture
  working set before scaling production substantially. Rare cultural content is original generated
  absurdist imagery and original fictional forum fragments, not imported internet memes. Motion uses transformed image cards, not GIFs,
  skeletal swimming or a multi-frame cooking animation. Some story parts are intentionally
  occluded by other scenery; every composition is not fully visible in every portrait frame.
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
E09 (full gallery/share flow), G06/G07 (StoreKit and actual rewarded-ad scenarios), H02 (physical render soak), and H04 (device interruptions and
storage faults). The static contrast scene partly occludes the zebra behind the horse and
the pig behind a balloon; it is not complete moving-encounter visibility evidence.
No simulator screenshot establishes physical-device or store readiness.
- Google Mobile Ads and UMP are linked with the owner's IDs, but live ad serving remains disabled.
  The Debug Lab uses Google's test ad unit and does not grant production rewards. Consent messaging,
  live inventory behavior and reward callbacks still need simulator sandbox checks before release.
