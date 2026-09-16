import XCTest
import AVFAudio
@testable import DreamAgain

final class NativeDreamAudioTests:XCTestCase {
    @MainActor func testBundledSoundAndThetaChannelSeparation() throws {
        let audio=DreamAudio()
        XCTAssertEqual(audio.buffers.count,25)
        for (name,buffer) in audio.buffers {
            XCTAssertGreaterThan(buffer.frameLength,0,name)
            let samples=try XCTUnwrap(buffer.floatChannelData?[0])
            var peak:Float=0
            for i in 0..<Int(buffer.frameLength) { XCTAssertTrue(samples[i].isFinite);peak=max(peak,abs(samples[i])) }
            XCTAssertGreaterThan(peak,0.01,name);XCTAssertLessThan(peak,0.2,name)
        }
        let theta=try XCTUnwrap(audio.buffers["theta"])
        XCTAssertEqual(theta.format.channelCount,2);XCTAssertEqual(theta.format.sampleRate,44100)
        XCTAssertEqual(theta.frameLength,88200)
        let channels=try XCTUnwrap(theta.floatChannelData)
        func amplitude(_ channel:Int,_ frequency:Double)->Double {
            var sine=0.0,cosine=0.0
            for i in 0..<Int(theta.frameLength) {
                let phase=2*Double.pi*frequency*Double(i)/44100
                sine+=Double(channels[channel][i])*sin(phase)
                cosine+=Double(channels[channel][i])*cos(phase)
            }
            return 2*hypot(sine,cosine)/Double(theta.frameLength)
        }
        XCTAssertEqual(amplitude(0,200),0.025,accuracy:0.0001)
        XCTAssertEqual(amplitude(1,206),0.025,accuracy:0.0001)
        XCTAssertLessThan(amplitude(0,206),0.0001)
        XCTAssertLessThan(amplitude(1,200),0.0001)
        audio.stop()
    }
    @MainActor func testIndependentControlsAndPause() {
        let audio=DreamAudio()
        var settings=Settings();settings.music=false;settings.effects=true;settings.haptics=false
        var run=RunState(identity:.current(seed:42),mode:.debug);run.phase = .running
        audio.update(run:run,settings:settings,delta:1.0/60)
        XCTAssertFalse(audio.musicIsPlaying);XCTAssertFalse(audio.theta.isPlaying)
        settings.music=true
        audio.update(run:run,settings:settings,delta:1.0/60)
        XCTAssertTrue(audio.musicIsPlaying)
        audio.stop()
        XCTAssertFalse(audio.musicIsPlaying);XCTAssertFalse(audio.theta.isPlaying);XCTAssertFalse(audio.engine.isRunning)
        run.phase = .waking
        audio.update(run:run,settings:settings,delta:1.0/60)
        XCTAssertFalse(audio.engine.isRunning,"Fatal contact must not restart the score")
        run.phase = .luckyTransition
        audio.update(run:run,settings:settings,delta:1.0/60)
        XCTAssertTrue(audio.musicIsPlaying,"Lucky Dream must keep its fading score")
        audio.stop()
    }
}
