import SwiftUI

// §14.3 — school detail. Explicit allowlist of fields to render. The UI has
// NO component that accepts a student-PII prop; a type-level guarantee
// against accidental leakage.

public struct SchoolDetailView: View {
    public let school: SchoolCard

    public init(school: SchoolCard) { self.school = school }

    public var body: some View {
        List {
            Section("Enrollment + billing") {
                LabeledContent("Students", value: "\(school.enrolledStudentCount)")
                LabeledContent("Balance", value: "$\(school.billingBalanceUSD)")
            }
            Section("AI usage") {
                LabeledContent("Tokens this month", value: "\(school.aiTokensUsedMonth)")
                LabeledContent("Cost this month", value: "$\(school.aiCostUSD)")
            }
            Section("Success metrics") {
                if let rate = school.successRatePercent {
                    LabeledContent("College matriculation", value: String(format: "%.1f%%", rate))
                } else {
                    Text("Not yet submitted").foregroundStyle(.secondary)
                }
            }
            Section("Feature flags") {
                NavigationLink("Manage with Varun") { FeatureFlagsTenantView(tenantId: school.id) }
            }
            Section("Contracts") {
                Link("Data Processing Agreement", destination: URL(string: "https://purewavejosh.com/legal/dpa/\(school.id)")!)
                Link("Liability acknowledgement", destination: URL(string: "https://purewavejosh.com/legal/liability/\(school.id)")!)
            }
            Section {
                Text("This view does not render student names, grades, schedules, quiz answers, or AI logs. A founder session is denied those fields at the API layer (§14.5) and at the database via RLS.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(school.displayName)
    }
}
