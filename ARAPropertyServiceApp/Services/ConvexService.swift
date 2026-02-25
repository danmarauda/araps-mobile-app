import Foundation
import ConvexMobile
import Combine

private let _convexDeploymentURL = ProcessInfo.processInfo.environment["CONVEX_DEPLOYMENT_URL"] ?? ""

@Observable
@MainActor
final class ConvexService {
    static let shared = ConvexService()

    let client: ConvexClientWithAuth<WorkOSAuthResult>
    var isAuthenticated = false

    private init() {
        let provider = WorkOSAuthProvider()
        let url = _convexDeploymentURL.isEmpty ? "https://placeholder.convex.cloud" : _convexDeploymentURL
        client = ConvexClientWithAuth(deploymentUrl: url, authProvider: provider)
    }

    func login() async -> Result<WorkOSAuthResult, Error> {
        let result = await client.login()
        if case .success = result {
            isAuthenticated = true
        }
        return result
    }

    func loginFromCache() async -> Result<WorkOSAuthResult, Error> {
        let result = await client.loginFromCache()
        if case .success = result {
            isAuthenticated = true
        }
        return result
    }

    func logout() async {
        await client.logout()
        isAuthenticated = false
    }

    func subscribe<T: Decodable>(to query: String, yielding type: T.Type) -> AnyPublisher<T, ClientError> {
        client.subscribe(to: query, yielding: type)
    }

    func subscribe<T: Decodable>(to query: String, with args: [String: (any ConvexEncodable)?], yielding type: T.Type) -> AnyPublisher<T, ClientError> {
        client.subscribe(to: query, with: args, yielding: type)
    }

    func mutation(_ name: String) async throws {
        try await client.mutation(name)
    }

    func mutation(_ name: String, with args: [String: (any ConvexEncodable)?]) async throws {
        try await client.mutation(name, with: args)
    }

    func action(_ name: String) async throws {
        try await client.action(name)
    }

    func action(_ name: String, with args: [String: (any ConvexEncodable)?]) async throws {
        try await client.action(name, with: args)
    }
}
