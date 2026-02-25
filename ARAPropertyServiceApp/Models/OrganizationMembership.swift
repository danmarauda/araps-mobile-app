import Foundation
import SwiftData

nonisolated enum MembershipRole: String, Codable, CaseIterable, Sendable {
    case owner
    case admin
    case manager
    case member
    case viewer

    var label: String { rawValue.capitalized }

    var canManageMembers: Bool {
        switch self {
        case .owner, .admin: return true
        default: return false
        }
    }

    var canManageSettings: Bool {
        switch self {
        case .owner, .admin, .manager: return true
        default: return false
        }
    }
}

@Model
final class OrganizationMembership {
    var id: UUID
    var userId: UUID
    var organizationId: UUID
    var membershipRoleRaw: String
    var isActive: Bool
    var joinedAt: Date

    var membershipRole: MembershipRole {
        get { MembershipRole(rawValue: membershipRoleRaw) ?? .member }
        set { membershipRoleRaw = newValue.rawValue }
    }

    init(
        userId: UUID,
        organizationId: UUID,
        role: MembershipRole = .member
    ) {
        self.id = UUID()
        self.userId = userId
        self.organizationId = organizationId
        self.membershipRoleRaw = role.rawValue
        self.isActive = true
        self.joinedAt = .now
    }
}
