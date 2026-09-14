# Collage kit C2

References are a style bible. They are not production resources or layouts to recreate.
The runtime composes the picture from 29 independent ingredients: three sky/ocean plates,
five horses, five trees, four houses, five clouds/mists, three moons, three arches and a window.
The plates contain only atmosphere and ocean. All other images have real transparent alpha.
The abandoned complete scenes are quarantined under `art-review/quarantine`, outside the app.

`DreamCollageKit` records representation ID, semantic concept, medium, mood/palette tags,
orientation, allowed depths, background-only status, interactive compatibility, rarity,
pixel dimensions, measured alpha bounds and recommended scale range. There remain exactly
42 semantic families. Every family retains its procedural 3D implementation. The proof kit
adds alternative representations to six families; it does not introduce a 43rd concept.

`DreamCollageComposition` is pure Swift, with explicitly versioned keyed RNG domains.
Distance cells and staggered slot offsets determine selection and placement independently
of resource loading and frame rate. Rarity weights vary the representation medium. The
runtime varies semantic concept, scale, side, elevation, depth, mirroring, house inversion
and atmospheric opacity. Slots are not fixed to the same window/house/moon arrangement.

`HybridDreamLayers` preallocates 16 object cards and two full-frame sky cards. It shares one
quad mesh, loads 29 optimized textures asynchronously and sequentially, and reuses the pool.
Ordinary slot replacements fade through transparent at independently staggered lifetime
boundaries. Sky changes dissolve over 24 active seconds (1.8 if entered during mirror/drop).
The second sky card is used only for dissolving. No transition creates extra scene groups.
World-space scenery translates once during floating-origin shifts; the infinite sky stays
camera-relative at 5,000 m and aspect-fills the field of view. Camera-facing object cards
retain world positions, producing perspective and depth-dependent motion. A route readability
guard reduces opacity if a large object projects into the lower central corridor.
The 18 cards share a back-to-front sort group with a deferred depth pass, preventing clear
quad regions from clipping farther translucent layers. API availability was checked in the
iOS 26.5 SDK (available since iOS 18); see Apple's
[ModelSortGroupComponent documentation](https://developer.apple.com/documentation/RealityKit/ModelSortGroupComponent).
Cards explicitly do not cast dynamic-light shadows; gameplay geometry retains its shadows.

C2 removes the old dense decorative chunk/horizon meshes; player, track, hazards, balloons,
pig encounters, landing markers and distant route remain 3D. Cards have no collisions or
reward components. Low power reduces enabled object cards to ten. Density breathes during
normal play, fades into void, strips at three hours, then rebuilds; Lucky White hides scenery.

New dreams use G1/R4/C2. C1 codes and snapshots remain supported with their original 3D scenery.
C2 deliberately shares C1 simulation stream namespaces so hazards, routes and pig odds do not
change merely because the presentation version changes. Collage streams include C2 explicitly.
Both shareable codes and saved identities retain the content version.

## Reproduce the proof

Build the shared `Dream Again` scheme for iOS Simulator. In DEBUG open Lab and select collage
1–5, or launch with `--art-review --collage-scene 0` (indices 0–4). Add `--collage-moving`
to run the real simulation at normal speed with a DEBUG safe corridor and no rewards.
The five seed values are 42, 117, 802, 2026 and 9001. Screenshots must come from RealityKit,
never from an image generator composing complete scenes.

## Production and verification

`art-review/kit-generation.json` retains prompts and source master paths.
`art-review/collage-kit-manifest.json` retains metadata. Shipping PNGs have a maximum edge
of 768 pixels for cutouts and 1024 for skies. Source masters remain outside the app bundle.
The 29 images total approximately 50.07 MiB as base RGBA pixels, approximately 66.76 MiB
with a complete mip chain; this is an estimate, not measured total GPU residency.

Run `swift tools/check_collage_alpha.swift 'Dream Again/Resources/DreamCollage/'*.png` to audit
actual decoded pixels. `evidence/collage-alpha.jsonl` records the audit. Transparent assets
must have substantial zero-alpha area and no significant edge pixels. Also review silhouettes,
interior holes, and colored-edge artifacts in the runtime at near and far scales.

Do not expand this library until the five-scene runtime proof, motion review and profiling
are accepted. Physical-device GPU/thermal testing is separate from simulator CPU timing.
