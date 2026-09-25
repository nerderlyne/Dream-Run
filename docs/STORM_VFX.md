# Stitched thunderhead

The lightning encounter uses `Dream Again/Resources/Weather/storm-stitched.png`, an original 1536 × 1024 transparent cutout. Layered lavender, dusty rose and pearl-cyan folds with warm-gold seams replace the rejected charcoal storm photograph. It is a representation of the existing cloud family, not an additional world-asset family.

`StormVFX` loads the image once, then shares its texture with each encounter. The transparent card is camera-facing and scaled to 8.4 × 5.6 world units above the strike point. The card gently breathes and rolls while local rain, dim ground fissures, charge arcs, a brief bolt and a point-light flash communicate the fixed lightning target. The thunder sound, strike timing, damage and dodge contract are unchanged. The scene's daylight/fill recover after the encounter.

Lightning hazards use live model instances rather than cached empty prototypes so a cloud placed before the asynchronous texture load still receives the image when loading completes. The focused simulator test covers that path, the bolt light and lighting recovery.

Preview after installing a Debug simulator build:

```sh
python3 tools/capture_storm.py <booted-simulator-id>
```

The script captures far approach, 22-meter warning, five-meter close and strike views in `evidence/storm-rework-*.png`. The gallery's `obstacle-lightning*.png` views now show this design. Visual captures were reviewed on the iPhone 16 Pro Max simulator; no physical-device test or sustained thermal measurement was performed.
