import SwiftUI

// §14.2 — two major sections: Schools (B2B tenants) + Solo people (B2C families).

public struct FounderDashboardView: View {
    public init() {}
    public var body: some View {
        TabView {
            SchoolsGridView().tabItem { Label("Schools", systemImage: "building.columns") }
            SoloPeopleView().tabItem { Label("Solo people", systemImage: "person.3") }
            FeatureFlagsRootView().tabItem { Label("Flags", systemImage: "flag") }
            VarunPanelView().tabItem { Label("Varun", systemImage: "link.circle") }
        }
        .navigationTitle("Founder backdoor")
        .navigationBarTitleDisplayMode(.inline)
    }
}
