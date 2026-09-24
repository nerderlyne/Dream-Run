import XCTest

final class PerformanceSmokeUITests:XCTestCase {
    @MainActor func testAutomatedRunCompletesWithoutRewardsOrSaveError() {
        let app=XCUIApplication()
        app.launchArguments=["--performance-run","--performance-seconds","15","--performance-seed","42"]
        app.launch()
        XCTAssertTrue(app.staticTexts["PREVIEW · NO REWARDS"].waitForExistence(timeout:30))
        XCTAssertTrue(app.staticTexts["Performance test complete"].waitForExistence(timeout:30))
        XCTAssertTrue(app.buttons["ready"].exists,"Completion must leave gameplay paused")
        XCTAssertEqual(app.alerts.count,0)
        XCTAssertEqual(app.state,.runningForeground)
        let frame=XCTAttachment(screenshot:app.screenshot())
        frame.name="Performance smoke — paused after automated run"
        frame.lifetime = .keepAlways
        add(frame)
    }
}
