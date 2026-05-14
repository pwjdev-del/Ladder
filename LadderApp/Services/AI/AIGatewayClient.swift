import Foundation

// CLAUDE.md §8.4 — iOS never calls Gemini directly. All AI traffic goes
// through the ai-gateway Edge Function which enforces session auth, tenant
// scoping, PII redaction, token budget, audit, and response redaction.
//
// ADR-005 is the single source of truth for the gateway contract.

public enum AIFeature: String, Codable, Sendable {
    case careerQuizScoring = "career_quiz_scoring"
    case classSuggester = "class_suggester"
    case extracurricularSession = "extracurricular_session"
    case scheduleSuggester = "schedule_suggester"
    case helpSurface = "help_surface"
    case siaChat = "sia_chat"
    case memoryExtraction = "memory_extraction"
    /// Counselor "Ask SIA" brief — system instruction enforces summary-only, no raw chat.
    case counselorBrief = "counselor_brief"
}

public struct AIGatewayResponse: Codable, Sendable {
    public let output: String
    public let inTokens: Int
    public let outTokens: Int
    /// Non-nil when the backend safety-flag scan detected crisis language in the
    /// model's response or the user's input. iOS client routes this to the
    /// counselor's safety queue (T015 Step 4).
    /// Known values: "crisis_resource_mentioned", "crisis_topic_in_response".
    /// v1.1: replace keyword-scan source with a proper ML safety classifier.
    public let safetyFlag: String?

    enum CodingKeys: String, CodingKey {
        case output
        case inTokens = "in_tokens"
        case outTokens = "out_tokens"
        case safetyFlag = "safety_flag"
    }
}

public enum AIGatewayError: Error {
    case unauthenticated
    case forbiddenFounderSession
    case budgetExhausted
    case rateLimited
    case serverError(Int, String?)
    case decode(Error)
}

private struct GatewayRequestBody<I: Encodable>: Encodable {
    let feature: AIFeature
    let input: I
}

public actor AIGatewayClient {
    public static let shared = AIGatewayClient()

    private let endpoint: URL
    private let session: URLSession

    // Rationale for force-unwrap on the fallback URL: it is a compile-time string
    // literal that is structurally valid. Changes would be caught immediately in CI.
    public init(endpoint: URL? = AppConfig.geminiProxyURL,
                session: URLSession = TLSPinnedSessionFactory.shared.session) {
        self.endpoint = endpoint
            ?? URL(string: "https://edge.ladder.app/functions/v1/ai-gateway")! // swiftlint:disable:this force_unwrapping
        self.session = session
    }

    public func call<Input: Encodable>(feature: AIFeature,
                                       input: Input,
                                       accessToken: String) async throws -> AIGatewayResponse {
        let body = GatewayRequestBody(feature: feature, input: input)

        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw AIGatewayError.serverError(0, nil)
        }
        switch http.statusCode {
        case 200..<300:
            do {
                return try JSONDecoder().decode(AIGatewayResponse.self, from: data)
            } catch {
                throw AIGatewayError.decode(error)
            }
        case 401:
            throw AIGatewayError.unauthenticated
        case 403:
            throw AIGatewayError.forbiddenFounderSession
        case 429:
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            throw bodyStr.contains("budget_exhausted") ? AIGatewayError.budgetExhausted : AIGatewayError.rateLimited
        default:
            throw AIGatewayError.serverError(http.statusCode, String(data: data, encoding: .utf8))
        }
    }
}

public enum AppConfig {
    // Reads from Info.plist at runtime. See Config/Base.xcconfig template.
    public static var geminiProxyURL: URL? {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "GEMINI_PROXY_URL") as? String,
              let url = URL(string: urlString) else { return nil }
        return url
    }
}
