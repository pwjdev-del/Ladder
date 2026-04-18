import SwiftUI

public struct CounselorDashboardView: View {
    public init() {}
    public var body: some View {
        TabView {
            StudentQueueView().tabItem { Label("Queue", systemImage: "tray") }
            ClassListUploadView().tabItem { Label("Classes", systemImage: "tablecells") }
            SchedulingWindowView().tabItem { Label("Window", systemImage: "calendar") }
            CounselorInviteCodesView().tabItem { Label("Invites", systemImage: "envelope") }
        }
        .navigationTitle("Counselor")
    }
}
