# Acceptance tests — executable completion contract

Record **PASS / FAIL / NOT RUN**, test name, command/device and relevant output in `IMPLEMENTATION_STATUS.md`. A test described here is not already passed. The Python tools included with this pack check specification data only, not the Swift app. Automated oracle success is not a substitute for human playtesting or physical-device performance.

## A. Project and offline boot

**A01 — Real native project.** Open the committed Xcode project and shared scheme. Build a generic iOS Simulator destination without signing. App is Swift/SwiftUI/RealityKit, not a web view, Unity export or SceneKit placeholder. No unavailable source file or absent asset bundle.

**A02 — No-account offline start.** Airplane mode, fresh install, ads/products disabled. Home → dream → running works. No login, camera session, loading spinner waiting for a server or forced purchase.

**A03 — All screens.** Home, pause, result, wardrobe, saved dreams, import, achievements and settings have working controls and readable empty/error states. There are no unexplained dead buttons.

**A04 — Supported sizes.** Test one small supported phone layout, a tall phone, and iPad portrait. Character, hat, HUD and pause/input controls are not clipped. Report actual devices/simulators used.

## B. Movement and collisions

**B01 — Constrained continuous movement.** Inputs -1/0/+1 settle near -1.25/0/+1.25 m without lane snapping. Forward progression is automatic; broad scenery never increases steering freedom.

**B02 — Input parity.** Inject the same normalized inputs through mock motion/touch and compare core traces. Speed, collision and eligibility match. Simulator controls must be usable.

**B03 — Real tilt.** On a physical iPhone, calibrate at two comfortable orientations, steer left/right, pause and recalibrate. Translation/shaking must not become an unbounded lateral impulse. Mark NOT RUN without a device.

**B04 — Stairs.** Cross a long intact staircase with no jump input. No riser collision/sticking. Encounter a deliberately missing group of steps: timely jump survives; insufficient jump falls.

**B05 — Jump buffers.** Unit-test supported jump, airborne refusal, coyote/buffer boundaries, ascending landing and descending landing. No double jump. Down swipe while airborne does not create an undocumented fast fall.

**B06 — Slide.** Sliding capsule/animation clears the certified zebra/horse opening. Standing collides. Completion stands safely, cannot remain low indefinitely, and cannot grant a smaller collision body forever.

**B07 — Straw damage.** Each distinct sports ball after contact immunity removes one arm, the other arm, then a leg, then the last leg. The first three stumble/slow; the fourth produces a rising straw burst and wakes. Same-ball overlap is deduplicated. Edge knockback and fatal semantic hazards retain their existing rules.

**B08 — Straw repair.** A rolling hay ball always grants +1 hay with sound and visible feedback, including at full health, and cannot be recollected. It restores one missing limb or accumulates reserve straw. Banked straw repairs after a one-second delay. Motion, collision and saved roll-start ticks agree; no balloon currency is awarded. Damage persists through pause/suspend. Continue restores the avatar. DEBUG damage/repair/burst previews cannot earn rewards. Break and repair effects respect the Effects setting.

**B09 — Fatal semantic hazards.** A cute on-track rabbit and a blue nazar both wake on actual contact, including during soft-hit immunity. An off-track animal does not collide. No anatomical eye asset appears.

**B10 — Continuous collision.** At maximum player/ball closing speed, no tunnelling through spheres, animals, narrow supported ledges or pickup triggers. Sweep tests hit objects crossed between ticks.

**B11 — Hat neutrality.** Equip every item and replay the same input trace. Time, hitbox, pickups, clovers and outcomes are unchanged. Paid hats do not hide the obstacle horizon more than normal hats.

## C. Exact 42 and art direction

**C01 — Registry.** Count is exactly 42, IDs/ordinals unique, ordinals 1...42, `pig` is #42. No unregistered decorative prop is generated. Composite pig/clover uses IDs 42 and 37.

**C02 — Asset gallery.** All families have real original meshes or procedural prefab builders; inspect silhouettes. Balls have their respective markings, nazar is blue concentric amulet, pig has snout/tail, rabbit ears, equines separated legs, stairs visible treads.

**C03 — Material variation.** Show one staircase/column/tree in at least four perceptually different material/palette contexts. Not every object is a default primitive with hue rotation. White/pastel is not overexposed; glass track is still readable.

**C04 — Mood screenshots.** Capture representative cloud-garden, aqua courtyard, pearl bridge, lonely/void and beyond-palette scenes. Compare composition/scale/material language to supplied references, not exact copied scenes.

**C05 — Semantic invariants.** Across all palettes, nazar markings, balloon pickup cues, four-leaf clover and track edges remain distinct. Hearts never increase currency/lives.

