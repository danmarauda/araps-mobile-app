import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.bottom, 48)

                workOSSignInButton
                    .padding(.bottom, 12)

                appleSignInButton
                    .padding(.bottom, 16)

                biometricButton

                Spacer()
                    .frame(height: 32)

                poweredBySection

                #if DEBUG
                devBypassButton
                    .padding(.top, 24)
                #endif
            }
            .padding(.horizontal, 24)
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .alert("Authentication Error", isPresented: $authVM.showError) {
            Button("OK") {}
        } message: {
            Text(authVM.errorMessage ?? "An unknown error occurred")
        }
    }

    private var headerSection: some View {
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
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("ARAPS Mobile")
                    .font(.largeTitle.bold())

                Text("ARA Property Services")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("Field Management Platform")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
        }
    }

    private var workOSSignInButton: some View {
        Button {
            Task { await authVM.signInWithWorkOS() }
        } label: {
            HStack(spacing: 12) {
                if authVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "lock.shield.fill")
                        .font(.title3)
                    Text("Sign in with AuthKit")
                        .font(.body.bold())
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.borderedProminent)
        .tint(ARATheme.primaryBlue)
        .clipShape(.rect(cornerRadius: 14))
        .disabled(authVM.isLoading)
    }

    private var appleSignInButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { _ in
            Task { await authVM.signInWithApple() }
        }
        .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
        .frame(height: 54)
        .clipShape(.rect(cornerRadius: 14))
        .disabled(authVM.isLoading)
    }

    @ViewBuilder
    private var biometricButton: some View {
        let hasBiometric = UserDefaults.standard.bool(forKey: "biometricUserId")

        if hasBiometric {
            Button {
                Task { await authVM.signInWithBiometrics() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: authVM.biometricService.biometryIcon)
                        .font(.title3)
                    Text("Sign in with \(authVM.biometricService.biometryName)")
                        .font(.body.weight(.medium))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
            }
            .buttonStyle(.bordered)
            .clipShape(.rect(cornerRadius: 14))
            .onAppear {
                authVM.biometricService.checkAvailability()
            }
        }
    }

    private var poweredBySection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(ARATheme.primaryBlue)
                Text("Enterprise SSO")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("·")
                    .foregroundStyle(.quaternary)

                Image(systemName: "person.badge.key.fill")
                    .foregroundStyle(ARATheme.primaryBlue)
                Text("Apple Sign-In")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Multi-factor authentication · Passwordless login")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    #if DEBUG
    private var devBypassButton: some View {
        Button {
            authVM.devBypassLogin()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "hammer.fill")
                    .font(.subheadline)
                Text("Dev Bypass")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(.orange.opacity(0.12))
            .clipShape(.rect(cornerRadius: 10))
        }
    }
    #endif
}
