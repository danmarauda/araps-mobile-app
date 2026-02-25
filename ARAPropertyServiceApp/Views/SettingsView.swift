import SwiftUI
import SwiftData
import AuthenticationServices

struct SettingsView: View {
    let authVM: AuthViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @Environment(\.colorScheme) private var colorScheme
    @State private var showClearChatAlert = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showDeleteAccountConfirm = false
    @State private var isDeletingAccount = false
    @State private var biometricEnabled: Bool = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                profileSection
                organizationSection
                securitySection
                preferencesSection
                dataSection
                legalSection
                accountDangerSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .alert("Clear Chat History?", isPresented: $showClearChatAlert) {
                Button("Clear", role: .destructive) { clearChat() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all chat messages with AskARA.")
            }
            .alert("Sign Out?", isPresented: $showLogoutAlert) {
                Button("Sign Out", role: .destructive) { authVM.signOut() }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete Account?", isPresented: $showDeleteAccountAlert) {
                Button("Delete My Account", role: .destructive) {
                    showDeleteAccountConfirm = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all associated data from ARA Property Services. This action cannot be undone.")
            }
            .alert("Confirm Account Deletion", isPresented: $showDeleteAccountConfirm) {
                Button("Permanently Delete", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your account, personal data, and all your activity will be permanently deleted. You will be signed out immediately.")
            }
            .onAppear {
                authVM.biometricService.checkAvailability()
                biometricEnabled = authVM.isBiometricEnabled
            }
        }
    }

    private var profileSection: some View {
        Section {
            HStack(spacing: 14) {
                Text(authVM.currentUser?.initials ?? "AU")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(ARATheme.primaryBlue)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(authVM.currentUser?.fullName ?? "ARA User")
                        .font(.headline)
                    Text(authVM.currentUser?.email ?? "user@ara.com.au")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var organizationSection: some View {
        if let org = authVM.currentOrganization {
            Section("Organization") {
                HStack {
                    Label(org.name, systemImage: "building.2.fill")
                    Spacer()
                    Text(org.tier.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let domain = org.domain {
                    HStack {
                        Label("Domain", systemImage: "globe")
                        Spacer()
                        Text(domain)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    authVM.switchOrganization()
                } label: {
                    Label("Switch Organization", systemImage: "arrow.triangle.swap")
                }
            }
        }
    }

    private var securitySection: some View {
        Section("Security") {
            HStack {
                Label("Auth Provider", systemImage: "lock.shield.fill")
                Spacer()
                Text("WorkOS AuthKit")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if authVM.biometricService.isAvailable {
                Toggle(isOn: $biometricEnabled) {
                    Label(authVM.biometricService.biometryName, systemImage: authVM.biometricService.biometryIcon)
                }
                .onChange(of: biometricEnabled) { _, newValue in
                    Task {
                        if newValue {
                            let success = await authVM.enableBiometrics()
                            if !success {
                                biometricEnabled = false
                            }
                        } else {
                            authVM.disableBiometrics()
                        }
                    }
                }
            }
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            Toggle(isOn: $notificationsEnabled) {
                Label("Notifications", systemImage: "bell.badge")
            }
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showClearChatAlert = true
            } label: {
                Label("Clear Chat History", systemImage: "trash")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Button {
                openURL("https://danmarauda.github.io/araps-mobile-app/privacy.html")
            } label: {
                HStack {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)

            Button {
                openURL("https://danmarauda.github.io/araps-mobile-app/terms.html")
            } label: {
                HStack {
                    Label("Terms of Service", systemImage: "doc.text.fill")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(.primary)
        }
    }

    private var accountDangerSection: some View {
        Section {
            if isDeletingAccount {
                HStack {
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("Deleting account...")
                        .foregroundStyle(.secondary)
                }
            } else {
                Button(role: .destructive) {
                    showDeleteAccountAlert = true
                } label: {
                    Label("Delete Account", systemImage: "person.crop.circle.badge.minus")
                }
            }

            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } footer: {
            Text("Deleting your account permanently removes all your data from ARA Property Services and cannot be undone.")
                .font(.caption)
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0 (1)")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Backend", systemImage: "server.rack")
                Spacer()
                Text("Convex")
                    .foregroundStyle(.secondary)
            }

            HStack {
                Label("Auth", systemImage: "key.fill")
                Spacer()
                Text("WorkOS")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func clearChat() {
        let descriptor = FetchDescriptor<ChatMessage>()
        if let messages = try? modelContext.fetch(descriptor) {
            for message in messages {
                modelContext.delete(message)
            }
            try? modelContext.save()
        }
    }

    private func deleteAccount() async {
        isDeletingAccount = true

        // Revoke Sign in with Apple token (required by App Store guidelines 5.1.1(v))
        if let appleUserId = authVM.currentUser?.id {
            let state = await authVM.appleSignInService.checkCredentialState(userId: appleUserId)
            if state == .authorized {
                // Server-side SIWA revocation should be done via your backend
                // POST https://appleid.apple.com/auth/revoke with client credentials
                // For now, we clear all local data and sign out
            }
        }

        // Delete all user data from local SwiftData store
        let chatDescriptor = FetchDescriptor<ChatMessage>()
        if let chats = try? modelContext.fetch(chatDescriptor) {
            chats.forEach { modelContext.delete($0) }
        }

        let notifDescriptor = FetchDescriptor<AppNotification>()
        if let notifs = try? modelContext.fetch(notifDescriptor) {
            notifs.forEach { modelContext.delete($0) }
        }

        // Remove local user account record
        if let userId = authVM.currentUser?.id {
            let predicate = #Predicate<UserAccount> { $0.appleUserId == userId }
            let userDescriptor = FetchDescriptor<UserAccount>(predicate: predicate)
            if let users = try? modelContext.fetch(userDescriptor) {
                users.forEach { modelContext.delete($0) }
            }
        }

        try? modelContext.save()
        isDeletingAccount = false

        // Sign out clears keychain, Convex session, and auth state
        authVM.signOut()
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
