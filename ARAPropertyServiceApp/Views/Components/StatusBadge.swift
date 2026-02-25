import SwiftUI

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2.bold())
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct PriorityBadge: View {
    let priority: IssuePriority

    var body: some View {
        Label(priority.label, systemImage: priority.systemImage)
            .font(.caption2.bold())
            .foregroundStyle(ARATheme.priorityColor(priority))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ARATheme.priorityColor(priority).opacity(0.12))
            .clipShape(Capsule())
    }
}
