import SwiftUI

// §14.1 — founder login screen (separate from dashboard). Accessed only via
// the 30s logo hold trigger in LandingView. MFA required (passkey/TOTP).

public struct FounderLoginView: View {
    @State private var founderId: String = ""
    @State private var password: String = ""
    @State private var totp: String = ""
    @State private var working = false
    @State private var goDashboard = false
    @State private var error: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Founder authentication") {
                TextField("Founder ID", text: $founderId)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                TextField("Passkey / TOTP code", text: $totp)
                    .keyboardType(.numberPad)
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            Section {
                Button {
                    submit()
                } label: {
                    if working { ProgressView() } else { Text("Enter") }
                }
                .disabled(working || founderId.isEmpty || password.isEmpty || totp.isEmpty)
            }
            Section {
                Text("This surface does not render tenant data. Founders cannot read student PII, grades, schedules, quiz answers, or AI logs (§14.5). CloudTrail audits every KMS call from this session.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Founder login")
        .navigationDestination(isPresented: $goDashboard) {
            FounderDashboardView()
        }
    }

    private func submit() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: POST /rest/v1/rpc/founder_login with founderId+password; verify TOTP.
            // On success, bind TenantContext with role=founder, tenantId=nil.
            error = "Founder auth flow wired but backend not yet connected"
        }
    }
}
