import Foundation

nonisolated struct DashboardKPI: Identifiable, Sendable {
    let id = UUID()
    let label: String
    let value: String
    let sub: String
    let trend: TrendDirection
    let trendValue: String
    let good: Bool
    let icon: String
    let iconColor: String
}

nonisolated enum TrendDirection: Sendable {
    case up, down, neutral
}

nonisolated struct DashboardSafetyAlert: Identifiable, Sendable {
    let id: String
    let severity: AlertSeverity
    let site: String
    let message: String
    let time: String
    let resolved: Bool
}

nonisolated enum AlertSeverity: Sendable {
    case critical, warning, info
    
    var label: String {
        switch self {
        case .critical: return "Critical"
        case .warning: return "Warning"
        case .info: return "Info"
        }
    }
}

nonisolated struct DashboardMeeting: Identifiable, Sendable {
    let id: String
    let title: String
    let time: String
    let date: String
    let type: MeetingType
    let attendees: Int
    let location: String
}

nonisolated enum MeetingType: Sendable {
    case client, team, safety, review
    
    var label: String {
        switch self {
        case .client: return "Client"
        case .team: return "Team"
        case .safety: return "Safety"
        case .review: return "Review"
        }
    }
}

nonisolated struct DashboardJob: Identifiable, Sendable {
    let id: String
    let site: String
    let address: String
    let status: JobStatus
    let team: String
    let time: String
    let score: Double?
}

nonisolated enum JobStatus: Sendable {
    case inProgress, completed, scheduled, issue
    
    var label: String {
        switch self {
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .scheduled: return "Scheduled"
        case .issue: return "Issue"
        }
    }
}

nonisolated struct DashboardTeamMember: Identifiable, Sendable {
    let id: String
    let name: String
    let role: String
    let site: String
    let status: TeamMemberStatus
    let hrs: String
    
    var initials: String {
        name.split(separator: " ").map { String($0.prefix(1)) }.joined()
    }
}

nonisolated enum TeamMemberStatus: Sendable {
    case onSite, transit, off
    
    var label: String {
        switch self {
        case .onSite: return "On Site"
        case .transit: return "In Transit"
        case .off: return "Off Duty"
        }
    }
}

nonisolated struct RevenueBreakdown: Identifiable, Sendable {
    let id = UUID()
    let label: String
    let value: String
    let percentage: Double
}

nonisolated struct MonthlyRevenue: Identifiable, Sendable {
    let id = UUID()
    let month: String
    let value: Double
}
