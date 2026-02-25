import AuthenticationServices
import SwiftUI

nonisolated struct AppleSignInResult: Sendable {
    let userId: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let identityToken: Data?
    let authorizationCode: Data?
}

@Observable
@MainActor
class AppleSignInService: NSObject {
    var isProcessing = false
    var errorMessage: String?

    private var continuation: CheckedContinuation<AppleSignInResult, Error>?

    func signIn() async throws -> AppleSignInResult {
        isProcessing = true
        defer { isProcessing = false }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    func checkCredentialState(userId: String) async -> ASAuthorizationAppleIDProvider.CredentialState {
        let provider = ASAuthorizationAppleIDProvider()
        do {
            return try await provider.credentialState(forUserID: userId)
        } catch {
            return .notFound
        }
    }
}

extension AppleSignInService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            Task { @MainActor in
                self.continuation?.resume(throwing: AppleSignInError.invalidCredential)
                self.continuation = nil
            }
            return
        }

        let result = AppleSignInResult(
            userId: appleIDCredential.user,
            email: appleIDCredential.email,
            firstName: appleIDCredential.fullName?.givenName,
            lastName: appleIDCredential.fullName?.familyName,
            identityToken: appleIDCredential.identityToken,
            authorizationCode: appleIDCredential.authorizationCode
        )

        Task { @MainActor in
            self.continuation?.resume(returning: result)
            self.continuation = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                self.continuation?.resume(throwing: AppleSignInError.cancelled)
            } else {
                self.continuation?.resume(throwing: error)
            }
            self.continuation = nil
        }
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            ?? ASPresentationAnchor()
    }
}

enum AppleSignInError: LocalizedError {
    case cancelled
    case invalidCredential
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .cancelled: return "Sign in was cancelled."
        case .invalidCredential: return "Invalid Apple credential received."
        case .notConfigured: return "Apple Sign-In is not configured for this app."
        }
    }
}
