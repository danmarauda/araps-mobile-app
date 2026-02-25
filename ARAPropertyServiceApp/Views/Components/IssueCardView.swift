import SwiftUI

struct IssueCardView: View {
    let issue: Issue

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: issue.category.systemImage)
                    .font(.title3)
                    .foregroundStyle(ARATheme.priorityColor(issue.priority))
                    .frame(width: 32, height: 32)
                    .background(ARATheme.priorityColor(issue.priority).opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(issue.title)
                        .font(.subheadline.bold())
                        .lineLimit(2)
                    Text(issue.location)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(
                    text: issue.status.label,
                    color: ARATheme.statusColor(issue.status)
                )
            }

            HStack(spacing: 16) {
                PriorityBadge(priority: issue.priority)

                Label(issue.category.label, systemImage: issue.category.systemImage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(issue.reportedAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}
