# Agent instructions — Dream Again

Build the complete native Swift game specified in `GAME_SYSTEM_SPEC.md`. This repository pack is the specification and reference data, not an already-built app. Do not answer with another design document instead of implementation.

## Read first

1. `START_HERE.md` and `GAME_SYSTEM_SPEC.md` in full.
2. Every JSON file under `data/`, `data/persistence_schema.sql`, and `docs/REFERENCE_ALGORITHMS.md`.
3. `ACCEPTANCE_TESTS.md` and all six supplied images under `references/`.

Use `docs/SOURCES.md` and the installed SDK to verify framework signatures/availability. Do not assume this conversation or proprietary assets exist in your environment.

## Design invariants

Exactly 42 registered world-asset families. Pig is #42. Humanoid/cosmetics/UI/materials are outside that cap; unregistered scenery is not. Native SwiftUI + non-AR RealityKit with close third-person camera; constrained tilt, up-jump, down-slide; automatically follow route and ordinary stairs. No free exploration, lane snapping or overhead camera.

Balloons are the sole currency; earned or purchased currency buys cosmetics only. Achievement rewards are never purchasable. Cute rabbit and blue nazar end a run on contact; ordinary sports balls cause a soft stumble; horses/zebras have slide-through leg clearance. No anatomical eyeball.

Every 780 active seconds: 1/2 chance of pig, conditional 1/3 chance of clover. After one continue: conditional 1/6 for future uncommitted events. No pity. Three collected clover pigs trigger Lucky Dream/white fainting ending with three pigs. Three hours triggers visual stripping and later alien-palette rebuilding, NOT an ending.

Mirrors lead through reflected void into a visual-state change. Safe drops always have a consistent cue and a prevalidated landing. Surreal scenery never excuses unfair gameplay or unreadable hazards. Saved dreams are versioned seeds; live run suspension is distinct from revisiting.

## Execution

This game is unreleased. Replace superseded implementations and delete rejected art/review files. Do not add compatibility branches, duplicate catalogs or migrations solely to preserve earlier development builds.

Inspect existing files and tools before changes; preserve unrelated user work. Use specification defaults instead of repeatedly asking product questions. Work in verified increments but continue through the entire scope, including 42 assets, economy, save/share, endings and tests. Maintain `IMPLEMENTATION_STATUS.md` with real completion evidence.

Commit a real runnable Xcode project and shared schemes. The first greybox is a milestone, not the finished deliverable. Generate original recognizable procedural assets when external models are absent. No missing-file stubs, fake in-app purchases or copied unlicensed art/audio. The six mood images are reference-only, not production resources.

Separate deterministic Swift core from renderer/input/commerce. Match provided RNG/seed/pig fixtures. Use transactional idempotent persistence. Verify simulator build/tests when Xcode exists. Without Apple tooling, still implement the project/core and report exactly which checks could not run; never invent build success.

Real payments, ads, signing, Game Center, Universal Links and cloud accounts require owner provisioning. Supply real adapters/configuration seams and safe disabled/local test modes. Debug grants/clock acceleration must never earn production rewards. Do not publish, spend money, create live products or use real ad inventory without explicit authorization.

Run `python3 tools/validate_spec.py` to check specification data, then implement/run the actual Swift tests. The Python pass does NOT prove the iOS game builds.

## Finish

Deliver implementation, project/resources/tests, launch/build instructions, configuration examples, test outputs, screenshots where available, `IMPLEMENTATION_STATUS.md` and `KNOWN_LIMITATIONS.md`. Distinguish implemented, externally unconfigured, failed and untested. Do not claim asset polish, physical tilt, thermal performance or App Store readiness without evidence.
