# Owner-photo background curation

The September 26 batch contained 59 Unsplash downloads in workspace-root `DreamObjects/`. We reviewed each image as a full scene, isolated object or held source. The decisions, tags, source URLs, license links and SHA-256 hashes are in `data/dream_objects_intake.json`.

- 20 complete scenes became optimized DreamPlates, raising that library to 122 backgrounds.
- 22 distinct subjects became transparent photo cutouts in `Dream Again/Resources/DreamCollage/`. The game now uses only these owner-photo cutouts for background objects and all five vignettes.
- 13 photos remain source-only reserves, mainly alternate orchids, jellyfish, planets and props or cutouts with clipped source edges.
- Four photos were held: two recognizable public figures, one prominent brand and one chalk rainbow that depends on its pavement.

The untouched originals are ignored by Git and stay available for another pass. New full-frame plate selection can be rerun with `swift tools/import_dream_plates.swift`; that importer reads the copied plate originals in root `DreamPlates/`. New cutouts need individual edge review and a catalog entry in `DreamOwnerObjectKit.swift`.

The resulting photos are distinct, but perspective inside each photograph remains fixed. Simulator scene review should determine which backgrounds and foreground pairings still feel too busy, especially when the path crosses a strong photographic vanishing point.
