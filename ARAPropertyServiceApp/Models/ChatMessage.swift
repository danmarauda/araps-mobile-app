import Foundation
import SwiftData

nonisolated enum MessageSender: String, Codable, Sendable {
    case user, assistant
}

@Model
final class ChatMessage {
    var id: UUID
    var content: String
    var senderRaw: String
    var timestamp: Date

    var sender: MessageSender {
        get { MessageSender(rawValue: senderRaw) ?? .user }
        set { senderRaw = newValue.rawValue }
    }

    var isUser: Bool { sender == .user }

    init(content: String, sender: MessageSender, timestamp: Date = .now) {
        self.id = UUID()
        self.content = content
        self.senderRaw = sender.rawValue
        self.timestamp = timestamp
    }
}
