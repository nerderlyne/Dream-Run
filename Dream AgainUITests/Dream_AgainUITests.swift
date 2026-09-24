import XCTest
final class Dream_AgainUITests:XCTestCase {
    @MainActor func testWardrobeTryOnWithoutPurchase() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["wardrobe"].waitForExistence(timeout:10))
        app.buttons["wardrobe"].tap()
        XCTAssertTrue(app.staticTexts["Your straw looper"].waitForExistence(timeout:5))
        let hat=app.buttons["preview paper_hat"]
        XCTAssertTrue(hat.waitForExistence(timeout:5))
        hat.tap()
        XCTAssertTrue(app.buttons["buy"].exists,"Preview must leave the item unowned")
        XCTAssertTrue(app.staticTexts["Smiley paper bag"].exists)
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Wardrobe try-on";attachment.lifetime = .keepAlways;add(attachment)
    }
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
        XCTAssertTrue(app.staticTexts["Your straw looper"].waitForExistence(timeout:5))
        XCTAssertTrue(app.buttons["preview paper_hat"].waitForExistence(timeout:5))
        app.buttons["preview paper_hat"].tap()
        XCTAssertTrue(app.buttons["buy"].exists)
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

extension Dream_AgainUITests {
    @MainActor func testFloatingStairProgressionPreviews() throws {
        for variant in ["floating","late"] {
            let app=XCUIApplication()
            app.launchArguments=["--ui-test","--art-review","--design-review","--jump-sequence",variant,"--pattern","checker"]
            app.launch()
            XCTAssertTrue(app.staticTexts["PREVIEW · NO REWARDS"].waitForExistence(timeout:30))
            let stillRunning=XCTNSPredicateExpectation(predicate:NSPredicate(format:"exists == false"),object:app.staticTexts["PREVIEW · NO REWARDS"])
            stillRunning.isInverted=true;wait(for:[stillRunning],timeout:4)
            let shot=XCTAttachment(screenshot:app.screenshot());shot.name="Jump sequence - \(variant)";shot.lifetime = .keepAlways;add(shot)
            XCTAssertEqual(app.state,.runningForeground)
            app.terminate()
        }
    }
}
