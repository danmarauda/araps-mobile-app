import Foundation
import ConvexMobile
import AuthenticationServices
import CryptoKit

nonisolated struct WorkOSAuthResult: Sendable {
    let user: WorkOSUser
    let accessToken: String
    let refreshToken: String?
    let idToken: String?
    let organizationId: String?
}

private let _workOSClientId = ProcessInfo.processInfo.environment["WORKOS_CLIENT_ID"] ?? ""
private let _redirectURI = "araps://auth/callback"
private let _callbackScheme = "araps"
private let _authorizeURL = "https://api.workos.com/user_management/authorize"
private let _tokenURL = "https://api.workos.com/user_management/authenticate"
private let _refreshURL = "https://api.workos.com/user_management/authenticate"

final class WorkOSAuthProvider: NSObject, @unchecked Sendable {
    private let keychain = KeychainService.shared
    private var onIdTokenCallback: (@Sendable (String?) -> Void)?
}

extension WorkOSAuthProvider: ConvexMobile.AuthProvider {
    typealias T = WorkOSAuthResult

    func login(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> WorkOSAuthResult {
        onIdTokenCallback = onIdToken

        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        let authCode = try await startAuthSession(codeChallenge: codeChallenge)
        let result = try await exchangeCodeForTokens(code: authCode, codeVerifier: codeVerifier)

        persistTokens(result)

        let token = result.idToken ?? result.accessToken
        onIdToken(token)

        return result
    }

    func logout() async throws {
        onIdTokenCallback?(nil)
        onIdTokenCallback = nil
        keychain.clearAll()
    }

    func loginFromCache(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> WorkOSAuthResult {
        onIdTokenCallback = onIdToken

        guard let accessToken = keychain.accessToken,
              let userId = keychain.userId else {
            throw WorkOSError.refreshFailed
        }

        if let refreshToken = keychain.refreshToken {
            let refreshed = try await refreshAccessToken(refreshToken: refreshToken)
            let token = refreshed.idToken ?? refreshed.accessToken
            onIdToken(token)
            return refreshed
        }

        let cachedResult = WorkOSAuthResult(
            user: WorkOSUser(
                id: userId,
                email: "",
                firstName: nil,
                lastName: nil,
                profilePictureUrl: nil
            ),
            accessToken: accessToken,
            refreshToken: keychain.refreshToken,
            idToken: keychain.idToken,
            organizationId: keychain.organizationId
        )

        let token = cachedResult.idToken ?? cachedResult.accessToken
        onIdToken(token)
        return cachedResult
    }

    func extractIdToken(from authResult: WorkOSAuthResult) -> String {
        authResult.idToken ?? authResult.accessToken
    }
}

extension WorkOSAuthProvider {
    private func startAuthSession(codeChallenge: String) async throws -> String {
        var components = URLComponents(string: _authorizeURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: _workOSClientId),
            URLQueryItem(name: "redirect_uri", value: _redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "provider", value: "authkit"),
        ]

        guard let authURL = components.url else {
            throw WorkOSError.missingConfiguration
        }

        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: _callbackScheme
            ) { callbackURL, error in
                if let error {
                    let nsError = error as NSError
                    if nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                        continuation.resume(throwing: WorkOSError.userCancelled)
                    } else {
                        continuation.resume(throwing: WorkOSError.authSessionFailed(error.localizedDescription))
                    }
                    return
                }

                guard let callbackURL,
                      let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
                      let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: WorkOSError.invalidCallbackURL)
                    return
                }

                continuation.resume(returning: code)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
    }

    private func exchangeCodeForTokens(code: String, codeVerifier: String) async throws -> WorkOSAuthResult {
        var request = URLRequest(url: URL(string: _tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "client_id": _workOSClientId,
            "code": code,
            "code_verifier": codeVerifier,
            "grant_type": "authorization_code",
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse, response.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw WorkOSError.tokenExchangeFailed(errorBody)
        }

        let tokenResponse = try JSONDecoder().decode(WorkOSAuthenticateResponse.self, from: data)

        return WorkOSAuthResult(
            user: tokenResponse.user ?? WorkOSUser(id: "", email: "", firstName: nil, lastName: nil, profilePictureUrl: nil),
            accessToken: tokenResponse.accessToken ?? "",
            refreshToken: tokenResponse.refreshToken,
            idToken: nil,
            organizationId: tokenResponse.organizationId
        )
    }

    private func refreshAccessToken(refreshToken: String) async throws -> WorkOSAuthResult {
        var request = URLRequest(url: URL(string: _refreshURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "client_id": _workOSClientId,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken,
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw WorkOSError.refreshFailed
        }

        let refreshResponse = try JSONDecoder().decode(WorkOSRefreshResponse.self, from: data)

        let userId = keychain.userId ?? ""
        let result = WorkOSAuthResult(
            user: WorkOSUser(id: userId, email: "", firstName: nil, lastName: nil, profilePictureUrl: nil),
            accessToken: refreshResponse.accessToken,
            refreshToken: refreshResponse.refreshToken,
            idToken: nil,
            organizationId: keychain.organizationId
        )

        persistTokens(result)
        return result
    }

    private func persistTokens(_ result: WorkOSAuthResult) {
        keychain.accessToken = result.accessToken
        if let refresh = result.refreshToken {
            keychain.refreshToken = refresh
        }
        if let idToken = result.idToken {
            keychain.idToken = idToken
        }
        if !result.user.id.isEmpty {
            keychain.userId = result.user.id
        }
        if let orgId = result.organizationId {
            keychain.organizationId = orgId
        }
    }

    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash)
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}

extension WorkOSAuthProvider: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            ASPresentationAnchor()
        }
    }
}
