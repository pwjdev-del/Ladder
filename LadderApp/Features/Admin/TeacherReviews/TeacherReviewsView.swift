import SwiftUI

// §5 — admin ONLY (hard rule). Counselors cannot read or write here.

public struct TeacherReviewsView: View {
    public init() {}
    public var body: some View {
        List {
            ContentUnavailableView(
                "Teacher reviews",
                systemImage: "text.badge.checkmark",
                description: Text("Admin-exclusive. Grades are never shown — this is performance review data only.")
            )
        }
    }
}
