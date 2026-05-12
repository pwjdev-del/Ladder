import SwiftUI
import Supabase

// Bug-fix (S2-8): admin "Import Students" button used to be a TODO no-op.
// This sheet collects pasted emails (one per line, optional grade) and
// generates a B2B_STUDENT_SINGLE invite code per email via the existing
// invite-redeem infrastructure. Each invite is shown back to the admin to
// distribute. Real auth-user provisioning happens when the student redeems.

struct StudentBulkImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pastedText: String = ""
    @State private var generated: [GeneratedInvite] = []
    @State private var working = false
    @State private var error: String?

    var body: some View {
        Form {
            Section("Paste students") {
                Text("One per line. Format: email[,grade]\nExample:\nemma@school.org,11\nliam@school.org,10")
                    .font(.footnote).foregroundStyle(.secondary)
                TextEditor(text: $pastedText).frame(minHeight: 140)
            }
            if let error { Section { Text(error).foregroundStyle(.red) } }
            if !generated.isEmpty {
                Section("Invite codes to distribute") {
                    ForEach(generated) { g in
                        VStack(alignment: .leading) {
                            Text(g.email).font(.body)
                            Text(g.code).font(.body.monospaced()).textSelection(.enabled)
                        }
                    }
                }
            }
            Section {
                Button(working ? "Generating…" : "Generate \(parsedRows.count) invites") {
                    Task { await generateInvites() }
                }
                .disabled(working || parsedRows.isEmpty)
            }
        }
        .navigationTitle("Import students")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
            }
        }
    }

    private struct ParsedStudent {
        let email: String
        let grade: Int?
    }

    private var parsedRows: [ParsedStudent] {
        pastedText
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line in
                let parts = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                guard let email = parts.first, email.contains("@") else { return nil }
                let grade = parts.count >= 2 ? Int(parts[1]) : nil
                return ParsedStudent(email: email, grade: grade)
            }
    }

    struct GeneratedInvite: Identifiable {
        let id = UUID()
        let email: String
        let code: String
    }

    private struct InviteRPCParams: Encodable {
        let p_email: String
        let p_grade: Int?
    }

    private struct InviteRPCResult: Decodable {
        let code: String
    }

    private func generateInvites() async {
        working = true
        error = nil
        generated = []
        defer { working = false }

        let client = await SupabaseAuthService.shared.supabase
        for row in parsedRows {
            do {
                let response = try await client
                    .rpc("generate_student_invite", params: InviteRPCParams(
                        p_email: row.email,
                        p_grade: row.grade
                    ))
                    .execute()
                let rows = try JSONDecoder().decode([InviteRPCResult].self, from: response.data)
                if let first = rows.first {
                    generated.append(GeneratedInvite(email: row.email, code: first.code))
                }
            } catch {
                self.error = "Couldn't generate invite for \(row.email): \(error.localizedDescription)"
                break
            }
        }
    }
}
