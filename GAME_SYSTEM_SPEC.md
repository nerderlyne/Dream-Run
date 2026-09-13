# DREAM AGAIN — complete game-system and implementation specification

**Working title:** Dream Again. This is a project name, not a cleared commercial title.  
**Creator:** Shiv / Shiv is Gaming.  
**Specification version:** 1.0 — 13 September 2026.  
**Target:** A playable, native Swift iPhone game, with iPad support, built from this document without access to the original conversation.  
**Deliverable:** Working project, all 42 world-asset families, complete run loop, procedural presentation, persistence, cosmetic economy, purchase/ad adapters, and automated tests. A design-only response, a mock home screen, or a grey-box-only runner is not completion.

> Run through a beautiful, unpredictable dream. Your movement is deliberately simple. The world is not. Collect balloons, avoid waking, save places you loved, and discover what the dream can become.

## 0. Authority, scope, and how to use this specification

Read this document completely before implementing. Read the supplied reference images and data files, then execute the build in the order in §25. `AGENTS.md` is a short project instruction file, not a substitute for this document. OpenAI documents `AGENTS.md` as a source of project instructions; keeping it concise and explicitly pointing to the specification avoids burying the requirements in an oversized instruction file. [S12]

**LOCKED** means explicitly selected by the creator, including decisions that superseded earlier brainstorming. **DEFAULT** means a concrete implementation choice supplied here to close an unresolved question. Defaults are binding for the first implementation but are tunable later. **EXTERNAL** means an owner account, credential, licensed production asset, or device-side validation is necessary; supply the integration and configuration instructions, never pretend it is provisioned.

Priority: locked design constraints → numerical/mechanical rules in this specification → data files → defaults → implementation convenience. If a data file and this document conflict, repair the data and add a regression test; do not silently reinterpret a locked rule. Public platform requirements still apply.

This is a complete first-version target, not a promise that a single agent execution will produce release-ready art, perfect tuning, or an approved App Store submission. The agent must report actual build/test evidence and any remaining external setup. It must not silently omit hard features.

### 0.1 Locked design decisions

- Native Apple implementation in **Swift**. Portrait, close third-person view, constrained **tilt positioning**, swipe up to jump, swipe down to slide. Automatic forward motion; the character remains approximately anchored on screen. Not a bird's-eye, free-roaming, or three-lane tap runner.
- The appeal is an **endlessly recombining, art-directed dream**, not candy/fruit kawaii or a reskinned jungle runner. Use the six supplied mood references. Include beautiful pastel, uncanny, dark void/horror, and later non-pastel visual states.
- Exactly **42 canonical world-asset families**. Their combinations, materials, colours, scale, lighting and placement create variety. Humanoid runner and wearable cosmetics are outside this world-asset count.
- Paths, bridges and staircases are runnable. Ordinary stairs are climbed automatically. Missing steps/gaps require jumps. Sliding under horses/zebras is a signature obstacle. Track versus scenery must be trustworthy and readable; checkerboard is a core motif.
- A normal run ends by the dream dissolving into void from the **bottom of the screen upward**. Use “you woke up” and “dream again,” not literal death/gore lore. No chasing monster is required.
- Rabbits are cute but instantly end a run on contact. The special rolling hazard is a **blue nazar / evil-eye bead motif (🧿)**, not an anatomical eyeball; it also instantly ends a run. Other sports balls roll toward the player and need not be immediately fatal.
- **Balloons** are the one earnable and purchasable currency. Hearts remain world objects. Currency purchases cosmetics, never skill, score, clover odds or achievement-only items.
- Every **13 active minutes**, a pig opportunity has a **50%** chance of a pig. If present, it has a **1/3** chance of a clover. Collect **three clover pigs in one run** to reach the white **Lucky Dream** ending. No pity timer or improving odds.
- Using a rewarded continue halves the future clover probability. It does not make Lucky Dream impossible and does not buy clean-run status.
- Lucky Dream gradually becomes a minimalist white dreamscape; the character eventually faints. The three collected pigs appear. Unlock an achievement called **Lucky Dream**, not “You win.”
- Around **three hours**, the world strips down, awards a mastery achievement for eligible play, then rebuilds using stranger palettes/rules. **It does not end at three hours.**
- Dreams have seeds, can be saved/bookmarked and shared from the result screen, and can be revisited.
- Mirrors naturally straddle the route. They appear to reflect the **void behind you**, yet crossing one abruptly changes the world ahead. They are gateways, not endings.
- Some drops are survivable transitions. They **always have a consistent advance cue**. Their destination can be mysterious; whether the route is survivable cannot be a hidden coin flip.

### 0.2 Explicit defaults closing unresolved choices

| Decision | First-version default |
|---|---|
| Project/module | `DreamAgain`; placeholder bundle `com.example.dreamagain` |
| Device floor | iOS/iPadOS 18.0; compile with an installed stable compatible Xcode; do not require beta-only APIs |
| Renderer | RealityKit in non-AR mode, with a custom perspective camera |
| Player navigation | Continuous constrained tilt offset on an auto-followed route; no manual intersection turns or forks in v1 |
| Main record | Active gameplay time, with distance and balloons reported separately |
| Continues | At most **one rewarded-ad continue per run**; no paid revive product in v1 |
| Ordinary collision | First soft hit destabilizes; a second distinct soft hit within five active seconds wakes the player |
| Ordinary pig | Soft avoidable obstacle; clover variant is collectible and harmless |
| Revisited seeds | Playable and can show endings, but cannot grant fresh-run prestige rewards/records |
| Purchased cosmetics | Same cosmetic catalogue as earned currency; achievement items cannot be purchased |
| Storage | Local, transactional profile and suspended-run storage; no mandatory login |
| Cloud and rankings | Local records required; Game Center/cloud are integration seams, not fake connected features |
| Ads provider | Optional Google Mobile Ads rewarded adapter, isolated from game logic; development mock and disabled modes required |
| Pause | Unlimited ordinary pause/suspend/resume; not a continue and not a skill penalty |
| Title/other achievement names | Working names; all text lives in localization/configuration resources |

Do not reintroduce discarded ideas: anatomical eyeballs, hearts as currency, jump-per-stair, an exit-door ending, secretly random safe falls, indefinitely increasing speed, or mandatory sliding removal.

## 1. Product pillars and exclusion rules

### 1.1 The four things that must work

**Feel:** Tilt a little, read the route, jump or slide. Steering has limited range and never becomes free exploration. Immediate retry must be satisfying even before decoration.

**Place:** The generator composes scenes, not a random pile of props. A pearly staircase above clouds, a flooded aqua courtyard, and a lonely striped animal against blackness must feel related but emotionally different.

**Trust:** The player can understand why a collision occurred and can distinguish track, collectible and hazard. Mystery belongs to meaning and destination, not incorrect hitboxes or impossible obstacle sequences.

**Persistence:** The dream is temporary; personal bests, discovered achievements, bought/earned hats and saved dream bookmarks persist.

### 1.2 Non-goals

No open-world controls, combat, health upgrades, double jump, dash, grappling, loot boxes, energy system, battle pass, forced interstitial ads, subscription, paid clovers, speed purchases, or online generation service. No runtime AI image/model generation. No network requirement to start, continue an already suspended offline run, or enjoy the generator. No public user-content feed or multiplayer backend in v1.

The adjective “endless” means bounded-memory procedural continuation, not prebuilding infinite geometry. The 42-asset constraint does not mean enumerating every mathematical combination.

## 2. First playable experience and complete run loop

### 2.1 First launch

Show an original restrained title screen with the humanoid and a live, inexpensive dream backdrop made from the same registry. Primary button: **dream**. Secondary: **wardrobe**, **saved dreams**, and settings icon. Show wallet total, not an advertisement or a purchase prompt. Local gameplay starts without an account or purchase.

The first run has a 45–60 second deterministic onboarding prefix: tilt toward three balloons, jump one clear gap, slide beneath one oversized zebra, then avoid a stationary rabbit. Teach only one action at a time, with generous sightlines and automatic pause if the app loses focus. Onboarding prompts are brief and dismiss after success. The first rabbit receives an unobtrusive avoid cue; it remains cute. The first safe drop uses the same cue as future drops, not an unrelated tutorial-only graphic.

**DEFAULT:** The onboarding run has a `tutorial` flag and earns currency but not competitive or rare prestige records. After onboarding, every fresh run starts with an eight-second comfortable opening, not an endlessly repeating tutorial. Tutorial can be replayed from settings and never grants the first-run bonus twice.

### 2.2 Normal loop

`Home → Generate seed + prepare initial chunks → short ready fade → Running → Waking → Result → Dream Again / Continue / Save / Share / Home`

During running: advance automatically; follow route height/curves; steer slightly with tilt; jump gaps/low certified barriers; slide under certified overhead shapes; dodge rabbits and rolling balls; collect reachable balloons; pass mirrors and marked drops; survive evolving challenge and visual mutations.

Normal fatal contact commits the run's gameplay endpoint immediately. The character loses its running pose, the nearby path and character dissolve, blackness grows upward while the distant dream remains visible briefly, then the result UI appears. Do not rotate to a separate cinematic death camera. No blood or animal harm.

`Third clover pig → LuckyTransition → WhiteEnding → LuckyResult` is an alternate terminal route. No continue is offered after Lucky Dream. Three-hour evolution changes generation state without entering a result screen.

### 2.3 First-version result screen

Normal copy: **you woke up.**  
Lucky copy: **Lucky Dream** / *You were very lucky.*

Show active time, best comparison, distance, balloons collected this run, clover-pig count, mode (`fresh` / `revisited` / `tutorial`) and continue count. Show the unbroken segment record separately when relevant. The organic white-ending screenshot includes three pigs, the runner's equipped hat, and a small legible statistical caption. Do not stamp “verified” on a local result.

Primary: **dream again** creates a new random fresh seed. Secondary actions: **save dream**, **share**, and **home**. **revisit this dream** is available but is not the default replay button. A rewarded continue is a separate optional control when eligible, never an automatic overlay before the user can see their result.

Target a restart in under two seconds after tap once assets are warm. This is a performance target to measure, not a guaranteed timing assertion. No mandatory countdown timer or wait before restart.

## 3. Application and simulation state

Use explicit enums, not a collection of unrelated booleans.

**App screen:** `home`, `gameplay`, `results`, `wardrobe`, `savedDreams`, `settings`, `achievements`, `importDream`.

**Run phase:** `preparing`, `ready`, `running`, `safeDrop`, `mirrorCrossing`, `paused`, `waking`, `awaitingContinue`, `adPresenting`, `resuming`, `luckyTransition`, `whiteEnding`, `finished`.

**Visual phase:** `ordinary`, `deepStripping`, `deepSparse`, `deepRebuilding`, `beyond`, `luckyWhite`. Visual phase is independent from run phase and mood.

**Run mode:** `fresh`, `revisit`, `tutorial`, `debug`, `reviewDemo`. Debug/reviewer-assisted play is permanently ineligible for currency, records and prestige achievements; never hide that fact in exported results.

### 3.1 Time and progress

Maintain `activeTicks: UInt64` at 60 simulation ticks/second, `routeDistanceMeters: Double`, and a separate presentation clock. The active clock advances only while legitimate gameplay progression is occurring (`running`, brief normal mirror transitions, and certified safe drops). It stops for pause, OS inactivity, ad/loading UI, resume countdown, normal waking animation and the Lucky Dream cinematic.

Collecting clover pig #3 freezes the scored time and distance at contact. The white sequence is presentation, not free survival time. A mirror/drop never resets time, difficulty, pig checkpoints, clovers, mode, or continue penalty. A safe-drop transition lasts at most three active seconds; it cannot be used to wait safely for pig rolls.

Use active time rather than phone wall-clock time. Moving the device clock, leaving the app open in a menu, watching an ad, or taking a lunch break must not progress toward thirteen-minute rolls or mastery.

### 3.2 Event precedence

Resolve events in increasing time-of-impact within a fixed tick. At an exact tie: fatal collision → second soft hit → ordinary soft hit → clover pickup → balloon pickup → transitions. A third pig and a rabbit occupying the same collision instant cannot make the runner invincible; normal generation must avoid that placement anyway. A collectible acquired strictly before a fatal impact remains credited. Each instance ID produces at most one pickup/impact event.

