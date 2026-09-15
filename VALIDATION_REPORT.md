# Specification data validation report

Pig rules: guaranteed three-minute encounters; 1/3 lucky, 1/6 after continue.

**Artifact status:** This script checks specification data and reference algorithms only. See IMPLEMENTATION_STATUS.md for separate Swift and simulator results.

**Executed:** `python3 tools/validate_spec.py` — 54 checks passed.

## Checks passed

1. All eight JSON contract and asset manifest files parse
2. Curated plate IDs are unique and nonempty
3. Curated photos respect the 2048 pixel limit
4. Every curated photo has a bundled resource
5. Exactly 42 world-asset families
6. Ordinals are exactly 1...42
7. World IDs are unique
8. Pig occupies slot 42
9. All creator-selected symbolic objects exist
10. No anatomical eyeball replacing the nazar
11. All assets have construction and budget metadata
12. Full specification names all 42 stable IDs
13. Pig timing and three-pig requirement preserved
14. Pig presence is guaranteed
15. Clean conditional clover probability is one third
16. Continued conditional clover probability is one sixth
17. Guaranteed pig checkpoint without lucky pity
18. Three-hour transition is not an ending
19. Balloons are the purchasable currency
20. One-continue default consistent
21. Ordinary narrow full-width deck supports entire constrained steering range
22. Chunk cap accommodates forward/rear window plus margin
23. Generation window can support rolling hazard preview distance
24. Cosmetic and achievement IDs unique
25. Achievement-only items have no store price
26. All cosmetic achievement references resolve
27. All achievement cosmetic rewards resolve
28. Bidirectional reward mapping: lucky_pig_hat
29. Bidirectional reward mapping: unbroken_clover
30. Bidirectional reward mapping: beyond_crown
31. Bidirectional reward mapping: void_ribbon
32. Palette IDs unique
33. All palette swatches are valid hex colors
34. Ordinary, white and beyond palette phases present
35. SplitMix64 vectors reproduce
36. Known SplitMix64 zero-state first result matches
37. FNV-1a fixtures reproduce
38. Dream ID roundtrip: 0
39. Dream ID roundtrip: 1
40. Dream ID roundtrip: 42
41. Dream ID roundtrip: 123456789
42. Dream ID roundtrip: 16045690984503111693
43. Dream ID roundtrip: 18446744073709551615
44. All 100 pig checkpoints reproduce; continued lucky set is subset
45. Exact six-draw pig truth table validated
46. Earliest nominal ending probability is 1/27
47. 15-minute clean probability is exactly 17/81
48. Expected nominal times are 27 and 54 minutes
49. Malformed/overflow/corrupt Dream IDs rejected by reference parser
50. SQLite schema creates required tables
51. SQLite negative-wallet check enforced
52. All six creator visual references included
53. Root agent instructions remain compact
54. All entry, reference and acceptance files present

## Not tested / not claimed

Swift/Xcode compilation; native rendering; actual 42-asset mesh implementation; physical-device motion, frame rate, battery/thermal behaviour; live StoreKit purchases, ad rewards, Game Center or cloud recovery; human playtesting and final art quality. Those are implementing-agent/release acceptance tasks, not completed work in this pack.
