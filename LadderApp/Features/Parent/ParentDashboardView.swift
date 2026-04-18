import SwiftUI

// §6.2 + §5 — parent is a viewer of linked student(s). Can switch between
// siblings via a selector. Cannot edit student data.

public struct LinkedStudent: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let displayName: String
    public let gradeLevel: Int
}

public struct ParentDashboardView: View {
    @State private var linked: [LinkedStudent] = []
    @State private var selected: LinkedStudent?

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack {
                if linked.count > 1 {
                    Picker("Child", selection: $selected) {
                        ForEach(linked) { Text($0.displayName).tag(Optional($0)) }
                    }.pickerStyle(.segmented).padding()
                }
                List {
                    Section("Career quiz") { Text("Linked child's result summary (view-only)") }
                    Section("Schedule") { Text("Linked child's approved schedule (view-only)") }
                    Section("Grades") {
                        Text("Grades are shown only if the student chooses to share (§5).")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    Section { NavigationLink("Add another child") { Text("Accept another invite code here.") } }
                }
            }
            .navigationTitle("Parent")
        }
    }
}
