import LocalAuthentication

@Observable
@MainActor
class BiometricAuthService {
    var isAvailable = false
    var biometryType: LABiometryType = .none
    var errorMessage: String?

    func checkAvailability() {
        let context = LAContext()
        var error: NSError?
        isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometryType = context.biometryType
        if let error {
            errorMessage = error.localizedDescription
        }
    }

    func authenticate(reason: String = "Authenticate to access ARAPS") async -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Use Password"
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            errorMessage = error?.localizedDescription ?? "Biometric authentication unavailable"
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return success
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    var biometryName: String {
        switch biometryType {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default: return "Biometrics"
        }
    }

    var biometryIcon: String {
        switch biometryType {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        default: return "lock.fill"
        }
    }
}
