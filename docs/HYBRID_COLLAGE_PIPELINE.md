# Current collage pipeline

There is one visual pipeline and one runtime catalog: `DreamCollageKit.swift`.
35 shipping images provide 26 transparent objects and nine atmosphere-only backdrops.
The six new backdrops depict space, underwater light, aurora, desert mirage, lavender mist
and opal dawn. The supplied mood references are never production resources.

`HybridDreamLayers` retains 16 world-space object cards and two camera-relative sky cards.
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
