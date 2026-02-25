import SwiftUI
import SwiftData

struct SettingsView: View {
    let authVM: AuthViewModel
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @Environment(\.colorScheme) private var colorScheme
    @State private var showClearChatAlert = false
    @State private var showLogoutAlert = false
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

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text("1.0.0")
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

            Button(role: .destructive) {
                showLogoutAlert = true
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
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
}
