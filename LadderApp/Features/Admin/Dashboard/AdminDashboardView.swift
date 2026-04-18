import SwiftUI

public struct AdminDashboardView: View {
    @State private var showingSuccessMetrics = false

    public init() {}

    public var body: some View {
        TabView {
            StudentQueueView().tabItem { Label("Queue", systemImage: "tray") }
            ClassListUploadView().tabItem { Label("Classes", systemImage: "tablecells") }
            TeacherProfilesView().tabItem { Label("Teachers", systemImage: "person.2") }
            TeacherSchedulesView().tabItem { Label("Schedules", systemImage: "calendar") }
            TeacherReviewsView().tabItem { Label("Reviews", systemImage: "text.badge.checkmark") }
            CounselorInviteCodesView().tabItem { Label("Invites", systemImage: "envelope") }
        }
        .navigationTitle("Admin")
        .sheet(isPresented: $showingSuccessMetrics) { SuccessMetricsPopupView() }
        .onAppear { evaluateSuccessMetricsTrigger() }
    }

    private func evaluateSuccessMetricsTrigger() {
        // §13 — if last update ≥ N months ago, force the popup.
        // TODO: check success_metrics.submitted_at vs now; if stale, show.
    }
}
