import XCTest

@MainActor
final class OnboardingUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunchesApplication() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(
            app.windows.firstMatch.waitForExistence(timeout: 5),
            "Expected main application window to appear after launch."
        )
    }
}
