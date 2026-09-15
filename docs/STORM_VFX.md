# Threatening storm effect

The lightning encounter uses `Dream Again/Resources/Weather/storm-threat.png`, generated with the built-in image generation tool. Original 1536 × 1024 PNG alpha is retained (519,176 pixels have alpha below 10); the runtime card preserves its 3:2 aspect ratio. This is a camera-facing photographic VFX layer, not volumetric cloud simulation. It is a representation of the existing cloud family, not an extra registered world family.

The image is preloaded once per renderer and shared. Local animated rain, six low-opacity shade bands, approach-driven daylight/fill attenuation, and a strike light provide environmental effects. Thin dim fissures replace the bright ground ring while preserving the warning footprint. No hazard timing, damage or thunder changes.

Final generation prompt:

> Create a production game VFX sprite: one hyper-realistic menacing supercell thunderstorm cloud, seen from ground level looking slightly upward, huge low hanging turbulent shelf cloud with charcoal black underside, slate grey anvil, complex photographic billowing vapor detail and wispy ragged edges. Isolated on actual transparent background with clean natural alpha falloff, NO scenery, no ground, no rectangle, no sky background, no text, no stylized toy spheres. Wide roughly 3:2 silhouette fully contained with small transparent margins, darker central underside, subtle cold silver rim light, faint pale internal electrical glow but NO protruding lightning bolt (game draws bolt separately). Extremely threatening approaching-death atmosphere, convincing volumetric storm photography, dark but visible vapor detail. Deliver a transparent PNG asset suitable for layering over bright or dark game backgrounds.

Reproduce the simulator views using `python3 tools/capture_storm.py <booted-simulator-id>` after installing a Debug build. Capture mode cannot earn rewards. Physical-device performance and subjective threat/readability still need device playtesting.
