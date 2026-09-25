# Owner DreamObjects intake

Keep untouched source downloads in the workspace root `DreamObjects/` folder. They are local originals, excluded from Git and the app bundle. The case-by-case curation and source records live in `data/dream_objects_intake.json`; every entry has a source URL, license URL, content tags, decision, and original SHA-256 hash.

The first 59-photo batch was sorted into 20 complete-scene plates, 22 transparent object cutouts, 13 source-only reserves and four held images. Plates are imported by `tools/import_dream_plates.swift` from copies in root `DreamPlates/`. Optimized game cutouts are in `Dream Again/Resources/DreamCollage/` with `owner_` names; the runtime catalog is `DreamOwnerObjectKit.swift`.

For the next batch, keep the original Unsplash filename if possible. The photo ID in that filename lets us record a link back to the photographer's page. For a different source, include the source page and license in a same-named text file or in your message.
