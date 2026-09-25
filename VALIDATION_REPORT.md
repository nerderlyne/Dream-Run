# Specification data validation report

Pig rules: guaranteed three-minute encounters; 1/3 lucky, 1/6 after continue.

**Artifact status:** This script checks specification data and reference algorithms only. See IMPLEMENTATION_STATUS.md for separate Swift and simulator results.

**Executed:** `python3 tools/validate_spec.py` — 56 checks passed.

## Checks passed

1. All nine JSON contract and asset manifest files parse
2. Owner photo intake has unique files and Unsplash source URLs
3. All 22 owner photo cutouts have bundled resources
4. Curated plate IDs are unique and nonempty
5. Curated photos respect the 2048 pixel limit
6. Every curated photo has a bundled resource
7. Exactly 42 world-asset families
8. Ordinals are exactly 1...42
9. World IDs are unique
10. Pig occupies slot 42
11. All creator-selected symbolic objects exist
12. No anatomical eyeball replacing the nazar
13. All assets have construction and budget metadata
14. Full specification names all 42 stable IDs
15. Pig timing and three-pig requirement preserved
16. Pig presence is guaranteed
17. Clean conditional clover probability is one third
18. Continued conditional clover probability is one sixth
19. Guaranteed pig checkpoint without lucky pity
20. Three-hour transition is not an ending
21. Balloons are the purchasable currency
22. One-continue default consistent
23. Ordinary narrow full-width deck supports entire constrained steering range
24. Chunk cap accommodates forward/rear window plus margin
25. Generation window can support rolling hazard preview distance
26. Cosmetic and achievement IDs unique
27. Achievement-only items have no store price
28. All cosmetic achievement references resolve
29. All achievement cosmetic rewards resolve
30. Bidirectional reward mapping: lucky_pig_hat
31. Bidirectional reward mapping: unbroken_clover
32. Bidirectional reward mapping: beyond_crown
33. Bidirectional reward mapping: void_ribbon
34. Palette IDs unique
35. All palette swatches are valid hex colors
36. Ordinary, white and beyond palette phases present
37. SplitMix64 vectors reproduce
38. Known SplitMix64 zero-state first result matches
39. FNV-1a fixtures reproduce
40. Dream ID roundtrip: 0
41. Dream ID roundtrip: 1
42. Dream ID roundtrip: 42
43. Dream ID roundtrip: 123456789
44. Dream ID roundtrip: 16045690984503111693
45. Dream ID roundtrip: 18446744073709551615
46. All 100 pig checkpoints reproduce; continued lucky set is subset
47. Exact six-draw pig truth table validated
48. Earliest nominal ending probability is 1/27
49. 15-minute clean probability is exactly 17/81
50. Expected nominal times are 27 and 54 minutes
51. Malformed/overflow/corrupt Dream IDs rejected by reference parser
52. SQLite schema creates required tables
53. SQLite negative-wallet check enforced
54. All six creator visual references included
55. Root agent instructions remain compact
56. All entry, reference and acceptance files present

## Not tested / not claimed

Swift/Xcode compilation; native rendering; actual 42-asset mesh implementation; physical-device motion, frame rate, battery/thermal behaviour; live StoreKit purchases, ad rewards, Game Center or cloud recovery; human playtesting and final art quality. Those are implementing-agent/release acceptance tasks, not completed work in this pack.
