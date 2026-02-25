import Foundation
import AuthenticationServices
import CryptoKit

nonisolated struct WorkOSTokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?
    let tokenType: String?
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}

nonisolated struct WorkOSAuthenticateResponse: Codable, Sendable {
    let user: WorkOSUser?
    let accessToken: String?
    let refreshToken: String?
    let organizationId: String?

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case organizationId = "organization_id"
    }
}

nonisolated struct WorkOSUser: Codable, Sendable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let profilePictureUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case profilePictureUrl = "profile_picture_url"
    }
}

nonisolated struct WorkOSRefreshResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let idToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
}

nonisolated enum WorkOSError: Error, Sendable {
    case missingConfiguration
    case authSessionFailed(String)
    case tokenExchangeFailed(String)
    case refreshFailed
    case invalidCallbackURL
    case userCancelled
}
