import Foundation
import SwiftData

nonisolated enum UserRole: String, Codable, CaseIterable, Sendable {
    case ceo
    case execGeneralManager
    case stateManager
    case nationalOpsManager
    case accountManager
    case clientRelationshipMgr
    case finance
    case peopleSafety
    case cxCompliance
    case fieldWorker
    case supervisor
    case publicUser

    var label: String {
        switch self {
        case .ceo: return "CEO"
        case .execGeneralManager: return "Exec General Manager"
        case .stateManager: return "State Manager"
        case .nationalOpsManager: return "National Ops Manager"
        case .accountManager: return "Account Manager"
        case .clientRelationshipMgr: return "Client Relationship Mgr"
        case .finance: return "Finance"
        case .peopleSafety: return "People & Safety"
        case .cxCompliance: return "CX & Compliance"
        case .fieldWorker: return "Field Worker"
        case .supervisor: return "Supervisor"
        case .publicUser: return "Public"
        }
    }

    var systemImage: String {
        switch self {
        case .ceo, .execGeneralManager: return "crown.fill"
        case .stateManager, .nationalOpsManager: return "person.badge.shield.checkmark.fill"
        case .accountManager, .clientRelationshipMgr: return "person.crop.rectangle.fill"
        case .finance: return "dollarsign.circle.fill"
        case .peopleSafety: return "shield.checkered"
        case .cxCompliance: return "checkmark.seal.fill"
        case .fieldWorker: return "wrench.and.screwdriver.fill"
        case .supervisor: return "person.badge.clock.fill"
        case .publicUser: return "person.fill"
        }
    }
}

nonisolated enum AuthProvider: String, Codable, Sendable {
    case email
    case apple
    case passwordless
    case workos
}

@Model
final class UserAccount {
    var id: UUID
    var appleUserId: String?
    var email: String
    var firstName: String
    var lastName: String
    var roleRaw: String
    var authProviderRaw: String
    var organizationId: UUID?
    var isActive: Bool
    var isBiometricEnabled: Bool
    var lastLoginAt: Date?
    var createdAt: Date

    var role: UserRole {
        get { UserRole(rawValue: roleRaw) ?? .fieldWorker }
        set { roleRaw = newValue.rawValue }
    }

    var authProvider: AuthProvider {
        get { AuthProvider(rawValue: authProviderRaw) ?? .email }
        set { authProviderRaw = newValue.rawValue }
    }

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var initials: String {
        let first = firstName.prefix(1)
        let last = lastName.prefix(1)
        return "\(first)\(last)".uppercased()
    }

    init(
        email: String,
        firstName: String,
        lastName: String,
        role: UserRole = .fieldWorker,
        authProvider: AuthProvider = .email,
        appleUserId: String? = nil,
        organizationId: UUID? = nil
    ) {
        self.id = UUID()
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.roleRaw = role.rawValue
        self.authProviderRaw = authProvider.rawValue
        self.appleUserId = appleUserId
        self.organizationId = organizationId
        self.isActive = true
        self.isBiometricEnabled = false
        self.lastLoginAt = nil
        self.createdAt = .now
    }
}
