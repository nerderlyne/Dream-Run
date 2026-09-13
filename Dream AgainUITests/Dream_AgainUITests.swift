import XCTest
final class Dream_AgainUITests:XCTestCase {
    @MainActor func testOfflineStartPauseAndMenus() throws {
        let app=XCUIApplication();app.launchArguments=["--ui-test"];app.launch()
        XCTAssertTrue(app.buttons["dream"].waitForExistence(timeout:10))
        app.buttons["dream"].tap();XCTAssertTrue(app.buttons["ready"].waitForExistence(timeout:10));app.buttons["ready"].tap()
        XCTAssertTrue(app.buttons["pause"].waitForExistence(timeout:5));app.buttons["pause"].tap()
        XCTAssertTrue(app.buttons["save & leave"].waitForExistence(timeout:5));app.buttons["save & leave"].tap()
        app.buttons["wardrobe"].tap();XCTAssertTrue(app.staticTexts["Paper hat"].waitForExistence(timeout:5))
        let attachment=XCTAttachment(screenshot:app.screenshot());attachment.name="Wardrobe";attachment.lifetime = .keepAlways;add(attachment)
    }
}
