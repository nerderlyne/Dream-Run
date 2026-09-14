# Dream Again — Codex implementation pack

**For Shiv / Shiv is Gaming • 13 September 2026**

This pack turns the design discussion into a self-contained implementation brief. **It is not the compiled game or an existing set of 3D models.** It specifies the complete first build, with original procedural model construction as the default asset-production route.

## Use it

Extract the pack into a fresh project folder/repository. Open that folder in Codex and give it the text from `CODEX_PROMPT.md`. Keep the whole pack available: the long specification, machine-readable catalogues and six visual references work together. Do not paste only the asset list and expect the same game.

A Mac environment with Xcode can build/test the iOS app; the coding agent must report its actual available tooling and tests. Live purchases, ads and Apple service configuration need your accounts. Disabled/test implementations allow a full offline playable game without pretending those services are live.

## Contents

| File | Purpose |
|---|---|
| `GAME_SYSTEM_SPEC.md` | Complete product, gameplay, generation, art, economy, architecture and delivery contract |
| `AGENTS.md` | Compact persistent implementation instructions |
| `CODEX_PROMPT.md` | The task prompt to hand to Codex |
| `ACCEPTANCE_TESTS.md` | Named verification cases; the implementing agent fills in evidence |
| `data/asset_catalog.json` | Exactly 42 numbered world families, roles and construction notes |
| `data/game_config.json` | Versioned initial mechanics, timing and performance targets |
| `data/palettes.json` | Base/void/ending/beyond art-direction palettes |
| `data/cosmetics.json` | Earned/bought items and achievement-only rewards |
| `data/achievements.json` | Explicit triggers and eligibility |
| `data/store_products.json` | Placeholder products and clearly marked local test prices |
| `data/persistence_schema.sql` | Transactional local wallet/run/bookmark storage proposal |
| `data/conformance_vectors.json` | Stable RNG/seed/pig examples and exact probability checks |
| `docs/REFERENCE_ALGORITHMS.md` | Determinism, encoding, sampling and accounting contracts |
| `docs/SOURCES.md` | Official Apple, Google and OpenAI implementation references |
| `tools/reference_rules.py` | Executable reference for seed IDs and pig probabilities, not the game |
| `tools/validate_spec.py` | Internal consistency checks for the specification pack |
| `references/` | Six creator-supplied, reference-only mood images |
| `VALIDATION_REPORT.md` | What was actually checked while preparing this pack |

## Defaults to be aware of

The spec identifies these as defaults, not things you explicitly decided: one rewarded continue maximum per run; fresh versus revisited prestige eligibility; local-first records/saves; initial hat catalogue/prices; a two-hit soft-stumble recovery rule; camera/movement tuning; iOS 18 deployment floor; and a working project name. None changes the core game you described.

The counted unit is **42 registered world prefab families**, not exactly 42 raw mesh buffers. A sports ball may share primitive sphere geometry with another ball; a clover pig composes existing pig and clover families. Hats, avatar, textures, palettes, lights and implementation effects do not consume world slots. The build cannot hide extra decorative objects outside the registry.

The updated pig rule guarantees a pig every three active minutes. With perfect survival/collection, three clean lucky pigs take 27 minutes on average; the earliest nominal possibility is nine minutes. A continue halves future uncommitted clover odds. The spec deliberately adds no mercy system.

## What “one shot” targets

One full agent assignment that builds a complete first playable version in increments and verifies each part. It is not an assertion that a generated first build will need no art/feel tuning, device testing, signing, service setup or release review. The coding agent is instructed to distinguish implemented, unconfigured and untested features instead of hiding gaps.
