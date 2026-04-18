import SwiftUI

// §14.3 + §15 — flag editor. Every proposed change routes through Varun;
// rejected changes show inline as `.blocked(reason:)` with the violated rule.

public struct FeatureFlagsRootView: View {
    public init() {}
    public var body: some View {
        NavigationStack {
            List {
                Text("Choose a school from the Schools tab to edit its flags, or pick a family from Solo people.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Feature flags")
        }
    }
}

public struct FeatureFlagsTenantView: View {
    public let tenantId: UUID
    @State private var flags: [String: Bool] = [:]
    @State private var proposedFlags: [String: Bool] = [:]
    @State private var violations: [VarunViolation] = []
    @State private var working = false

    public init(tenantId: UUID) { self.tenantId = tenantId }

    public var body: some View {
        List {
            ForEach(Self.knownKeys, id: \.self) { key in
                FlagRow(
                    key: key,
                    enabled: proposedFlags[key] ?? false,
                    violation: violations.first(where: { $0.fix?[key] != nil }),
                    toggle: { newValue in
                        proposedFlags[key] = newValue
                        Task { await validate() }
                    }
                )
            }
            if !violations.isEmpty {
                Section("Varun says") {
                    ForEach(violations, id: \.rule) { v in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(v.rule).font(.caption.monospaced()).foregroundStyle(.secondary)
                            Text(v.message)
                            if let fix = v.fix, !fix.isEmpty {
                                Button("Apply fix") {
                                    for (k, v) in fix { proposedFlags[k] = v }
                                    Task { await validate() }
                                }
                                .font(.caption.bold())
                            }
                        }
                    }
                }
            }
            Section {
                Button {
                    Task { await save() }
                } label: {
                    if working { ProgressView() } else { Text("Save") }
                }
                .disabled(working || !violations.isEmpty)
            }
        }
        .navigationTitle("Flags for \(tenantId.uuidString.prefix(4))")
        .task { await load() }
    }

    private static let knownKeys = [
        "feature.auth",
        "feature.school_login",
        "feature.b2c_signup",
        "feature.parent_invite",
        "feature.invite_codes",
        "feature.student_profile",
        "feature.grades_self_entry",
        "feature.career_quiz",
        "feature.class_suggester",
        "feature.extracurriculars_ai",
        "feature.classes",
        "feature.teacher_data",
        "feature.teacher_reviews",
        "feature.scheduling",
        "feature.flex_scheduling",
    ]

    private func load() async {
        // TODO: GET /rest/v1/feature_flags?tenant_id=eq.\(tenantId)
        let snap: [String: Bool] = ["feature.auth": true]
        flags = snap
        proposedFlags = snap
        await validate()
    }

    private func validate() async {
        // TODO: POST /functions/v1/varun-validate { flags: proposedFlags, tenant_type }
        violations = []
    }

    private func save() async {
        working = true
        defer { working = false }
        // TODO: PATCH /rest/v1/feature_flags rows where tenant_id matches.
        flags = proposedFlags
    }
}

private struct FlagRow: View {
    let key: String
    let enabled: Bool
    let violation: VarunViolation?
    let toggle: (Bool) -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(key).font(.body.monospaced())
                if let v = violation {
                    Text(v.message).font(.caption).foregroundStyle(.orange)
                }
            }
            Spacer()
            Toggle("", isOn: Binding(get: { enabled }, set: { toggle($0) }))
                .labelsHidden()
        }
        .padding(.vertical, 4)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(violation == nil ? Color.clear : Color.orange, lineWidth: 1)
        )
    }
}
