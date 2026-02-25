import SwiftUI
import SwiftData
import AuthenticationServices

nonisolated enum AppAuthState: Sendable {
    case loading
    case unauthenticated
    case authenticated
    case onboarding
    case organizationSelection
}

nonisolated struct AuthenticatedUser: Sendable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let profilePictureUrl: String?
    let organizationId: String?

    var fullName: String { "\(firstName) \(lastName)" }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }
}

@Observable
@MainActor
class AuthViewModel {
    var authState: AppAuthState = .loading
    var currentUser: AuthenticatedUser?
    var currentOrganization: Organization?
    var availableOrganizations: [Organization] = []

    var isLoading = false
    var errorMessage: String?
    var showError = false

    let biometricService = BiometricAuthService()
    let appleSignInService = AppleSignInService()
    private let convex = ConvexService.shared
    private let keychain = KeychainService.shared

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func checkAuthState() {
        guard keychain.accessToken != nil, keychain.userId != nil else {
            authState = .unauthenticated
            return
        }

        Task {
            let result = await convex.loginFromCache()
            switch result {
            case .success(let authResult):
                handleAuthSuccess(authResult)
            case .failure:
                authState = .unauthenticated
            }
        }
    }

    func signInWithWorkOS() async {
        isLoading = true
        defer { isLoading = false }

        let result = await convex.login()
        switch result {
        case .success(let authResult):
            handleAuthSuccess(authResult)
        case .failure(let error):
            if case WorkOSError.userCancelled = error {
                return
            }
            showErrorMessage("Sign in failed: \(error.localizedDescription)")
        }
    }

    func signInWithApple() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await appleSignInService.signIn()

            let user = AuthenticatedUser(
                id: result.userId,
                email: result.email ?? "\(result.userId)@privaterelay.appleid.com",
                firstName: result.firstName ?? "ARA",
                lastName: result.lastName ?? "User",
                profilePictureUrl: nil,
                organizationId: nil
            )
            currentUser = user

            if let modelContext {
                syncAppleUserToLocal(result: result, modelContext: modelContext)
            }

