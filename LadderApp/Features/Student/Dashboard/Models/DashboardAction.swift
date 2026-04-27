import Foundation

// MARK: - DashboardAction
// Grade + career specific action tiles surfaced by ConnectionEngine.dashboardActions().
// Extracted from Features/Legacy/Dashboard/ViewModels/DashboardViewModel.swift (Batch 2).

struct DashboardAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let route: Route
}

// MARK: - DashboardDeadline
// Lightweight view-model struct for upcoming deadline tiles on the dashboard.

struct DashboardDeadline: Identifiable {
    let id = UUID()
    let collegeName: String
    let deadlineType: String
    let dateFormatted: String
    let daysRemaining: Int
}
