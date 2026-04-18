import SwiftUI

// §6.2 — student invites a parent AFTER their own signup. Code is hashed +
// DEK-signed server-side; shown to student once.

public struct ParentInviteView: View {
    @State private var parentEmail = ""
    @State private var relationship = "parent"
    @State private var generatedCode: String?
    @State private var working = false
    @State private var error: String?

    public init() {}

    public var body: some View {
        Form {
            Section("Invite your parent or guardian") {
                TextField("Parent email", text: $parentEmail).keyboardType(.emailAddress).autocapitalization(.none)
                Picker("Relationship", selection: $relationship) {
                    Text("Parent").tag("parent")
                    Text("Guardian").tag("guardian")
                    Text("Other").tag("other")
                }
            }
            if let code = generatedCode {
                Section("Your one-time code") {
                    Text(code).font(.title2.monospaced()).textSelection(.enabled)
                    Text("Shown once. We emailed them already; this is your backup to copy/paste.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            Section {
                Button {
                    generate()
                } label: {
                    if working { ProgressView() } else { Text("Generate invite") }
                }
                .disabled(working || parentEmail.isEmpty)
            }
        }
        .navigationTitle("Add a parent")
    }

    private func generate() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: POST /rest/v1/rpc/generate_parent_invite
            // Response: { code (shown once), expires_at }
            generatedCode = "LDR-\(UUID().uuidString.prefix(8))"
        }
    }
}
