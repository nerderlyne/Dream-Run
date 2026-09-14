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
The general 16-card pool visits each eligible ingredient before repeating it in a slot.

The four composition cards join the existing 16 cards and two sky cards: 22 pooled entities total.
Transforms are sampled from active seconds with bounded drift, bob, rotation and jellyfish breathing.
They freeze with the run and are disabled by Reduced Motion or low-power presentation. No GIF
decoder, new runtime meshes, file decoding per frame or background collisions are introduced.
Cards retain world-space anchors through origin rebasing. Scene opacity follows the existing
maximalist/moderate/sparse/void cycle and Lucky Dream stripping.

Family #05 is now sea creatures; ordinary curved stairs are #04 variants. Family #23 is cultural
apparitions; mountains/cliffs are #22 rock variants. The registry and pig #42 remain intact.
