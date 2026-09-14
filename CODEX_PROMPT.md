# Paste this into Codex from the project folder

Build the complete native iPhone/iPad game specified in this folder. Read `AGENTS.md`, then all of `GAME_SYSTEM_SPEC.md`, the `data/` contracts, `docs/REFERENCE_ALGORITHMS.md`, `ACCEPTANCE_TESTS.md`, and the six images in `references/` before implementing. The full specification replaces the need for any earlier conversation.

This is an implementation task, not a request for another plan or pitch. The target is a complete first playable game called **Dream Again** (working title): native SwiftUI + non-AR RealityKit, close third-person runner, constrained tilt/touch steering, jump and slide, a beautiful seeded procedural dream built from exactly 42 world-asset families, readable obstacles, mirrors and marked safe drops, balloon currency and hats, exact lucky-pig rules and white ending, nonterminal three-hour visual evolution, versioned saved/shareable seeds, pause/suspend, achievements and sound.

Use the specification's DEFAULT choices where a product detail was unresolved. Preserve LOCKED decisions, especially the 42-family cap, balloon-only cosmetic economy, guaranteed three-minute pigs with no-pity one-third lucky odds, halved future clover odds after a continue, and no ending at three hours. Do not replace the aesthetic with generic candy, neon or a jungle. Create original procedural geometry for every asset instead of referencing missing model files.

Inspect the repository and available toolchain. Make a short execution plan, then implement it end to end in verified increments. Keep the deterministic core independently testable. Match the golden RNG/seed/pig fixtures. Build a DEBUG Lab to preview every asset, hazard, ending and deep state without waiting hours; debug overrides must never earn real rewards.

Deliver a real Xcode project with shared schemes, resources, Swift tests, complete UI flows, safe persistence, local StoreKit configuration, purchase adapter and optional rewarded-ad adapter with honest disabled/mock modes. Account-dependent services must not block offline play. Do not invent credentials, provision live services or charge anything. Document exact owner setup that remains.

Run the actual Swift/package and simulator tests when the environment supports them; fix failures rather than stopping at a greybox. On environments without Apple tooling, implement the full project and test whatever is available, then explicitly list the unavailable checks. Do not claim simulator/device/performance tests you did not run.

Finish with working implementation files, build/run instructions, `IMPLEMENTATION_STATUS.md`, `KNOWN_LIMITATIONS.md`, exact test results, and screenshots where supported. Identify any unmet acceptance criteria precisely. Do not stop after creating screens, scaffolding, or an implementation plan.
