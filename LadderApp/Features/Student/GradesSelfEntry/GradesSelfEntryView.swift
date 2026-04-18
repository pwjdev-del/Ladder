import SwiftUI

// §2.2 — STUDENT-SELF-ONLY grades. No counselor/admin/teacher/founder ever
// reads these through Ladder. Enforced at RLS (see 0002 migration) AND at
// the UI layer (this view only mounts for role=student).

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

    public init() {}

    public var body: some View {
        List {
            if grades.isEmpty {
                ContentUnavailableView(
                    "No grades yet",
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
        .sheet(isPresented: $showingNew) { NewGradeSheet { new in grades.append(new); showingNew = false } }
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
