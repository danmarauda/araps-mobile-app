import SwiftUI

struct RootView: View {
    @Bindable var authVM: AuthViewModel
    @State private var navState = AppNavigationState()

    var body: some View {
        Group {
            switch authVM.authState {
            case .loading:
                launchScreen

            case .unauthenticated:
                LoginView(authVM: authVM)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))

            case .onboarding:
                LoginView(authVM: authVM)
                    .transition(.opacity)

            case .organizationSelection:
                OrganizationPickerView(
                    organizations: authVM.availableOrganizations
                ) { org in
                    authVM.selectOrganization(org)
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))

            case .authenticated:
                ContentView(authVM: authVM, navState: navState)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .animation(.easeInOut(duration: 0.4), value: authVM.authState == .authenticated)
        .animation(.easeInOut(duration: 0.4), value: authVM.authState == .unauthenticated)
        .onReceive(NotificationCenter.default.publisher(for: .araDeepLink)) { notification in
            guard authVM.authState == .authenticated,
                  let url = notification.userInfo?["url"] as? URL else { return }
            navState.handleDeepLink(url)
        }
    }

    private var launchScreen: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ARATheme.primaryBlue, ARATheme.primaryBlue.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("ARAPS Mobile")
                .font(.title2.bold())

            ProgressView()
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

extension AppAuthState: Equatable {
    nonisolated static func == (lhs: AppAuthState, rhs: AppAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading),
             (.unauthenticated, .unauthenticated),
             (.authenticated, .authenticated),
             (.onboarding, .onboarding),
             (.organizationSelection, .organizationSelection):
            return true
        default:
            return false
        }
    }
}
