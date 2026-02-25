import SwiftUI

struct ContentView: View {
    let authVM: AuthViewModel
    @Bindable var navState: AppNavigationState

    init(authVM: AuthViewModel, navState: AppNavigationState = AppNavigationState()) {
        self.authVM = authVM
        self.navState = navState
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch navState.selectedTab {
                case .dashboard:
                    ExecDashboardView(authVM: authVM)
                case .tasks:
                    TasksListView()
                case .issues:
                    IssuesListView()
                case .chat:
                    ChatView()
                case .cleanOps:
                    CleanOpsView()
                case .properties:
                    FacilitiesListView()
                case .contacts:
                    ContactsListView()
                case .reports:
                    ReportsView()
                case .settings:
                    SettingsView(authVM: authVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .environment(navState)
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    if navState.selectedTab != tab {
                        navState.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: navState.selectedTab == tab ? .semibold : .regular))
                            .foregroundStyle(navState.selectedTab == tab ? ARATheme.primaryBlue : .secondary)

                        Circle()
                            .fill(navState.selectedTab == tab ? ARATheme.primaryBlue : .clear)
                            .frame(width: 4, height: 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 2)
                }
                .sensoryFeedback(.selection, trigger: navState.selectedTab)
            }
        }
        .padding(.bottom, 16)
        .background {
            Rectangle()
                .fill(.bar)
                .ignoresSafeArea(edges: .bottom)
                .shadow(color: .black.opacity(0.06), radius: 8, y: -2)
        }
    }
}

nonisolated enum AppTab: String, CaseIterable, Sendable {
    case dashboard, tasks, issues, chat, cleanOps, properties, contacts, reports, settings

    var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .tasks: return "checkmark.square.fill"
        case .issues: return "exclamationmark.bubble.fill"
        case .chat: return "message.fill"
        case .cleanOps: return "qrcode.viewfinder"
        case .properties: return "building.2.fill"
        case .contacts: return "person.2.fill"
        case .reports: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
}