When a run becomes terminal, stop physics/control and pending gameplay events immediately, then play presentation. Result finalization is idempotent. No double wallet grant from a repeated callback, app resume, or tapping share/retry twice.

## 4. Controls, runner and close camera

### 4.1 Coordinate model

Keep a logical route centreline parameterized by distance `s`. Each sample supplies position, tangent, up and lateral/right vector. Player world position is route position + lateral offset + jump offset. Walk surface follows a smooth ramp underneath visible stairs; gap masks deliberately remove support. Decorative geometry does not define the game rules.

Default world axes are +Y up. RealityKit camera looks down its local -Z; implement the route/camera transform explicitly rather than assuming global Z always means forward. Use a parallel-transport or equivalent stable route frame; do not accumulate camera roll around curves.

### 4.2 Tilt

Default: processed Core Motion attitude/gravity, calibrated relative to the device position when the player presses ready/resume. Core Motion supplies processed motion through `CMMotionManager`; use one owned manager and stop updates when gameplay is inactive. [S03]

Map a calibrated left/right rotation to continuous lateral position, not discrete lanes. Full desired offset at ±18 degrees; dead zone 1.5 degrees; desired offset clamped to ±1.25 m. Smooth using a roughly 75 ms filter and limit lateral speed to 4.5 m/s. A tiny physical adjustment should be sufficient. Returning to neutral recentres the runner; there is no uncontrolled sideways drift.

Do not map raw accelerometer X directly without removing gravity/reference orientation. Device translation should not launch the character sideways. Pause automatically if motion data becomes unavailable/stale rather than accepting a giant discontinuity. Recalibration is allowed from pause and never costs currency.

Support alternate touch steering and visible jump/slide buttons for simulator and accessibility. Both feed the identical normalized input path, speed limits and collision rules. They do not silently enable invulnerability or alter record eligibility. Vertical swipe detection must not steal horizontal steering gestures; visible buttons are separate input targets.

### 4.3 Jump and slide

Jump: upward swipe of at least 34 points within 450 ms, sufficiently more vertical than horizontal. Default vertical launch velocity 8 m/s and gravity 22 m/s²: approximately 0.73 seconds flight on level ground, approximately 1.45 m apex. Use a 120 ms input buffer and 80 ms coyote allowance. One jump per airborne cycle; no double jump. Use actual floor height at landing, including ascending/descending stairs.

Slide: downward swipe with the same recognition thresholds. Reduce gameplay capsule height from 1.55 m to 0.58 m for 0.85 seconds, with the base still on the route. Match the pose visually; do not just shrink the mesh. Max extra clearance extension is 0.25 seconds if an overhead obstacle would otherwise make the character stand into its underside. Level validation must fit slides inside that window. Holding/swiping repeatedly cannot slide forever.

Jump requested during slide buffers only until a safe stand/jump state; slide requested shortly before landing can buffer for 120 ms. Do not implement a down-swipe fast-fall or unpredictable automatic action cancellation. Express action transition rules in tests.

Normal stair treads never require tapping. The player automatically climbs them. Missing steps and separate platforms are the jump question.

### 4.4 Humanoid and customization

Use an original simple humanoid: readable head, torso, two arms, two legs, a slightly doll-like rather than realistic human face, and a neutral body material. Height 1.55 m, fixed collision radius 0.28 m. Gentle running cycle, tilt lean, jump tuck, low slide, stumble, and faint poses are required. Programmatic bone/entity animation is acceptable; procedural primitives may construct a stylized character, but a static capsule is not the finished avatar.

Have a stable `headAttachment` transform. Hats share fit metadata and cannot modify hitbox, camera, speed, jump height, luck, input limits or ability to see hazards. Restrict maximum hat size and trail opacity so paid items do not confer a visibility advantage or obscure the track. Achievement hats remain distinct in the catalogue and purchase validation.

### 4.5 Camera contract

A close, perspective chase view; never a bird's-eye view. Initial tuning: camera 4.8 m behind, 2.8 m above the route, looking about 9 m ahead; vertical field of view 62 degrees. Tune framing so the head is roughly in the lower-middle and feet near the lower fifth on a portrait phone. Do not crop the head/hat under the HUD.

Follow route curves/elevation smoothly. Follow only 20% of lateral displacement so tilt movement remains perceptible without moving the runner across the entire screen. No head bob, camera roll, speed FOV pumping, forced orbit or dramatic zoom-out. Brief soft positional feedback on stumble is optional and removed by reduced-motion settings.

Lock framing against iPhone safe areas and iPad aspect ratios, not a single screenshot size. At every maximum-speed segment, the camera must reveal an actionable hazard early enough for §7. Curves/spirals must be redesigned or rejected if close framing hides the route. Cinematic spectacle is not permission to obscure collision space.

## 5. The exact 42-asset contract

A **world asset** is one registered prefab/archetype with an ID, recognizable geometry, construction rules, material policy and allowable roles. It may contain multiple meshes, use a procedural mesh builder, or share primitive geometry with another archetype. The sports balls intentionally remain separately named prefab families even when they share a sphere mesh. The constraint is **42 world families, not exactly 42 unique mesh buffers**.

Palette, material, LOD, left/right mirroring and instancing do not create extra IDs. The pig plus clover is a composite of existing IDs 42 and 37. A room with a bed and windows is a composition of existing registered families. Sky domes, collision volumes, particle billboards, UI, materials, textures, the humanoid and equipped wearables are implementation/support resources, not new world props. Do not use this exception to smuggle unregistered decorative objects into the dream.

Every family below must be implemented and visible in an in-app DEBUG asset gallery. Procedural original geometry is the default so the build does not depend on missing `.usdz` files. Supplied images are mood references only; their production-use rights are not established. Imported replacements must preserve IDs, sockets and hitbox envelopes and include license/provenance records.

Each prefab needs: bounds, pivot, LODs, semantic material slots, collision role defaulting to `none`, allowed scale range, safe attachment points, silhouette tags, and role-specific construction constraints. Rendering variants must not create duplicate pickup/hazard triggers.

| # | Stable ID / object | Construction and first-version function |
|---:|---|---|
| 01 | `track_straight` — **Straight track** | Parametric extruded deck, patterned top, visible rim, separate underside. Entry/exit route sockets; length 18–30 m; width normally 4 m. |
| 02 | `track_curve` — **Curved track** | Extrude the same cross-section along a gentle planar curve; preserve checker UV spacing. Left/right from signed curvature; no separately counted mirrored prefab; validate lookahead. |
| 03 | `track_ramp` — **Rising/falling ramp** | Smooth deck with continuous height profile, not an obstacle or speed boost. Grade capped at 18 degrees initially; appearance can be grander outside the play strip. |
| 04 | `stairs_straight` — **Straight staircase** | Repeated visible treads and risers over a continuous logical walk surface. Automatic climbing; explicit missing support intervals require jumping. |
| 05 | `stairs_curve` — **Curved staircase** | Stair treads arranged along a broad curved centreline. Gentle curvature; player/camera follow the route automatically. |
| 06 | `stairs_spiral` — **Spiral staircase** | Large-radius ascending/descending helix assembled from wedge treads. Gameplay radius at least 24 m; no tight blind spiral, camera obstruction, or roll. |
| 07 | `platform` — **Floating platform / landing** | Broad beveled slab, round or rounded-square outline; patterned certified landing zone. Used for plazas, drop landings and step-like sequences; cosmetic widening does not increase steering range. |
| 08 | `track_broken` — **Broken track / missing steps** | Paired ledges or stair groups with explicit empty support intervals. Real gap mask in simulation, not merely a black texture; telegraph based on current maximum speed. |
| 09 | `arch` — **Arch** | Open classical/rounded arch with actual hole, two uprights and curved lintel. Ordinary arches have generous clearance; certified low-arch variant has a conspicuous underpass. |
| 10 | `column` — **Column** | Fluted or smooth shaft, base and capital; instanced colonnades. A validated horizontal low-column template may be a jump obstacle; random scenery never acquires collision. |
| 11 | `mirror` — **Void mirror gateway** | Freestanding rounded/ornate frame and opaque black inset with restrained sheen. Opening straddles the runnable ribbon; passing through mutates the visual grammar, never kills. |
| 12 | `window` — **Open window frame** | Frame plus two hinged/open casements; no painted pretend opening. References the pastel window image; scenery only, including oversized distant versions. |
| 13 | `room_shell` — **Open room / liminal courtyard** | Walls, doorway-like openings and ceiling strips built as one parameterized room family. Room floor uses existing track/water instances; keep traversal exit visible. |
| 14 | `house` — **Small strange house** | Simple recognizable pitched-roof house with inset windows and door geometry. Can float, repeat or invert off-track; never an exit or secret win trigger. |
| 15 | `tower` — **Tower** | Narrow tiered tower with strong distant silhouette; optional existing window instances. Landmark from 100–500 m away; do not spawn an unregistered skyline kit. |
| 16 | `fountain` — **Fountain** | Basin, stem and tiers; water is material/particles or asset 25. Small courtyard object or huge suspended landmark; no random gameplay effect. |
| 17 | `chair` — **Unoccupied chair** | Recognizable seat, back and legs, with subtly ornate silhouette. Small domestic object at impossible scale or in water; not another hidden ending. |
| 18 | `bed` — **Bed** | Pillow, mattress, low frame and simple headboard. May dress a certified soft landing; the landing trigger belongs to the route, never inferred from its mesh. |
| 19 | `tree` — **Dream tree** | Trunk and branching silhouette with optional clustered canopy. Bare, fuzzy, chrome and giant material/scale treatments reuse this family. |
| 20 | `flower` — **Oversized flower** | Curved stem, leaves, distinct petals and centre. Meadow clusters or monumental overhead flowers; never hide an active hazard. |
| 21 | `mushroom` — **Mushroom** | Curved stem, cap, underside and optional procedural spots. May repeat into forests or appear alone; no secret power-up. |
| 22 | `rock` — **Rock** | Seeded low-frequency displaced rounded rock with controllable faceting. Can be pearl, glass-like or velvet; not a route surface without an existing landing/track instance. |
| 23 | `mountain` — **Mountain / cliff mass** | Large low-detail eroded silhouette with inset rock planes. Distant backdrop; cloud and track instances can surround it. |
| 24 | `cloud` — **Cloud / fluffy mass** | Soft clustered volumes with an opaque stylized fallback; low transparent overdraw. Safe drops require a marker and a generated landing; a cloud alone never promises safety. |
| 25 | `water` — **Water / reflective plane** | Bounded tileable plane with animated normal/ripple treatment. Ocean, flooded room or black reflecting surface; not automatically walkable or safe to fall into. |
| 26 | `moon` — **Moon** | Sphere/disc with a restrained crater texture and optional crescent mask. Tiny, multiple, enormous or grounded; no luck effect. |
| 27 | `balloon` — **Balloon** | Rounded inflated body, pinched neck, knot and lightweight curved string. Collectible form small, reachable, halo-marked and worth exactly one balloon; giant scenery form is unmarked. |
| 28 | `heart` — **Heart** | Rounded 3D heart with clear central notch, not two disconnected spheres. A visual object only in v1; hearts are not currency, lives or upgrades. |
| 29 | `star` — **Star** | Rounded five-point extruded star. Floating decoration and optional cosmetic motif; no second currency. |
| 30 | `ball_soccer` — **Football / soccer ball** | Sphere with recognizable contrasting football panel pattern. Predictable rolling towards runner; one hit causes stumble, not automatic waking. |
| 31 | `ball_eight` — **Eight-ball** | Glossy near-black sphere with two readable white number-8 patches. Preserve identifying patch; recolouring cannot turn it into the nazar. |
| 32 | `ball_softball` — **Softball / tennis-like ball** | Yellow-green round ball with curved seam detail. Matches the supplied round sports-ball motif; deterministic path, no random bounce into safe space. |
| 33 | `ball_american` — **American football** | Prolate body, pointed-ish ends, laces and end stripes. Visual tumble with a stable predictable hazard corridor; no physics-driven erratic ricochets. |
| 34 | `nazar` — **Blue evil-eye ball** | Round blue glass-like body bearing navy/white/light-blue/black concentric eye motif. This is the blue amulet motif, NOT an anatomical eyeball. Keep motif orientation readable as it rolls. |
| 35 | `ribbon` — **Floating ribbon / bow** | Extruded curved band with optional bow loop, built from a swept strip. Low transverse ribbon is a certified slide template; other placements are non-colliding. |
| 36 | `curtain` — **Freestanding curtain** | Two lightweight pleated cloth panels on an invisible or simple integrated header. Certified slide version has a visible lower opening; no opaque blind collision plane. |
| 37 | `clover` — **Four-leaf clover** | Exactly four distinct heart-shaped leaves on a short stem. Appears only attached to lucky pig events and owned rewards/ending; never an independent currency or random pickup. |
| 38 | `rail` — **Bridge balustrade / railing** | Repeating balusters and top rail; connectors allow straight or curved instancing. Frames bridges/stairs; cannot imply solid protection where simulation allows a fall. |
| 39 | `horse` — **Horse** | Elegant recognizably equine body, four separated legs, mane, tail and head. Slide template enlarges belly clearance; scenery horses may be monumental. No harm to animal. |
| 40 | `zebra` — **Zebra** | Stockier equine silhouette, upright mane, striped coat and four separated legs. Not merely an invisible box with stripes. Leg gap must be visible and match collision geometry. |
| 41 | `rabbit` — **Rabbit** | Small soft rabbit with long ears, rounded body, haunches and tail. Looks cute, never bloodshot or monstrous. On-track collision instantly ends run; off-track is scenery. |
| 42 | `pig` — **Lucky pig** | Small friendly round pig with snout, ears, four short legs and curly tail. Ordinary pig is an avoidable soft obstacle; clover pig is collectible. Same pig family dresses the three-pig ending. |

