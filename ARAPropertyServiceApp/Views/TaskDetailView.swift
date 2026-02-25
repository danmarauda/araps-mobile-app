import SwiftUI
import SwiftData

struct TaskDetailView: View {
    let task: FieldTask
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                scheduleSection
                detailsSection
                actionSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(task.taskNumber)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadge(text: task.taskStatus.label, color: ARATheme.taskStatusColor(task.taskStatus))
                StatusBadge(text: task.priority.label, color: ARATheme.taskPriorityColor(task.priority))
                Spacer()
                Text(task.taskType)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .clipShape(Capsule())
            }

            Text(task.title)
                .font(.title3.bold())

            if let desc = task.taskDescription {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var scheduleSection: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "calendar", title: "Scheduled Start", value: task.scheduledStart.formatted(date: .abbreviated, time: .shortened))
            Divider().padding(.leading, 44)
            DetailRow(icon: "calendar.badge.clock", title: "Scheduled End", value: task.scheduledEnd.formatted(date: .abbreviated, time: .shortened))
            Divider().padding(.leading, 44)
            DetailRow(icon: "clock", title: "Estimated Duration", value: "\(task.estimatedDuration) minutes")
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var detailsSection: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "building.2.fill", title: "Facility", value: task.facilityName)
            Divider().padding(.leading, 44)
            DetailRow(icon: "person.fill", title: "Assigned To", value: task.assignedWorker)
            if let safety = task.safetyRequirements {
                Divider().padding(.leading, 44)
                DetailRow(icon: "exclamationmark.shield.fill", title: "Safety", value: safety)
            }
            if let instructions = task.instructions {
                Divider().padding(.leading, 44)
                DetailRow(icon: "doc.text.fill", title: "Instructions", value: instructions)
            }
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            if task.taskStatus == .assigned || task.taskStatus == .pending {
                Button {
                    task.taskStatus = .inProgress
                    try? modelContext.save()
                } label: {
                    Label("Start Task", systemImage: "play.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(ARATheme.primaryBlue)
                .controlSize(.large)
            }

            if task.taskStatus == .inProgress {
                Button {
                    task.taskStatus = .completed
                    try? modelContext.save()
                } label: {
                    Label("Complete Task", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
            }
        }
    }
}
