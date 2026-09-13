#!/bin/sh
set -eu
python3 tools/validate_spec.py
python3 scripts/release_preflight.py
swift test -c release
xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again' -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build-for-testing
xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again' -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO build
