import SwiftUI
import SwiftData

struct ExecMeetingsView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query(sort: \FieldTask.scheduledStart) private var tasks: [FieldTask]
    @Query(sort: \Issue.reportedAt, order: .reverse) private var issues: [Issue]

    private var upcomingTasks: [FieldTask] {
        let now = Date.now
        return tasks.filter {
            $0.taskStatus != .completed &&
            $0.taskStatus != .cancelled &&
            $0.scheduledStart >= now
        }.prefix(6).map { $0 }
    }

    private var pendingIssues: [Issue] {
        issues.filter { $0.status == .open || $0.status == .inProgress }.prefix(4).map { $0 }
    }

    var body: some View {
        ExecScreenWrapper(title: "Schedule & Actions", onBack: onBack) {
            upcomingScheduleSection
            openActionsSection
        }
        .onAppear { appeared = true }
    }

    private var upcomingScheduleSection: some View {
        Group {
            Text("Upcoming Schedule")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            if upcomingTasks.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 28))
                        .foregroundStyle(araGreen)
                    Text("No upcoming tasks scheduled")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.4), value: appeared)
            } else {
                ForEach(Array(upcomingTasks.enumerated()), id: \.element.id) { index, task in
                    taskCard(task, index: index)
                }
            }
        }
    }

    private var openActionsSection: some View {
        Group {
            Text("Open Actions")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)

            if pendingIssues.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(araGreen)
                    Text("No open issues requiring action")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.4), value: appeared)
            } else {
                ForEach(Array(pendingIssues.enumerated()), id: \.element.id) { index, issue in
                    issueCard(issue, index: upcomingTasks.count + index)
                }
            }
        }
    }

    private func taskCard(_ task: FieldTask, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(task.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Label(task.facilityName, systemImage: "mappin")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.45))
                        .lineLimit(1)
                }
                Spacer()
                Text(formattedDate(task.scheduledStart))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(araGreen)
            }

            HStack {
                Label(task.assignedWorker, systemImage: "person.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Label("\(task.estimatedDuration)min", systemImage: "clock")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(14)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
    }

    private func issueCard(_ issue: Issue, index: Int) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(issuePriorityColor(issue.priority))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 3) {
                Text(issue.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(issue.location)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
            }

            Spacer()

            Text(issue.priority.label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(issuePriorityColor(issue.priority))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background {
                    Capsule().fill(issuePriorityColor(issue.priority).opacity(0.12))
                }
        }
        .padding(14)
        .glassCard()
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
    }

    private func issuePriorityColor(_ priority: IssuePriority) -> Color {
        switch priority {
        case .critical: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .blue
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            f.dateFormat = "h:mm a"
        } else if Calendar.current.isDateInTomorrow(date) {
            f.dateFormat = "'Tomorrow' h:mm a"
        } else {
            f.dateFormat = "EEE d MMM"
        }
        f.locale = Locale(identifier: "en_AU")
        return f.string(from: date)
    }
}
