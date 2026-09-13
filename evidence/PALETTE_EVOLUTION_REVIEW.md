# Gradual palette evolution — September 14, 2026

Actual iPhone 16 Pro Max / iOS 26.5 Simulator captures of the same scene and camera, with debug active-time progression and no production rewards:

- [Start: 0 seconds](evolution-00.png)
- [Mixed objects: 8 seconds](evolution-08.png)
- [Completed colour blend: 22 seconds](evolution-22.png)

The windows, trees, skyline and track retain their geometry and positions. At the middle capture, individual frames/trees/water surfaces are at different points in the blend. The character, balloons and semantic hazard colours are not recoloured. These deliberately frozen debug captures compare appearance, not device animation smoothness.

Ordinary transitions stagger starts by 0–8.8 seconds and blend for 10 seconds. Mirrors and safe drops permit a faster 1.4–1.8-second colour transition, using the same retained surfaces. New scenery types arrive through streaming; a palette change no longer rebuilds the scene or regenerates the sky lighting resource. The horizon retains each landmark until it is behind the player and creates at most one replacement per frame.

Validation: 12 native tests pass (19.507 s), gameplay UI test passes (31.245 s), Debug/Release simulator builds pass, 51 specification checks and release preflight pass. Logs: `evolution-final-tests.log`, `evolution-release.log`, `evolution-spec.log`, `evolution-preflight.log`. The native test crosses 432 m, checks retained track/horizon identity and unchanged initial colour, advances the blend, verifies the four-material-per-frame cap, and checks the accelerated mirror path. CPU boundary sample: 33.045 ms, including streaming; steady median/p95/max: 0.633/3.978/10.852 ms. These are simulator CPU diagnostics, not GPU or physical-device performance certification.

Debug reproduction: launch with `--art-review --art-theme 0 --art-transition-to 1 --art-transition-time 8` (use 0 or 22 for the other captures). Existing core seed/rules/pig contracts are unchanged. Package tests were not rerun for this rendering-only change. Full palette-pair/device/thermal validation remains outstanding; the sky uses a retained texture/tint approximation and new mesh streaming can still miss a strict frame budget.

Final atmospheric-shading refinement: recolouring now composes with the cached haze immediately instead of exposing an unshaded material until the next haze update. Native suite rerun: **12 tests, 0 failures, 27.340 s** (`evolution-atmosphere-tests.log`). This sample measured boundary **46.988 ms**, steady median/p95/max **0.861/5.143/13.929 ms**; host load varies, and new-chunk streaming is not yet guaranteed to fit 16.7 ms. Release was rebuilt successfully after this refinement. Midpoint/end screenshots were refreshed from that build; initial colours are unchanged.
