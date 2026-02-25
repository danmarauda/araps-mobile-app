import Foundation

struct ChatService {
    private static let systemPrompt = """
    You are ARA (Autonomous Response Assistant), an intelligent operations assistant for ARA Property Services — a professional commercial cleaning and facilities management company.

    Your role is to help field workers, supervisors, and executives with:
    - Issue tracking and reporting
    - Task management and scheduling
    - Facility and compliance information
    - Team coordination
    - Safety protocol guidance
    - General facilities management questions

    Company context:
    - ARA Property Services manages commercial cleaning contracts for offices, retail, industrial, and government facilities
    - The team includes field workers, supervisors, and contractors
    - Key metrics include compliance ratings, task completion rates, and safety alerts
    - Services are delivered across multiple sites

    Keep responses concise, professional, and action-oriented. Use Australian spelling (e.g. "organise" not "organize").
    When you don't have specific data, acknowledge this and suggest the user check the relevant section of the app.
    """

    static func sendMessage(
        userMessage: String,
        conversationHistory: [ChatMessage]
    ) async throws -> String {
        guard !AppConfig.openAIApiKey.isEmpty else {
            return "AI chat is not configured. Please add your OpenAI API key to enable this feature."
        }

        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]

        for msg in conversationHistory.suffix(8) {
            messages.append([
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.content
            ])
        }
        messages.append(["role": "user", "content": userMessage])

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": messages,
            "max_tokens": 600,
            "temperature": 0.7
        ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw ChatServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AppConfig.openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 30

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ChatServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw ChatServiceError.unauthorized
            }
            throw ChatServiceError.serverError(httpResponse.statusCode)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw ChatServiceError.parsingFailed
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum ChatServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .invalidResponse: return "Invalid response from server."
        case .unauthorized: return "Invalid API key. Please check your OpenAI API key."
        case .serverError(let code): return "Server error (\(code)). Please try again."
        case .parsingFailed: return "Failed to parse response. Please try again."
        }
    }
}
