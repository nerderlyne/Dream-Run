# Wardrobe revision

Actual iPhone 16 Pro Max / iOS 26.5 Simulator captures; original procedural meshes, no mockups.

- [Girl/dress selection and final wardrobe framing](wardrobe-ui-final/F667041C-C282-4FA3-9F8C-E23011BAEA63.png)
- [Fitted bucket hat and dress](wardrobe-bucket.png)
- [Beret and separate top/trousers](wardrobe-beret.png)
- [Dress running without a hat](wardrobe-dress-run.png)
- [Dress and ribbon in a feet-first back slide](wardrobe-dress-slide.png)

The first UI capture under `wardrobe-ui/` exposed dim lighting and title overlap; `wardrobe-ui-final/` supersedes it. Review also caught the trouser waist's old pointed hem and an excessive heel lift through the dress: the trouser waist was rebuilt, and the dress uses a lower heel recovery with the same cadence and a fuller skirt volume around the moving thighs. Portrait/UI/slide captures precede that last skirt-volume refinement; the running capture shows it.

Native renderer suite: 8 tests, 0 failures (10.987 s). Final UI flow: 1 test, 0 failures (35.381 s). Debug/Release simulator builds and 51 specification checks pass. See the corresponding `wardrobe-*.log` files. Last numeric geometry/stride refinements received build and screenshot verification, not another full test run.

This remains procedural character art, with no simulated cloth or authored rig. Screenshots cover representative fits and poses, not every hat in every animation or physical-device performance.
