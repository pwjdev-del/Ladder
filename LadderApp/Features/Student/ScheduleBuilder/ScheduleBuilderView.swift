import SwiftUI

// §11.2 — student schedule builder. Quiz gate: cannot enter unless career
// quiz is dated within the current academic year. Window gate: cannot
// submit outside scheduling_windows.opens_at / closes_at.

public struct SchedulePick: Identifiable, Sendable {
    public let id: UUID
    public var classId: UUID
    public var period: String
    public var classTitle: String
}

public struct ScheduleBuilderView: View {
    @State private var picks: [SchedulePick] = []
    @State private var windowOpen = true       // from window_state API
    @State private var quizFresh = true        // from student profile
    @State private var submitState: String = "DRAFT"

    public init() {}

    public var body: some View {
        Group {
            if !quizFresh {
                ContentUnavailableView(
                    "Take the career quiz first",
                    systemImage: "pencil.and.list.clipboard",
                    description: Text("Your career quiz needs to be dated this school year before you can plan classes (§11.2).")
                )
            } else if !windowOpen {
                ContentUnavailableView(
                    "Scheduling window is closed",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Your counselor or admin opens this window when it's time to plan.")
                )
            } else {
                ScheduleBuilderBody(picks: $picks, submitState: $submitState)
            }
        }
        .navigationTitle("Next year's schedule")
    }
}

private struct ScheduleBuilderBody: View {
    @Binding var picks: [SchedulePick]
    @Binding var submitState: String

    var body: some View {
        List {
            Section("Periods") {
                ForEach(["P1", "P2", "P3", "P4", "P5", "P6", "P7"], id: \.self) { period in
                    HStack {
                        Text(period).font(.body.monospaced())
                        Spacer()
                        if let pick = picks.first(where: { $0.period == period }) {
                            Text(pick.classTitle).foregroundStyle(.primary)
                        } else {
                            Text("— pick a class —").foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section {
                Button("Submit for counselor review") {
                    submitState = "SUBMITTED"
                    // TODO: POST /rest/v1/schedules ; insert schedule_events row.
                }
                .disabled(picks.count < 7 || submitState != "DRAFT")
            }
        }
    }
}
