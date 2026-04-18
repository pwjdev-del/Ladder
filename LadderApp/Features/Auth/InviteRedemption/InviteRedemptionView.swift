import SwiftUI

// §6.1 — invite code redemption. Client calls invite-redeem Edge Function
// which validates hash, expiry, max_uses, and allowed_email_domain.

public struct InviteRedemptionView: View {
    public let code: String
    public let tenantId: UUID

    @State private var email: String = ""
    @State private var working = false
    @State private var error: String?
    @State private var success = false

    public init(code: String, tenantId: UUID) {
        self.code = code
        self.tenantId = tenantId
    }

    public var body: some View {
        Form {
            Section("Redeem") {
                LabeledContent("Code") { Text(code.prefix(4) + "…") }
                TextField("Your school email", text: $email).autocapitalization(.none)
            }
            Section {
                Button {
                    redeem()
                } label: {
                    if working { ProgressView() } else { Text("Join") }
                }.disabled(working || email.isEmpty)
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            if success {
                Section { Text("Welcome aboard! 🎉").foregroundStyle(.green) }
            }
        }
        .navigationTitle("Invite code")
    }

    private func redeem() {
        Task { @MainActor in
            working = true
            defer { working = false }
            // TODO: wire to POST /functions/v1/invite-redeem
            // Request: { code, email, intended_student_id? }
            try? await Task.sleep(nanoseconds: 400_000_000)
            error = "Backend not yet deployed — scaffolded in LadderBackend/supabase/functions/invite-redeem"
        }
    }
}
