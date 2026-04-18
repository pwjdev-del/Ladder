import SwiftUI

// §14.3 — "Add a new school" provisioning form. On submit, backend:
//   - generates per-tenant DEK via KMS GenerateDataKey (ADR-004)
//   - inserts tenants row + default feature flags validated by Varun
//   - emails seed admin credentials.

public struct AddSchoolFormView: View {
    @State private var schoolName = ""
    @State private var slug = ""
    @State private var primaryColor = "#0A4B8F"
    @State private var logoURL = ""
    @State private var plan = "pilot"
    @State private var seedAdminEmail = ""
    @State private var working = false
    @State private var error: String?
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section("School") {
                    TextField("Display name", text: $schoolName)
                    TextField("Slug", text: $slug).autocapitalization(.none)
                    TextField("Primary color (#RRGGBB)", text: $primaryColor).autocapitalization(.allCharacters)
                    TextField("Logo URL", text: $logoURL).keyboardType(.URL).autocapitalization(.none)
                }
                Section("Plan") {
                    Picker("Plan", selection: $plan) {
                        Text("Pilot").tag("pilot")
                        Text("Standard").tag("standard")
                        Text("Custom").tag("custom")
                    }
                }
                Section("Seed admin") {
                    TextField("Admin email", text: $seedAdminEmail).keyboardType(.emailAddress).autocapitalization(.none)
                }
                if let error { Section { Text(error).foregroundStyle(.red) } }
                Section {
                    Button {
                        submit()
                    } label: {
                        if working { ProgressView() } else { Text("Provision tenant") }
                    }
                    .disabled(working || schoolName.isEmpty || slug.isEmpty || seedAdminEmail.isEmpty)
                }
            }
            .navigationTitle("New school")
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } }
        }
    }

    private func submit() {
        Task { @MainActor in
            working = true
            defer { working = false }
            try? await Task.sleep(nanoseconds: 400_000_000)
            // TODO: POST /functions/v1/provision-tenant with fields
            error = "provision-tenant Edge Function scaffolded but not yet deployed"
        }
    }
}
