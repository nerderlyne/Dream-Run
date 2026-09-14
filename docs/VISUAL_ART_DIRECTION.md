# Dream Again visual direction

The current implementation is described in [HYBRID_COLLAGE_PIPELINE.md](HYBRID_COLLAGE_PIPELINE.md).
Use the six supplied references for material, atmosphere, impossible scale and collage contrast.
They are not shipping images. Compose foreground, midground and distant transparent ingredients
against a full-frame atmosphere plate while protecting the route corridor.

The protagonist is a slim, faceless straw doll made of reed bundles and twine bindings.
One rig supports every look. Ribbon, short straw skirt, apron, lace and fitted hats are modular
cosmetics. Run uses strong opposing limbs; jump tucks the knees; slide lies on the back.

The floor is a simple, saturated lacquer surface. Checkerboard dominates; long sections may
use stripes or solids. Twelve palette pairs include pale/gold Lucky Dream and deep mutations.
Mirror portals use a rectangular black interior fitted inside gold rails and fine trim.

## DEBUG review

After installing a Debug simulator build:

```sh
python3 tools/capture_design.py SIMULATOR_ID
```

This captures actual runtime views for six new skies, five looks, four poses, mirror, track
patterns and twelve hazard-contrast palettes. It waits for all textures before capture.
Review runs have isolated temporary saves and cannot earn production rewards.

Individual launch example:

```sh
xcrun simctl launch --terminate-running-process booted nani.Dream-Again --art-review --design-review --art-theme 2 --art-pose jump --variant 2 --sky sky_aurora
```

Simulator views do not establish physical-device frame pacing, GPU budgets or thermal safety.
