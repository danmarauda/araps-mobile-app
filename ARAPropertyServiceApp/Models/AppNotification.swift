import Foundation
import SwiftData

@Model
final class AppNotification {
    var id: UUID
    var title: String
    var body: String
    var type: String
    var isRead: Bool
    var createdAt: Date

    init(
        title: String,
        body: String,
        type: String,
        isRead: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.type = type
        self.isRead = isRead
        self.createdAt = createdAt
    }
}
