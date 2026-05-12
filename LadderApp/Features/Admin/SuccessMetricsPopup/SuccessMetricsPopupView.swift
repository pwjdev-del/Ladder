import SwiftUI
import Supabase

// §13 — mandatory periodic popup. Admin submits aggregated per-school
// metrics. Feeds the founder School detail card as a percentage — never
// underlying student data.
//
// Bug-fix (S2-6): Submit now actually inserts into success_metrics and only
// dismisses on success. Failure shows a banner so the admin doesn't think
// they saved.

public struct SuccessMetricsPopupView: View {
    @State private var periodLabel = "2025-2026"
    @State private var collegeAcceptances = 0
    @State private var graduationRate: Double = 0
    @State private var custom: [String: String] = [:]
    @State private var submitting = false
    @State private var error: String?
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
                if let error {
                    Section { Text(error).foregroundStyle(.red) }
                }
                Section {
                    Button(submitting ? "Submitting…" : "Submit") {
                        Task { await submit() }
                    }
                    .disabled(submitting)
                }
            }
            .navigationTitle("Periodic metrics")
        }
        .requireNonFounder()
    }

    private struct MetricInsert: Encodable {
        let period_label: String
        let college_acceptance_count: Int
        let graduation_rate: Double
    }

    private func submit() async {
        submitting = true
        error = nil
        defer { submitting = false }
        do {
            let client = await SupabaseAuthService.shared.supabase
            try await client.from("success_metrics").insert(MetricInsert(
                period_label: periodLabel,
                college_acceptance_count: collegeAcceptances,
                graduation_rate: graduationRate
            )).execute()
            dismiss()
        } catch {
            self.error = "Couldn't submit: \(error.localizedDescription)"
        }
    }
}
