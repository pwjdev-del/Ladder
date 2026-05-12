import SwiftUI
import Supabase

// §12 — counselor / admin class-list upload. CSV / XLSX / PDF / pasted text.
// AI parser extracts rows; uploader confirms before writes.
//
// Bug-fix (S2-4): "Parse with AI" now does a deterministic local CSV parse
// (one class per line: code,title,grade,capacity) so the counselor sees rows
// and can confirm. AI parsing is a follow-up. "Confirm & save" inserts into
// the classes table.

public struct ClassListUploadView: View {
    @State private var pastedText: String = ""
    @State private var parsedRows: [ParsedClass] = []
    @State private var working = false
    @State private var error: String?
    @State private var saved: Int?

    public init() {}

    public var body: some View {
        Form {
            Section("Paste or import") {
                Text("One class per line: code,title,grade,capacity")
                    .font(.footnote).foregroundStyle(.secondary)
                TextEditor(text: $pastedText).frame(minHeight: 120)
                Button(working ? "Parsing…" : "Parse") { parse() }
                    .disabled(pastedText.isEmpty || working)
            }
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            if let saved {
                Section { Text("Saved \(saved) classes.").foregroundStyle(.green) }
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
                    Button("Confirm & save \(parsedRows.count) classes") {
                        Task { await save() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(working)
                }
            }
        }
        .navigationTitle("Class list")
    }

    private func parse() {
        working = true
        error = nil
        saved = nil
        let rows = pastedText
            .split(separator: "\n", omittingEmptySubsequences: true)
            .compactMap { line -> ParsedClass? in
                let parts = line.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                guard parts.count >= 2 else { return nil }
                let code  = parts[0]
                let title = parts[1]
                let grade = parts.count >= 3 ? Int(parts[2]) ?? 9 : 9
                let cap   = parts.count >= 4 ? Int(parts[3]) ?? 30 : 30
                return ParsedClass(id: UUID(), code: code, title: title, gradeLevel: grade, maxCapacity: cap)
            }
        parsedRows = rows
        if rows.isEmpty {
            error = "Couldn't parse any rows. Format: code,title,grade,capacity"
        }
        working = false
    }

    private struct ClassInsert: Encodable {
        let code: String
        let title: String
        let grade_level: Int
        let max_capacity: Int
    }

    private func save() async {
        working = true
        error = nil
        defer { working = false }
        let payload = parsedRows.map {
            ClassInsert(code: $0.code, title: $0.title, grade_level: $0.gradeLevel, max_capacity: $0.maxCapacity)
        }
        do {
            let client = await SupabaseAuthService.shared.supabase
            try await client.from("classes").insert(payload).execute()
            saved = payload.count
            parsedRows = []
            pastedText = ""
        } catch {
            self.error = "Couldn't save: \(error.localizedDescription)"
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