**C06 — Budget review.** Inspect near/mid/far LODs, triangle counts, material cache and entity count. Report profiling targets separately from measured device results.

**C07 — Cultural reposts.** Across seeded Midnight Kitchen cells, exactly two of four cards are original low-resolution forum reposts and two remain unframed cultural objects. Repost selection is deterministic, covers the eight-card deck, stays background-only and does not change the 42-family registry. No starter-pack layout or third-party meme/brand/person appears.

## D. Procedural fairness and transitions

**D01 — Connectivity.** For a seeded manifest, all neighbouring route sockets align within tolerance; support masks reflect visible gaps. No duplicate overlapping floors or phantom stairs.

**D02 — Solvable horizon.** Run a headless oracle through certified templates and random two-chunk combinations at maximum speed, all moods and relevant entry states. Reject no-path candidates. Retried failure produces a safe fallback within eight attempts.

**D03 — Visibility.** Validate minimum preview based on relative velocity. A ball closing at 20 m/s cannot first become readable at 12 m. Curves, stair crests, fog and foreground props must not reduce effective warning below the contract.

**D04 — Required-action compatibility.** No impossible immediate jump/slide combination, unavoidable landing rabbit, or two mandatory lateral positions too far apart for current input limits.

**D05 — Mirror.** Approach a dark inset with a visible frame, pass through and see a new visual grammar without route/camera discontinuity. Pig counter, clock, seed, difficulty and continue flag persist. New mandatory hazards respect the two-second buffer.

**D06 — Marked drop.** Its paired rim/descending balloon cue and landing/beacon appear before the decision. Landing is generated and validated. Descent/landing succeeds inside the envelope, preserves state and reveals the new place.

**D07 — Fatal drop.** An ordinary missed gap has no safe-drop marker and wakes consistently. No hidden probabilistic rescue. Clouds/water alone are never interpreted as safety.

**D08 — Void readability.** A safe drop inside a void chapter still shows its landing cue; ordinary dark environment is not confused with a disappearing playable surface.

**D09 — Repetition.** Bounded histories change normal composition selection without changing pig domains. No infinite list of all past scenes; no impossible demand to never repeat a silhouette.

## E. Determinism, seeds and saves

**E01 — Golden vectors.** Swift output matches every SplitMix/FNV/Dream ID/pig trace in `data/conformance_vectors.json`, including zero and UInt64.max seeds.

**E02 — Invalid IDs.** Reject wrong checksum, oversized string, integer overflow, unknown format, invalid alphabet and unsupported versions. Accept normalized lowercase/allowed aliases. Never start an unknown seed under silently substituted rules.

**E03 — Frame independence.** Run one core input trace under 30/60/120 presentation pacing. Compare gameplay manifests, pig decisions and outcome to documented tolerance. Graphics quality/scenery culling cannot alter any core event.

**E04 — Snapshot.** Suspend mid-jump, mid-slide, mid-stumble, during a rolling approach, before/after pig commitment and during a marked drop. Resume same logic without duplicate events or contact teleportation.

**E05 — Pause clocks.** Pause/background for a simulated hour. Active ticks, pig ordinal and difficulty do not advance. Resume does not consume a continue or change clean eligibility.

**E06 — Save vs resume.** Bookmark replays from beginning in Revisit. Suspend resumes the original run UUID/mode. Importing a result never duplicates a live run.

**E07 — End pending recovery.** Kill/relaunch after a third-pig commit but before white ending finishes. Resume the cinematic or finalize the same outcome, grant achievements/items at most once.

**E08 — Stream isolation.** Generate extra scenic objects and reduced-LOD versions. Pig truth tables and hazard IDs are unchanged. Shader randomness never increments the simulation RNG.

**E09 — Gallery/share.** Save/rename/favourite/delete, share a code/file/card, import on a new local profile, and revisit the same supported dream. Deleting a bookmark cannot delete wallet/purchases. Unknown versions preserve bookmarks with an explanatory state.

## F. Pig system and endings

**F01 — Schedule.** Zero opportunities at time zero, ordinal 1 at 3:00, ordinal 2 at 6:00. Commit/presentation lead-in behaves as specified. Pause, ad and result animations cannot manufacture time.

**F02 — Exact odds.** Exhaustively test all six clover draws: six pig appearances, two clean lucky outcomes, one continued lucky outcome. This tests the rule exactly; do not rely only on Monte Carlo.

**F03 — No pity.** Feed many unlucky outcomes and two previous clovers. Neither state changes the next distribution. Purchases/hats change nothing.

