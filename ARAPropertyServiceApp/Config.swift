import Foundation

enum AppConfig {
    static let workOSClientId = ProcessInfo.processInfo.environment["WORKOS_CLIENT_ID"]
        ?? Bundle.main.infoDictionary?["WORKOS_CLIENT_ID"] as? String
        ?? ""

    static let convexDeploymentURL = ProcessInfo.processInfo.environment["CONVEX_DEPLOYMENT_URL"]
        ?? Bundle.main.infoDictionary?["CONVEX_DEPLOYMENT_URL"] as? String
        ?? ""

    static let openAIApiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
        ?? Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String
        ?? ""

    static let redirectURI = "araps://auth/callback"
    static let callbackURLScheme = "araps"

    static let workOSAuthorizeURL = "https://api.workos.com/user_management/authorize"
    static let workOSTokenURL = "https://api.workos.com/user_management/authenticate"
    static let workOSRefreshURL = "https://api.workos.com/user_management/authenticate"
    static let workOSUserURL = "https://api.workos.com/user_management/me"

    static let universalLinkDomain = "araps.aliaslabs.ai"
    static let deepLinkScheme = "araps"

    static var isConfigured: Bool {
        !workOSClientId.isEmpty && !convexDeploymentURL.isEmpty
    }
}
