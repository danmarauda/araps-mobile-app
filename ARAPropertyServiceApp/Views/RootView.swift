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
        ZStack {
            araDarkBg.ignoresSafeArea()

            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(x: -60, y: -60, width: 300, height: 300)),
                    with: .color(araGreen.opacity(0.07))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width - 160, y: size.height - 200, width: 280, height: 280)),
                    with: .color(Color.blue.opacity(0.04))
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 20) {
                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(araGreen.opacity(0.16))
                        .frame(width: 88, height: 88)
                        .blur(radius: 14)

                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [araGreen, araGreen.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                        }
                        .frame(width: 76, height: 76)
                        .shadow(color: araGreen.opacity(0.4), radius: 20, y: 6)

                    Image(systemName: "building.2.fill")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(araDarkBg)
                }

                VStack(spacing: 5) {
                    Text("ARA Property Services")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)

                    Text("ARAPS Mobile")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(araGreen.opacity(0.7))
                        .tracking(1.6)
                        .textCase(.uppercase)
                }

                ProgressView()
                    .tint(araGreen.opacity(0.6))
                    .scaleEffect(0.9)
                    .padding(.top, 12)
            }
        }
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
