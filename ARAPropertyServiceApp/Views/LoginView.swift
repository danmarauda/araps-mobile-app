import SwiftUI
import AuthenticationServices

// MARK: - Login View

struct LoginView: View {
    @Bindable var authVM: AuthViewModel
    @State private var showDemoInfo = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            // Brand background
            araDarkBg.ignoresSafeArea()

            // Ambient gradient blobs
            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(x: -60, y: -60, width: 340, height: 340)),
                    with: .color(araGreen.opacity(0.07))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width - 180, y: size.height * 0.2, width: 300, height: 300)),
                    with: .color(Color.blue.opacity(0.04))
                )
                context.fill(
                    Path(ellipseIn: CGRect(x: size.width * 0.1, y: size.height - 220, width: 260, height: 260)),
                    with: .color(araGreen.opacity(0.05))
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                brandMark
                    .padding(.bottom, 48)

                Spacer()

                signInCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 52)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.72, dampingFraction: 0.86).delay(0.08)) {
                appeared = true
            }
        }
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

    // MARK: - Brand Mark

    private var brandMark: some View {
        VStack(spacing: 28) {
            // Logomark
            ZStack {
                // Glow halo
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(araGreen.opacity(0.18))
                    .frame(width: 96, height: 96)
                    .blur(radius: 16)

                // Icon tile
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [araGreen, araGreen.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 0.5)
                    }
                    .frame(width: 80, height: 80)
                    .shadow(color: araGreen.opacity(0.4), radius: 20, y: 8)

                Image(systemName: "building.2.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(araDarkBg)
            }
            .scaleEffect(appeared ? 1 : 0.78)
            .opacity(appeared ? 1 : 0)
            .animation(.spring(response: 0.64, dampingFraction: 0.72).delay(0.1), value: appeared)

            // Wordmark
            VStack(spacing: 6) {
                Text("ARA Property Services")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(-0.3)

                Text("ARAPS Mobile")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(araGreen.opacity(0.85))
                    .tracking(1.4)
                    .textCase(.uppercase)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.85).delay(0.2), value: appeared)
        }
    }

    // MARK: - Sign-In Card

    private var signInCard: some View {
        VStack(spacing: 10) {

            // Section label
            Text("Sign in to continue")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.3))
                .textCase(.uppercase)
                .tracking(1.2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
                .padding(.bottom, 2)

            // WorkOS
            ARAAuthButton(
                label: authVM.isLoading ? "Signing in…" : "Sign in with AuthKit",
                icon: "lock.shield.fill",
                style: .primary,
                isLoading: authVM.isLoading
            ) {
                Task { await authVM.signInWithWorkOS() }
            }

            // Apple
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { _ in
                Task { await authVM.signInWithApple() }
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 54)
            .clipShape(.rect(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 0.5)
            }
            .disabled(authVM.isLoading)

            // Biometrics
            biometricRow

            // Divider
            HStack(spacing: 0) {
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)
                Text("or")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.22))
                    .padding(.horizontal, 14)
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 0.5)
            }
            .padding(.vertical, 4)

            // Demo
            ARAAuthButton(
                label: "View Demo",
                icon: "eye",
                style: .ghost,
                isLoading: false
            ) {
                showDemoInfo = true
            }

            // Trust badges
            trustBadges
                .padding(.top, 12)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.6))
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.07), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.18), .white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
        }
        .shadow(color: .black.opacity(0.35), radius: 32, y: 12)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 24)
        .animation(.spring(response: 0.68, dampingFraction: 0.86).delay(0.3), value: appeared)
    }

    @ViewBuilder
    private var biometricRow: some View {
        if UserDefaults.standard.bool(forKey: "biometricUserId") {
            ARAAuthButton(
                label: "Sign in with \(authVM.biometricService.biometryName)",
                icon: authVM.biometricService.biometryIcon,
                style: .secondary,
                isLoading: false
            ) {
                Task { await authVM.signInWithBiometrics() }
            }
            .onAppear { authVM.biometricService.checkAvailability() }
        }
    }

    private var trustBadges: some View {
        HStack(spacing: 20) {
            TrustBadge(icon: "checkmark.shield.fill", label: "Enterprise SSO")
            TrustBadge(icon: "key.fill", label: "Passwordless")
            TrustBadge(icon: "lock.fill", label: "MFA Ready")
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shared Button Component

enum ARAAuthButtonStyle { case primary, secondary, ghost }

struct ARAAuthButton: View {
    let label: String
    let icon: String
    let style: ARAAuthButtonStyle
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(style == .primary ? araDarkBg : .white)
                        .scaleEffect(0.85)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .foregroundStyle(foreground)
            .background { backgroundShape }
            .clipShape(.rect(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: 0.5)
            }
        }
        .disabled(isLoading)
    }

    private var foreground: Color {
        switch style {
        case .primary: return araDarkBg
        case .secondary, .ghost: return .white.opacity(0.8)
        }
    }

    @ViewBuilder
    private var backgroundShape: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(araGreen)
        case .secondary:
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.09))
        case .ghost:
            RoundedRectangle(cornerRadius: 14, style: .continuous).fill(.white.opacity(0.04))
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary: return araGreen.opacity(0.5)
        case .secondary: return .white.opacity(0.13)
        case .ghost: return .white.opacity(0.09)
        }
    }
}

