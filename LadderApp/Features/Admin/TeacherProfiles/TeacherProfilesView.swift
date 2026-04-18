import SwiftUI

public struct TeacherProfilesView: View {
    public init() {}
    public var body: some View {
        List {
            ContentUnavailableView(
                "Teacher profiles",
                systemImage: "person.2.fill",
                description: Text("Admin-only per §5. Add a teacher to populate schedules and reviews.")
            )
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { /* TODO */ } label: { Image(systemName: "plus") }
            }
        }
    }
}
