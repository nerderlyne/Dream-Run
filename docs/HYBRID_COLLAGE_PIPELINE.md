# Current collage pipeline

There is one visual pipeline and one runtime catalog: `DreamCollageKit.swift`.
55 shipping images provide 46 transparent objects and nine atmosphere-only backdrops.
The six new backdrops depict space, underwater light, aurora, desert mirage, lavender mist
and opal dawn. The supplied mood references are never production resources.

`HybridDreamLayers` retains 20 world-space object cards and two camera-relative sky cards.
Perspective and parallax follow the real runner camera. Texture loading is asynchronous,
sequential and cached. Cards share a back-to-front sort group with a deferred depth pass;
transparent regions cannot cut rectangular holes in other layers. Cards cast no shadows.
Ordinary replacements fade at staggered distance cells; sky dissolves last 24 active seconds,
accelerated to 1.8 seconds for mirror/drop transitions. Density strips, reaches void and
rebuilds without ending a three-hour run. Gameplay geometry remains separate and readable.

The old sky dome, procedural decorative horizon, cloud impostor renderer and presentation
version switches have been removed. The only environment resource supplies neutral lighting;
it is not a visible solid-color background. There is no alternate old-art path.

The track uses saturated lacquer materials with checkerboard as the dominant pattern,
plus occasional stripes and solids. Track palette changes use a bounded four-material
update budget and staggered transitions. Hazards retain their semantic colors.

The straw doll uses one articulated reed/twine rig. Hats, waist ribbons, apron, lace and short
straw skirt are overlays; switching looks does not rebuild the body. The unused USDZ fallback
and generic mannequin construction are removed. All 42 procedural world families remain.

Prompts and generation master paths are in `art-review/kit-generation.json`. Runtime metadata
lives only in Swift. Abandoned full-scene experiments and old review outputs were deleted.
Use `tools/capture_design.py` after installing a DEBUG simulator build for current screenshots.


## Animated pilot

`DreamPilotKit` adds 20 original built-in-imagegen cutouts at a maximum 512 × 512 pixels.
Prompts and original source paths are recorded in `COLLAGE_PILOT.json`; shipping PNGs are in
`Dream Again/Resources/DreamCollage`. `evidence/pilot-alpha.jsonl` records real clear pixels,
alpha bounds and untouched image-edge margins. Source masters remain outside the app bundle.

Five `DreamVignette` compositions use four separate cards each: whale/cottage, jellyfish garden,
upside-down procession, floating bedroom and midnight kitchen. One occurrence of each is scheduled
in every shuffled five-cell cycle; each cell is 640 metres. Cultural apparitions only appear in
midnight kitchen, never in the general scenery deck. Their frequency is one cell per 3,200 metres.
The ordinary scenery slots visit each eligible ingredient before repeating a deck. Slot zero
now reserves the single semantic scale-event budget described below.

The four composition cards join the existing 16 cards and two sky cards: 22 pooled entities total.
Transforms are sampled from active seconds with bounded drift, bob, rotation and jellyfish breathing.
They freeze with the run and are disabled by Reduced Motion or low-power presentation. No GIF
decoder, new runtime meshes, file decoding per frame or background collisions are introduced.
Cards retain world-space anchors through origin rebasing. Scene opacity follows the existing
maximalist/moderate/sparse/void cycle and Lucky Dream stripping.

Family #05 is now sea creatures; ordinary curved stairs are #04 variants. Family #23 is cultural
apparitions; mountains/cliffs are #22 rock variants. The registry and pig #42 remain intact.

## Relative scale hierarchy

`DreamScaleComposition` owns the scene-wide scale budget. Each 768 m scene has a seeded
60% chance of no anomaly, 15% miniature, 19% oversized, 5% monumental and 1% absurd.
An event selects horse, moon, chair, house, tree, window or arch as its semantic subject;
only slot zero can become monumental or absurd. This is visual RNG, independent of gameplay luck.
Twelve supporting slots are tiny, six are ordinary, and at most one is modestly oversized.
For monumental/absurd events that extra oversized support is also ordinary. Vignettes obey
these same roles, so their four ingredients no longer all appear at landmark scale.

Sizes account for asset aspect ratio and depth, with ordinary angular diameters of 0.022/0.05
for tiny/ordinary and 0.085 for modest oversized support. Monumental/absurd subjects start at
0.32/0.55; miniature subjects at 0.008. These are longest-side/depth ratios, not metre sizes
or probabilities. Motion amplitude scales down with object size. Fixed world-space geometry
retains parallax; a smooth approach fade prevents ordinary props becoming accidental giants.

Existing cards retain their assigned roles until their normal staggered replacement. There is
no simultaneous whole-scene resizing, and the single event slot fades before its next event.
Density/void evolution and full-frame sky plates remain independent of object size.
DEBUG Lab offers all five scale cases. Launch with `--art-review --design-review --scale-event 0`
(0–4); normal play clears the override. Capture using `tools/capture_scale.py DEVICE_ID`.

## Vertical composition and partial landmarks

Seven supporting slots per 19-slot context group are placed below route level, at distinct
negative elevations and lateral offsets. They remain background-only world-space cards; track
geometry occludes them. This supplies scenery beneath the player, not only across the skyline.
Large scale events also choose whole, beneath, crown-from-below or roots-overhead framing.
The latter two deliberately extend the object beyond the image rather than fitting every landmark
inside it. With tree subjects, one exposes the crown while the trunk/roots continue beneath the
frame, and the other exposes hanging roots while upper branches continue beyond the top edge.
The same placement vocabulary applies to houses, arches and other selected semantic subjects.

DEBUG Lab offers all four framing cases using an absurd-scale subject. Launch with
`--art-review --design-review --scale-event 4 --scale-framing 2` (framing 0–3).
These overrides change composition only and remain reward-isolated.

## Independent atmospheric collage

`DreamAtmosphere` adds three dedicated compositional slots outside the 20 semantic slots.
They reuse existing registered architecture/window, tree/botanical/organic and fog/fabric/cloud
images. They are not extra world families or new texture resources. The pool is now 25 cards:
20 semantic, 3 atmospheric and 2 sky plates, sharing geometry and preloaded image textures.

The atmospheric longest-side/depth ratios are 0.62–1.14, with base opacity 0.20–0.27 and further
attenuation where they cover the projected route. These forms intentionally span/crop beyond
large areas of the frame, blend into the sky and overlap semantic scenery at distinct world-space
depths. They bypass semantic approach-size limits and never select horses, moons, chairs, pigs
or rabbits as atmospheric subjects. The rare scale-event selection is unchanged.

Density weights introduce one layer at low density, two above 0.32, and three above 0.65,
with gradual opacity ramps. Void/white-ending states remove them; Low Power keeps only one.
Independent 1280/1024/768 m lifetimes and 96 m entrance/exit fades stagger replacement.
They use active-time drift and retained world anchors; no whole-scene rebuild or new image decode
occurs during updates. Opaque track/player/hazard geometry remains in front of the imagery.
The broad route-overlap attenuation is conservative; it is not a per-pixel corridor mask.

Current simulator comparison: `evidence/atmosphere-gallery.html`.
Capture using `python3 tools/capture_atmosphere.py DEVICE_ID` after installing the DEBUG build.
