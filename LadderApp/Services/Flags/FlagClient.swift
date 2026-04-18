import Foundation

// CLAUDE.md §15 — Varun validator client. Client only READS flags; founders
// write them via the backdoor, and every write is validated by Varun first.

public struct FeatureFlag: Codable, Sendable, Equatable {
    public let key: String
    public let enabled: Bool
}

public enum VarunViolationKind: String, Codable, Sendable {
    case rule1AuthOffCascades = "rule_1_auth_off_cascades"
    case rule2SchoolLoginRequiresAuth = "rule_2_school_login_requires_auth"
    case rule2SchoolLoginRequiresSchool = "rule_2_school_login_requires_school_tenant"
    case rule3B2CSignupRequiresAuth = "rule_3_b2c_signup_requires_auth"
    case rule3B2CSignupRequiresParentInvite = "rule_3_b2c_signup_requires_parent_invite"
    case rule4SchedulingDependencies = "rule_4_scheduling_dependencies"
    case rule5FlexRequiresScheduling = "rule_5_flex_requires_scheduling"
    case rule6QuizRequiresStudentProfile = "rule_6_quiz_requires_student_profile"
    case rule7ClassSuggesterDependencies = "rule_7_class_suggester_dependencies"
    case rule8ExtracurricularsDependencies = "rule_8_extracurriculars_dependencies"
    case rule9TeacherReviewsRequiresTeacherData = "rule_9_teacher_reviews_requires_teacher_data"
    case rule10InviteCodesRequiresAuth = "rule_10_invite_codes_requires_auth"
}

public struct VarunViolation: Codable, Sendable {
    public let rule: String
    public let message: String
    public let fix: [String: Bool]?
}

public struct VarunValidation: Codable, Sendable {
    public let ok: Bool
    public let violations: [VarunViolation]
    public let corrected: [String: Bool]?
}

@MainActor
public final class FlagClient: ObservableObject {
    public static let shared = FlagClient()

    @Published public private(set) var flags: [String: Bool] = [:]

    private let endpoint: URL
    private let session: URLSession

    public init(endpoint: URL = URL(string: "https://edge.ladder.app/functions/v1/varun-validate")!,
                session: URLSession = TLSPinnedSessionFactory.shared.session) {
        self.endpoint = endpoint
        self.session = session
    }

    public func isEnabled(_ key: String) -> Bool {
        flags[key] ?? false
    }

    public func load(from snapshot: [FeatureFlag]) {
        flags = Dictionary(uniqueKeysWithValues: snapshot.map { ($0.key, $0.enabled) })
    }

    /// Founder-only path. Validates a proposed flag change with Varun before
    /// persisting. Never persists on-device — write is server-side.
    public func validate(proposed: [String: Bool], tenantType: String, accessToken: String) async throws -> VarunValidation {
        struct Body: Encodable { let flags: [String: Bool]; let tenant_type: String }
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONEncoder().encode(Body(flags: proposed, tenant_type: tenantType))
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(VarunValidation.self, from: data)
    }
}
