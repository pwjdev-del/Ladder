import SwiftUI

// §11.3 — counselor schedule approval queue. Left rail: student list with
// conflict pips. Center: 7-period grid. Right: issue panel.

public struct QueuedSchedule: Identifiable, Sendable {
    public let id: UUID
    public let studentDisplayName: String
    public let conflictCount: Int
    public let submittedAt: Date
    public let state: String
}

public struct StudentQueueView: View {
    @State private var queue: [QueuedSchedule] = []
    @State private var selected: QueuedSchedule?

    public init() {}

    public var body: some View {
        NavigationSplitView {
            List(selection: $selected) {
                ForEach(queue) { row in
                    HStack {
                        Circle()
                            .fill(row.conflictCount > 0 ? .red : .green)
                            .frame(width: 8, height: 8)
                        Text(row.studentDisplayName)
                        Spacer()
                        if row.conflictCount > 0 {
                            Text("\(row.conflictCount)").font(.caption).foregroundStyle(.red)
                        }
                    }.tag(row)
                }
            }
            .navigationTitle("Queue")
        } detail: {
            if let sel = selected {
                ScheduleReviewView(schedule: sel)
            } else {
                ContentUnavailableView("Pick a submission", systemImage: "rectangle.on.rectangle",
                                       description: Text("Left rail ranked by conflict count."))
            }
        }
    }
}

public struct ScheduleReviewView: View {
    public let schedule: QueuedSchedule
    @State private var issues: [String] = []
    @State private var sendBackNote: String = ""

    public init(schedule: QueuedSchedule) { self.schedule = schedule }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(schedule.studentDisplayName).font(.title2)
            ScheduleGrid()
            Divider()
            if !issues.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Conflicts").font(.headline)
                    ForEach(issues, id: \.self) { Text("• \($0)").foregroundStyle(.red) }
                }
            }
            Spacer()
            HStack {
                Button("Send back") { /* TODO */ }
                    .buttonStyle(.bordered)
                TextField("Note for student", text: $sendBackNote).textFieldStyle(.roundedBorder)
                Button("Modify & approve") { /* TODO */ }.buttonStyle(.borderedProminent)
                Button("Approve") { /* TODO */ }.buttonStyle(.borderedProminent)
                    .disabled(!issues.isEmpty)
            }
        }
        .padding()
    }
}
