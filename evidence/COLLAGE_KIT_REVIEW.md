# Collage kit proof — September 14, 2026

Scope: the user's correction from finished scenes to reusable ingredients. Generation stopped
at 29 accepted candidates; no complete scene was generated for this proof. The prior full-scene
plates are preserved outside the shipping resources in `art-review/quarantine`.

## Checks run

| Check | Result | Evidence |
|---|---|---|
| Specification data | 51 checks passed | `tools/validate_spec.py` |
| Core suite | 29 tests, zero failures, 150.178 s; six-hour oracle excluded | `collage-core-tests.log` |
| Final collage contracts | 4 tests, zero failures, 0.193 s | `collage-core-final.log` |
| Native suite | 16 tests, zero failures, 90.234 s | `collage-final-tests.log` |
| UI suite | 3 tests, zero failures, 77.144 s | `collage-final-tests.log` |
| Preview gap regression | 1 test, zero failures, 6.352 s | `collage-preview-regression.log` |
| Final layout, preload, rebase and reward regression | 3 tests, zero failures, 54.168 s | `collage-layout-tests.log` |
| Transparent compositing correction | 3 targeted tests, zero failures, 41.255 s | `collage-compositing-tests.log` |
| DEBUG simulator build | Succeeded with final sorting, non-shadowing cards and actor isolation | `collage-debug-final.log` |
| Release simulator build | Succeeded with final compositing/shadow settings, arm64 iOS Simulator | `collage-release-final.log` |
| Offline release preflight | Passed | `scripts/release_preflight.py` |
| Pixel transparency | All 26 cutouts have zero occupied edge pixels; 3 plates opaque | `collage-alpha.jsonl` |

The alpha audit reads actual decoded pixels. Cutout zero-alpha area is approximately 35–79%.
Cloud and mist edges contain partial alpha. An alpha channel alone is not treated as proof.
The shipping textures occupy approximately 14 MB on disk, 50.07 MiB base RGBA pixel storage,
or an estimated 66.76 MiB including full mip chains. Total GPU residency was not measured.
Hashes: `collage-texture-sha256.txt`.

## CPU comparison

Same simulator, same seed, route from 400 m, 720 renderer updates at a simulated 60 Hz;
first 60 excluded, 660 measured. Includes normal chunk streaming and palette boundaries.

| Renderer | Median | p95 | Maximum | End entities |
|---|---:|---:|---:|---:|
| C1 legacy decorative geometry | 2.578 ms | 6.973 ms | 950.206 ms | 387 |
| C2 pooled collage, cached placement | 0.374 ms | 0.513 ms | 10.341 ms | 229 |

Source: `COLLAGE_CPU_C1/C2` in `collage-compositing-tests.log`. The fixed card pool has 18 entities;
17 were active at the end of that C2 sample. Tests also keep the same entity identities through
20 interrupted sky transitions and verify one-time translation across a 192 m origin shift.
These are host CPU update timings, not GPU presentation times, device FPS or a thermal guarantee.
The native test process also logged CAMetalLayer drawable allocation failures while exercising
multiple renderers. Passing CPU assertions do not establish a clean GPU/memory profile.

## Runtime visual evidence

The capture tool launches DEBUG seeds 42, 117, 802, 2026 and 9001 and waits for a unique
readiness marker confirming all 29 textures loaded. The screenshots below are produced by
RealityKit using the same ingredient bundle. They are not pre-rendered level images.

1. `collage-scene-1.png` — seed 42.
2. `collage-scene-2.png` — seed 117.
3. `collage-scene-3.png` — seed 802.
4. `collage-scene-4.png` — seed 2026.
5. `collage-scene-5.png` — seed 9001.

Motion: `collage-running.mov`, with final frame `collage-running-end.png`. This is the real
simulation at normal speed in a DEBUG-safe corridor, with rewards disabled. The first fixed-delay
capture attempt caught launch screens; the readiness-based rerun supersedes those images.
The final H.264 recording is 7.7 seconds at 1320 × 2868, with 469 encoded frames (see
`collage-video-metadata.json`). Recording startup is excluded by simctl, so this is shorter
than the harness's 12-second wall-clock wait. Encoded frame counts are not a device FPS test.
Frames at 2 and 7 seconds show the near house/tree/arch moving and enlarging relative to the
far moon and sky while the runner and route progress. The five still captures retain a clear
central track; floating architecture and viewport cropping are intentional collage placement.
Earlier diagnostic images and videos are retained locally under
`art-review/quarantine/diagnostic-captures`, not used as final proof.
The first working layout repeated a window and two moons. The final generator varies semantic
concept choice, side, size and elevation as well as representation; a core regression checks
that the five seeds have distinct concept layouts.
Motion inspection also caught rectangular overlap artifacts. The final renderer sorts all
18 cards back-to-front in a shared post-depth group before writing their depths.
The inspected rerun removed the rectangular sky clipping. Scenery cards also explicitly
disable shadow casting. The targeted tests preceded that final shadow flag/actor annotation;
the final DEBUG and Release builds compile those settings.

## Limits and acceptance

The core, kit-count, alpha, semantic-cap, pool, rebase, reward-isolation and compatibility checks
passed. Subjective art approval remains with the owner. Do not expand the library yet.
Physical iPhone/iPad tilt, GPU frame timing, thermal/load tests, long-duration residency, and
every landscape/iPad layout remain untested. The six-hour oracle was not rerun in this pass.
Cloud cards are not volumetric; object cards do not reveal new sides as the camera turns.
The close player/hats/gameplay art is outside this proof and retains its earlier limitations.
No live services, credentials, products, ads or payments were provisioned or used.
