# Determinism, probability and accounting reference

These are **versioned game-design algorithms**, not claims about an Apple engine's internal physics. `tools/reference_rules.py` is an executable standard-library reference. Port it to Swift and compare against `data/conformance_vectors.json` before building game logic on top of it.

## 1. Reproducibility tiers

1. **Dream identity:** format + generator + rules + content versions + UInt64 seed.
2. **World reproducibility:** same supported identity recreates baseline chunk/encounter/style decisions.
3. **Run reproducibility:** additionally requires the same initial state and tick-indexed normalized inputs/events, including a continue. Different player actions can change arrival time, state-dependent transitions and whether a pig is collected.
4. **Visual similarity:** the same scene is recognizable at different quality settings, but pixel-identical shader output across GPUs is not promised.

Do not use nondeterministic engine physics or async completion order for authority. A seed does not make a run tamper-proof and a checksum is not a digital signature.

## 2. RNG specification

All operations are unsigned 64-bit, overflow wraps modulo 2^64. Use Swift `&+` and `&*` for intentional overflow.

**SplitMix64 next:**

```text
state = state + 0x9E3779B97F4A7C15         modulo 2^64
z = state
z = (z XOR (z >> 30)) * 0xBF58476D1CE4E5B9 modulo 2^64
z = (z XOR (z >> 27)) * 0x94D049BB133111EB modulo 2^64
return z XOR (z >> 31)
```

For an unbiased integer in `0..<upperBound`, let `threshold = (0 &- upperBound) % upperBound` using UInt64 wrapping subtraction. Draw until `value >= threshold`, then return `value % upperBound`. Reject a zero bound. Do not use floating-point rounded percentages for one-third probabilities.

Seed a domain/index stream with **FNV-1a 64** of this literal ASCII string:

```text
DR1|G{g}|R{r}|C{c}|{seed_as_16_uppercase_hex_digits}|{domain}|{index}
```

Versions/index are unpadded decimal. No spaces/newline. Domain is a stable ASCII name such as `pigPresence`, `pigClover`, `route`, `hazards`, `scenery`, `palette`, `mood`, `mirror`, `drop`, `audio`. FNV-1a uses initial 14695981039346656037; for each UTF-8/ASCII byte, XOR the byte then multiply by 1099511628211 with UInt64 wrapping. The resulting hash is the initial SplitMix64 state, before its first increment.

For slot-specific chunk work, either derive a domain that includes a documented fixed numeric sub-index via the index field, or use a stable ordered local stream. Never allocate randomness by enumerating an unordered dictionary. Adding a decorative slot must not consume another system's stream. Version changes to the domain grammar are generator changes.

Golden vector: SplitMix64 initialized with zero first returns `E220A8397B1DCDAF`. Full vectors are in the supplied JSON, including maximum-UInt64 seed encoding.

## 3. Dream ID encoding

Alphabet: `0123456789ABCDEFGHJKMNPQRSTVWXYZ`.

Encode UInt64 seed into **13** base-32 digits, most-significant digit first and zero-padded. The leading digit cannot overflow 64 bits. Prefix: `DR1-G{g}-R{r}-C{c}-{seed_digits}`. Compute standard reflected CRC-32/ISO-HDLC of its ASCII bytes: polynomial `0xEDB88320`, initial `0xFFFFFFFF`, final XOR `0xFFFFFFFF`. Keep low 20 bits, encode as four base-32 digits, append after a hyphen.

Example for seed **42**, G1/R1/C1:

```text
DR1-G1-R1-C1-000000000001A-460B
```

Normalize surrounding whitespace and lowercase. Translate O→0 and I/L→1 only in seed/checksum fields. Reject malformed prefixes, unsupported format, versions outside 1...65535, seed overflow, invalid alphabet and wrong checksum. The decoder can parse a syntactically valid future version, but the game must reject unsupported versions before starting it.

JSON stores UInt64 seeds as hex or decimal **strings**, not an assumed JavaScript-safe numeric literal. Seed sharing excludes purchases, personal profile information and arbitrary asset URLs. Every imported code is Revisit mode.

## 4. Pig decision truth table

