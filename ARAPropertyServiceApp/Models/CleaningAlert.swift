import Foundation
import SwiftData

nonisolated enum AlertIssueType: String, Codable, CaseIterable, Sendable {
    case cleaning, maintenance, safety, security, other

    var label: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .cleaning: return "sparkles"
        case .maintenance: return "wrench.and.screwdriver.fill"
        case .safety: return "exclamationmark.shield.fill"
        case .security: return "lock.shield.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

nonisolated enum AlertUrgency: String, Codable, CaseIterable, Sendable {
    case low, normal, high

    var label: String { rawValue.capitalized }
}

nonisolated enum AlertStatus: String, Codable, CaseIterable, Sendable {
    case pending, acknowledged, inProgress = "in_progress", resolved, closed

    var label: String {
        switch self {
        case .pending: return "Pending"
        case .acknowledged: return "Acknowledged"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        }
    }
}

@Model
final class CleaningAlert {
    var id: UUID
    var alertId: String
    var locationName: String
    var issueTypeRaw: String
    var urgencyRaw: String
    var statusRaw: String
    var alertDescription: String
    var reporterName: String
    var reporterContact: String
    var reportedAt: Date

    var issueType: AlertIssueType {
        get { AlertIssueType(rawValue: issueTypeRaw) ?? .other }
        set { issueTypeRaw = newValue.rawValue }
    }

    var urgency: AlertUrgency {
        get { AlertUrgency(rawValue: urgencyRaw) ?? .normal }
        set { urgencyRaw = newValue.rawValue }
    }

    var alertStatus: AlertStatus {
        get { AlertStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        alertId: String,
        locationName: String,
        issueType: AlertIssueType,
        urgency: AlertUrgency = .normal,
        status: AlertStatus = .pending,
        alertDescription: String,
        reporterName: String,
        reporterContact: String,
        reportedAt: Date = .now
    ) {
        self.id = UUID()
        self.alertId = alertId
        self.locationName = locationName
        self.issueTypeRaw = issueType.rawValue
        self.urgencyRaw = urgency.rawValue
        self.statusRaw = status.rawValue
        self.alertDescription = alertDescription
        self.reporterName = reporterName
        self.reporterContact = reporterContact
        self.reportedAt = reportedAt
    }
}
