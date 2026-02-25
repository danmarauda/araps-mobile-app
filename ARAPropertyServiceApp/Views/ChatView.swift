import SwiftUI
import SwiftData

struct ChatView: View {
    @Query(sort: \ChatMessage.timestamp) private var messages: [ChatMessage]
    @Environment(\.modelContext) private var modelContext
    @State private var inputText = ""
    @State private var isTyping = false
    @State private var errorAlert: String?
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                inputBar
            }
            .navigationTitle("AskARA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Clear Chat", systemImage: "trash", role: .destructive) {
                            clearChat()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { errorAlert != nil },
                set: { if !$0 { errorAlert = nil } }
            )) {
                Button("OK") { errorAlert = nil }
            } message: {
                if let errorAlert {
                    Text(errorAlert)
                }
            }
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if messages.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }

                        if isTyping {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .id("typing")
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: isTyping) { _, typing in
                if typing {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "message.badge.waveform.fill")
                .font(.system(size: 56))
                .foregroundStyle(ARATheme.primaryBlue.opacity(0.5))
                .symbolEffect(.pulse)

            Text("Ask ARA Anything")
                .font(.title2.bold())

            Text("Get help with facility operations,\ntask management, and more.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                SuggestionChip(text: "Show open issues") { sendMessage("Show me all open issues") }
                SuggestionChip(text: "Today's schedule") { sendMessage("What's on the schedule today?") }
                SuggestionChip(text: "Compliance status") { sendMessage("What's the current compliance status?") }
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask ARA...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .textFieldStyle(.plain)
                .focused($isInputFocused)
                .onSubmit { sendCurrentMessage() }
                .submitLabel(.send)

            Button {
                sendCurrentMessage()
            } label: {
                Image(systemName: isTyping ? "ellipsis.circle.fill" : "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        inputText.trimmingCharacters(in: .whitespaces).isEmpty || isTyping
                            ? .secondary
                            : ARATheme.primaryBlue
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isTyping)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func sendCurrentMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        sendMessage(text)
    }

    private func sendMessage(_ text: String) {
        let userMessage = ChatMessage(content: text, sender: .user)
        modelContext.insert(userMessage)
        inputText = ""
        isTyping = true

        let history = messages

        Task { @MainActor in
            do {
                let response = try await ChatService.sendMessage(
                    userMessage: text,
                    conversationHistory: history
                )
                let assistantMessage = ChatMessage(content: response, sender: .assistant)
                modelContext.insert(assistantMessage)
            } catch {
                let errorMessage = ChatMessage(
                    content: "Sorry, I couldn't process that request. \(error.localizedDescription)",
                    sender: .assistant
                )
                modelContext.insert(errorMessage)
            }
            isTyping = false
            try? modelContext.save()
        }
    }

    private func clearChat() {
        for message in messages {
            modelContext.delete(message)
        }
        try? modelContext.save()
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer(minLength: 60) }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(message.isUser ? .white : .primary)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(message.isUser ? .white.opacity(0.7) : .secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(message.isUser ? ARATheme.primaryBlue : Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 18, style: .continuous))

            if !message.isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 16)
    }
}

struct TypingIndicator: View {
    @State private var dotOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .offset(y: dotOffset)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(index) * 0.15),
                        value: dotOffset
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 18))
        .onAppear { dotOffset = -6 }
    }
}

struct SuggestionChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .foregroundStyle(ARATheme.primaryBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(ARATheme.primaryBlue.opacity(0.08))
                .clipShape(Capsule())
        }
    }
}
