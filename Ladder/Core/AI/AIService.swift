import Foundation

// MARK: - AI Service
// Proxies AI requests through Supabase Edge Functions to Gemini API
// API key stays server-side, never in app bundle

@Observable
@MainActor
final class AIService {
    static let shared = AIService()

    var isStreaming = false

    // MARK: - Send Message (non-streaming)

    func sendMessage(
        messages: [AIMessage],
        systemPrompt: String
    ) async throws -> String {
        let url = URL(string: AppConfiguration.geminiProxyURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // TODO: Add auth token
        // request.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")

        let body = AIRequest(
            messages: messages,
            systemPrompt: systemPrompt,
            stream: false
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AIResponse.self, from: data)
        return response.content
    }

    // MARK: - Stream Message (SSE for chat UI)

    func streamMessage(
        messages: [AIMessage],
        systemPrompt: String
    ) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = URL(string: AppConfiguration.geminiProxyURL)!
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

                    let body = AIRequest(
                        messages: messages,
                        systemPrompt: systemPrompt,
                        stream: true
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (bytes, _) = try await URLSession.shared.bytes(for: request)

                    for try await line in bytes.lines {
                        if line.hasPrefix("data: ") {
                            let data = String(line.dropFirst(6))
                            if data == "[DONE]" { break }
                            if let chunk = parseChunk(data) {
                                continuation.yield(chunk)
                            }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func parseChunk(_ json: String) -> String? {
        guard let data = json.data(using: .utf8),
              let parsed = try? JSONDecoder().decode(StreamChunk.self, from: data) else {
            return nil
        }
        return parsed.text
    }
}

// MARK: - Models

struct AIMessage: Codable {
    let role: String // "user" or "assistant"
    let content: String
}

struct AIRequest: Codable {
    let messages: [AIMessage]
    let systemPrompt: String
    let stream: Bool
}

struct AIResponse: Codable {
    let content: String
}

struct StreamChunk: Codable {
    let text: String
}
