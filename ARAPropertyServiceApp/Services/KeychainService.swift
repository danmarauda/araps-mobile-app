import Foundation
import Security

nonisolated final class KeychainService: Sendable {
    static let shared = KeychainService()

    private let serviceName = "app.rork.araps-mobile-app"

    private enum Keys {
        static let accessToken = "workos_access_token"
        static let refreshToken = "workos_refresh_token"
        static let idToken = "workos_id_token"
        static let userId = "workos_user_id"
        static let organizationId = "workos_organization_id"
    }

    var accessToken: String? {
        get { read(key: Keys.accessToken) }
        set { save(key: Keys.accessToken, value: newValue) }
    }

    var refreshToken: String? {
        get { read(key: Keys.refreshToken) }
        set { save(key: Keys.refreshToken, value: newValue) }
    }

    var idToken: String? {
        get { read(key: Keys.idToken) }
        set { save(key: Keys.idToken, value: newValue) }
    }

    var userId: String? {
        get { read(key: Keys.userId) }
        set { save(key: Keys.userId, value: newValue) }
    }

    var organizationId: String? {
        get { read(key: Keys.organizationId) }
        set { save(key: Keys.organizationId, value: newValue) }
    }

    func clearAll() {
        accessToken = nil
        refreshToken = nil
        idToken = nil
        userId = nil
        organizationId = nil
    }

    private func save(key: String, value: String?) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
        ]

        SecItemDelete(query as CFDictionary)

        guard let value, let data = value.data(using: .utf8) else { return }

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        SecItemAdd(addQuery as CFDictionary, nil)
    }

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
