# Curated DreamPlates backgrounds

The owner's photos replace the generated sky plates. Existing transparent scenery and atmospheric collage layers remain above the photographs; black void and white ending behavior remain separate. These environmental base images do not add registered gameplay/scenery families.

Current imported batch: **102 unique backgrounds from 103 source files** (one exact duplicate), approximately **97 MiB** of optimized JPEG resources. The source folder was still being populated during this pass; run the importer again after later arrivals.

## Import

Place complete source images in the workspace's `DreamPlates/` directory, then run from the project root:

```sh
swift tools/import_dream_plates.swift
```

The importer reads JPEG, PNG and HEIC, applies image orientation, exports JPEG at a maximum 2048-pixel longest side and 0.84 quality, and deduplicates exact source-file duplicates by SHA-256. It generates `Dream Again/Core/DreamPlateLibrary.swift`, `data/dream_plates.json`, optimized images under `Dream Again/Resources/DreamPlates/`, and numbered contact sheets under `evidence/`.

Original files are kept untouched outside the app bundle. Only optimized images are required to build/run the project. The manifest records original filenames and full source hashes. Per-photo Unsplash URLs and photographer names were not supplied; attribution is not invented. Preserve any separately available source/credit records with the collection.

## Runtime

A seeded shuffled sequence visits every photograph before repeating one, avoids repetition across deck boundaries, and advances when crossing a mirror or taking a safe drop. Ordinary changes retain the existing 24-second crossfade; mirror/drop changes use the existing shorter transition.

The renderer preloads the 46 transparent cutouts, requests photos asynchronously, and retains at most three photo textures in its cache. Texture decoding is not performed synchronously in the frame update. Selection is cached between sections. Large libraries therefore do not cause every photo to be decoded at launch.

Both sky cards use the actual image aspect ratio and aspect-fill the camera view. Wide photos are cropped to fill portrait screens, not stretched. Portrait photos similarly cover iPad layouts. The loaded current background remains displayed while the next photo loads.

The 25-card renderer pool is unchanged. Photos remain full-color source imagery; they are not recolored, composited into new AI images, or distorted to mimic cutout props. GPU/thermal performance still requires device testing.
