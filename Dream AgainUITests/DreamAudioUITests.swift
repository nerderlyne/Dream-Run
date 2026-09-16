import XCTest

final class DreamAudioUITests:XCTestCase {
    @MainActor func testThetaSettingsAreOptInAndAdjustable() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["settings"].waitForExistence(timeout:20))
        app.buttons["settings"].tap()
        let theta=app.switches["theta audio"]
        XCTAssertTrue(theta.waitForExistence(timeout:5))
        XCTAssertEqual(theta.value as? String,"0")
        theta.tap()
        XCTAssertEqual(theta.value as? String,"1")
        let level=app.sliders["theta level"]
        if !level.isHittable { app.swipeUp() }
        XCTAssertTrue(level.waitForExistence(timeout:5));level.adjust(toNormalizedSliderPosition:0.25)
        let screenshot=XCTAttachment(screenshot:app.screenshot())
        screenshot.name="Dream audio settings";screenshot.lifetime = .keepAlways;add(screenshot)
        let save=app.buttons["save settings"]
        if !save.isHittable { app.swipeUp() }
        save.tap()
        app.buttons["‹ home"].tap()
        app.buttons["settings"].tap()
        XCTAssertEqual(app.switches["theta audio"].value as? String,"1")
    }
}
