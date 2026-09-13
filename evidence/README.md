# Verification outputs

`core-tests.log`: complete release-mode Swift package suite, including golden fixtures, ledger/recovery, certification regression and twenty six-hour seeded traversals. The XCTest summary is authoritative; Swift Testing's trailing “0 tests” is its separate unused runner.

`core-unit-tests.log`: latest focused package suite excluding the long traversal soak.

`build-tests.log`: generic iOS Simulator SDK Debug app and native test-bundle compilation. This is **build-for-testing**, not simulator test execution.

`build-release.log`: generic iOS Simulator SDK Release app compilation, signing disabled.

`build-debug.log`: earlier Debug build milestone; the final Debug source is verified by `build-tests.log`.

`spec-validation.log`: supplied Python specification-data consistency checks only.

`release-preflight.log`: disabled service configuration, exact registry, bundled contract parity and reference-resource exclusion.

No device/simulator screenshots or physical-performance results were obtained. CoreSimulator access escalation was denied. See the root implementation status and known limitations.
