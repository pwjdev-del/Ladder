import SwiftUI

// §11.3 — counselor schedule approval queue. Left rail: student list with
// conflict pips. Center: 7-period grid. Right: issue panel.
//
// T024 iPad parity: NavigationSplitView is used on all size classes.
// On iPad (regular) NSV shows the sidebar + detail columns simultaneously.
// On iPhone (compact) NSV collapses to a single stack — identical UX to before.
// The sidebar column is pinned to 320pt so the detail column gets maximum space.

public struct QueuedSchedule: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let studentDisplayName: String
    /// The student's auth.uid — used by the D-002 SIA summary surface.
    public let studentAuthUid: String
    public let conflictCount: Int
    public let submittedAt: Date
    public let state: String
}

public struct StudentQueueView: View {
    /// The counselor's auth UID — forwarded to D-002 SIA surface.
    public let counselorAuthUid: String

    @Environment(\.horizontalSizeClass) private var sizeClass

    @State private var queue: [QueuedSchedule] = []
    @State private var selected: QueuedSchedule?
    /// When non-nil, show the SIA summary sheet for this student.
    @State private var summaryTarget: QueuedSchedule?

    public init(counselorAuthUid: String = "") {
        self.counselorAuthUid = counselorAuthUid
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: .constant(sizeClass == .regular ? .all : .automatic)) {
            queueList
                .navigationSplitViewColumnWidth(
                    min: 280, ideal: 320, max: 480
                )
        } detail: {
            if let sel = selected {
                ScheduleReviewView(schedule: sel)
            } else {
                ContentUnavailableView(
                    "Pick a submission",
                    systemImage: "rectangle.on.rectangle",
                    description: Text("Left rail ranked by conflict count.")
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
        .requireNonFounder()
        .sheet(item: $summaryTarget) { target in
            // D-002: routes to SIA-only summary — never to raw chat.
            // On iPad this renders as a .formSheet; MaxWidthContainer inside
            // StudentSiaSummaryView prevents content overflow at any sheet size.
            NavigationStack {
                StudentSiaSummaryView(
                    studentId: target.studentAuthUid,
                    studentDisplayName: target.studentDisplayName,
                    counselorAuthUid: counselorAuthUid
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { summaryTarget = nil }
                    }
                }
            }
        }
    }

    // MARK: - Queue list (extracted to its own computed property to avoid
    // type-checker ambiguity with ForEach overloads inside List closures)

    private var queueList: some View {
        List {
            ForEach(queueSnapshot, id: \.id) { row in
                queueRowView(row)
            }
        }
        .navigationTitle("Queue")
    }

    /// Local snapshot so ForEach gets a concrete [QueuedSchedule], not a
    /// @State property wrapper that the compiler might mis-infer as Binding.
    private var queueSnapshot: [QueuedSchedule] { queue }

    private func queueRowView(_ row: QueuedSchedule) -> some View {
        HStack {
            Circle()
                .fill(row.conflictCount > 0 ? Color.red : Color.green)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.studentDisplayName)
                Text("Tap SIA for overview")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if row.conflictCount > 0 {
                Text("\(row.conflictCount)").font(.caption).foregroundStyle(.red)
            }
            // SIA overview button (D-002 route)
            Button {
                summaryTarget = row
            } label: {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.accentColor)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .onTapGesture { selected = row }
    }
}

public struct ScheduleReviewView: View {
    public let schedule: QueuedSchedule
    @State private var issues: [String] = []
    @State private var sendBackNote: String = ""
    @State private var isWorking = false
    @State private var resultBanner: String?
    @State private var resultIsError = false
    @State private var resultIsAuditWarning = false

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
                    .foregroundStyle(
                        resultIsError ? Color.red
                        : resultIsAuditWarning ? Color.orange
                        : Color.green
                    )
                    .padding(.vertical, 4)
            }
            Spacer()
            HStack {
                if isWorking {
                    ProgressView().padding(.trailing, 4)
                }
                Button("Send back") {
                    Task { await transition(to: "RETURNED", reason: sendBackNote.isEmpty ? nil : sendBackNote) }
                }
                .buttonStyle(.bordered)
                .disabled(isWorking)
                TextField("Note for student", text: $sendBackNote).textFieldStyle(.roundedBorder)
                Button("Modify & approve") {
                    Task { await transition(to: "APPROVED_WITH_MODS", reason: nil) }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isWorking)
                Button("Approve") {
                    Task { await transition(to: "APPROVED", reason: nil) }
                }
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

            // S1#2 fix: audit-log insert is best-effort but failures must surface in UI.
            // The PATCH above already succeeded; we do NOT roll back. We do however
            // warn the counselor so an out-of-band audit correction can be filed.
            do {
                try await client
                    .from("schedule_events")
                    .insert(ScheduleEventInsert(
                        schedule_id: schedule.id.uuidString,
                        to_state: newState,
                        reason: reason
                    ))
                    .execute()

                resultIsError = false
                resultIsAuditWarning = false
                resultBanner = "Saved — \(newState.replacingOccurrences(of: "_", with: " ").lowercased())"
            } catch let auditError {
                Log.error("[audit-log fail] schedule_events insert failed for \(schedule.id): \(auditError)")
                resultIsError = false
                resultIsAuditWarning = true
                resultBanner = "\(newState.replacingOccurrences(of: "_", with: " ").lowercased()) saved, but audit log failed — please notify support"
            }
        } catch {
            resultIsError = true
            resultBanner = "Couldn't save: \(error.localizedDescription)"
        }
    }
}
