import SwiftUI
import SwiftData

struct IssueDetailView: View {
    let issue: Issue
    @Environment(\.modelContext) private var modelContext
    @State private var showStatusPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard
                detailsCard
                locationCard
                actionsCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Issue Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: issue.category.systemImage)
                    .font(.title2)
                    .foregroundStyle(ARATheme.priorityColor(issue.priority))
                    .frame(width: 44, height: 44)
                    .background(ARATheme.priorityColor(issue.priority).opacity(0.12))
                    .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(issue.title)
                        .font(.headline)
                    Text(issue.category.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                StatusBadge(text: issue.status.label, color: ARATheme.statusColor(issue.status))
                PriorityBadge(priority: issue.priority)
                Spacer()
            }

            Text(issue.issueDescription)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var detailsCard: some View {
        VStack(spacing: 0) {
            DetailRow(icon: "person.fill", title: "Reported By", value: issue.reportedBy)
            Divider().padding(.leading, 44)
            DetailRow(icon: "person.badge.shield.checkmark.fill", title: "Assigned To", value: issue.assignedTo ?? "Unassigned")
            Divider().padding(.leading, 44)
            DetailRow(icon: "calendar", title: "Reported", value: issue.reportedAt.formatted(date: .abbreviated, time: .shortened))
        }
        .padding(.vertical, 4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var locationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(ARATheme.primaryBlue)
            VStack(alignment: .leading, spacing: 2) {
                Text("Location")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(issue.location)
                    .font(.subheadline.bold())
            }
            Spacer()
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var actionsCard: some View {
        VStack(spacing: 12) {
            Button {
                showStatusPicker = true
            } label: {
                Label("Update Status", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(ARATheme.primaryBlue)
            .controlSize(.large)

            if issue.status == .open {
                Button {
                    issue.status = .inProgress
                    try? modelContext.save()
                } label: {
                    Label("Start Working", systemImage: "play.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            if issue.status == .inProgress {
                Button {
                    issue.status = .resolved
                    issue.resolvedAt = .now
                    try? modelContext.save()
                } label: {
                    Label("Mark Resolved", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
                .controlSize(.large)
            }
        }
        .confirmationDialog("Update Status", isPresented: $showStatusPicker, titleVisibility: .visible) {
            ForEach(IssueStatus.allCases, id: \.self) { status in
                Button(status.label) {
                    issue.status = status
                    if status == .resolved { issue.resolvedAt = .now }
                    try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
