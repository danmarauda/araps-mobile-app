import XCTest

final class ARAPSMobileAppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool { true }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Takes App Store screenshots automatically via Fastlane Snapshot.
    /// Run: `fastlane screenshots` from the project root.
    func testTakeAppStoreScreenshots() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "DEMO_MODE"]
        setupSnapshot(app)
        app.launch()

        // 1. Login screen
        let loginTitle = app.staticTexts["ARAPS Mobile"]
        if loginTitle.waitForExistence(timeout: 8) {
            snapshot("01_Login")

            // Tap "View Demo" to enter without credentials
            let demoButton = app.buttons["View Demo"]
            if demoButton.waitForExistence(timeout: 3) {
                demoButton.tap()
                // Tap "Continue to Demo" in the sheet
                let continueButton = app.buttons["Continue to Demo"]
                if continueButton.waitForExistence(timeout: 3) {
                    continueButton.tap()
                }
            }
        }

        // Wait for main app to load
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 10) else { return }

        // 2. Executive Dashboard (tab 0)
        app.tabBars.buttons.element(boundBy: 0).tap()
        sleep(2)
        snapshot("02_Dashboard")

        // 3. Tasks list (tab 1)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(1)
        snapshot("03_Tasks")

        // 4. Issues list (tab 2)
        app.tabBars.buttons.element(boundBy: 2).tap()
        sleep(1)
        snapshot("04_Issues")

        // 5. CleanOps (tab 4)
        app.tabBars.buttons.element(boundBy: 4).tap()
        sleep(1)
        snapshot("05_CleanOps")

        // 6. Facilities (tab 5)
        app.tabBars.buttons.element(boundBy: 5).tap()
        sleep(1)
        snapshot("06_Facilities")

        // 7. Contacts (tab 6)
        app.tabBars.buttons.element(boundBy: 6).tap()
        sleep(1)
        snapshot("07_Contacts")

        // 8. Chat / AskARA (tab 3)
        app.tabBars.buttons.element(boundBy: 3).tap()
        sleep(1)
        snapshot("08_AskARA")

        // 9. Reports (tab 7)
        app.tabBars.buttons.element(boundBy: 7).tap()
        sleep(1)
        snapshot("09_Reports")

        // 10. Settings (tab 8)
        app.tabBars.buttons.element(boundBy: 8).tap()
        sleep(1)
        snapshot("10_Settings")
    }
}