**F04 — Commitment.** A continue before an uncommitted event uses reduced odds. A previously telegraphed clover remains unchanged after a continue. Snapshot/reload does not reroll either case.

**F05 — Collect vs see.** Spawn three clover pigs but intentionally miss one. Lucky Dream does not trigger. Contact ordinary pigs yields no clover; contact lucky pig grants exactly one and no soft damage.

**F06 — Third collection.** At the third valid pickup, freeze score and disable hazards. Store three appearances; white transformation plays, three pigs are visible, humanoid slows/faints, correct achievement/cosmetic granted. No exit door/explicit WIN screen.

**F07 — Collision ordering.** Earlier pickup before fatal hit is recorded; exact-tie fatal wins. Event dedup prevents multiple clovers from one pig.

**F08 — Nominal probability checks.** Verify 9 min = 1/27 possibility with ideal survival/collection, 15 min = 17/81, clean expectation = 27 min, all-lowered expectation = 54 min. These tests do not assert practical human win rates.

**F09 — Mastery.** Advance a fresh clean run to 10,800 active seconds: mastery unlocks and stripping begins, game continues. Continued/Revisit can see the phase but do not get fresh-unbroken prestige.

**F10 — Beyond.** Sparse phase retains route/cues and at most one focal scenery object. Palette rebuilding uses existing registry IDs; it works at six hours and beyond. Three clovers during deep phase still enter Lucky Dream.

## G. Wallet, cosmetics, purchases and ads

**G01 — Currency.** Each collectible balloon = one; no heart/clover bonus. Only valid non-debug gameplay credits wallet. First Dream bonus grants once per profile.

**G02 — Continued settlement.** First waking at total 100 grants 100. Continue and finish at total 150 grants only 50. Reopening/sharing either result never recredits the already-settled total.

**G03 — Purchase atomicity.** Verify a whitelisted StoreKit transaction, interrupt at each persistence boundary, then redeliver. Credit exactly once; finish only after durable delivery. Unverified/pending/cancelled purchases grant zero.

**G04 — Catalogue.** Purchase an affordable normal hat, spend through the correct lots, equip and relaunch. Double tap does not double debit. Unaffordable/owned/achievement-only item cannot be bought.

**G05 — Refund/revocation.** Apply revocation twice. Unspent purchased lot is reversed only once; earned currency/achievement items untouched; no negative displayed balance. Document local-only limitations.

**G06 — Local StoreKit.** Test success, pending, cancellation and duplicate transaction using local configuration. Run on real sandbox/store configuration separately when available. Test price strings never masquerade as live localized prices.

**G07 — Rewarded continue.** Explicit warning shown. Only earned callback creates grant. Dismissal/no-fill/failure grants nothing and does not reduce future odds. Duplicate reward events do not create second grant.

**G08 — Continue restore.** After earned callback, crash before consumption and restore; consume once. Max one per run, no further prompt. Resume on a supported safe route, retain pigs/currency, change future odds once, keep score clocks stopped in protected recovery.

**G09 — Achievement eligibility.** Fresh continued Lucky Dream earns general pig hat, not unbroken pin/mastery. Revisit shows outcome but no fresh prestige. Debug never earns or spends production wallet/achievements.

**G10 — Service unavailability.** Offline/no products/no ads/declined tracking or consent does not block starting a free run. No fake “success” message. Production purchase enable flag with example product IDs fails preflight.

## H. Performance and release evidence

**H01 — Core soak.** Run at least 20 seeded headless six-hour simulations using oracle/test inputs, or report actual coverage if runtime limits intervene. No overflow, NaN, unbounded history or terminal three-hour limit. Force all deep/lucky transitions separately.

**H02 — Render soak.** On physical hardware, measure sustained frame pacing, memory/thermal state and input responsiveness. Quality fallback may change scenery cost, never gameplay/odds. A simulator cannot certify battery/tilt/thermal behaviour.

**H03 — Origin rebase.** Cross many rebase boundaries during jump/slide/ball approach; world remains visually and mechanically continuous. Repeat at long logical distances.

**H04 — Interruptions/errors.** Call/lock/background, motion failure, audio interruption, failed save, disk full and corrupt import all preserve known-good data and provide recoverable states.

**H05 — Release guards.** No debug event grants, simulated ad rewards, fake transactions or accelerated clean scores in Release. No mood-reference images included in production resources. No unknown third-party asset licenses.

**H06 — Evidence report.** Include exact toolchain/build commands, tests run, failures, screenshots, device names for actual device tests, service modes and outstanding account setup. Report unrun checks as NOT RUN, not PASS.
