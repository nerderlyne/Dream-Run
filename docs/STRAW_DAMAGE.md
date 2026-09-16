# Straw damage and rebuilding

A sports ball removes one currently attached limb after contact immunity: the two arms first, then the legs. Impact side selects the first available limb in that tier. The first three hits retain the existing stumble, one-second slowdown and lateral knockback. The fourth unrepaired hit wakes the runner with a 2.4-second rising burst of reeds. Other hazards and edge falls remain lethal; limbs are cosmetic damage indicators and never shrink the collision capsule or change jump/slide input.

A tied cube of reclaimed avatar straw restores the last missing limb. Each bale is consumed once, only while damaged. It is not currency, cannot be purchased, and does not increment the balloon counter. Generation uses a dedicated seeded stream, a one-in-five chance per eligible chunk after 120 metres, and only hazard-free chunks without gaps, steps or drops. Bales are humanoid repair fragments, outside the registered 42 world-scenery families.

Missing limbs and consumed pickup IDs serialize with the live run. Pausing does not heal. Continue restores the full avatar and preserves the existing one-continue/pig rules. There is no migration for older unreleased snapshots.

Rendering hides the affected articulated limb, sends bounded shared-mesh reeds outward, and draws reeds inward on repair. Fourth-hit presentation fades the remaining body while the reeds rise. At most five bursts (48 reeds for a full burst, 20 otherwise) coexist. Original mono PCM effects are generated reproducibly by `tools/generate_straw_audio.py`; Effects volume/mute applies.

DEBUG Lab has Straw damage and Straw burst actions; `--art-review --design-review --straw-limbs 3` previews the injured avatar and bale, and `4` previews the burst. Use `tools/capture_straw.py <simulator-id>` to capture both. All such runs remain reward-disabled.