            authState = .authenticated
        } catch AppleSignInError.cancelled {
            // User cancelled — no error to show
        } catch {
            showErrorMessage("Apple Sign-In failed: \(error.localizedDescription)")
        }
    }

    private func syncAppleUserToLocal(result: AppleSignInResult, modelContext: ModelContext) {
        let descriptor = FetchDescriptor<UserAccount>()
        let existingUsers = (try? modelContext.fetch(descriptor)) ?? []

        if let existing = existingUsers.first(where: { $0.appleUserId == result.userId }) {
            existing.lastLoginAt = .now
            if let firstName = result.firstName { existing.firstName = firstName }
            if let lastName = result.lastName { existing.lastName = lastName }
        } else {
            let newUser = UserAccount(
                email: result.email ?? "\(result.userId)@privaterelay.appleid.com",
                firstName: result.firstName ?? "ARA",
                lastName: result.lastName ?? "User",
                role: .fieldWorker,
                authProvider: .apple,
                appleUserId: result.userId
            )
            modelContext.insert(newUser)

            let defaultOrg = getOrCreateDefaultOrganization(modelContext: modelContext)
            let membership = OrganizationMembership(
                userId: newUser.id,
                organizationId: defaultOrg.id,
                role: .member
            )
            modelContext.insert(membership)
            newUser.organizationId = defaultOrg.id

            currentOrganization = defaultOrg
        }

        try? modelContext.save()

        if currentOrganization == nil {
            loadOrganization(orgIdString: nil)
        }
    }

    func signInWithBiometrics() async {
        biometricService.checkAvailability()
        guard biometricService.isAvailable else {
            showErrorMessage("Biometric authentication is not available")
            return
        }

        guard keychain.accessToken != nil, keychain.userId != nil else {
            showErrorMessage("No previous session found. Please sign in first.")
            return
        }

        isLoading = true
        let success = await biometricService.authenticate()
        isLoading = false

        if success {
            let result = await convex.loginFromCache()
            switch result {
            case .success(let authResult):
                handleAuthSuccess(authResult)
            case .failure:
                showErrorMessage("Session expired. Please sign in again.")
                authState = .unauthenticated
            }
        } else if let errorMsg = biometricService.errorMessage {
            showErrorMessage(errorMsg)
        }
    }

    func signOut() {
        Task {
            await convex.logout()
        }
        UserDefaults.standard.removeObject(forKey: "biometricUserId")
        currentUser = nil
        currentOrganization = nil
        availableOrganizations = []
        authState = .unauthenticated
    }

    func enableBiometrics() async -> Bool {
        guard currentUser != nil else { return false }
        biometricService.checkAvailability()
        guard biometricService.isAvailable else { return false }

        let success = await biometricService.authenticate(reason: "Enable \(biometricService.biometryName) for quick sign in")
        if success {
            UserDefaults.standard.set(true, forKey: "biometricUserId")
        }
        return success
    }

    func disableBiometrics() {
        UserDefaults.standard.removeObject(forKey: "biometricUserId")
    }

    var isBiometricEnabled: Bool {
        UserDefaults.standard.bool(forKey: "biometricUserId")
    }

    func selectOrganization(_ org: Organization) {
        currentOrganization = org
        keychain.organizationId = org.id.uuidString
        authState = .authenticated
    }

    func switchOrganization() {
        guard let modelContext else { return }

        let orgDescriptor = FetchDescriptor<Organization>()
        let allOrgs = (try? modelContext.fetch(orgDescriptor)) ?? []
        availableOrganizations = allOrgs

        if availableOrganizations.count > 1 {
            authState = .organizationSelection
        }
    }

    private func handleAuthSuccess(_ authResult: WorkOSAuthResult) {
        let user = authResult.user
        let authenticatedUser = AuthenticatedUser(
            id: user.id,
            email: user.email,
            firstName: user.firstName ?? "ARA",
            lastName: user.lastName ?? "User",
            profilePictureUrl: user.profilePictureUrl,
            organizationId: authResult.organizationId
        )
        currentUser = authenticatedUser

        if !user.id.isEmpty {
            syncUserToLocal(user: user, organizationId: authResult.organizationId)
        }

        loadOrganization(orgIdString: authResult.organizationId)
        authState = .authenticated
    }

    private func syncUserToLocal(user: WorkOSUser, organizationId: String?) {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<UserAccount>()
        let existingUsers = (try? modelContext.fetch(descriptor)) ?? []

        if let existing = existingUsers.first(where: { $0.email.lowercased() == user.email.lowercased() }) {
            existing.firstName = user.firstName ?? existing.firstName
            existing.lastName = user.lastName ?? existing.lastName
            existing.appleUserId = user.id
            existing.lastLoginAt = .now
            existing.authProvider = .workos
        } else {
            let newUser = UserAccount(
                email: user.email,
                firstName: user.firstName ?? "ARA",
                lastName: user.lastName ?? "User",
                role: .fieldWorker,
                authProvider: .workos,
                appleUserId: user.id
            )
            modelContext.insert(newUser)

            let defaultOrg = getOrCreateDefaultOrganization(modelContext: modelContext)
            let membership = OrganizationMembership(
                userId: newUser.id,
                organizationId: defaultOrg.id,
                role: .member
            )
            modelContext.insert(membership)
            newUser.organizationId = defaultOrg.id
        }

        try? modelContext.save()
    }

    private func loadOrganization(orgIdString: String?) {
        guard let modelContext else { return }

        if let orgIdString, let uuid = UUID(uuidString: orgIdString) {
            let predicate = #Predicate<Organization> { $0.id == uuid }
            let descriptor = FetchDescriptor<Organization>(predicate: predicate)
            currentOrganization = try? modelContext.fetch(descriptor).first
        }

        if currentOrganization == nil {
            let descriptor = FetchDescriptor<Organization>(
                predicate: #Predicate { $0.slug == "ara-property-services" }
            )
            currentOrganization = try? modelContext.fetch(descriptor).first
        }
    }

    private func getOrCreateDefaultOrganization(modelContext: ModelContext) -> Organization {
        let descriptor = FetchDescriptor<Organization>(
            predicate: #Predicate { $0.slug == "ara-property-services" }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let org = Organization(
            name: "ARA Property Services",
            slug: "ara-property-services",
            domain: "ara.com.au",
            tier: .enterprise
        )
        modelContext.insert(org)
        return org
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }

#if DEBUG
    func devBypassLogin() {
        let devUser = AuthenticatedUser(
            id: "dev-bypass-user",
            email: "dev@ara.com.au",
            firstName: "Dev",
            lastName: "User",
            profilePictureUrl: nil,
            organizationId: nil
        )
        currentUser = devUser

        if let modelContext {
            let org = getOrCreateDefaultOrganization(modelContext: modelContext)
            currentOrganization = org
        }

        authState = .authenticated
    }
#endif
}
