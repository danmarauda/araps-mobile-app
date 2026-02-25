import SwiftUI
import SwiftData

struct NotificationsView: View {
    @Query(sort: \AppNotification.createdAt, order: .reverse) private var notifications: [AppNotification]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if notifications.isEmpty {
                    ContentUnavailableView("No Notifications", systemImage: "bell.slash", description: Text("You're all caught up"))
                } else {
                    ForEach(notifications) { notification in
                        NotificationRow(notification: notification)
                            .onTapGesture {
                                notification.isRead = true
                                try? modelContext.save()
                            }
                    }
                    .onDelete(perform: deleteNotifications)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Read All") { markAllRead() }
                        .disabled(notifications.allSatisfy(\.isRead))
                }
            }
        }
    }

    private func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notifications[index])
        }
        try? modelContext.save()
    }

    private func markAllRead() {
        for notification in notifications {
            notification.isRead = true
        }
        try? modelContext.save()
    }
}

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForType)
                .foregroundStyle(colorForType)
                .frame(width: 32, height: 32)
                .background(colorForType.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(notification.isRead ? .regular : .bold)
                    Spacer()
                    if !notification.isRead {
                        Circle()
                            .fill(ARATheme.primaryBlue)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(notification.body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Text(notification.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private var iconForType: String {
        switch notification.type {
        case "issue": return "exclamationmark.bubble.fill"
        case "task": return "checkmark.square.fill"
        case "alert": return "bell.badge.fill"
        case "compliance": return "checkmark.shield.fill"
        default: return "bell.fill"
        }
    }

    private var colorForType: Color {
        switch notification.type {
        case "issue": return .orange
        case "task": return ARATheme.primaryBlue
        case "alert": return .red
        case "compliance": return .green
        default: return .secondary
        }
    }
}
