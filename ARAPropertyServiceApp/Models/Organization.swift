import Foundation
import SwiftData

nonisolated enum OrganizationTier: String, Codable, CaseIterable, Sendable {
    case enterprise
    case professional
    case standard
    case trial

    var label: String { rawValue.capitalized }

    var maxUsers: Int {
        switch self {
        case .enterprise: return 500
        case .professional: return 100
        case .standard: return 25
        case .trial: return 5
        }
    }
}

@Model
final class Organization {
    var id: UUID
    var name: String
    var slug: String
    var domain: String?
    var tierRaw: String
    var logoURL: String?
    var primaryColor: String?
    var isActive: Bool
    var createdAt: Date

    var tier: OrganizationTier {
        get { OrganizationTier(rawValue: tierRaw) ?? .trial }
        set { tierRaw = newValue.rawValue }
    }

    init(
        name: String,
        slug: String,
        domain: String? = nil,
        tier: OrganizationTier = .trial,
        logoURL: String? = nil,
        primaryColor: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.slug = slug
        self.domain = domain
        self.tierRaw = tier.rawValue
        self.logoURL = logoURL
        self.primaryColor = primaryColor
        self.isActive = true
        self.createdAt = .now
    }
}
