#!/usr/bin/env python3
"""Summarize a bounded device frame recording; never equate callback timing with GPU FPS."""
import argparse
import json
import math
from collections import Counter
from pathlib import Path


def distribution(values):
    values = sorted(values)
    if not values:
        return {}
    def percentile(p):
        return round(values[max(0, math.ceil(len(values) * p) - 1)], 3)
    return {"count": len(values), "p50_ms": percentile(.5), "p95_ms": percentile(.95),
            "p99_ms": percentile(.99), "p999_ms": percentile(.999),
            "max_ms": round(values[-1], 3),
            "over_33_34ms": sum(v > 33.34 for v in values),
            "over_50ms": sum(v > 50 for v in values),
            "over_100ms": sum(v > 100 for v in values)}


def summarize(report):
    samples = report["samples"]
    active = [s for s in samples if s["phase"] in ("running", "safeDrop", "mirrorCrossing")]
    warm = [s for s in active if s["elapsed"] >= 10]
    stages = sorted({key for s in samples for key in s["stages"]})
    worst = sorted(enumerate(samples), key=lambda pair: pair[1]["intervalMS"], reverse=True)[:12]
    return {
        "note": report["note"], "duration_seconds": report["duration"],
        "recording_overflow": report["framesDroppedFromRecording"],
        "seeds": sorted({s["seed"] for s in samples}),
        "phases": dict(Counter(s["phase"] for s in samples)),
        "thermal_states": dict(Counter(s["thermal"] for s in samples)),
        "max_entities": max((s["entities"] for s in samples), default=0),
        "active_intervals": distribution([s["intervalMS"] for s in active if s["intervalMS"] > 0]),
        "warm_active_intervals": distribution([s["intervalMS"] for s in warm]),
        "active_cpu_work": distribution([s["workMS"] for s in active]),
        "stages_when_executed": {k: distribution([s["stages"][k] for s in samples if k in s["stages"]]) for k in stages},
        "worst_intervals": [{"frame": s, "preceding_frame": samples[i-1] if i else None} for i, s in worst],
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("recording", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = summarize(json.loads(args.recording.read_text()))
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    compact = {k: v for k, v in result.items() if k != "worst_intervals"}
    print(json.dumps(compact, indent=2))