// MARK: - Trust Badge

struct TrustBadge: View {
    let icon: String
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(araGreen.opacity(0.6))
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.25))
        }
    }
}

// MARK: - Demo Info Sheet

struct DemoInfoSheet: View {
    let onContinue: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        ZStack {
            araDarkBg.ignoresSafeArea()

            Canvas { context, size in
                context.fill(
                    Path(ellipseIn: CGRect(x: -40, y: -40, width: 240, height: 240)),
                    with: .color(araGreen.opacity(0.06))
                )
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(.white.opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 28)

                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(araGreen.opacity(0.12))
                        .frame(width: 68, height: 68)
                    Image(systemName: "eye.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(araGreen)
                }
                .padding(.bottom, 20)
                .opacity(appeared ? 1 : 0)
                .scaleEffect(appeared ? 1 : 0.8)
                .animation(.spring(response: 0.55, dampingFraction: 0.72), value: appeared)

                // Header
                VStack(spacing: 8) {
                    Text("Demo Mode")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Explore ARAPS Mobile with\npre-loaded sample data.")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(.bottom, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.08), value: appeared)

                // Feature list
                VStack(spacing: 0) {
                    DemoFeatureRow(icon: "house.fill", label: "Executive Dashboard", sub: "KPIs, safety alerts, team overview")
                    DemoFeatureRow(icon: "checkmark.square.fill", label: "Task Management", sub: "Field tasks and scheduling")
                    DemoFeatureRow(icon: "exclamationmark.bubble.fill", label: "Issue Tracking", sub: "Report and monitor facility issues")
                    DemoFeatureRow(icon: "qrcode.viewfinder", label: "CleanOps", sub: "QR scanning and alert workflow")
                    DemoFeatureRow(icon: "message.fill", label: "AskARA AI", sub: "AI operations assistant")
                }
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.white.opacity(0.05))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(.white.opacity(0.08), lineWidth: 0.5)
                        }
                }
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.16), value: appeared)

                Spacer().frame(height: 28)

                // CTA
                VStack(spacing: 10) {
                    Button {
                        onContinue()
                    } label: {
                        Text("Continue to Demo")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(araDarkBg)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(araGreen)
                            .clipShape(.rect(cornerRadius: 14, style: .continuous))
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 14))
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(height: 44)
                }
                .padding(.horizontal, 20)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.55, dampingFraction: 0.85).delay(0.24), value: appeared)

                Spacer().frame(height: 16)
            }
        }
        .onAppear { appeared = true }
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(araDarkBg)
    }
}

struct DemoFeatureRow: View {
    let icon: String
    let label: String
    let sub: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(araGreen.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(araGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
                Text(sub)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.35))
            }
            Spacer()
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 14)
        }
    }
}