### 5.1 Asset production requirements

Use material slots such as `body`, `trim`, `underside`, `semanticMarking`, `glassLike`, and `trackTop`. Track patterns must keep a world-scale tile size of approximately 0.8–1.2 m instead of stretching a single checker over a 30 m segment. Curved pieces need continuous UVs. Ground-contact pivots are bottom-centre; rolling-object pivots are their centres. Document a consistent metre scale.

Animals must have actual silhouette-defining parts: rabbit ears, pig snout/curly tail, horse mane/tail/four separated legs, zebra upright mane/stripes. Construct them with smooth original low-poly surfaces or composites if needed, but do not substitute a labelled cube. A horse's body collision must leave real under-belly clearance; an invisible solid box around the whole animal is unacceptable.

Use three quality representations where useful: near readable mesh, simplified mid-distance mesh, and far silhouette. Triangle targets in `asset_catalog.json` are budgets, not quotas. A single detailed prop may never compromise response time. Reusing primitive geometry or a primitive mesh builder is encouraged; registering 42 names around 42 indistinguishable spheres is not completion.

Apply transformations by **role**. A 40 m scenery horse may be beautiful; a slide-hazard horse must use the validated dimensions. A giant balloon can be scenery; collectible balloons retain their small canonical pickup appearance. Objects only gain collision when a certified gameplay template assigns it. Runtime random scaling of a live collider is prohibited.

### 5.2 Material vocabulary

Implement recognizably different versions of matte porcelain, glossy plastic, pearl, metal/chrome, glass-like translucent surface, velvet/fuzzy-looking surface, marble/stone, and emissive accent. These are art treatments, not eight mandatory physically exact optical simulations.

RealityKit mesh resources/materials provide the rendering foundation; generate reusable geometry rather than loading nonexistent asset files. [S02] For the first build, achieve glass with limited transparency/specular response, fuzz with roughness/normal detail and soft silhouette, pearl with restrained view-dependent colour or layered texture. Do not require true ray-traced refraction, volumetric clouds, dynamic hair, screen-space water reflections, or recursive mirror rendering. Any custom shader must compile for the deployment target and have a tested PBR fallback, not an imaginary API.

Avoid transparent stacks over the whole screen. The track's top and edge must remain readable even when the rest of a bridge looks translucent. Do not put chrome glare, rainbow noise or fur over every object at once. Material contrast is composed, not randomized independently per triangle.

## 6. Gameplay vocabulary and collision outcomes

| Encounter | Required response / meaning | Collision result |
|---|---|---|
| Small halo-marked balloon | Move through the pickup or follow its reachable arc | +1 balloon; pop/shrink response; no score multiplier |
| Normal soccer/eight/soft/American ball | Tilt out of its predictable rolling corridor | Soft hit; stumble and destabilization |
| Blue nazar ball | Tilt out of its rolling corridor | Immediate waking; no gore, literal eye or health subtraction |
| On-track rabbit | Avoid by lateral positioning; jumping is permitted only when the physical trajectory genuinely clears it | Immediate waking on actual contact |
| Off-track rabbit/horse/other scenery | Nothing | No collider |
| Enlarged horse/zebra spanning track | Slide through the visible under-belly opening | Standing collision wakes; sliding body capsule must fit |
| Low certified arch/ribbon/curtain | Slide under the visible lower opening | Standing collision wakes |
| Low horizontal column template | Jump over the low, visibly solid obstacle | Soft hit unless already destabilized |
| Normal pig at a timed opportunity | Pass beside it | Soft hit on contact; it is not a collectible |
| Clover pig | Intentionally intersect the whole pig's pickup envelope | Collect pig + its clover together, store appearance, progress toward three |
| Full-width missing support / broken stairs | Jump to supported track | Falling without a safe-drop contract wakes |
| Mirror across track | Keep running through it | Safe visual-state transition |
| Marked downward route / drop | Follow its descent cue | Certified safe descent and landing |
| Heart, moon, giant decorative ball, house, etc. | Neutral scenery unless listed in a certified template | No arbitrary secret effect or collision |

The clover is not a second currency and is not independently farmable. The whole lucky pig briefly dissolves into a friendly shimmer when collected; its stored appearance returns in the ending. This follows the creator's “collect three pigs,” not the earlier suggestion to leave all pigs standing behind.

### 6.1 Soft impacts and dream instability

On the first distinct soft impact: a short stumble animation, momentary speed scale 0.75 recovering over one second, and a black lower-edge intrusion. Set `destabilizedUntil = activeTicks + 300`. If a second distinct soft hazard hits after the brief contact lockout but before recovery, wake. After five collision-free active seconds, the edge recedes and instability clears.

Use 0.8 seconds of immunity to **soft repeat impacts** only, plus per-instance hit deduplication. Rabbits, nazar, fatal gaps and blocked full-body underpasses remain fatal during that period. Do not let recovery effects conceal the next obstacle. A single ball's collider cannot hit every tick and instantly count as two hits.

A soft stumble is not a continue; an otherwise uninterrupted run remains eligible for clean records/mastery. “Unbroken” means no run-ending event was bought/watched past, not zero nonfatal touches.

### 6.2 Rolling objects

Move rolling hazards analytically along the route, towards the player at a default 4 m/s relative to the route, within a predetermined lateral corridor. The football may tumble visually; its collision path must remain readable. Do not rely on nondeterministic rigid-body rolling/bouncing to decide whether a lane suddenly becomes unsafe.

Use swept collision at relative closing speed. At player speed 16 m/s and ball speed 4 m/s, a two-second warning needs approximately 40 m of visible approach, plus margin. A fixed “spawn 12 metres away” rule is forbidden. Bodies and materials retain their semantic markings. The nazar retains its blue concentric motif across every palette, including the post-mastery phase; keep one motif facing sufficiently towards the approaching player to remain identifiable.

## 7. Route generation, fairness and valid transitions

### 7.1 Generate a route ribbon, then stage a world around it

Represent each module with entry/exit route poses, length, width profile, height profile, support mask, curvature, safe gameplay envelope and sockets for optional composition. Base chunks are 24 logical metres; variable geometry may span more than one chunk but must preserve deterministic IDs.

Generate/retain about 240 m ahead and 48 m behind, subject to visibility and a maximum active chunk budget of 16. Larger landmarks may be represented by a small far-scene pool outside that gameplay window. They are recycled/crossfaded before their budget can grow without bound. A world does not need thousands of past chunks to feel infinite.

Build a logical `ChunkDescription` first. It contains route, gameplay objects and scenery placements as plain deterministic data. Validate it, then instantiate render entities. Do not let asynchronous mesh loading, GPU frame rate or entity completion order make generation decisions.

### 7.2 Route restrictions

Maintain a standard 4 m visible play ribbon and at least 3.2 m on deliberately narrow pieces. Input remains ±1.25 m; do not expand steering across broad plazas. Normal full-width decks therefore do not punish an ordinary full tilt by letting the player drift out of the world. Missing-edge support regions can create explicit hazards, but must be marked/readable and validated like gaps.

Curves follow automatically. No sudden swipe-turn junctions, lane snapping or optional branching maze in v1. Stairs have a smooth logical climb surface with visible treads. Limit default slopes to 18 degrees; a spiral needs a broad radius of at least 24 m and adequate forward visibility. Visual side stairs can be impossible; the actual play route cannot.

Track tiles, an uninterrupted top-edge/rim, repeatable width and contact shadow establish playable surfaces. Nontraversable background stairs do not wear the full live-track marking/edge treatment near the player. Reflection and fog must never make a hole look like solid checkerboard.

### 7.3 Hazard grammar

Use a small library of certified encounter templates rather than independently scattering colliders:

`breathing straight`, `single lateral dodge`, `rolling ball dodge`, `single gap`, `stair gap`, `horse/zebra slide`, `low arch/ribbon slide`, `low column jump`, `dodge then jump`, `slide then dodge`, `two offset hazards with a surviving corridor`, `mirror approach`, `marked drop`, `pig runway`.

Default cadence evolves from one simple required action roughly every 4–6 seconds near the start to 1.6–3.0 seconds in sustained difficult play, with breathers. Required actions must never be spaced less than one second apart, and sequential jump/slide constraints must honour their actual durations and landing state. These are starting tuning values, not measured player ability.

At generation time, each template specifies a safe input trajectory or set of reachable safe intervals. Validate the two-chunk horizon using the same movement model, conservative collision margins, maximum reachable speed and action timings as gameplay. For moving hazards, include relative motion. Search across continuous-offset reachability intervals or a conservative sampled lattice; any numerical validator's tolerances must be explicit. Tests are evidence of coverage, not proof against every possible device bug.

Reject sequences where a legal recovery exit from the preceding mandatory action has no reachable continuation. There must be a survivable advertised route **without collecting balloons or clovers**, without a paid action, and without needing foreknowledge. No rabbit placed at the only landing, no ball hidden behind a mirror, no unavoidable second impact during a stumble, no forced jump whose landing requires an overlapping incompatible slide.

Limit candidate retries to eight. If all fail, insert a safe track/breathing template with original deterministic candidate metadata, log the seed/chunk, and continue. Never accept an impossible candidate because a spawn timer expired.

### 7.4 Initial encounter dimensions

Use these conservative starting dimensions, then certify against the movement model: ordinary rolling ball radius about 0.45 m; nazar radius about 0.70 m; rabbit footprint radius about 0.35 m; ordinary pig footprint radius about 0.38 m; lucky-pig pickup envelope radius about 0.65 m. Ball/rabbit/pig side placements must leave a genuinely reachable corridor after accounting for the runner radius. Scenery scale does not override these gameplay presets.

A normal gap starts around `min(4.8, max(1.8, 0.30 × approachSpeed))` metres long. The jump solver still validates launch and landing margins, floor elevation and both nearby obstacles; this formula is not a replacement for validation. Low jump-column height starts at 0.45 m. A slide passage starts with 0.85 m clear height above the logical walking surface, leaving margin over the 0.58 m sliding body while blocking the 1.55 m standing body. Equine legs stand outside the certified central slide corridor. Do not auto-generate jump or slide dimensions from a randomly scaled scenery mesh.

### 7.5 Visibility contract

At the maximum possible approach speed, each required response has at least two seconds of readable preview. Measure from the earliest position where the hazard and relevant escape are actually visible, not from when its entity exists. Keep active gameplay out of opaque clouds, foreground curtains and excessive glare. Curves and stair crests reserve clear lead-ins. Add conservative line-of-sight checks and device screenshot reviews.

After a mirror wipe or safe-drop landing, there are at least two seconds before a new mandatory response. Maintain a danger-free buffer on both sides of the mirror and for a pig collection opportunity. Balloons may tempt a harder route, but no recommended trail leads to certain failure.

### 7.6 Safe falls: subtle, consistent, never a lottery

Use one recurring combination: a thin pale double rim at the drop lip, a descending ribbon of **collectible balloons**, and a visible faint patterned landing or its restrained beacon below. The markers are ordinary world styling, not a huge “SAFE DROP” label. The first encounter can make the destination generous enough to learn the rule.

