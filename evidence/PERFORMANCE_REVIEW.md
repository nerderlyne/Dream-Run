# Renderer hitch investigation — September 14, 2026

A native XCTest runs 120 sequential renderer updates in the seeded cloud scene with the dress character. This measures CPU time inside `DreamRenderer.render`, not GPU frame presentation or real-time simulation throughput. Builds use Debug on the iPhone 16 Pro Max / iOS 26.5 Simulator. Timing varies with host load; this is diagnostic evidence, not a device performance certification.

| CPU update | Before | First optimized run |
|---|---:|---:|
| Median | 1.797 ms | 0.399 ms |
| 95th percentile | 107.572 ms | 5.837 ms |
| Maximum | 167.758 ms | 38.858 ms |

Logs: `perf-before.log`, `perf-after.log`. The latter contains one failed assertion in the new reuse test: it originally selected the partially visible leading distant-route segment, which legitimately changes as the near stream advances. The corrected test selects a complete retained segment. Final regression results are in `perf-final-tests.log`.

Changes:
- Do not reassign the skybox, environment lighting resource and sky material on unchanged frames. Explicitly invalidate the binding after preview or scene transitions.
- Atmospheric shading updates at most four models per frame. Cache local mesh centres, preserve correct world-space distance after rebasing, skip negligible changes, and prune departed-model metadata.
- Rebase existing near track, props, pickups and distant route sections by translation at 192 m boundaries instead of regenerating all their meshes. New partial distant sections are still built against the current origin. Horizon composition keeps its existing section changes.
- Compare equipped values directly; a hat change retains the character body and restores/hides hair appropriately.

The run-speed rules and fixed-step clock are unchanged. The existing clock bounds catch-up work after long frame stalls, which can make overloaded rendering feel like slower running. This patch reduces rendering work rather than advancing gameplay through stalls. No change to seeds, pig odds, rewards, input, the 42-family registry, or the requested scene density.

Final native rerun: **10 tests, 0 failures, 17.418 s**. CPU median **0.183 ms**, p95 **3.409 ms**, maximum **20.463 ms**. Release simulator build, 51 specification checks and release preflight pass. Existing deterministic package tests were not repeated because core code/data did not change.
Final offline start/play/pause/wardrobe UI check: **1 test, 0 failures, 35.747 s**. Combined simulator test command: **TEST SUCCEEDED**.
