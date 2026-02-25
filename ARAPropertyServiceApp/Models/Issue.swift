import Foundation
import SwiftData

nonisolated enum IssuePriority: String, Codable, CaseIterable, Sendable {
    case low, medium, high, critical

    var label: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "arrow.up.circle.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
}

nonisolated enum IssueStatus: String, Codable, CaseIterable, Sendable {
    case open, inProgress = "in-progress", resolved, closed

    var label: String {
        switch self {
        case .open: return "Open"
        case .inProgress: return "In Progress"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        }
    }

    var systemImage: String {
        switch self {
        case .open: return "circle"
        case .inProgress: return "arrow.trianglehead.clockwise.rotate.90"
        case .resolved: return "checkmark.circle.fill"
        case .closed: return "xmark.circle.fill"
        }
    }
}

nonisolated enum IssueCategory: String, Codable, CaseIterable, Sendable {
    case plumbing, hvac, structural, cleaning, electrical

    var label: String {
        switch self {
        case .hvac: return "HVAC"
        default: return rawValue.capitalized
        }
    }

    var systemImage: String {
        switch self {
        case .plumbing: return "drop.fill"
        case .hvac: return "fan.fill"
        case .structural: return "building.2.fill"
        case .cleaning: return "sparkles"
        case .electrical: return "bolt.fill"
        }
    }
}

@Model
final class Issue {
    var id: UUID
    var title: String
    var issueDescription: String
    var statusRaw: String
    var priorityRaw: String
    var categoryRaw: String
    var location: String
    var reportedBy: String
    var assignedTo: String?
    var reportedAt: Date
    var resolvedAt: Date?

    var status: IssueStatus {
        get { IssueStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    var priority: IssuePriority {
        get { IssuePriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var category: IssueCategory {
        get { IssueCategory(rawValue: categoryRaw) ?? .cleaning }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        title: String,
        issueDescription: String,
        status: IssueStatus = .open,
        priority: IssuePriority = .medium,
        category: IssueCategory = .cleaning,
        location: String,
        reportedBy: String,
        assignedTo: String? = nil,
        reportedAt: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.issueDescription = issueDescription
        self.statusRaw = status.rawValue
        self.priorityRaw = priority.rawValue
        self.categoryRaw = category.rawValue
        self.location = location
        self.reportedBy = reportedBy
        self.assignedTo = assignedTo
        self.reportedAt = reportedAt
    }
}