The generator must create and validate the landing **before** advertising the drop. A safe-drop record stores its departure socket, landing socket, trajectory, time, input tolerance and recovery buffer. Camera and character follow a 1–3 second scripted descent with preserved lateral offset inside the safe envelope; no uncontrolled physics tumble. It may dress the landing with an existing platform, cloud arrangement or bed, but landing support is explicit data.

Clouds, water, pastel colours or absence of black alone are **not** safety promises. The same backgrounds exist beside fatal gaps. Fatal gaps have no descent marker, no collectible path into guaranteed death, and visibly unsupported space. In void chapters, a marked safe landing retains its rim/beacon even when the background is black. The player need not know *where* they will arrive, but the learned cue must correctly indicate *that* the transition is survivable.

No retroactive rescue roll after a missed ordinary jump. No changing an already visible landing to fatal. A failed input outside the safe-drop's marked envelope can still cause a normal waking event.

## 8. The dream-composition generator

### 8.1 Separate deterministic streams and responsibilities

Use separate seeded domains for `route`, `hazards`, `scenery`, `palette`, `mood`, `mirror`, `drop`, `pigPresence`, `pigClover`, and `audio`. Event/cosmetic particles may have their own disposable stream. Rendering fewer decorations on a slower device must never change pig odds, obstacles, currency placements or the underlying saved dream.

Pipeline: select route family → certify next gameplay segment → choose/continue visual state → compose scenery around exclusion volumes → add material/palette/lighting treatment → validate readability → stream entities. Safe gameplay wins if a beautiful composition would cover the next gap.

### 8.2 Scene state, not independent random colours

A `DreamStyleState` includes mood, palette ID, dominant/secondary material, architecture/nature balance, prop density, scale regime, fog, sky, illumination, repetition pattern and oddity budget. A chapter has one dominant palette and no more than two strong material families, plus controlled accents.

At ordinary chunk boundaries, approximately 85% of stylistic choices inherit the current chapter. About 12% may mutate one compatible property; about 3% may introduce a conspicuous but nonhazardous contradiction. These are defaults, not pig odds, and can be art-tuned. Validate that a mutation does not cause flickering, an invisible floor or a confusing currency/hazard silhouette.

Compose with templates such as:

- Cloud staircase framed by a distant house and one enormous heart.
- Aqua flooded courtyard with repeating windows/columns and a clear checker ribbon.
- Pearl bridge with iridescent accents, reflected water and sparse stars.
- Pink path through blackness, bare trees, a few distant horses and gold-speckled ground.
- Domestic chair or bed at impossible scale beside an otherwise empty route.
- Repeated arches becoming progressively taller while the camera remains close.

These are reusable **composition recipes**, not pre-rendered levels or six fixed biomes. A recipe references only the 42 assets. Alter rhythm, placement, scale and materials across reuse. Do not guarantee a visible new mesh every few seconds; deliberate emptiness is part of the language.

### 8.3 Mood states

| Mood | Visual/audio direction | Gameplay invariant |
|---|---|---|
| Serene | Open sky, pearl/pastel, low-density architecture, airy layers | Clear track and warnings |
| Playful | Balloons/hearts, unusual scale, light material contrasts | Currency still unambiguous |
| Uncanny | Repetition, lonely domestic items, asymmetrical monumental forms | No fake collision or false safe routes |
| Lonely | Sparse skyline, slower visual change, distant forms | Difficulty is not hidden in fog |
| Void | Black/near-black environment, limited highlights, sparse sound, unmistakable horror atmosphere | Track edge, hazards and nazar remain visible |

Mood transitions are allowed within the same palette or by mirror. Void is not necessarily the final or hardest state; an early run can briefly pass through it and return to something beautiful. Onboarding remains visually readable. No mandatory jump scares, flashing strobes or copyrighted Backrooms creatures.

### 8.4 Novelty memory

Keep bounded recent history: last 12 foreground asset-family placements, last two route families, last two hazard families, last three composition recipes, and chapter palette history. Penalize immediate repeats without changing special-event probability. Do not claim this makes generation nondeterministic: seeded choices plus bounded memory are deterministic and serializable.

A large scene change should involve multiple perceptual dimensions over time: silhouette composition, density, material, scale or spatial rhythm—not merely swapping pink for blue. Prohibit uninterrupted random hue cycling. Reserve readable rest areas and one distant focal landmark per composition. Avoid a screen full of equally bright focal points.

### 8.5 Mirrors

A mirror frame stands across the playable ribbon with enough width for every valid lateral offset. Its surface is a **deliberately false reflection**: black void, a faint reflection-like shimmer or silhouette, not a view of the destination. A true planar reflection is not required.

On crossing, keep route continuity, camera heading, speed, controls, score, pig counters and RNG version. Hide the visual state swap with a short dark passage (approximately 80–150 ms, no white flash), then reveal the new composition. New scenery is prepared before the player reaches the surface. No load spinner or abrupt camera relocation.

Default spacing: a chapter opportunity approximately every 90–210 active seconds, at least 75 seconds apart and subject to safe route scheduling. This is not a forced quota; never spawn a mirror inside a dangerous action sequence or a pig runway. After the mirror, mutate several stylistic properties at once. Within a chapter, mutate gradually.

## 9. Difficulty without an impossible speed ceiling

Default forward speed: `v(t) = 7 + 9 × (1 − exp(−t/300))` m/s, where `t` is active gameplay seconds. This approaches 16 m/s rather than increasing without limit. Put constants in `game_config.json`; no hardcoded difficulty multiplication after each minute.

Long-run difficulty comes from fair combinations, tighter-but-valid lateral corridors, pattern alternation, more rolling approaches and sustained attention—not visibility failure or subhuman reaction windows. Do not alter collision sizes secretly at high time. Procedural palette/horror intensity does not automatically imply a harder geometry sequence.

Use low/high-intensity encounter runs separated by recovery spaces. A tiny three-hour skill gate is meaningless if the deterministic speed equation guarantees unavoidable failure after five minutes. Test that the oracle controller can remain alive at the cap and through each state transition; separately test whether people enjoy it. Do not advertise automated-agent survival as human playtest evidence.

Optional distance computation is integrated route travel, not a score multiplier. Stumbles may slow travel briefly; time is still the main challenge statistic. Clovers, currency, purchased cosmetics, mirror transitions and graphic quality do not modify difficulty or score rates.

## 10. Pig checkpoints and exact luck rules

### 10.1 The rule must be literal

Checkpoints occur at **13:00, 26:00, 39:00, 52:00, 65:00…** of active gameplay. At each ordinal `k ≥ 1`, draw pig presence with probability 1/2. If present, clover probability is 1/3 before a continue, 1/6 after one. Overall clover-pig probabilities are therefore 1/6 and 1/12 per checkpoint.

No pity system, no bad-luck protection, no improved probability after earlier clovers, no guaranteed third pig, no odds boosts from hats, purchases, ads watched elsewhere or device setting. A regular pig appearance is not itself a clover. Missing a collectable pig does not reroll it. Pig/clover counters reset on a genuinely new run, never on a mirror or safe drop.

Outside these scheduled events, do not randomly spawn pig/clover imagery in normal gameplay and accidentally fake an opportunity. The ending and owned cosmetic are exceptions. Other animal scenery is unrestricted by this pig schedule.

### 10.2 Deterministic sampling

Create two independent keyed draws for each ordinal: `pigPresence(k)` uniformly in 0..<2 and `pigClover(k)` uniformly in 0..<6. Pig exists when presence is 0. It is lucky in a clean run when clover draw is 0 or 1; after continue it is lucky only when draw is 0. This makes the continued lucky set an exact subset of the clean set while preserving the specified probabilities.

This is a design algorithm, not a security protocol. Use the versioned RNG in `docs/REFERENCE_ALGORITHMS.md` and conformance vectors, not Swift's randomized `Hasher` or a render-loop random call. Draws are indexed; changing the number of clouds cannot advance the pig stream.

### 10.3 Presentation without spawn unfairness

To give a readable approach, commit a checkpoint result approximately six active seconds before its nominal encounter and reserve a safe runway. Persist the commitment and its event ordinal immediately. Its probability policy is fixed at commitment; a continue must not recolour a visibly promised clover pig into an ordinary pig. Only future uncommitted events get the reduced odds. Explicitly test the six-second boundary.

The target encounter is the exact thirteen-minute checkpoint, but a mirror, certified descent or recovery may defer the physical runway by at most ten active seconds. Do not reroll, duplicate, skip or move the next nominal checkpoint because of the delay. The rare-event roll still belongs to its scheduled ordinal. If the player wakes before reaching the event, there is no earned pig.

The pig runway guarantees a viable route both to collect and to bypass the pig at the current maximum speed. Place no competing mandatory hazard until the encounter/recovery completes. Ordinary pig footprint leaves a lateral safe route. Clover pig uses a forgiving but visible pickup envelope and no damage collider. Collecting it stores an appearance descriptor, adds one of three tiny pig/clover markers to the HUD, plays a gentle response, and persists progress. Collecting three starts Lucky Dream immediately.

### 10.4 What the brutality mathematically means

With independent clean checkpoints and perfect collection/survival, expected checkpoints for three lucky pigs = `3 / (1/6) = 18`, or **234 minutes (3 h 54 m)**. Minimum possible nominal completion is **39 minutes**. Through 65 minutes there are five opportunities; probability of at least three lucky pigs is about **3.55%**. These are conditional on living long enough and collecting every lucky appearance, not the chance an ordinary attempt wins.

If the lower odds apply from the start, expected checkpoint time is **468 minutes (7 h 48 m)**. A continue used halfway through produces a mixed-probability process, not that simple all-continued calculation. Survival failure and missed pigs lower the practical success probability further. Preserve these consequences; do not silently “fix” them to an hour-long ending.

Pausing is free and can safely suspend a multi-hour run. The game must not require the phone to remain actively running for hours just to protect a chance at a rare ending.

## 11. Waking, continuing and terminal sequences

### 11.1 Normal waking

Freeze game score at fatal contact, keep the close camera, show a brief stumble/fall pose, then grow an irregular dark mask from the bottom over roughly 1.25 seconds. Dissolve player/path locally using an inexpensive material effect or coordinated visibility wipe. Keep the distant dream visible until last. Final background becomes black; show **you woke up.** and results. No sudden audio blast or literal explanation of whether the nazar protects the runner.

The player may skip the normal presentation after the first 0.35 seconds, but completion/finalization logic must be the same. Saving/sharing is offered after it. Varying the death presentation does not change the collision cause recorded in the run ledger.

### 11.2 Rewarded continue

**DEFAULT: one maximum per run.** Only after a normal waking event; never after the Lucky Dream endpoint. The player chooses it explicitly, with accessible **dream again** alongside.

Before accepting, say: **Continue this dream — watch an ad. This run will be marked continued. Future clover chances are halved.** Further details may explain 1/3 → 1/6 conditional clover odds; do not hide the disadvantage in a secret achievement description. Rejecting an ad does not erase the result or confiscate balloons.

A successful rewarded callback grants a single continuation entitlement for this run. Persist the grant and its consumption separately/idempotently. Dismissal without reward, failure to present, no fill, offline state or cancelled consent grants nothing and applies no probability penalty. Never equate ad dismissal with earned reward. Google provides a specific rewarded-ad callback and requires opt-in/test ads for development; integrate through that contract. [S10]

On return, restore at a validated supported checkpoint at or just beyond the fatal location, removing only the already-resolved fatal obstacle. Do not rewind the game clock or event index. Preserve collected balloons, previously collected pigs and committed event results. Supply a two-second safe recovery lead-in; no new pickups/pig events or scored time during this protected lead-in. Then resume at the proper difficulty.

Set `continueCount = 1`, `freshUnbrokenEligible = false`, and future uncommitted clover selection to the reduced rule. Ordinary pig probability stays 50%. A continued fresh run may still earn **Lucky Dream**, but never **Lucky Dream — Unbroken** or the clean three-hour mastery award. Do not falsely describe a continue as equivalent to a clean run.

### 11.3 Lucky Dream

At third pig contact, atomically mark an ending pending, freeze scored time/distance, disable hazards and stop new currency/rare-event generation. Store all three collected pig appearances. Continue forward in a cinematic presentation with player controls softened/disabled only after the transition is apparent.

