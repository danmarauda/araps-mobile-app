import Foundation
import SwiftData

nonisolated enum TaskPriority: String, Codable, CaseIterable, Sendable {
    case low, medium, high, urgent

    var label: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .low: return "arrow.down.circle.fill"
        case .medium: return "minus.circle.fill"
        case .high: return "arrow.up.circle.fill"
        case .urgent: return "exclamationmark.triangle.fill"
        }
    }
}

nonisolated enum TaskStatus: String, Codable, CaseIterable, Sendable {
    case pending, assigned, inProgress = "in-progress", completed, cancelled

    var label: String {
        switch self {
        case .pending: return "Pending"
        case .assigned: return "Assigned"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    var systemImage: String {
        switch self {
        case .pending: return "clock"
        case .assigned: return "person.badge.clock"
        case .inProgress: return "arrow.trianglehead.clockwise.rotate.90"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
}

@Model
final class FieldTask {
    var id: UUID
    var taskNumber: String
    var title: String
    var taskDescription: String?
    var taskType: String
    var priorityRaw: String
    var statusRaw: String
    var facilityName: String
    var assignedWorker: String
    var scheduledStart: Date
    var scheduledEnd: Date
    var estimatedDuration: Int
    var instructions: String?
    var safetyRequirements: String?

    var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var taskStatus: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    init(
        taskNumber: String,
        title: String,
        taskDescription: String? = nil,
        taskType: String,
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        facilityName: String,
        assignedWorker: String,
        scheduledStart: Date,
        scheduledEnd: Date,
        estimatedDuration: Int,
        instructions: String? = nil,
        safetyRequirements: String? = nil
    ) {
        self.id = UUID()
        self.taskNumber = taskNumber
        self.title = title
        self.taskDescription = taskDescription
        self.taskType = taskType
        self.priorityRaw = priority.rawValue
        self.statusRaw = status.rawValue
        self.facilityName = facilityName
        self.assignedWorker = assignedWorker
        self.scheduledStart = scheduledStart
        self.scheduledEnd = scheduledEnd
        self.estimatedDuration = estimatedDuration
        self.instructions = instructions
        self.safetyRequirements = safetyRequirements
    }
}
