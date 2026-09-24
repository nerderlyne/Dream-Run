# Performance measurements and regression workflow

## September 20, 2026 results

Two completed, normal-speed, two-minute runs were recorded on the owner's iPhone 17e,
iOS 26.4.2, with Xcode 26.6 (17F113). The owner authorized these recordings and then
ended phone testing. Further verification in this pass uses source review and the simulator.

Both recordings used seed 42, automated oracle inputs, the actual simulation and renderer,
60 Hz requested presentation, and an isolated nonrewarding profile. The builds used
`Debug`, `SWIFT_OPTIMIZATION_LEVEL=-O`, and `SWIFT_COMPILATION_MODE=wholemodule`.
Commerce observation was disabled for the profiling session. The run retained ordinary
hazards and exercised the real checkpoint writer without production rewards.

| Display-link callback metric | Baseline | Audio changes |
|---|---:|---:|
| Duration | 120.009 s | 120.001 s |
| p95 interval | 36.294 ms | 16.852 ms |
| p99 interval | 52.061 ms | 21.251 ms |
| Worst interval | 163.634 ms | 82.224 ms |
| Intervals over 50 ms | 192 | 2 |
| Intervals over 100 ms | 6 | 0 |
| Median audio-update CPU time | 1.866 ms | 0.049 ms |
| Worst audio-update CPU time | 150.659 ms | 16.573 ms |

**This is not a controlled graphics benchmark or measured GPU FPS.** Thermal state was
`fair` throughout the baseline and `serious` throughout the comparison. The existing
thermal fallback therefore reduced decorative rendering during the comparison. These
short recordings support the audio diagnosis and show fewer callback stalls, but do not
prove the whole difference comes from audio or establish long-run thermal stability.
The first audio engine start moved out of active gameplay into preparation intentionally.

Source recordings: `evidence/performance-baseline.json`, `performance-audio.json`.
Summaries, including the frames preceding the worst callback gaps:
`evidence/performance-baseline-summary.json`, `performance-audio-summary.json`.
No samples overflowed either recording buffer. There were still two gaps over 50 ms after
the audio change; the largest remaining CPU spikes were in rendering at chunk boundaries.

Instruments CLI attempts did not produce a usable CPU/GPU trace: attachment by executable
name and PID failed, and launch-based recording stalled before a second run began. That
recorder was stopped. No GPU timeline, resident-memory measurement, or physical tilt
measurement is claimed. A duplicate retrieval of the original report was discarded.

## Implemented changes

- Prepare the audio engine before the active clock starts, including resume/continue.
  Reuse effect players with interrupting buffer scheduling; avoid repeatedly stopping
  silent players and querying the headphone route when theta is disabled. Replace motif
  buffers without stopping/restarting the player.
- Prebuild shared procedural material maps and expensive fixed-color gameplay assets
  while preparing a run. Fixed-color semantic prefabs reuse geometry across palettes.
- Reuse hay-ball and authored obstacle prototypes, with separate cloned entity state.
  Lightning prototypes distinguish lateral footprint geometry. Cache limits remain finite.
- Replace whole-cache purges with least-recently-used, single-entry eviction. Retire
  matching triangle-count metadata. Count scene entities only once per second in Debug.
- Encode/write gameplay checkpoints on one serial background writer. Readers see the last
  durable profile without waiting for disk I/O. Synchronous lifecycle/commerce writes drain
  earlier queued writes, preserving ordering and idempotence. At most eight asynchronous
  writes may be pending; overload/failure pauses play rather than retaining unlimited
  snapshots. State is published only after the atomic save succeeds.
- Add opt-in signposts and a bounded frame recorder. Simulation, rendering, audio,
  resource misses and checkpoint enqueue are measured separately. Report encoding and
  file writing occur after capture on a utility task.

**Only the initial audio changes were measured on the iPhone.** Later audio refinement,
resource caching/preparation, and asynchronous persistence were implemented after phone
testing ended. Their device speedup and memory cost remain unmeasured. Preparation shifts
some work into startup/retry; cold-start latency needs measurement. No gameplay rules,
hazard sizes, art geometry, pig probabilities, or reward eligibility were changed.

## Repeatable local workflow

1. Run `python3 tools/validate_spec.py` and `swift test -c release`.
2. Build the app with the shared `Dream Again` scheme. For CPU timing, use an optimized
   development build (`-O`, whole-module optimization), not ordinary unoptimized Debug.
3. Launch the development app with:

   ```text
   --performance-run --performance-seconds 120 --performance-seed 42
   ```

   The harness creates an isolated temporary profile, disables commerce, uses Debug mode
   throughout, and drives normal inputs with `EncounterOracle`. If the runner wakes, it
   restarts with the next seed. It does not remove hazards or accelerate the clock. Capture
   length is clamped to 15–600 seconds; at most 36,100 frame samples are retained, and any
   overflow is counted explicitly. The app pauses automatically when capture completes.
   The launch hook is compiled out of Release. It is not a player setting or a live reward mode.

4. Retrieve `Documents/performance-last.json` from that simulator's app container. Verify
   the capture ID/date before comparison; an old file remains until a new capture completes.
   A console `PERFORMANCE_REPORT_READY` message confirms the write completed. The format
   includes thermal state, seed, tick, distance, phase, CPU stage times and sampled entity
   count. The two original device reports predate capture ID/date fields.
5. Summarize it:

   ```sh
   python3 tools/summarize_performance.py path/to/performance-last.json --output evidence/run-summary.json
   ```

6. Compare matching seeds, run durations, optimization flags, visual quality, power mode
   and thermal state. Keep cold frames, warm frames, and restart/ending frames distinguishable.
   Callback timing excludes neither OS scheduling delays nor work elsewhere on the main
   thread; the stage timers cover only their named CPU scopes. `CheckpointEnqueue` measures
   scheduling cost, not asynchronous encoding/disk latency. Entity count is diagnostic sampling.
7. When separately authorized again, use real hardware and an Instruments Game Performance
   trace for GPU presentation, CPU scheduling, allocation and memory analysis. Simulator
   timing cannot certify an iPhone. Current authorization is simulator-only.

## Regression criteria and remaining coverage

Target 16.7 ms presentation intervals at 60 Hz. Investigate every unexplained active-play
gap over 50 ms; reject any unexplained gap over 100 ms in a measured scenario. A passing
short run is not evidence of a zero-stall game. Keep p95/p99/p99.9, worst interval, counts
over thresholds, and memory/thermal trends instead of relying on average FPS.

Expand rendered coverage across cold launch, different seeds, retries, maximum speed,
pig commitments, palette/mirror/drop changes, suspend/resume and endings. Multi-hour
rendered soak, controlled device retesting of the final changes, GPU frame presentation,
and resident/GPU memory remain unverified. The existing 20-seed six-hour **core** soak
validates bounded simulation behavior, not graphics or audio performance.

Test outputs and final pass/fail counts are recorded in `IMPLEMENTATION_STATUS.md`.
The final fresh-process simulator smoke test passed and exported an inspected paused-scene
screenshot at `evidence/performance-smoke-attachments/859A7C63-78BD-491E-BBBB-BC47804E1F69.png`.
Unlike the multi-instance native suite, its log contained no drawable-allocation failures.
This smoke run used unoptimized Debug and is not a timing benchmark.