Over about 45 seconds, reduce colour variation and scenery density; keep a coherent pale path. Props thin out, materials soften, the sky/ground merge toward warm off-white. Do not simply run an exposure slider to a blinding white flash. Optional skip becomes available once the transformation is understood; it awards exactly the same valid outcome.

In the last approximately 12 seconds, remove HUD, reveal **three pigs ahead**, slow the runner from run to walk, then an ambiguous gentle faint. The pigs stand/gather nearby. No gore, laughing antagonist, exit door, “level complete,” or explanatory lore. End with the three-pig composition and **Lucky Dream**. Unlock its achievement and cosmetic once, including after a crash-resumed pending ending. The unbroken variant also unlocks when eligible.

No ordinary hazards can end the cinematic after the third pig. Freeze records at collection rather than padding them with 57 safe seconds. Returning to the title permits a new dream; this is not a canonical completion of all content.

### 11.4 Three-hour boundary and beyond

At `activeTicks == 10800 × 60`, an eligible fresh unbroken run earns **Still Dreaming**. This is a named time/milestone gate, not an attempt to exhaust all possible asset combinations. Show a small unobtrusive achievement notice, not a result screen.

For all nonterminal runs reaching the time (including revisits/continued), enter a visual phase: roughly four minutes thinning → one minute very sparse → five minutes rebuilding. During the sparse phase, show no more than **one focal scenery object at a time** in addition to the essential route/player/gameplay cues. Do not erase the track, safe-drop markers or required hazard telegraphs. Keep occasional fair actions; it is not a permanent idle farming mode.

Then gradually enable the post-mastery palette families: acid cobalt, red/cyan, ink/lime, violet/orange, harsher matte surfaces, stranger architectural repetition. The same 42 assets remain; do not add a 43rd “secret asset pack.” The nazar/balloon/clover/track semantic markers still obey readability rules.

Beyond this, continue composing indefinitely at capped difficulty. A further thinning/rebuilding cycle may occur every additional three active hours as a default, without stacking more mastery achievements. Do not run out of legal palettes or crash after an enum's final state. Lucky Dream takes priority if a third pig is collected during any deep phase. Future pig rolls still occur every thirteen active minutes, including sparse phases; reserve them as the focal event rather than hiding them.


## 12. Seeds, saved dreams, reproducibility and eligibility

### 12.1 What a seed promises

A dream is identified by a 64-bit root seed plus **generator, rules and content versions**. All three matter: changing collision timings, palette selection or asset socket geometry can invalidate reproducibility. Do not save only a random integer and claim it survives arbitrary updates.

The same supported Dream ID recreates the same baseline route, placements, chapter decisions and indexed pig outcomes. Animation and player-dependent state may differ when the player makes different inputs, stumbles or continues. Deep transitions are gated by active time, and a continue deliberately changes future clover eligibility. Therefore **a seed is not a recording of a run**. Exact simulation reproduction additionally needs an initial snapshot or input/event log. GPU pixels/physics are not promised bit-identical across every device.

Use one deterministic path/collider core rather than RealityKit's dynamic physics as the authority. Random choices must be independent of frame rate, render quality, dictionary iteration, wall clock, number of generated background objects, asynchronous loading order and network responses.

### 12.2 Canonical Dream ID

Use the format `DR1-G1-R1-C1-<13 base32 characters>-<4 checksum characters>`. The fields are format, generator version, rules version, content version, a 64-bit seed encoded as fixed-width Crockford-style Base32, and a 20-bit truncation of CRC-32 over the uppercase prefix before the final hyphen. The reference algorithm and exact fixtures are supplied in `tools/reference_rules.py` and `data/conformance_vectors.json`.

A human-friendly optional name (“Pink Ocean”) is a bookmark title, not a second seed encoding. Do not use only four whimsical words with an unspecified mapping or insufficient entropy. Copy/paste ignores whitespace around the code and accepts lowercase; normalize O→0 and I/L→1 only inside the seed/checksum fields. Reject overflows, invalid checksum and unsupported versions. Limit input length before parsing.

Sharing uses native share sheet with a thumbnail/result card, plain Dream ID, and optional `dreamagain://dream/<code>` custom URL. The custom scheme is a development convenience, not a verified unique or universal web link. Owned HTTPS Universal Links need a real domain and association file; supply a later integration seam, do not invent a functioning website. A tiny `.dream` JSON import/export file is also supported, with a strict whitelist and size limit of 32 KiB. Imported seeds are data, never code or asset URLs.

### 12.3 Save versus suspend

**Save Dream** creates a bookmark: Dream ID, title, creation date, achieved duration/distance, a thumbnail, last-seen composition/chunk marker and favourite flag. It lets the player replay from the beginning. It does not silently grant a checkpoint at the rarest location.

**Suspend** stores the current live run: run UUID, seed/versions, mode, active clock, route progress, avatar/input state, buffered actions, recent generator history, active hazard states, committed pig events, collected pig appearances, currency counters, instability, continue grant status and current phase. Resuming it is the same attempt, not a Revisit or a rewarded continue.

Offer **save & leave** in pause. Pause automatically for backgrounding, lock screen, calls and interruptions; persist the run. Resume behind a ready/recalibration step with no scored time passing. A multi-hour dream should survive an ordinary overnight pause. Periodic snapshots (default 15 active seconds) limit crash loss; state that abrupt failure can restore the last durable point, never claim zero-loss survival when no write happened.

Bookmark deletion never deletes purchased cosmetics or the wallet. Thumbnail cache eviction never deletes a seed. **DEFAULT:** no monetized save-slot limit; allow many bookmarks, with a bounded thumbnail cache. A bookmark made after Lucky Dream replays the world, not a free instant achievement.

### 12.4 Fresh versus Revisit

Fresh seeds are chosen internally from a secure random seed source once at run creation, then deterministic generation takes over. Imported, selected or previously saved seeds run as **Revisit**, visibly labelled on pause/results/share cards.

Revisits may earn ordinary balloon currency at the same rate and show the natural pig/white/deep sequences. They have per-seed local bests. They cannot grant the fresh-only Lucky Dream/mastery cosmetics or populate fresh-run records. Ordinary discovery/tutorial achievements may be available according to the achievement catalogue. Cosmetic purchases cannot promote a Revisit to Fresh.

This eligibility policy is a first-version default protecting the intended rarity from a widely shared favourable seed; it was not a creator demand to ban replay rewards. Keep it configurable but explicit. Do not secretly reroll pigs on every revisit while promising that the same dream is replayable.

Save/reload cannot reroll a pending pig or replenish previously collected balloons in the same attempt. Persist unique event IDs and continue decisions. Reopening an old result starts either a new Fresh run or a labelled Revisit, not a duplicate writable copy of the original run.

### 12.5 Version migration

Release v1 supports G1/R1/C1. Store immutable tables or version-specific implementations when later versions change. Unknown versions produce a clear unsupported-version message and preserve the bookmark; do not crash or silently substitute a different dream. To migrate an old dream aesthetically, create a new explicitly labelled Dream ID while retaining the original record.

A compatibility update must run the same golden-seed fixtures before claiming that old saves are compatible. Debug logs include seed, versions, chunk, event ordinal and active tick. The agent must provide a reproducible bug-report export without including advertising IDs or unnecessary personal data.

## 13. Balloons, wallet, cosmetics and commerce

### 13.1 One currency

The unit is **balloons**. Every normal small collectible = one balloon. A world balloon has a knot/string and a restrained halo/highlight that survives palette changes. Distant scenic balloons may be huge and unmarked; keep them out of the live collectible envelope. Never place invisible black collectible balloons in a black void without a contrasting cue.

Use clusters/trails, gentle arcs and risky-but-survivable offsets. Default spawn budget is approximately 30–50 available balloons per active minute, adjusted by route safety rather than paid status. Treat this as provisional economy tuning; do not promise a player income without playtesting. Balloon pursuit is optional, and never required to preserve a record.

Collecting one makes a quiet pop/shrink/spark response. Rate-limit audio/haptics in dense trails. Balloon pickup radius is slightly forgiving and identical for every cosmetic and input mode. No purchasable magnet.

The player keeps collected currency after waking or voluntarily ending the run. A rewarded continue keeps the same total; currency already settled at the first waking must not be awarded again. Debug/review play credits nothing. There is no interest, expiration, second premium currency, hidden multiplier or cash-out.

### 13.2 Wardrobe and ownership

Use `data/cosmetics.json` as the first catalogue: ordinary hats, body colour presets and one ordinary trail, plus achievement-only rewards. All listed normal items can be purchased with earned **or bought** balloons. Price and ownership are explicit. Allow preview on a rotating or static runner outside gameplay; no loot-box reveal or randomness.

The catalogue includes Paper Hat (150), Bow (300), Nightcap (450), Bucket Hat (600), Balloon Hat (800), Checker Cap (1,000), Eight-ball Hat (1,200), Little House (1,600), Moon Hat (2,000), three body presets (500 each), and Ribbon Trail (1,000). These prices are **defaults**, not settled commercial requirements. A one-time First Dream bonus of 100 balloons is a default stored with an idempotent key.

Achievement rewards: Lucky Pig Hat, Unbroken Clover Pin, Beyond Crown, Void Ribbon. Their store price is `null`, not an extremely high number; validation rejects any purchase attempt. The catalogue knows each item's acquisition source. A continued Lucky Dream may earn the pig hat, so only the separate unbroken pin/record proves no continue was used.

Equipping/unequipping is free, reversible, persistent and does not change collision or gameplay. Prevent duplicate purchases of an owned non-stackable item. Debit and ownership grant occur in the same transaction. Do not allow negative wallet balances through rapid taps or failed writes.

### 13.3 Paid balloon packs

Implement three **consumable StoreKit** products for 500, 1,500 and 4,000 balloons. IDs in the supplied data are placeholders. Include a local `.storekit` configuration with clearly identified test prices; display real store prices only from StoreKit's localized product data. Native purchase sheets handle authorization. Missing/unavailable products show “unavailable,” not a fake price or local credit button.

The app's policy is StoreKit for digital balloon purchases, no expiring purchased balance, and appropriate restoration for any restorable products later added. These choices align with Apple's in-app-purchase guidance. [S04] StoreKit's transaction and persistence APIs are the implementation references; do not treat a screen closing as a successful purchase. [S05]

On verified success: look up the product in the whitelist, check the transaction ID, atomically persist the wallet credit and transaction record, then finish the transaction. Observe updates on app startup so interrupted completions can be processed. On pending/cancelled/unverified/error: do not grant, do not erase existing balance, and show appropriate nonfatal state. A repeated delivery of one transaction never credits twice.

Local StoreKit testing is a required development path; production products, banking agreements, storefront configuration and signing are external owner setup. [S06] Include restore/reconciliation code where applicable, but **do not promise StoreKit automatically restores the remaining spent/unspent consumable wallet**. Wallet history is application data. v1 has local storage/normal device-backup behaviour, not guaranteed cross-device or reinstall recovery. Before enabling sales, the owner must accept and communicate that limitation or provision the optional synchronized ledger. Never reconstruct a wallet by crediting every historical purchase again.

Refund/revocation handling must be idempotent and recorded. For v1, reverse at most the still-unspent credited amount associated with that purchase lot; do not take earned balloons or achievement rewards to compensate for a spent refund. Log unsupported reconciliation cases for support and do not claim this local policy is fraud-proof. A stronger shared wallet/refund service is external scope.

### 13.4 Ads and what is not sold

The only v1 ad placement is the voluntary one-time continue after a normal waking event. No banner in the dream, surprise interstitial between runs, rewarded clover, ad to see the ending, paid retry gate, or “ad-free” upsell when there are no forced ads. No paid continue pack or infinite resurrection product is included by default.

Define a `RewardedContinueProvider` with live, disabled and debug mock implementations. A mocked ad says **Developer test reward** and is compiled out of Release. In Release with no configured provider, hide/disable the offer gracefully; the free game still works. Do not ship a fake ad that earns production continues as though advertising were live.

Integrate privacy state before requesting ads. Google's UMP documentation covers consent refresh, required forms/privacy options and the `canRequestAds` gate; implement it in the optional live adapter. [S11] Tracking permission and consent are different concerns. Use Apple's tracking/data-use requirements where tracking applies; never reward granting tracking permission or make refusal block ordinary play. [S07]

## 14. Achievements and record semantics

