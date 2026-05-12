import SwiftUI

// §11.3 — counselor schedule approval queue. Left rail: student list with
// conflict pips. Center: 7-period grid. Right: issue panel.

public struct QueuedSchedule: Identifiable, Sendable, Hashable {
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
    @State private var isWorking = false
    @State private var resultBanner: String?
    @State private var resultIsError = false

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
            if let banner = resultBanner {
                Text(banner)
                    .font(.callout)
                    .foregroundStyle(resultIsError ? .red : .green)
                    .padding(.vertical, 4)
            }
            Spacer()
            HStack {
                Button("Send back") { Task { await transition(to: "RETURNED", reason: sendBackNote.isEmpty ? nil : sendBackNote) } }
                    .buttonStyle(.bordered)
                    .disabled(isWorking)
                TextField("Note for student", text: $sendBackNote).textFieldStyle(.roundedBorder)
                Button("Modify & approve") { Task { await transition(to: "APPROVED_WITH_MODS", reason: nil) } }
                    .buttonStyle(.borderedProminent)
                    .disabled(isWorking)
                Button("Approve") { Task { await transition(to: "APPROVED", reason: nil) } }
                    .buttonStyle(.borderedProminent)
                    .disabled(isWorking || !issues.isEmpty)
            }
        }
        .padding()
    }

    private struct ScheduleStateUpdate: Encodable {
        let state: String
        let approved_at: String?
    }

    private struct ScheduleEventInsert: Encodable {
        let schedule_id: String
        let to_state: String
        let reason: String?
    }

    private func transition(to newState: String, reason: String?) async {
        isWorking = true
        resultBanner = nil
        defer { isWorking = false }

        let client = await SupabaseAuthService.shared.supabase
        let now = ISO8601DateFormatter().string(from: Date())
        let body = ScheduleStateUpdate(
            state: newState,
            approved_at: newState.hasPrefix("APPROVED") ? now : nil
        )

        do {
            try await client
                .from("schedules")
                .update(body)
                .eq("id", value: schedule.id.uuidString)
                .execute()

            try? await client
                .from("schedule_events")
                .insert(ScheduleEventInsert(
                    schedule_id: schedule.id.uuidString,
                    to_state: newState,
                    reason: reason
                ))
                .execute()

            resultIsError = false
            resultBanner = "Saved — \(newState.replacingOccurrences(of: "_", with: " ").lowercased())"
        } catch {
            resultIsError = true
            resultBanner = "Couldn't save: \(error.localizedDescription)"
        }
    }
}
