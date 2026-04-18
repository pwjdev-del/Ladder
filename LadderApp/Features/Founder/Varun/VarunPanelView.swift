import SwiftUI

// §15 — explain pane. "Why can't I turn this off?" — enumerate active rules
// with per-rule trace.

public struct VarunPanelView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            List {
                Section("Varun — feature dependency rules") {
                    ForEach(Self.ruleDescriptions, id: \.number) { rule in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rule \(rule.number)").font(.caption.monospaced())
                            Text(rule.description)
                        }
                    }
                }
                Section {
                    Text("Varun does NOT read student data (§15.4). It validates flag-dependency invariants only.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Varun")
        }
    }

    private static let ruleDescriptions: [(number: Int, description: String)] = [
        (1, "auth OFF ⇒ all other flags OFF"),
        (2, "school_login ON ⇒ auth ON AND tenant type = school"),
        (3, "b2c_signup ON ⇒ auth ON AND parent_invite ON"),
        (4, "scheduling ON ⇒ classes ON AND teacher_data ON AND student_profile ON"),
        (5, "flex_scheduling ON ⇒ scheduling ON"),
        (6, "career_quiz ON ⇒ student_profile ON"),
        (7, "class_suggester ON ⇒ career_quiz ON AND grades_self_entry ON"),
        (8, "extracurriculars_ai ON ⇒ career_quiz ON AND student_profile ON"),
        (9, "teacher_reviews ON ⇒ teacher_data ON (admin-only in UI regardless)"),
        (10, "invite_codes ON ⇒ auth ON"),
    ]
}