Implement local achievements first, idempotently. `data/achievements.json` is the complete initial list, with ID, visible title, trigger, mode eligibility and reward. Names other than Lucky Dream are defaults. Hidden achievements can show `???` until earned, but gameplay/commerce conditions that materially affect the player must not be deceitful.

| Achievement | Default condition | Reward |
|---|---|---|
| First Dream | Finish a non-debug run | One-time 100 balloons through the economy bonus key |
| A Little Longer | Five minutes fresh, unbroken | Badge |
| Long Dream | Thirty minutes fresh, unbroken | Badge |
| Very Long Dream | One hour fresh, unbroken | Badge |
| Through the Glass | Cross a mirror | Badge |
| Another Way Down | Finish a marked safe drop | Badge |
| Lucky Pig | Collect one clover pig in Fresh | Badge |
| Empty Dream | Stay 120 active seconds in one void chapter and leave alive, Fresh and unbroken | Void Ribbon |
| Lucky Dream | Three collected clover pigs and white ending in Fresh, continue allowed | Lucky Pig Hat |
| Lucky Dream — Unbroken | Lucky Dream without any continue | Unbroken Clover Pin |
| Still Dreaming | Three active hours in Fresh without a continue | Beyond Crown |
| Remembered Dream | Save a bookmark | Badge |

Do not add “find all 42” achievement unless separately requested: the registry is a design constraint, not an advertised checklist spoiling every mystery. No achievement based on literal exhaustive combinations. Never require watching ads or buying balloons for a badge.

Maintain **Best Unbroken Dream** for a fresh run's time up to its first waking; **Longest Continued Dream** for total duration of a fresh run with a continue; and **Revisit Best** per supported seed/rules version. Tutorial/debug modes do not enter these. If a player continues after setting a new clean best, keep that original unbroken endpoint rather than overwriting it with the longer continued total. A second leg is not a new fresh clean run.

Every result/share card carries mode, continues, duration, seed and rules version. Distance and currency are context, not hidden tie-break bonuses purchased with cash. If Game Center is configured later, use separate leaderboard IDs and eligibility filtering for each category; GameKit is the native integration reference. [S08] Do not display invented remote rankings when authentication/configuration is absent.

**Security boundary:** A seed and a local screenshot are not proof of human skill. On-device rules can be modified and seeds can be searched. Signed server-validated records or replay verification would be a separate project. Ship honest local records; do not advertise tamper-proof prestige.

## 15. Persistence, interruptions and data integrity

### 15.1 Storage contract

Use one serialized persistence service and transactional storage. The supplied `data/persistence_schema.sql` describes a viable SQLite layout; the agent may use an equivalent transactional native store if it preserves all invariants and tests. `UserDefaults` is acceptable for noncritical settings, not the wallet or the sole purchase ledger.

Required persistent domains: profile/settings; wallet lots and ledger entries; processed StoreKit transaction IDs; cosmetic ownership/equipped state; achievement unlocks; run records and result-finalization markers; one active suspended-run snapshot; bookmarks/thumbnails; recorded continue grants; and schema/generator version metadata.

Within one transaction, make coupled changes durable: purchase credit + processed ID; cosmetic debit + ownership; ending reward + achievement; earned-run settlement + highest already-settled amount; snapshot + pending rare-event state. Use prepared statements/typed persistence, not string-interpolated SQL with user-provided dream titles.

### 15.2 Run settlement

Track `balloonsCollectedTotal` and `balloonsAlreadySettled` per run UUID. On waking, final quit, Lucky Dream or later finalization after continue, credit only the nonnegative difference. Use one durable idempotency key per settlement revision. Share/save/reopen result cannot create another credit. Preserve the run's total for display even after it is settled.

If a continued run wakes a second time, only balloons collected after the prior settlement are added. Restore exactly one active run instance. A previously terminal run cannot be resumed by importing its result file.

### 15.3 Background/crash behaviour

On interruption: stop accepting gameplay inputs, stop advancing active time, snapshot, suspend rendering/audio/motion appropriately. On resume: show the same state behind a ready prompt; recalibrate tilt; do not advance pigs or penalize the player for the OS pause.

Store action phase, time offsets and rolling hazards so resuming does not place an airborne runner on the floor or teleport a ball into them. Regenerate render chunks from the logical snapshot. Save already collected IDs for the active/recovery window plus durable passed-event counters to prevent recollection. Do not serialize RealityKit entities as the authoritative save.

Save errors produce a visible retry/support state; do not zero a purchased wallet to “repair” it. Keep a validated last-good backup and a quarantine copy of corrupt input. Disk-full, failed atomic replacement, unsupported schema and interrupted migration need tests. Migrations must not change the count of earned pigs, currency or continues.

Keep personal data minimal: no account, email or precise location needed. Bookmarks may contain user text; store locally and escape during export. Thumbnails and reference mood images have separate lifecycles; mood images must not be bundled in the production app.

## 16. UI, audio, feedback and accessibility

### 16.1 UI direction

Minimal, calm, slightly uncanny. Use system fonts or an explicitly licensed bundled font; no external font downloads. A small readable sans-serif HUD with restrained lowercase labels fits the game. No imitation of Temple Run's logo, art, UI assets, sounds or characters. No giant glossy “SALE” cards in the dream.

HUD: active time; current-run balloon count; pause; show pig/clover markers only after the first collection. Keep primary action space and horizon clear. Hiding HUD for screenshots is optional and purely cosmetic. Always preserve accessible pause/input controls.

Home, results, wardrobe, saved gallery, import code, achievements and settings are complete interactive screens. Every button performs its action or explains unavailability. Wardrobe items expose price/owned/achievement-only states. Gallery has rename, favourite, delete, share and revisit; destructive deletion asks confirmation. Import errors are readable and recoverable.

### 16.2 Adaptive sound

Use original/licensed audio only. A code-generated ambient bed and simple synthesized pickups are acceptable for the self-contained build. Implement ambient layers for airy, watery, uncanny and void states, plus a rhythm/pulse layer that follows intensity without becoming an alarm. Crossfade chapter transitions; mirrors can briefly cut texture. White ending gradually removes layers. Void may be nearly silent but not rely on inaudible danger cues.

Use a bounded number of audio voices and an audio service separate from SwiftUI. AVAudioEngine is an appropriate native implementation reference. [S09] Handle interruptions/headphones/silent-mode policy intentionally. Default app audio respects mute; expose separate music/effects controls. Critical obstacles always have visual cues.

Use gentle haptics for balloon clusters, a distinct small response for clover pigs, and a short stumble cue. Rate-limit feedback, respect system settings and support haptics off. Do not play a violent explosion when the cute rabbit is touched.

### 16.3 Comfort/accessibility

Required: touch-steering alternative; jump/slide buttons; tilt sensitivity/dead zone/calibration; reduced motion; reduced flashes; text contrast; audio/haptic toggles; accessible labels on menus; colour-independent distinction of track, balloon and nazar; and pause/suspend without penalty.

No camera roll, strobing track tiles, abrupt white flashes or screen-shake dependence. Void horror stays visual/atmospheric, not gore. White-ending luminance transitions remain smooth. Do not claim a particular age rating; the owner must answer the content questionnaire accurately.

A centre-to-edge tilt calibration overlay is for settings/debug, not a permanent tutorial covering the game. Track pattern filtering/LOD should reduce distant shimmer. A thermal low-power mode lowers visual cost, not fairness or gameplay simulation rate.

## 17. Native implementation architecture

### 17.1 Framework choices

**SwiftUI** owns menus/HUD. **RealityKit** renders a fully virtual scene, with `ARView` explicitly set to `.nonAR` through a SwiftUI wrapper and a `PerspectiveCamera`. Apple documents both the non-AR camera mode and controllable perspective camera. [S01] Do not start a camera/AR session or request camera access for a non-AR runner.

**Swift** owns a fixed-step deterministic core, generation, collision, clocks and state. **Core Motion** provides input, **StoreKit** purchases, **AVFAudio** sound, and optionally **GameKit** achievements/leaderboards. iOS 18.0 is the chosen deployment floor, not a claim about the newest OS. Use only APIs verified against the installed SDK and availability checks; avoid unverified SceneKit/RealityKit migration assumptions.

RealityKit is the renderer, not the sole simulation authority. Do not mix engine-driven dynamic bodies with an independently advancing deterministic runner and hope collisions agree. Cosmetic physics may be faked analytically or isolated so it cannot alter gameplay.

### 17.2 Suggested project layout

```text
DreamAgain.xcodeproj/                 # committed, runnable project + shared schemes
DreamAgain/
  App/                               # entry, dependency wiring, app lifecycle
  UI/                                # screens, HUD, share/import
  Rendering/                         # RealityKit scene, camera, chunk renderer
  Assets/                            # 42 prefab builders, material library, avatar
  Input/                             # motion and touch adapters
  Audio/                             # ambient layers and feedback
  Persistence/                       # database actor, migrations, snapshots
  Commerce/                          # StoreKit; optional rewarded-ad adapter
  Resources/                         # catalog JSON, local StoreKit config, audio
  Configuration/                     # example config and build flags
Packages/DreamCore/
  Package.swift
  Sources/DreamCore/
    Simulation/                      # GameSession, movement, clock, collisions
    Generation/                      # route, gameplay, style, fairness validator
    Events/                          # pigs, mirrors, drops, endings, achievements
    Determinism/                     # RNG, Dream ID, versioning
    Models/                          # plain Sendable/Codable state
  Tests/DreamCoreTests/
DreamAgainTests/
DreamAgainUITests/
scripts/                             # validate/build/test/render checks
IMPLEMENTATION_STATUS.md
KNOWN_LIMITATIONS.md
```

Keep the core free of UIKit/RealityKit/StoreKit. It should be testable as a Swift package without iPhone hardware. Do not make 42 separate full engine subsystems; small typed models/services suffice.

### 17.3 Minimum domain interfaces

Use real implementations behind these conceptual interfaces; names can adapt to project conventions:

```swift
struct DreamIdentity: Codable, Equatable, Sendable {
    let generatorVersion: UInt16
    let rulesVersion: UInt16
    let contentVersion: UInt16
    let seed: UInt64
}

struct InputFrame: Codable, Sendable {
    let normalizedSteering: Double  // -1 ... +1, same for motion and touch
    let jumpPressed: Bool
    let slidePressed: Bool
}

protocol DreamGenerator {
    mutating func nextChunk(context: GenerationContext) throws -> ChunkDescription
}

protocol RunSimulation {
    mutating func step(input: InputFrame) -> [GameEvent] // exactly one fixed tick
    func snapshot() -> RunSnapshot
}
```

These are domain sketches, not an excuse to leave undefined types in the delivered app. Implement concrete state, serialization and tests. Make `ChunkDescription`, `RunSnapshot`, asset IDs, rule IDs and event IDs explicit; prefer typed enums over arbitrary strings in hot code.

Keep UI/RealityKit mutation main-actor isolated. Generate plain mesh arrays/description data away from the render path when useful, then create/publish resources through documented safe APIs. Avoid concurrency races between session updates, purchase callbacks, ad returns and persistence. Do not put per-frame state updates into a SwiftUI `body` evaluation.

### 17.4 Fixed-step loop

Use a frame callback to accumulate real elapsed time and step the core at 1/60 second, then interpolate presentation. Maximum four catch-up steps. If more whole simulation ticks would remain after that catch-up budget, pause rather than silently discard elapsed time or rush through unseen gameplay. A stall over 250 ms or an OS interruption also pauses safely. Do not fast-forward the player into an unseen obstacle. Normal brief catch-up must not secretly create extra scored time. Input frames are sampled deterministically at ticks.

Use `Double` for accumulated logical route distance and time calculations, `UInt64` for ticks/event counters, and bounded local float transforms for RealityKit. Rebase the render origin every approximately 192 m while preserving logical coordinates, active collider data and seed IDs. Do not let a three-hour position grow until float precision jitters the track or makes seams lethal.

Use capsule/sphere/box primitives and swept tests in logical route space. Model horse/zebra legs and belly separately. For gaps, evaluate supported intervals at the actual projected foot position; for jumps, detect landing across the sweep. Run animation follows this state; animation must not independently determine collision height.

## 18. Deterministic data and runtime models

At minimum implement the following persisted/testable concepts:

