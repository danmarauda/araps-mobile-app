import SwiftUI

enum ARATheme {
    static let primaryBlue = Color(red: 30/255, green: 95/255, blue: 153/255)
    static let accentOrange = Color(red: 204/255, green: 122/255, blue: 0/255)
    static let highlightGreen = Color(red: 159/255, green: 232/255, blue: 112/255)

    static let priorityLow = Color.blue
    static let priorityMedium = Color.orange
    static let priorityHigh = Color.red
    static let priorityCritical = Color(red: 0.7, green: 0, blue: 0)

    static let statusOpen = Color.blue
    static let statusInProgress = Color.orange
    static let statusResolved = Color.green
    static let statusClosed = Color.secondary

    static func priorityColor(_ priority: IssuePriority) -> Color {
        switch priority {
        case .low: return priorityLow
        case .medium: return priorityMedium
        case .high: return priorityHigh
        case .critical: return priorityCritical
        }
    }

    static func statusColor(_ status: IssueStatus) -> Color {
        switch status {
        case .open: return statusOpen
        case .inProgress: return statusInProgress
        case .resolved: return statusResolved
        case .closed: return statusClosed
        }
    }

    static func taskPriorityColor(_ priority: TaskPriority) -> Color {
        switch priority {
        case .low: return priorityLow
        case .medium: return priorityMedium
        case .high: return priorityHigh
        case .urgent: return priorityCritical
        }
    }

    static func taskStatusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .pending: return .secondary
        case .assigned: return .blue
        case .inProgress: return .orange
        case .completed: return .green
        case .cancelled: return .red
        }
    }

    static func alertUrgencyColor(_ urgency: AlertUrgency) -> Color {
        switch urgency {
        case .low: return .blue
        case .normal: return .orange
        case .high: return .red
        }
    }
}
