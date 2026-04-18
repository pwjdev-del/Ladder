import SwiftUI

// §11.2 — counselor opens/closes scheduling windows. Required preconditions:
// teacher schedules + class catalog + prereqs uploaded (§11.1).

public struct SchedulingWindowView: View {
    @State private var opensAt: Date = Date()
    @State private var closesAt: Date = Date().addingTimeInterval(60 * 60 * 24 * 7)
    @State private var academicYear: String = "2026-2027"
    @State private var prereqsReady = false
    @State private var teacherSchedulesReady = false
    @State private var classCatalogReady = false

    public init() {}

    public var body: some View {
        Form {
            Section("Preconditions (§11.1)") {
                row("Teacher schedules uploaded", teacherSchedulesReady)
                row("Class catalog uploaded", classCatalogReady)
                row("Prereqs confirmed", prereqsReady)
            }
            Section("Window") {
                TextField("Academic year", text: $academicYear)
                DatePicker("Opens at", selection: $opensAt)
                DatePicker("Closes at", selection: $closesAt)
            }
            Section {
                Button("Open scheduling window") {
                    // TODO: POST /rest/v1/scheduling_windows
                }
                .disabled(!(prereqsReady && teacherSchedulesReady && classCatalogReady))
            }
        }
        .navigationTitle("Scheduling window")
    }

    private func row(_ label: String, _ ready: Bool) -> some View {
        HStack {
            Image(systemName: ready ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(ready ? .green : .secondary)
            Text(label)
        }
    }
}
