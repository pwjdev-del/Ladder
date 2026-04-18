import SwiftUI

// §13 — mandatory periodic popup. Admin submits aggregated per-school
// metrics. Feeds the founder School detail card as a percentage — never
// underlying student data.

public struct SuccessMetricsPopupView: View {
    @State private var periodLabel = "2025-2026"
    @State private var collegeAcceptances = 0
    @State private var graduationRate: Double = 0
    @State private var custom: [String: String] = [:]
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("Period") {
                    TextField("Period label", text: $periodLabel)
                }
                Section("Core metrics") {
                    Stepper("College acceptances: \(collegeAcceptances)", value: $collegeAcceptances, in: 0...5000)
                    HStack {
                        Text("Graduation rate")
                        Slider(value: $graduationRate, in: 0...100)
                        Text(String(format: "%.1f%%", graduationRate))
                    }
                }
                Section("Custom") {
                    Text("Configurable per school in admin settings.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section {
                    Button("Submit") {
                        // TODO: POST /rest/v1/success_metrics
                        dismiss()
                    }
                }
            }
            .navigationTitle("Periodic metrics")
        }
    }
}
