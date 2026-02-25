import SwiftUI

@Observable
@MainActor
class AppNavigationState {
    var selectedTab: AppTab = .dashboard

    func navigate(to tab: AppTab) {
        selectedTab = tab
    }

    func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

        switch components.host {
        case "alert", "cleanops":
            navigate(to: .cleanOps)
        case "tasks":
            navigate(to: .tasks)
        case "issues":
            navigate(to: .issues)
        case "contacts":
            navigate(to: .contacts)
        case "properties":
            navigate(to: .properties)
        case "reports":
            navigate(to: .reports)
        case "settings":
            navigate(to: .settings)
        case "dashboard":
            navigate(to: .dashboard)
        default:
            break
        }
    }
}
