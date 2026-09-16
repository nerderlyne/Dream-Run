import XCTest
@testable import DreamCore

final class DreamAudioTests:XCTestCase {
    func testThetaIsOptInIndependentAndRequiresStereoHeadphones() throws {
        var settings=Settings()
        XCTAssertFalse(DreamSoundscape.thetaAllowed(settings:settings,headphones:true,mono:false))
        settings.thetaEnabled=true; settings.music=false; settings.effects=false; settings.thetaLevel=0.2
        XCTAssertTrue(DreamSoundscape.thetaAllowed(settings:settings,headphones:true,mono:false))
        XCTAssertFalse(DreamSoundscape.thetaAllowed(settings:settings,headphones:false,mono:false))
        XCTAssertFalse(DreamSoundscape.thetaAllowed(settings:settings,headphones:true,mono:true))
        let restored=try JSONDecoder().decode(Settings.self,from:JSONEncoder().encode(settings))
        XCTAssertTrue(restored.thetaEnabled); XCTAssertEqual(restored.thetaLevel,0.2)
        XCTAssertEqual(DreamSoundscape.level(.nan),0)
        XCTAssertEqual(DreamSoundscape.level(2),1)
    }
    func testMovementUsesAcceptedActionsAndActualGait() {
        let director=DreamMovementAudio()
        var before=RunState(identity:.current(seed:42),mode:.debug)
        before.phase = .running; before.distance=2.9
        var after=before; after.activeTicks=1; after.distance=3.1
        XCTAssertEqual(director.cues(before:before,after:after).count,1)
        after.player.grounded=false;after.player.velocityY=7
        XCTAssertEqual(director.cues(before:before,after:after),[.jump])
        before=after;after.activeTicks+=1;after.player.velocityY=5
        XCTAssertTrue(director.cues(before:before,after:after).isEmpty)
        after.player.grounded=true;after.player.velocityY=0
        XCTAssertEqual(director.cues(before:before,after:after),[.land])
        before=after;after.activeTicks+=1;after.player.slideTicks=25
        XCTAssertEqual(director.cues(before:before,after:after),[.slide])
        before=after;after.activeTicks+=1;after.distance=6.1
        XCTAssertTrue(director.cues(before:before,after:after).isEmpty)
        after.phase = .waking
        XCTAssertTrue(director.cues(before:before,after:after).isEmpty)
    }
    func testScoreStripsRebuildsAndEndsWithoutChangingRun() throws {
        var run=RunState(identity:.current(seed:42),mode:.debug);run.phase = .running
        let data=try JSONEncoder().encode(run)
        let scene=DreamSoundscape(run:run)
        XCTAssertEqual(scene.motifVariant,DreamSoundscape(run:run).motifVariant)
        XCTAssertEqual(try JSONEncoder().encode(run).count,data.count)
        run.activeTicks=UInt64(11050*60)
        XCTAssertLessThan(DreamSoundscape(run:run).bedGain,scene.bedGain)
        run.activeTicks=UInt64(11500*60)
        XCTAssertEqual(DreamSoundscape(run:run).bed,"alien")
        run.phase = .luckyTransition;run.endingElapsed=56
        XCTAssertEqual(DreamSoundscape(run:run).pulseGain,0)
        XCTAssertLessThan(DreamSoundscape(run:run).bedGain,0.03)
        run.endingElapsed=57
        XCTAssertEqual(DreamSoundscape(run:run).thetaGain,0)
    }
    func testPauseDoesNotCreateMovementCues() {
        let director=DreamMovementAudio()
        var before=RunState(identity:.current(seed:42),mode:.debug)
        var after=before;after.phase = .paused;after.activeTicks=2;after.distance=3
        XCTAssertTrue(director.cues(before:before,after:after).isEmpty)
        before=after;after.phase = .running
        XCTAssertTrue(director.cues(before:before,after:after).isEmpty)
    }
}
