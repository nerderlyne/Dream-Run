import XCTest
final class Dream_AgainUITests:XCTestCase {
    @MainActor func testOfflineStartPauseAndMenus() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["dream"].waitForExistence(timeout:10))
        app.buttons["dream"].tap();XCTAssertTrue(app.buttons["ready"].waitForExistence(timeout:10));app.buttons["ready"].tap()
        XCTAssertTrue(app.buttons["ready"].waitForNonExistence(timeout:3),"The full ready button must accept a tap")
        let unexpectedPause=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == true"),object:app.buttons["ready"])
        unexpectedPause.isInverted=true;wait(for:[unexpectedPause],timeout:8)
        XCTAssertEqual(app.sliders.count,0)
        XCTAssertFalse(app.switches["Drag steering instead of tilt"].exists)
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout:5));app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["save & leave"].waitForExistence(timeout:5));app.buttons["save & leave"].tap()
        app.buttons["wardrobe"].tap()
        let girl=app.buttons["Girl · dress"]
        if girl.waitForExistence(timeout:3) {girl.tap()}
        XCTAssertTrue(app.buttons["Girl · wearing dress"].waitForExistence(timeout:5))
        XCTAssertTrue(app.staticTexts["Paper hat"].waitForExistence(timeout:5))
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Wardrobe";attachment.lifetime = .keepAlways;add(attachment)
    }
}

extension Dream_AgainUITests {
    @MainActor func testTranslucentTrackDeviceReview() throws {
        let app=XCUIApplication()
        app.launchArguments=["--ui-test","--art-review","--design-review","--pattern","checker","--art-theme","1","--sky","plate_f46f34cb8f3c1332"]
        app.launch()
        XCTAssertTrue(app.staticTexts["PREVIEW · NO REWARDS"].waitForExistence(timeout:30))
        // Allow asynchronous photo upload and a sustained render interval on the destination device.
        let alive=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:app.staticTexts["PREVIEW · NO REWARDS"])
        alive.isInverted=true;wait(for:[alive],timeout:12)
        let screenshot=XCTAttachment(screenshot:app.screenshot());screenshot.name="Translucent checker over underwater photograph";screenshot.lifetime = .keepAlways;add(screenshot)
        XCTAssertEqual(app.state,.runningForeground)
    }
}
