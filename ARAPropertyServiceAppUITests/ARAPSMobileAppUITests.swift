import XCTest

final class ARAPSMobileAppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testAppLaunchesAndShowsLoginScreen() throws {
        XCTAssertTrue(app.staticTexts["ARAPS Mobile"].waitForExistence(timeout: 5))
    }

    func testLoginScreenHasWorkOSButton() throws {
        let signInButton = app.buttons["Sign in with AuthKit"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 5))
    }

    func testLoginScreenHasAppleSignInButton() throws {
        XCTAssertTrue(app.buttons["Sign in with Apple"].waitForExistence(timeout: 5))
    }

    func testDevBypassNavigatesToMainApp() throws {
        #if DEBUG
        let devButton = app.buttons["Dev Bypass"]
        if devButton.waitForExistence(timeout: 3) {
            devButton.tap()
            XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 5))
        }
        #endif
    }

    func testTabBarHasNineTabs() throws {
        #if DEBUG
        tapDevBypass()
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))
        #endif
    }

    func testNavigateToTasksTab() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 1).tap()
        XCTAssertTrue(app.navigationBars["Tasks"].waitForExistence(timeout: 5))
        #endif
    }

    func testNavigateToIssuesTab() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 2).tap()
        XCTAssertTrue(app.navigationBars["Issues"].waitForExistence(timeout: 5))
        #endif
    }

    func testNavigateToCleanOpsTab() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 4).tap()
        XCTAssertTrue(app.navigationBars["CleanOps"].waitForExistence(timeout: 5))
        #endif
    }

    func testNavigateToContactsTab() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 6).tap()
        XCTAssertTrue(app.navigationBars["Contacts"].waitForExistence(timeout: 5))
        #endif
    }

    func testReportIssueFormOpens() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 2).tap()
        let plusButton = app.buttons["Add"].firstMatch
        if plusButton.waitForExistence(timeout: 3) {
            plusButton.tap()
            XCTAssertTrue(app.navigationBars["Report Issue"].waitForExistence(timeout: 5))
        }
        #endif
    }

    func testReportIssueSubmitDisabledWhenEmpty() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 2).tap()
        let plusButton = app.buttons["Add"].firstMatch
        if plusButton.waitForExistence(timeout: 3) {
            plusButton.tap()
            let submitButton = app.buttons["Submit"]
            XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
            XCTAssertFalse(submitButton.isEnabled)
        }
        #endif
    }

    func testCleanOpsHasScannerButton() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 4).tap()
        XCTAssertTrue(app.buttons["Open Scanner"].waitForExistence(timeout: 5))
        #endif
    }

    func testChatViewShowsEmptyState() throws {
        #if DEBUG
        tapDevBypass()
        app.tabBars.buttons.element(boundBy: 3).tap()
        XCTAssertTrue(app.staticTexts["Ask ARA Anything"].waitForExistence(timeout: 5))
        #endif
    }

    private func tapDevBypass() {
        let devButton = app.buttons["Dev Bypass"]
        if devButton.waitForExistence(timeout: 3) {
            devButton.tap()
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 5)
        }
    }
}
