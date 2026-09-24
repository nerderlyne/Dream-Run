import XCTest
import AVFAudio
@testable import DreamAgain

final class NativeDreamAudioTests:XCTestCase {
    @MainActor func testPreparingAudioAndRepeatedEffectsReuseRunningEngine() {
        let audio=DreamAudio()
        var settings=Settings();settings.haptics=false
        var run=RunState(identity:.current(seed:42),mode:.debug)
        audio.prepare(run:run,settings:settings)
        XCTAssertEqual(run.phase,.ready,"Preparing audio cannot advance gameplay")
        XCTAssertEqual(audio.engineStartCount,1)
        run.phase = .running
        for tick in 1...120 {
            run.activeTicks=UInt64(tick)
            audio.update(run:run,settings:settings,delta:1.0/60)
            if tick%15 == 0 {audio.play(.step,settings:settings)}
        }
        XCTAssertEqual(audio.engineStartCount,1,"Footfalls and frame updates must reuse the prepared engine")
        audio.stop()
        XCTAssertFalse(audio.engine.isRunning)
        audio.prepare(run:run,settings:settings)
        XCTAssertEqual(audio.engineStartCount,2,"Resume restarts once behind the ready screen")
        audio.stop()
    }
    @MainActor func testBundledSoundAndThetaChannelSeparation() throws {
        let audio=DreamAudio()
        let expected=Set(DreamAudio.bedNames+["motif-0","motif-1","motif-2","pulse","theta","balloon-1","balloon-2"]+DreamSoundCue.allCases.map(\.rawValue))
        XCTAssertEqual(Set(audio.buffers.keys),expected)
        for (name,buffer) in audio.buffers {
            XCTAssertGreaterThan(buffer.frameLength,0,name)
            let samples=try XCTUnwrap(buffer.floatChannelData?[0])
            var peak:Float=0
            for i in 0..<Int(buffer.frameLength) { XCTAssertTrue(samples[i].isFinite);peak=max(peak,abs(samples[i])) }
            // The separately generated straw transients are intentionally louder
            // and clipped by their source generator at 0.8; ambient/music stays quiet.
            let ceiling:Float = ["strawBreak","strawRepair"].contains(name) ? 0.8:0.2
            XCTAssertGreaterThan(peak,0.01,name);XCTAssertLessThanOrEqual(peak,ceiling,name)
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
