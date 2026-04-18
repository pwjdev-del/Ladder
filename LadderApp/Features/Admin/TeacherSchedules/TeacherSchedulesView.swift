import SwiftUI

public struct TeacherSchedulesView: View {
    public init() {}
    public var body: some View {
        List {
            ContentUnavailableView(
                "Teacher schedules",
                systemImage: "calendar.badge.clock",
                description: Text("Upload which teacher teaches which section + period + room. Required before opening a scheduling window (§11.1).")
            )
        }
    }
}
