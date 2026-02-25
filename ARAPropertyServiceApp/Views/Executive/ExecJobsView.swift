import SwiftUI
import SwiftData

struct ExecJobsView: View {
    let onBack: () -> Void
    @State private var appeared: Bool = false

    @Query(sort: \FieldTask.scheduledStart) private var tasks: [FieldTask]

    private var activeTasks: [FieldTask] {
        tasks.filter { $0.taskStatus != .cancelled }
    }

    private var activeCount: Int { tasks.filter { $0.taskStatus == .inProgress }.count }
    private var doneCount: Int { tasks.filter { $0.taskStatus == .completed }.count }
    private var issueCount: Int { tasks.filter { $0.priority == .critical && $0.taskStatus != .completed && $0.taskStatus != .cancelled }.count }
    private var upcomingCount: Int { tasks.filter { $0.taskStatus == .pending || $0.taskStatus == .assigned }.count }

    var body: some View {
        ExecScreenWrapper(title: "Field Tasks", onBack: onBack) {
            summaryRow
            if activeTasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(araGreen)
                    Text("No tasks in the system")
                        .font(.system(size: 13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .glassCard()
                .clipShape(.rect(cornerRadius: 16))
            } else {
                ForEach(Array(activeTasks.enumerated()), id: \.element.id) { index, task in
                    taskCard(task, index: index)
                }
            }
        }
        .onAppear { appeared = true }
    }

    private var summaryRow: some View {
        HStack(spacing: 8) {
            SummaryPill(count: activeCount, label: "Active", color: .blue)
            SummaryPill(count: doneCount, label: "Done", color: araGreen)
            SummaryPill(count: issueCount, label: "Critical", color: .red)
            SummaryPill(count: upcomingCount, label: "Upcoming", color: .white.opacity(0.4))
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
                HStack(spacing: 5) {
                    Circle()
                        .fill(taskStatusColor(task.taskStatus))
                        .frame(width: 6, height: 6)
                        .overlay {
                            if task.priority == .critical && task.taskStatus != .completed {
                                Circle()
                                    .fill(taskStatusColor(task.taskStatus))
                                    .frame(width: 6, height: 6)
                                    .symbolEffect(.pulse)
                            }
                        }
                    Text(taskStatusLabel(task.taskStatus))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(taskStatusColor(task.taskStatus))
                }
            }

            HStack {
                Label(task.assignedWorker, systemImage: "person.2")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.4))
                Spacer()
                Label(formattedTime(task.scheduledStart), systemImage: "clock")
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

    private func taskStatusLabel(_ status: TaskStatus) -> String {
        switch status {
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .pending: return "Pending"
        case .assigned: return "Assigned"
        case .cancelled: return "Cancelled"
        }
    }

    private func taskStatusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .inProgress: return .blue
        case .completed: return araGreen
        case .pending: return .white.opacity(0.4)
        case .assigned: return .orange
        case .cancelled: return .red
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "en_AU")
        return f.string(from: date)
    }
}

struct SummaryPill: View {
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 3) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .glassCard()
        .clipShape(.rect(cornerRadius: 12))
    }
}
