import SwiftUI

// §6.1 — counselor-generated invite codes: single, bulk, class-level.
// Plaintext shown ONCE via InviteCodeDisplay component.

public struct CounselorInviteCodesView: View {
    public enum Mode: String, CaseIterable, Identifiable {
        case single = "Single"
        case bulk = "Bulk"
        case classLevel = "Class-level"
        public var id: Self { self }
    }

    @State private var mode: Mode = .single
    @State private var quantity: Int = 1
    @State private var expectedGrade: Int = 3
    @State private var allowedEmailDomain: String = ""
    @State private var expiresInDays: Int = 30
    @State private var issued: [String] = []

    public init() {}

    public var body: some View {
        Form {
            Section("Mode") {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
            }
            Section("Options") {
                if mode == .bulk { Stepper("Quantity: \(quantity)", value: $quantity, in: 1...200) }
                Stepper("Expected grade: \(expectedGrade)", value: $expectedGrade, in: 0...8)
                TextField("Allowed email domain (optional)", text: $allowedEmailDomain).autocapitalization(.none)
                Stepper("Expires in \(expiresInDays) days", value: $expiresInDays, in: 1...365)
            }
            Section {
                Button("Generate") {
                    issue()
                }
            }
            if !issued.isEmpty {
                Section("Shown once — copy now") {
                    ForEach(issued, id: \.self) { InviteCodeDisplay(code: $0) }
                }
            }
        }
        .navigationTitle("Invite codes")
    }

    private func issue() {
        // TODO: POST /rest/v1/rpc/counselor_issue_invite { mode, quantity, ... }
        // Response: codes[] (plaintext; backend stores only hash)
        issued = (0..<quantity).map { _ in "LDR-\(UUID().uuidString.prefix(8))" }
    }
}
