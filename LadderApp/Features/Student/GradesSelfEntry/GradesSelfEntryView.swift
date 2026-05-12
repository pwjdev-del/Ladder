import SwiftUI
import Supabase

// §2.2 — STUDENT-SELF-ONLY grades. No counselor/admin/teacher/founder ever
// reads these through Ladder. Enforced at RLS (see 0002 migration) AND at
// the UI layer (this view only mounts for role=student).
//
// Bug-fix (S1-6): grades now persist server-side via `record_grade` RPC and
// reload on every appear via `list_my_grades`. Previously they were @State only
// and disappeared on navigation.

public struct GradeEntry: Identifiable, Sendable {
    public let id: UUID
    public var subject: String
    public var score: String
    public var period: String
    public let enteredAt: Date
}

public struct GradesSelfEntryView: View {
    @State private var grades: [GradeEntry] = []
    @State private var showingNew = false
    @State private var isLoading = true
    @State private var error: String?

    public init() {}

    public var body: some View {
        List {
            if let error {
                Section { Text(error).foregroundStyle(.red) }
            }
            if grades.isEmpty {
                ContentUnavailableView(
                    isLoading ? "Loading…" : "No grades yet",
                    systemImage: "square.and.pencil",
                    description: Text("Only you see your grades. The AI uses them to suggest next year's classes (§9).")
                )
            } else {
                ForEach(grades) { entry in
                    HStack {
                        Text(entry.subject)
                        Spacer()
                        Text(entry.score).font(.body.monospaced())
                        Text(entry.period).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("My grades")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingNew = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $showingNew) {
            NewGradeSheet { new in
                Task {
                    await save(new)
                    showingNew = false
                }
            }
        }
        .task { await load() }
        .refreshable { await load() }
    }

    // MARK: - Backend

    private struct GradeRow: Decodable {
        let id: UUID
        let subject: String
        let period: String?
        let score: String
        let entered_at: Date
    }

    private struct RecordGradeParams: Encodable {
        let p_subject: String
        let p_period: String
        let p_score: String
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        let client = await SupabaseAuthService.shared.supabase
        do {
            let response = try await client.rpc("list_my_grades").execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let rows = try decoder.decode([GradeRow].self, from: response.data)
            grades = rows.map {
                GradeEntry(
                    id: $0.id,
                    subject: $0.subject,
                    score: $0.score,
                    period: $0.period ?? "",
                    enteredAt: $0.entered_at
                )
            }
            error = nil
        } catch {
            self.error = "Couldn't load grades: \(error.localizedDescription)"
        }
    }

    private func save(_ entry: GradeEntry) async {
        let client = await SupabaseAuthService.shared.supabase
        do {
            _ = try await client
                .rpc("record_grade", params: RecordGradeParams(
                    p_subject: entry.subject,
                    p_period: entry.period,
                    p_score: entry.score
                ))
                .execute()
            await load()
        } catch {
            self.error = "Couldn't save grade: \(error.localizedDescription)"
        }
    }
}

private struct NewGradeSheet: View {
    @State private var subject = ""
    @State private var score = ""
    @State private var period = "Q1"
    let onSave: (GradeEntry) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Subject", text: $subject)
                TextField("Grade / score", text: $score)
                Picker("Period", selection: $period) {
                    ForEach(["Q1", "Q2", "Q3", "Q4"], id: \.self) { Text($0).tag($0) }
                }
            }
            .navigationTitle("Add a grade")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(GradeEntry(id: UUID(), subject: subject, score: score, period: period, enteredAt: Date()))
                    }
                    .disabled(subject.isEmpty || score.isEmpty)
                }
            }
        }
    }
}