For checkpoint `k`, independently obtain `presence = stream(pigPresence,k).below(2)` and `clover = stream(pigClover,k).below(6)`.

| Presence draw | Clover draw | Before continue | After continue |
|---|---:|---|---|
| 1 | any | No pig | No pig |
| 0 | 0 | Clover pig | Clover pig |
| 0 | 1 | Clover pig | Ordinary pig |
| 0 | 2–5 | Ordinary pig | Ordinary pig |

There are 12 equally likely draw pairs. Two are clean clover pairs, one is a continued clover pair. This yields 1/6 and 1/12 per checkpoint, while presence remains 1/2 in both cases. There is no pity mechanism.

Compute/checkpoint-commit once per ordinal. A future continue cannot remove a clover from an already telegraphed committed event. Presentation delay does not produce a second draw. Save all commitments across suspend/restore. If a run ends before an event is reached, it yields nothing.

**Nominal checkpoints:** at `k × 780` active seconds. Commit roughly six seconds before the intended presentation to reserve a readable safe runway. Times refer to active play, never device wall clock.

## 5. Probability calculations

If all `n` independent opportunities have clover probability `p`, the chance that at least three appear is:

```text
P(X >= 3) = Σ [ C(n,k) × p^k × (1-p)^(n-k) ], k=3...n
```

The expected opportunities until the third success are `3/p`. Thus clean expected nominal active time is 234 minutes; all-lowered-odds expected nominal time is 468 minutes. These condition on continued survival and successfully collecting every appearance. Ordinary players may never survive long enough, so this is not the average number of attempted runs before an ending.

| Nominal elapsed | Checkpoints | Clean probability of ≥3 | Lower odds at every checkpoint |
|---|---:|---:|---:|
| 39 min | 3 | 0.4630% | 0.0579% |
| 52 min | 4 | 1.6204% | 0.2170% |
| 65 min | 5 | 3.5494% | 0.5088% |
| 78 min | 6 | 6.2286% | 0.9545% |
| 104 min | 8 | 13.4847% | 2.3540% |
| 130 min | 10 | 22.4773% | 4.4484% |
| 180 min | 13 | 37.1923% | 8.8011% |
| 234 min | 18 | 59.7346% | 18.5366% |

When a continue occurs later, use a small dynamic program for mixed probabilities: keep probabilities of 0, 1, 2 and at least 3 clovers. For each actual checkpoint policy `p_i`, move each state into fail/success next states, with the >=3 state absorbing. No approximation is necessary. Existing clovers are not erased by a continue.

## 6. Fixed-step and saved state

One `step()` = one 1/60-second tick. Fixed ticks alone do not guarantee determinism: unordered iteration, engine contacts, non-versioned data and async tasks must also be controlled. Record normalized input at tick boundaries. Motion samples are normalized at the adapter; the core never reads the sensor or wall clock.

Store route progress as Double and local render transforms near the origin. Quantize values where needed for stable golden manifests. Keep collision tolerances conservative; reproducible numerical results do not prove a course is human-readable. A scene snapshot contains logic/state and deterministic descriptions, not cached RealityKit render objects.

## 7. Idempotent money and rewards

Use stable transaction/event IDs, not a new UUID on each callback:

- Store purchase grant: `purchase:<store_transaction_id>`.
- One-time bonus: `bonus:first_dream`.
- Earned settlement: `run:<run_uuid>:settlement:<revision>` with atomic highest-settled-total update.
- Cosmetic acquisition: one `cosmetic_id` ownership row plus its debit in one transaction.
- Achievement: one `achievement_id` unlock plus its cosmetic grant in one transaction.
- Continue entitlement: one unique provider reward event bound to one run UUID, with separate earned/consumed states.

No purchase earns a clover or modifies the random stream. No repeated ad callback grants a second continue. A debug event can show the same visual sequence but permanently excludes the run from real rewards.

For spending, use earned/bonus lots first, then purchased lots, oldest-first within each source. Record the lot allocations in debit details. The simple local refund policy reverses only the remaining amount in the identified purchased lot and marks the revocation applied; no earned funds or prestige unlocks are confiscated. This policy is intentionally not a server-backed antifraud system.
