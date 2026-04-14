import SwiftUI

// MARK: - Main Tab View
// Adaptive: iPad uses NavigationSplitView sidebar, iPhone uses 5-tab TabView
// Detects device via horizontalSizeClass

struct MainTabView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                // iPad: Sidebar navigation
                iPadMainView()
            } else {
                // iPhone: Tab bar navigation
                iPhoneTabView()
            }
        }
        .onChange(of: horizontalSizeClass, initial: true) { _, newValue in
            coordinator.isIPad = (newValue == .regular)
        }
    }
}

// MARK: - iPhone Tab View

private struct iPhoneTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .bottom) {
            TabView(selection: $coordinator.selectedTab) {
                // Home Tab
                NavigationStack(path: $coordinator.homePath) {
                    DashboardView()
                        .navigationDestination(for: Route.self) { route in
                            sharedRouteToView(route)
                        }
                }
                .tag(Tab.home)

                // Tasks Tab
                NavigationStack(path: $coordinator.tasksPath) {
                    TasksView()
                        .navigationDestination(for: Route.self) { route in
                            sharedRouteToView(route)
                        }
                }
                .tag(Tab.tasks)

                // Colleges Tab
                NavigationStack(path: $coordinator.collegePath) {
                    CollegeDiscoveryView()
                        .navigationDestination(for: Route.self) { route in
                            sharedRouteToView(route)
                        }
                }
                .tag(Tab.colleges)

                // Advisor Tab
                NavigationStack(path: $coordinator.advisorPath) {
                    AdvisorHubView()
                        .navigationDestination(for: Route.self) { route in
                            sharedRouteToView(route)
                        }
                }
                .tag(Tab.advisor)

                // Profile Tab
                NavigationStack(path: $coordinator.profilePath) {
                    ProfileView()
                        .navigationDestination(for: Route.self) { route in
                            sharedRouteToView(route)
                        }
                }
                .tag(Tab.profile)
            }
            .toolbar(.hidden, for: .tabBar) // Hide default tab bar

            LadderTabBar(selectedTab: $coordinator.selectedTab)
        }
    }
}

// Route resolution is handled by sharedRouteToView() in iPadSidebarView.swift.
// Both iPhone and iPad use the exact same function — one source of truth.
