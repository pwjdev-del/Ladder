import SwiftUI

// §12 — counselor / admin class-list upload. CSV / XLSX / PDF / pasted text.
// AI parser extracts rows; uploader confirms before writes.

public struct ClassListUploadView: View {
    @State private var pastedText: String = ""
    @State private var parsedRows: [ParsedClass] = []
    @State private var working = false

    public init() {}

    public var body: some View {
        Form {
            Section("Paste or import") {
                TextEditor(text: $pastedText).frame(minHeight: 120)
                Button("Parse with AI") { parse() }.disabled(pastedText.isEmpty || working)
            }
            if !parsedRows.isEmpty {
                Section("Review before save") {
                    ForEach(parsedRows) { row in
                        VStack(alignment: .leading) {
                            Text(row.title).font(.headline)
                            HStack {
                                Text(row.code).font(.caption.monospaced())
                                Spacer()
                                Text("Grade \(row.gradeLevel)").font(.caption)
                                Text("Cap \(row.maxCapacity)").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Button("Confirm & save \(parsedRows.count) classes") { /* TODO */ }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle("Class list")
    }

    private func parse() {
        Task { @MainActor in
            working = true; defer { working = false }
            // TODO: call ai-gateway feature=class_list_parse ; confirm in UI before write
            parsedRows = []
        }
    }
}

public struct ParsedClass: Identifiable, Sendable {
    public let id: UUID
    public let code: String
    public let title: String
    public let gradeLevel: Int
    public let maxCapacity: Int
}
