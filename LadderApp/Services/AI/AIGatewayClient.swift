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

    // endpoint is resolved lazily per call so that AppConfiguration is read
    // after preflightOrCrash() has run, not at actor init time. This also
    // prevents the fallback URL from being locked in during XCTest / SwiftUI
    // preview eval when Info.plist may not be fully initialised (B-10 fix).
    // An explicit override may be injected at init for unit tests only.
    private let endpointOverride: URL?
    private let session: URLSession

    public init(endpointOverride: URL? = nil,
                session: URLSession = TLSPinnedSessionFactory.shared.session) {
        self.endpointOverride = endpointOverride
        self.session = session
    }

    // Resolved endpoint: override (tests) → AppConfiguration (production).
    // AppConfiguration.aiGatewayBaseURL calls fatalError if the config is
    // missing, satisfying the "fail fast on missing env" requirement (D1 / B-03).
    private var resolvedEndpoint: URL {
        endpointOverride ?? AppConfiguration.aiGatewayBaseURL
    }

    public func call<Input: Encodable>(feature: AIFeature,
                                       input: Input,
                                       accessToken: String) async throws -> AIGatewayResponse {
        let body = GatewayRequestBody(feature: feature, input: input)

        var req = URLRequest(url: resolvedEndpoint)
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

    // MARK: - SSE streaming for sia_chat (A4 contract)
    //
    // A4 changed sia_chat responses from JSON to Server-Sent Events
    // (text/event-stream). This method MUST be used for sia_chat.
    // All other features (counselor_brief, memory_extraction, etc.) continue
    // to use the JSON-returning `call(_:input:accessToken:)` method above.
    //
    // Wire protocol per A4:
    //   event: message\ndata: {"delta":"..."}\n\n
    //   data: {"done":true,"safety_flag":"...","in_tokens":N,"out_tokens":N}\n\n
    //
    // Each yielded `SiaDelta` is either a `.token(String)` chunk or a
    // `.done(safetyFlag: String?)` terminal event. The caller should accumulate
    // `.token` values and inspect `.done` for the safety flag.

    public func streamSiaChat<Input: Encodable>(
        input: Input,
        accessToken: String
    ) -> AsyncThrowingStream<SiaDelta, Error> {
        // Capture self (actor) for use inside the unstructured Task below.
        let capturedSelf = self
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let body = GatewayRequestBody(feature: .siaChat, input: input)

                    var req = URLRequest(url: await capturedSelf.resolvedEndpoint)
                    req.httpMethod = "POST"
                    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    req.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    req.httpBody = try JSONEncoder().encode(body)

                    let (bytes, response) = try await capturedSelf.session.bytes(for: req)

                    guard let http = response as? HTTPURLResponse else {
                        continuation.finish(throwing: AIGatewayError.serverError(0, nil))
                        return
                    }
                    guard http.statusCode == 200 else {
                        switch http.statusCode {
                        case 401: continuation.finish(throwing: AIGatewayError.unauthenticated)
                        case 403: continuation.finish(throwing: AIGatewayError.forbiddenFounderSession)
                        case 429: continuation.finish(throwing: AIGatewayError.rateLimited)
                        default:  continuation.finish(throwing: AIGatewayError.serverError(http.statusCode, nil))
                        }
                        return
                    }

                    let decoder = JSONDecoder()

                    for try await line in bytes.lines {
                        // SSE lines that carry data begin with "data: ".
                        // Skip "event:" lines, comments (":"), and blank lines.
                        guard line.hasPrefix("data: ") else { continue }
                        let payload = String(line.dropFirst(6))
                        if payload == "[DONE]" { continuation.finish(); return }

                        guard let eventData = payload.data(using: .utf8),
                              let event = try? decoder.decode(SiaStreamEvent.self, from: eventData)
                        else { continue }

                        if let delta = event.delta, !delta.isEmpty {
                            continuation.yield(.token(delta))
                        }
                        if event.done == true {
                            continuation.yield(.done(safetyFlag: event.safetyFlag))
                            continuation.finish()
                            return
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - SSE event model (internal — used by streamSiaChat)

/// Single decoded SSE `data:` payload from the sia_chat stream.
/// Fields are all optional so a single struct handles both delta and done events.
struct SiaStreamEvent: Decodable {
    let delta: String?
    let done: Bool?
    let safetyFlag: String?
    let inTokens: Int?
    let outTokens: Int?

    enum CodingKeys: String, CodingKey {
        case delta
        case done
        case safetyFlag = "safety_flag"
        case inTokens   = "in_tokens"
        case outTokens  = "out_tokens"
    }
}

/// Typed stream element yielded by `AIGatewayClient.streamSiaChat`.
/// - `.token`: a chunk of assistant text to append to the in-progress bubble.
/// - `.done`: stream complete; `safetyFlag` is non-nil when crisis language detected.
public enum SiaDelta: Sendable {
    case token(String)
    case done(safetyFlag: String?)
}

// MARK: - Input types that carry a context payload
//
// S1-002 coordinated rename: the gateway's `system_prompt` field has been
// renamed to `context_payload` on the server side (A4). All iOS input structs
// that previously used `system_prompt` must encode as `context_payload`.
// Use the CodingKey pattern below for any struct that wraps a context string.
//
// Example:
//   struct SiaChatInput: Encodable {
//       let messages: [ChatMessage]
//       let contextPayload: String   // encodes as "context_payload"
//
//       enum CodingKeys: String, CodingKey {
//           case messages
//           case contextPayload = "context_payload"
//       }
//   }
//
// The old key name "system_prompt" must not appear in any Encodable sent to
// AIGatewayClient.call(). Grep: `system_prompt` should return 0 hits in
// LadderApp/Services/AI/ and LadderApp/Features/.
