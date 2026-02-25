import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var authVM: AuthViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var showDemoInfo = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                    .padding(.bottom, 48)

                workOSSignInButton
                    .padding(.bottom, 12)

                appleSignInButton
                    .padding(.bottom, 12)

                biometricButton
                    .padding(.bottom, 24)

                divider

                demoModeButton
                    .padding(.top, 16)
                    .padding(.bottom, 24)

                poweredBySection
            }
            .padding(.horizontal, 24)
            .padding(.top, 64)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .alert("Authentication Error", isPresented: $authVM.showError) {
            Button("OK") {}
        } message: {
            Text(authVM.errorMessage ?? "An unknown error occurred")
        }
        .sheet(isPresented: $showDemoInfo) {
            DemoInfoSheet {
                showDemoInfo = false
                authVM.demoLogin()
            }
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

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
            Text("or")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
    }

    private var demoModeButton: some View {
        Button {
            showDemoInfo = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "eye.fill")
                    .font(.subheadline)
                Text("View Demo")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
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
}

struct DemoInfoSheet: View {
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(ARATheme.primaryBlue.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "eye.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(ARATheme.primaryBlue)
                    }

                    Text("Demo Mode")
                        .font(.title2.bold())

                    Text("Explore ARAPS Mobile with pre-loaded sample data. No account required.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    DemoFeatureRow(icon: "checkmark.square.fill", text: "Browse tasks, issues, and facilities")
                    DemoFeatureRow(icon: "exclamationmark.bubble.fill", text: "View the executive dashboard and KPIs")
                    DemoFeatureRow(icon: "qrcode.viewfinder", text: "Try the CleanOps QR workflow")
                    DemoFeatureRow(icon: "message.fill", text: "Send a message to AskARA (requires API key)")
                    DemoFeatureRow(icon: "person.2.fill", text: "Browse the team directory and contacts")
                }
                .padding(.horizontal, 8)

                VStack(spacing: 12) {
                    Button {
                        onContinue()
                    } label: {
                        Text("Continue to Demo")
                            .font(.body.bold())
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(ARATheme.primaryBlue)
                    .clipShape(.rect(cornerRadius: 14))

                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(28)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

struct DemoFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(ARATheme.primaryBlue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
    }
}
