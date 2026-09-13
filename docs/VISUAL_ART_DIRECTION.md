# Visual art direction — September 2026 pass

The six images in `references/` remain the authority. They are not shipped, sampled or copied into production textures. This pass is a visual vertical slice and shared rendering overhaul, not certification that all 42 assets have final art.

## Implemented visual system

- Foreground: close articulated runner, glazed balloons and a pearl checker surface with readable mint edge strips. Stair risers now meet their actual tread height instead of obscuring checker tiles.
- Near scenery: shaped foliage, joined rabbit surface, moulded open windows, cloud banks and water beneath the route. Scaled scenery bounds determine lateral clearance; open window frames deliberately span the route with clear space inside.
- Midground: coherent cloud/window/stair, flooded-plaster courtyard, and dark-stone/night compositions inherit the current palette rather than mixing unrelated prop recipes.
- Horizon: a separate bounded landscape layer uses existing cloud, window, stair, room, column, mountain, moon and tree families. A private `landscape-art-v1` stream composes scale, depth and asymmetry without consuming simulation random draws. These are presentation objects, never hazards or rewards.
- Sky: original procedural cloud/gradient imagery, a detailed environment dome and matching image-based light. Cloud banks use shaded, soft-edged billboard impostors at landscape scale. Their reusable color and opacity maps avoid multiplying large cloud mesh counts. The Lab cloud mesh remains a separate sculpted variant of family #24.
- Atmosphere: distance-dependent desaturation, roughness and light contribution on scenery; directional shadows; wet normal maps; multiple cloud depths. This is an approximation, not volumetric fog, ray-traced water reflection or physical cloud scattering.
- Density: ordinary landscapes breathe between maximal and moderate density; void palettes strip the environment. The existing nonterminal three-hour stripping/sparse/rebuilding phases control the horizon too. Three clover pigs still trigger the separate white ending, which removes landscape scenery.

No family was added to the 42-family registry. Sky, lighting, material maps and the humanoid remain outside the world-family count. All simulation/core contracts are unchanged by this pass.

## Materials

`DreamMaterials` supplies plaster (0), glazed ceramic (1), brushed metal (2), velvet-like cloth (3), pearl (4), frosted glass (5), honed stone (6), luminous glaze (7), wet surface (8), and absorptive dark (9). The original eight Lab indices retain their meanings; wet/absorptive variants are selected by art direction. Maps are original, seamless 256px procedural color/normal maps shared across prefabs. Pearl is a layered PBR approximation, not a spectral interference shader; glass does not promise refraction of the running scene.

## Reproducible review

Debug Lab contains cloud, aqua and void slice buttons. They enter a frozen seed-42 preview labelled **PREVIEW · NO REWARDS**. Pause → ready lets a preview run; it remains Debug and cannot settle rewards or replace a real suspension. Starting/resuming a real dream clears the visual override.

Simulator launch arguments:

```sh
xcrun simctl launch booted nani.Dream-Again --art-review --art-theme 0
xcrun simctl launch booted nani.Dream-Again --art-review --art-theme 1 --art-distance 1100
xcrun simctl launch booted nani.Dream-Again --art-review --art-theme 5
xcrun simctl launch booted nani.Dream-Again --art-review --art-theme 0 --art-pose slide
xcrun simctl launch booted nani.Dream-Again --art-review --art-theme 7 --art-pose white
```

Terminate the existing app before relaunching with new arguments. Theme is clamped to 0...11 and review distance to 0...100000 m. Review overrides are compiled only in Debug.

## Authored character replacement contract

The tailored procedural runner is an improved **stand-in**, not a finished authored character. `AuthoredDreamRunner` provides an optional local replacement:

1. Add an original licensed `DreamRunner.usdz` to the app's resources. No download or missing-file stub is required for offline play.
2. Use metres, +Y up, forward -Z, feet at origin, approximately 1.84 m total standing height. Preserve the collision silhouette independently; art never changes collision dimensions.
3. Supply an Entity named `hat.socket`, correctly animated with the head. Existing hats are attached there. Body meshes eligible for cosmetic recoloring must be named `avatar-body`; keep skin/hair in separate meshes.
4. Expose root animation resources named `idle`, `run`, `jump`, `slide`, `stumble`, `fall`, `faint`. Clips contain local articulation only: route motion and jump height come from the simulation. `run` is authored for 12.25 m/s and playback scales with speed. Run/idle repeat; action clips transition over 0.12 seconds.
5. Slide/faint clips include the back-facing-ground body rotation. The renderer supplies the existing slide root offset, so the feet lead forward. Imported animation must not translate the root along the route.
6. All names/clips are validated before replacing the stand-in. Invalid art leaves the working procedural runner in place and records `authoredArtError` for diagnostics. No authored USDZ is bundled or claimed as tested in this pass.

## Remaining art and performance work

The other animal builders and several furniture/rock families retain provisional procedural forms. They inherit better materials and smoother curves, but are not certified final assets. Further authored silhouette/animation work, deeper textures and composition review across many seeds are still required to reach the reference quality bar. Water is a lit normal-mapped surface, not a fluid or planar-reflection simulation. Impostor clouds are not volumetric and can expose their construction at unusual viewing angles. Device frame pacing, thermal behavior and memory still require physical iPhone/iPad profiling; simulator screenshots are visual evidence only.

### Wearable revision
Hats now use original, head-sized meshes in `FittedHats.swift`, with bands meeting the brow/crown line at 1.73 m. No world prefab is used as a hat. Novelty motifs are small appliques/charms on a cap or circlet. The checker cap is a beret, not a baseball cap. The default remains No hat; rounded skull-following hair replaces the previous brim-like nape shape.

The wardrobe provides two free saved character looks: Girl · dress (rose A-line dress, sash, ponytail) and Runner · trousers (mint top, charcoal trousers). Existing colour cosmetics tint the garment. This uses the existing versioned profile's equipped dictionary, changes no wallet ownership or price, and has no effect on collision bounds, movement or rewards. No cloth simulation is claimed.

DEBUG screenshots can use `--art-review --wardrobe-review --character girl --hat bucket_hat --art-pose portrait`; `run` and `slide` preserve the gameplay camera and pose. These visual overrides never alter the saved wardrobe and use a reward-ineligible debug run.

### Chapter evolution
The versioned core palette index is now a target, not an instruction to rebuild the visible world. `PaletteEvolution` recolours retained track/scenery surfaces over staggered active-time windows, with at most four material updates per frame; cosmetic and semantic hazard/currency surfaces remain excluded. The sky texture is retained and tinted gradually. Ordinary chapter evolution takes approximately 19 seconds; mirror/drop targets can blend faster. The renderer retains skyline objects across palette and origin boundaries and replaces retired slots individually. See `evidence/PALETTE_EVOLUTION_REVIEW.md` for captures and exact verification limits.
