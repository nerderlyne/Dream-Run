# Dream audio

The score is original procedural audio, reproduced with:

```sh
python3 tools/audio/generate_dream_audio.py
```

Open `Dream Again.xcodeproj`, select the shared `Dream Again` scheme and an iPhone
simulator, then Run. In settings, Music and Effects have independent levels.
**Theta · stereo headphones** is a separate, persisted opt-in; its slider appears
when enabled. Save settings, then start a dream. No accounts, network or paid
audio assets are required.

Six 24-second environmental beds, a seeded 32-second three-note motif and an
8-second gentle pulse combine into a longer musical cycle. The native audio
service preloads the 25 original PCM assets (about 11 MB on disk), bounds one-shot
voices to four, and crossfades beds rather than regenerating audio each frame.
Cloud/glass palettes are airy; aqua uses watery resonances; dusk/night/mint are
uncanny; void becomes sparse; Lucky Dream dissolves; alien palettes rebuild.
This follows the gameplay palette, not image recognition of the photo plates.

Accepted jumps, slides, landings and six-metre running strides drive immediate
feedback. Stairs and watery palettes have distinct footfalls. All running footfalls use
0.14 gain (about −17 dB) relative to other effects, retaining their contact
transients at a barely present level beneath the score. Balloon trails
cycle a three-note phrase with an eight-tick rate limit. Mirrors draw the texture
back and temporarily suppress music; safe drops soften it. Busy hazard windows
reduce decorative motif/pulse gain. Three-hour stripping and rebuilding change
layer density without ending a run. Lucky Dream removes the pulse and fades all
layers over its 57-second presentation. Haptics and thunder retain independent
existing controls; all critical obstacles still have visual cues.

Theta uses a seamless 44.1 kHz stereo buffer: 200 Hz left, 206 Hz right, a 6 Hz
difference. It bypasses the music reverb and spatial processing, fades in gently,
and is independently adjustable even with Music off. Its maximum source peak is
0.025 before user and master gain. This is a sound-design option, not a treatment
or a verified way to induce dreams, sleep or hypnosis.

Phone speaker/receiver, AirPlay, Bluetooth HFP and Mono Audio disable theta.
Wired headphone and Bluetooth A2DP/LE routes are eligible. iOS does not reliably
identify whether an A2DP route is headphones or a Bluetooth speaker: the player
must use stereo headphones as the toggle instructs. Unplugging/disconnecting
audio pauses the run. Pausing/backgrounding/interruption stops every bus;
normal waking cannot restart the score. Fatal thunder may finish playing.
The app uses the ambient session category and respects silent mode.

Verification commands (simulator only):

```sh
python3 tools/validate_spec.py
swift test -c release
xcodebuild -project 'Dream Again.xcodeproj' -scheme 'Dream Again' \
  -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
  -derivedDataPath DerivedData CODE_SIGNING_ALLOWED=NO \
  -parallel-testing-enabled NO \
  '-only-testing:Dream AgainTests/NativeDreamAudioTests' \
  '-only-testing:Dream AgainTests/Dream_AgainTests/testThunderSurvivesPickupAndFatalStrikeButStopsOnPause' test
```

Core tests check accepted-action timing, control persistence, theta eligibility
and ending/evolution mapping. Native tests inspect all PCM resources, measure the
200/206 Hz channel amplitudes and crosstalk, and exercise score/thunder lifecycle.
See IMPLEMENTATION_STATUS.md for actual results. Subjective headphone listening,
comfort, hearing-level calibration and perceptual benefits are not established
by these tests. No physical iPhone testing is authorized.
