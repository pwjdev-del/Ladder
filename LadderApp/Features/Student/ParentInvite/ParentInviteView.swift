import SwiftUI
import Supabase

// §6.2 — student invites a parent AFTER their own signup. Code is hashed +
// DEK-signed server-side; shown to student once.
//
// Bug-fix (S1-9): replaced fake client-side UUID with real RPC call to
// `generate_parent_invite`. Code is generated, hashed, and stored on the
// backend; the plaintext is returned to the caller exactly once.

public struct ParentInviteView: View {
    @State private var parentEmail = ""
    @State private var relationship = "parent"
    @State private var generatedCode: String?
    @State private var expiresAt: Date?
    @State private var working = false
    @State private var error: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Invite your parent or guardian") {
                TextField("Parent email", text: $parentEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                Picker("Relationship", selection: $relationship) {
                    Text("Parent").tag("parent")
                    Text("Guardian").tag("guardian")
                    Text("Other").tag("other")
                }
            }
            if let code = generatedCode {
                Section("Your one-time code") {
                    Text(code).font(.title2.monospaced()).textSelection(.enabled)
                    if let exp = expiresAt {
                        Text("Expires \(exp.formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Text("Shown once. Copy this and send it to your parent — they'll enter it on the parent sign-in screen.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            Section {
                Button {
                    Task { await generate() }
                } label: {
                    if working { ProgressView() } else { Text("Generate invite") }
                }
                .disabled(working || parentEmail.isEmpty)
            }
        }
        .navigationTitle("Add a parent")
    }

    // MARK: - Backend call

    private struct InviteRPCParams: Encodable {
        let p_parent_email: String
        let p_relationship: String
    }

    private struct InviteRPCResult: Decodable {
        let code: String
        let expires_at: Date
    }

    private func generate() async {
        working = true
        error = nil
        defer { working = false }

        let client = await SupabaseAuthService.shared.supabase
        let params = InviteRPCParams(p_parent_email: parentEmail, p_relationship: relationship)

        do {
            let response = try await client
                .rpc("generate_parent_invite", params: params)
                .execute()

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            // RPC returning a single row from a `returns table(...)` function comes back
            // as a JSON array of one object.
            let rows = try decoder.decode([InviteRPCResult].self, from: response.data)
            if let first = rows.first {
                generatedCode = first.code
                expiresAt = first.expires_at
            } else {
                error = "Couldn't generate code. Try again."
            }
        } catch {
            self.error = "Couldn't generate code: \(error.localizedDescription)"
        }
    }
}