`AssetDefinition` (42 IDs and construction metadata); `AssetInstanceID` (dream/chunk/slot); `MaterialFamily`; `PaletteDefinition`; `DreamStyleState`; `RouteSample`; `SupportInterval`; `ChunkDescription`; `EncounterTemplate`; `HazardDescription`; `PickupDescription`; `MirrorTransition`; `SafeDropContract`; `PigCheckpointEvent`; `CollectedPigAppearance`; `PlayerKinematicState`; `RunState`; `RunSnapshot`; `RunResult`; `DreamBookmark`; `WalletLedgerEntry`; `PurchaseRecord`; `CosmeticDefinition`; `AchievementDefinition`; `ContinueGrant`; `Settings`.

Every live hazard has immutable spawn-time geometry/role and a deterministic motion descriptor. Every collectible has an immutable value/ID. Scenery may animate/dissolve but has no gameplay event source. Random meshes do not auto-register as collision obstacles. A render-entity-to-instance mapping supports debugging but is not the authoritative game state.

Run metadata must include rule version and eligibility flags so later UI cannot accidentally present an assisted run as a clean achievement. Never infer eligibility solely from whether `continueCount` happens to be zero in a default-constructed result.

Keep content tables resource-backed and validated at startup/development time. Release should gracefully reject corrupt unsupported imports, not crash. A malformed bundled asset catalogue is a build/test failure, not a reason to continue with 41 assets.

## 19. Performance, memory and long-run durability

Starting budgets in config: 60 fps target, 30 fps low-power presentation, 16 active chunks, approximately 750 render entities, 180 draw calls, 220,000 visible triangles and 350 MB memory. These are **engineering targets to measure** on a baseline physical iPhone, not verified RealityKit performance guarantees. Adjust art cost before degrading responsiveness.

Reuse geometry and material resources. Cache material variants by a bounded palette/material key rather than allocate per instance/per frame. Pool common entities with maximum capacities; release excess. Static scenery can be merged within a chunk if it retains the same registered asset provenance. Do not assume shared resources automatically guarantee hardware instancing on every target.

Prebuild common meshes outside active gameplay. Limit simultaneous transparency, lights, shadows, particles and audio voices. Fake fog/soft atmosphere cheaply where necessary; avoid hundreds of large intersecting transparent cloud planes. No camera-facing opaque prop may hide the live track.

A long run must not append every previous chunk, input frame, particle, collision ID or screenshot to unbounded RAM. Keep rolling diagnostic windows and compact event histories; stream optional debug input logs to bounded disk, disabled by default. Collected balloon IDs only need their active/recovery window plus committed progress/settlement state.

Handle thermal changes by lowering distant detail, particles, shadows and presentation frame rate while preserving the identical logical course and pig stream. Stop nonessential background work. No racing to catch up game time after the app wakes from sleep. A genuine six-hour soak must show bounded memory after warmup and no growing coordinate jitter.

## 20. Developer tools required for a one-pass build

Provide a **DEBUG-only Lab** reachable from a clear debug control, not a secret production cheat. It contains:

- **Asset gallery:** all 42 IDs in order, near/mid LOD, palette/material cycling and collider preview.
- **World preview:** enter seed, step chunks, toggle mood/palette/material, show composition IDs and bounds.
- **Traversal course:** deterministic separate tilt, jump, slide, stair-gap, rolling-ball, rabbit, nazar, mirror and drop tests.
- **Event injection:** ordinary pig, clover pig, third pig, normal waking, white ending, 2:59:50/3:00:00 state, post-mastery palettes, continued penalty.
- **Diagnostics:** active tick, route distance, seed/versions, chunk count, pool sizes, draw/triangle estimates where available, memory, telegraph distances and eligible flags.
- **Commerce scenarios:** mock verified/pending/cancelled/duplicate purchase; ad success/failure/dismissal; saved pending ending recovery.

Activating any gameplay override permanently marks that run Debug and prevents currency/prestige grants. Resetting the UI toggle cannot undo the flag. Release strips Lab entry points, mock-grant code and accelerated-clock flags. A reviewer-accessible nonrewarding demonstration path may be separately documented and cannot post records.

These tools are essential: nobody should have to manually survive four hours just to see whether the white-ending animation renders. They must not alter the shipping probability rules.

## 21. Required automated and visual verification

Use the detailed `ACCEPTANCE_TESTS.md` as the completion checklist. At minimum:

**Determinism:** published RNG/seed golden vectors; same chunk/event manifest independent of frame pacing and render quality; snapshot/resume; version rejection; no random render-stream influence on pigs.

**Mechanics:** tilt clamps; alternate-input parity; automatic stairs; buffered jump; slide clearance; standing horse collision; one ball soft impact; two distinct soft impacts; instant rabbit/nazar; supported gap landing; forbidden hidden rescue.

**Generation:** connected sockets/supports; valid slopes/curves; lookahead at capped closing speed; no obstructed marker; safe drop landing exists; at least one survivable route per certified template/horizon; bounded fallback; no more than 42 registered families.

**Rare rules:** exactly thirteen-minute ordinals; no roll at time zero; correct presence/conditional clover tables; no pity; continue halves future uncommitted clovers only; three **collected**, not merely spawned pigs; RNG results persist; white ending and mastery coexist correctly.

**Economy:** verified purchase idempotence; pending/cancelled/unverified no grant; debit+ownership atomic; achievement item not buyable; repeated result/share no duplicate settlement; currency after continue grants only delta; no negative balance; refund/revocation handling; unavailable services do not block play.

**Long runs:** accelerated headless six-hour simulations without unbounded memory; three-hour stage transitions; after-six-hour continuation; no integer overflow or non-finite transforms; optional real-device thermal soak is separately recorded.

**Visual/device:** portrait start/run/result screenshots, all 42 assets recognizable in gallery, checkerboard stays clear, slide-under-animal actually looks possible, safe/fatal drops distinguishable, mirror transition continuous, white/pig ending, void state and post-mastery state. Tilt calibration and sustained frame pacing require physical-device testing, not just simulator success.

Do not equate Python validation of this pack with tests of the built Swift game. It verifies the specification's data and reference rules only. The implementing agent must run the actual app's tests and report results.

## 22. Platform and production gates

Account/service setup is **external**, not a reason to omit the offline game. Provide example configuration, a release preflight script and documentation for:

| Item | Implement in code | Owner/real-device step |
|---|---|---|
| App signing and identity | Valid project, example bundle ID, configurable team | Choose owned bundle/team and signing credentials |
| Balloon purchases | StoreKit adapter, ledger, local configuration and error handling | Create actual products, set storefront prices, test sandbox/production readiness |
| Rewarded ads | Provider interface, optional live adapter, privacy gate, test mode | Create provider account/app/ad unit, configure consent and privacy information |
| Privacy/support | Settings links configurable; disclosure checklist | Supply real privacy-policy/support URLs and complete accurate disclosures |
| Game Center | Local achievements/records plus adapter seam | Configure service IDs if enabled; otherwise no fake global rankings |
| Universal Links | Import/code sharing works without web service | Supply owned domain and association file if enabled |
| Cloud wallet/saves | Local robust persistence; sync seam documented | Optional actual cloud/backend provisioning, reconciliation and restore tests |
| Final assets/audio | Original self-contained procedural assets and sound | Review aesthetic quality and any replacement licensing |
| Release quality | Build/test scripts and smoke flows | Physical-device tilt, accessibility, thermal, StoreKit and ad verification |

Apple's review guidance calls for functioning features, accurate metadata, explained non-obvious behaviour and documented purchases. Describe rare endings, long-run modes and review access in reviewer notes; mystery for players is not an excuse to hide functionality from review. [S04] The title, characters, art and sounds must be original or licensed. Do not market the app using “Temple Run” or “Backrooms” as an implied licensed product.

Release preflight fails if mock currency grants are enabled, product IDs remain example placeholders while sales are enabled, live ads use missing IDs, debug grants can post records, privacy/support URLs are claimed but invalid, or imported content can execute code. The offline base game can remain fully playable when live commerce/ads are intentionally disabled.

## 23. Tuning controls and what must not be silently tuned

Expose speed, movement filter, jump/slide timing, gap lengths, reaction windows, encounter cadence, material intensity, palette transition lengths and currency/cosmetic prices as versioned data. Label playtest-driven changes in `IMPLEMENTATION_STATUS.md` and bump rules/content versions where they affect saved dreams.

Do **not** adjust thirteen-minute pig timing, 50% presence, 1/3 conditional clover, 50% continue penalty, three pigs, no-pity rule, non-ending three-hour evolution, 42 registry count, or currency-only cosmetic benefits without creator approval. Performance degradation must not change any of these.

Keep the readable play ribbon stable even in non-dreamcore palettes. Mystery never authorizes an undisclosed purchase penalty, incorrect collision bounds, corrupt save, changed seed or forced advertisement.

## 24. Definition of done

The build is complete only when a new developer can open the committed project, select a supported simulator, run it, start a dream, use touch controls to tilt/jump/slide, see all 42 implemented world families across gameplay/gallery, collect/spend balloons, equip a hat, encounter deterministic obstacles/transitions, wake/retry, bookmark/share/import/revisit, suspend/resume, and inspect rare outcomes in Debug without changing release odds.

The physical-device path must support Core Motion with working calibration. The renderer must look intentionally related to the supplied references, not like a grey-box test, candy runner or randomly coloured primitive demo. A post-run screenshot should be recognizably this game.

StoreKit local tests and mock/disabled ad paths must work. Optional live integrations must either be configured and tested or explicitly documented as unavailable; no fake purchase success or phantom Game Center records. Every required test is passed, failed or not run with an actual reason. Never say “tested on iPhone” when only static code inspection occurred.

Deliver source, resources, project/shared schemes, tests, build commands, original/procedural asset builders, local StoreKit config, config examples, screenshots where tooling permits, and a status report. Document open tuning/art issues separately from implementation defects.

## 25. Implementation order for Codex

This is one full assignment executed in verified increments, not permission to stop after the prototype.

1. Inspect repository and installed tools. Preserve unrelated user work. Read all specification/data/reference files. Create a short execution plan and status file. Select real, available APIs and record toolchain/deployment versions.
2. Create native app and independently testable `DreamCore` package. Add deterministic RNG/ID parsing, versioned configuration, state models, clocks and pure movement tests. Commit/open a real Xcode project, not just a proposal to generate one.
3. Implement constrained tilt/touch, close camera, automatic stairs, jump, slide, capsule collision and instant retry on a temporary plain course. Verify playable feel. The temporary greybox is a milestone, not the final artifact.
4. Implement the 42 prefab builders and material library; add Asset Gallery. Validate registry count, visible silhouette, pivots, LODs, semantic markings and functional underpasses. Build the original avatar and initial wearables.
5. Implement route/chunk streaming, fairness templates, support masks, rolling hazards, safe drops and mirrors. Run deterministic generation/route tests before increasing visual density.
6. Add the art-directed style system and mood transitions. Compose representative cloud, aqua, pearl, uncanny and void scenes from the supplied palette vocabulary. Validate screenshots/lookahead, not just seed counts.
7. Add pig schedule, continue flag, Lucky Dream choreography and three-hour/beyond state machine; test via accelerated Debug runs and golden probability rules. Preserve exact creator odds.
8. Add wallet, cosmetics, achievements, records, bookmarks, import/share and robust live-run suspension with idempotent persistence. Test duplicate callbacks and crashes.
9. Add StoreKit local purchase flow and optional rewarded-ad provider. Verify real configuration boundaries, clear continue warning and release guards. Do not fake services to make the feature list look complete.
10. Add audio, haptics, onboarding, comfort settings and all empty/error states. Run simulator UI flows and screenshots, then physical-device checks when hardware is available.
11. Run the full acceptance suite, six-hour core soak, debug/gallery checks, release preflight and actual build commands. Fix failures. Report measured results, missing external setup and remaining limitations precisely.

**Final implementation report:** what works; exact build/test commands and results; where the project is; how to launch the Lab; how to configure products/ads/signing; and any unimplemented items. Do not end the task with a new pitch for features instead of code.

## 26. Source notes and specification provenance

The game design, asset selection, numerical tuning defaults and algorithms in this pack are original implementation proposals derived from the creator's discussion. They are not claims that a particular design will guarantee retention, commercial success or novelty. The six mood references were supplied by the creator; their provenance/production license is not established.

External framework/service statements are anchored to these official references, checked on 13 September 2026. API pages sometimes expose only summaries through web extraction; the implementing agent must check signatures and availability in the actual installed SDK before using them. Do not infer an unavailable API from a documentation title.

# Official implementation references

Checked: **13 September 2026**. The specification's feature decisions are design choices; these sources support the platform/service details, not commercial predictions or a guarantee of engine performance. The implementation must verify availability and signatures against its installed stable SDK. Some Apple API pages exposed only a title/summary in web extraction, so a link alone is not evidence that a particular method signature has been tested.

## S01 — Non-AR RealityKit and a controllable perspective camera
- Apple, `ARView.CameraMode.nonAR`: https://developer.apple.com/documentation/realitykit/arview/cameramode-swift.enum/nonar
- Apple, `PerspectiveCamera`: https://developer.apple.com/documentation/realitykit/perspectivecamera

Supports a fully virtual RealityKit scene and a custom viewpoint. The specified camera framing is original tuning, not an Apple recommendation.

## S02 — Runtime mesh resources
- Apple, `MeshResource`: https://developer.apple.com/documentation/realitykit/meshresource
- Apple, `MeshDescriptor`: https://developer.apple.com/documentation/realitykit/meshdescriptor

Implementation references for procedural geometry. Validate exact generation/material APIs in the actual SDK; do not assume special rendering effects are available just because a mood reference depicts them.

## S03 — Device-motion input
- Apple, Getting processed device-motion data: https://developer.apple.com/documentation/coremotion/getting-processed-device-motion-data
- Apple, `CMMotionManager`: https://developer.apple.com/documentation/coremotion/cmmotionmanager

Supports reading processed device motion. The tilt calibration, sensitivity and filtering values are game-design defaults.

## S04 — App review, digital purchases, currency and metadata
- Apple, App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/

Relevant sections include 2.1/2.3 (complete functionality and accurate metadata), 3.1.1 (in-app purchase and non-expiring purchased currency) and 5.1 (privacy). Explain unusual game behaviour to review even when it remains mysterious to players. Recheck the live requirements before submission; this pack is not legal advice or an approval guarantee.

## S05 — Purchase transaction lifecycle and durable grants
- Apple, `Transaction`: https://developer.apple.com/documentation/storekit/transaction
- Apple, `Transaction.updates`: https://developer.apple.com/documentation/storekit/transaction/updates
- Apple, Persisting a purchase: https://developer.apple.com/documentation/storekit/persisting-a-purchase

References for verified transaction handling and finishing after delivery. The app still owns its wallet/spending ledger; do not promise automatic restoration of a consumable's remaining balance.

## S06 — Local purchase testing
- Apple, Setting up StoreKit Testing in Xcode: https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode

Use local configuration and test purchase states before configuring live products.

## S07 — Tracking/data-use requirements
- Apple, User Privacy and Data Use: https://developer.apple.com/app-store/user-privacy-and-data-use/

Tracking permission is distinct from ad-provider consent. Ordinary play must not be conditional on accepting tracking.

## S08 — Optional platform achievements and leaderboards
- Apple, GameKit: https://developer.apple.com/documentation/gamekit

GameKit is an optional service integration; local records do not automatically become authenticated global rankings.

## S09 — Native audio engine
- Apple, `AVAudioEngine`: https://developer.apple.com/documentation/avfaudio/avaudioengine

Reference for the audio service. The adaptive layers and sound design are original specification choices.

## S10 — Rewarded advertisement flow
- Google, iOS rewarded ads: https://developers.google.com/admob/ios/rewarded

Reference for opt-in presentation, earned-reward callback, lifecycle handling and use of test ad units. Grant the continue from the reward callback, not merely from dismissal.

## S11 — Ad privacy gating
- Google, Set up UMP SDK for iOS: https://developers.google.com/admob/ios/privacy

Reference for consent refresh/forms, privacy options and whether ads may be requested. Actual messages and identifiers require an owner-configured account.

## S12 — Codex project instructions
- OpenAI, Custom instructions with AGENTS.md: https://developers.openai.com/codex/guides/agents-md

The official entry redirected to https://learn.chatgpt.com/docs/agent-configuration/agents-md when checked. It describes instruction-file discovery and a default aggregate project-instruction limit of 32 KiB. This pack therefore uses a short root instruction file that explicitly points to the longer specification rather than placing the entire spec inside AGENTS.md.


---

# Appendix A — deterministic seed and rule reference


These are **versioned game-design algorithms**, not claims about an Apple engine's internal physics. `tools/reference_rules.py` is an executable standard-library reference. Port it to Swift and compare against `data/conformance_vectors.json` before building game logic on top of it.

## 1. Reproducibility tiers

1. **Dream identity:** format + generator + rules + content versions + UInt64 seed.
2. **World reproducibility:** same supported identity recreates baseline chunk/encounter/style decisions.
3. **Run reproducibility:** additionally requires the same initial state and tick-indexed normalized inputs/events, including a continue. Different player actions can change arrival time, state-dependent transitions and whether a pig is collected.
4. **Visual similarity:** the same scene is recognizable at different quality settings, but pixel-identical shader output across GPUs is not promised.

Do not use nondeterministic engine physics or async completion order for authority. A seed does not make a run tamper-proof and a checksum is not a digital signature.

## 2. RNG specification

All operations are unsigned 64-bit, overflow wraps modulo 2^64. Use Swift `&+` and `&*` for intentional overflow.

**SplitMix64 next:**

```text
state = state + 0x9E3779B97F4A7C15         modulo 2^64
z = state
z = (z XOR (z >> 30)) * 0xBF58476D1CE4E5B9 modulo 2^64
z = (z XOR (z >> 27)) * 0x94D049BB133111EB modulo 2^64
return z XOR (z >> 31)
```

For an unbiased integer in `0..<upperBound`, let `threshold = (0 &- upperBound) % upperBound` using UInt64 wrapping subtraction. Draw until `value >= threshold`, then return `value % upperBound`. Reject a zero bound. Do not use floating-point rounded percentages for one-third probabilities.

Seed a domain/index stream with **FNV-1a 64** of this literal ASCII string:

```text
DR1|G{g}|R{r}|C{c}|{seed_as_16_uppercase_hex_digits}|{domain}|{index}
```

Versions/index are unpadded decimal. No spaces/newline. Domain is a stable ASCII name such as `pigPresence`, `pigClover`, `route`, `hazards`, `scenery`, `palette`, `mood`, `mirror`, `drop`, `audio`. FNV-1a uses initial 14695981039346656037; for each UTF-8/ASCII byte, XOR the byte then multiply by 1099511628211 with UInt64 wrapping. The resulting hash is the initial SplitMix64 state, before its first increment.

For slot-specific chunk work, either derive a domain that includes a documented fixed numeric sub-index via the index field, or use a stable ordered local stream. Never allocate randomness by enumerating an unordered dictionary. Adding a decorative slot must not consume another system's stream. Version changes to the domain grammar are generator changes.

Golden vector: SplitMix64 initialized with zero first returns `E220A8397B1DCDAF`. Full vectors are in the supplied JSON, including maximum-UInt64 seed encoding.

## 3. Dream ID encoding

Alphabet: `0123456789ABCDEFGHJKMNPQRSTVWXYZ`.

Encode UInt64 seed into **13** base-32 digits, most-significant digit first and zero-padded. The leading digit cannot overflow 64 bits. Prefix: `DR1-G{g}-R{r}-C{c}-{seed_digits}`. Compute standard reflected CRC-32/ISO-HDLC of its ASCII bytes: polynomial `0xEDB88320`, initial `0xFFFFFFFF`, final XOR `0xFFFFFFFF`. Keep low 20 bits, encode as four base-32 digits, append after a hyphen.

Example for seed **42**, G1/R1/C1:

```text
DR1-G1-R1-C1-000000000001A-460B
```

Normalize surrounding whitespace and lowercase. Translate O→0 and I/L→1 only in seed/checksum fields. Reject malformed prefixes, unsupported format, versions outside 1...65535, seed overflow, invalid alphabet and wrong checksum. The decoder can parse a syntactically valid future version, but the game must reject unsupported versions before starting it.

JSON stores UInt64 seeds as hex or decimal **strings**, not an assumed JavaScript-safe numeric literal. Seed sharing excludes purchases, personal profile information and arbitrary asset URLs. Every imported code is Revisit mode.

## 4. Pig decision truth table

For checkpoint `k`, independently obtain `presence = stream(pigPresence,k).below(2)` and `clover = stream(pigClover,k).below(6)`.

| Presence draw | Clover draw | Before continue | After continue |
|---|---:|---|---|
| 1 | any | No pig | No pig |
| 0 | 0 | Clover pig | Clover pig |
| 0 | 1 | Clover pig | Ordinary pig |
| 0 | 2–5 | Ordinary pig | Ordinary pig |

There are 12 equally likely draw pairs. Two are clean clover pairs, one is a continued clover pair. This yields 1/6 and 1/12 per checkpoint, while presence remains 1/2 in both cases. There is no pity mechanism.

Compute/checkpoint-commit once per ordinal. A future continue cannot remove a clover from an already telegraphed committed event. Presentation delay does not produce a second draw. Save all commitments across suspend/restore. If a run ends before an event is reached, it yields nothing.

**Nominal checkpoints:** at `k × 780` active seconds. Commit roughly six seconds before the intended presentation to reserve a readable safe runway. Times refer to active play, never device wall clock.

## 5. Probability calculations

If all `n` independent opportunities have clover probability `p`, the chance that at least three appear is:

```text
P(X >= 3) = Σ [ C(n,k) × p^k × (1-p)^(n-k) ], k=3...n
```

The expected opportunities until the third success are `3/p`. Thus clean expected nominal active time is 234 minutes; all-lowered-odds expected nominal time is 468 minutes. These condition on continued survival and successfully collecting every appearance. Ordinary players may never survive long enough, so this is not the average number of attempted runs before an ending.

| Nominal elapsed | Checkpoints | Clean probability of ≥3 | Lower odds at every checkpoint |
|---|---:|---:|---:|
| 39 min | 3 | 0.4630% | 0.0579% |
| 52 min | 4 | 1.6204% | 0.2170% |
| 65 min | 5 | 3.5494% | 0.5088% |
| 78 min | 6 | 6.2286% | 0.9545% |
| 104 min | 8 | 13.4847% | 2.3540% |
| 130 min | 10 | 22.4773% | 4.4484% |
| 180 min | 13 | 37.1923% | 8.8011% |
| 234 min | 18 | 59.7346% | 18.5366% |

When a continue occurs later, use a small dynamic program for mixed probabilities: keep probabilities of 0, 1, 2 and at least 3 clovers. For each actual checkpoint policy `p_i`, move each state into fail/success next states, with the >=3 state absorbing. No approximation is necessary. Existing clovers are not erased by a continue.

## 6. Fixed-step and saved state

One `step()` = one 1/60-second tick. Fixed ticks alone do not guarantee determinism: unordered iteration, engine contacts, non-versioned data and async tasks must also be controlled. Record normalized input at tick boundaries. Motion samples are normalized at the adapter; the core never reads the sensor or wall clock.

Store route progress as Double and local render transforms near the origin. Quantize values where needed for stable golden manifests. Keep collision tolerances conservative; reproducible numerical results do not prove a course is human-readable. A scene snapshot contains logic/state and deterministic descriptions, not cached RealityKit render objects.

## 7. Idempotent money and rewards

Use stable transaction/event IDs, not a new UUID on each callback:

- Store purchase grant: `purchase:<store_transaction_id>`.
- One-time bonus: `bonus:first_dream`.
- Earned settlement: `run:<run_uuid>:settlement:<revision>` with atomic highest-settled-total update.
- Cosmetic acquisition: one `cosmetic_id` ownership row plus its debit in one transaction.
- Achievement: one `achievement_id` unlock plus its cosmetic grant in one transaction.
- Continue entitlement: one unique provider reward event bound to one run UUID, with separate earned/consumed states.

No purchase earns a clover or modifies the random stream. No repeated ad callback grants a second continue. A debug event can show the same visual sequence but permanently excludes the run from real rewards.

For spending, use earned/bonus lots first, then purchased lots, oldest-first within each source. Record the lot allocations in debit details. The simple local refund policy reverses only the remaining amount in the identified purchased lot and marks the revocation applied; no earned funds or prestige unlocks are confiscated. This policy is intentionally not a server-backed antifraud system.
