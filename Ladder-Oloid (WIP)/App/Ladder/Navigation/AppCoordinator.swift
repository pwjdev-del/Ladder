import SwiftUI

// MARK: - App Coordinator
// Manages global auth state and per-tab navigation stacks
// Supports both iPhone (tabs) and iPad (sidebar) navigation

@Observable
final class AppCoordinator {

    // MARK: - Auth State

    enum AuthState {
        case loading
        case unauthenticated
        case onboarding
        case authenticated
    }

    var authState: AuthState = .loading

    // MARK: - iPhone Tab Navigation

    var selectedTab: Tab = .home

    // Each tab has its own navigation path for independent stacks
    var homePath = NavigationPath()
    var tasksPath = NavigationPath()
    var collegePath = NavigationPath()
    var advisorPath = NavigationPath()
    var profilePath = NavigationPath()

    // MARK: - iPad Sidebar Navigation

    var selectedSidebarItem: SidebarItem = .dashboard
    var sidebarVisibility: NavigationSplitViewVisibility = .automatic
    var detailPath = NavigationPath()

    // MARK: - Device Mode

    /// Set to true when running on iPad (regular size class)
    var isIPad = false

    // MARK: - Navigation Helpers (unified)

    func navigate(to route: Route) {
        if isIPad {
            detailPath.append(route)
        } else {
            switch selectedTab {
            case .home: homePath.append(route)
            case .tasks: tasksPath.append(route)
            case .colleges: collegePath.append(route)
            case .advisor: advisorPath.append(route)
            case .profile: profilePath.append(route)
            }
        }
    }

    func popToRoot() {
        if isIPad {
            detailPath = NavigationPath()
        } else {
            switch selectedTab {
            case .home: homePath = NavigationPath()
            case .tasks: tasksPath = NavigationPath()
            case .colleges: collegePath = NavigationPath()
            case .advisor: advisorPath = NavigationPath()
            case .profile: profilePath = NavigationPath()
            }
        }
    }

    func switchTab(to tab: Tab) {
        if selectedTab == tab {
            popToRoot()
        } else {
            selectedTab = tab
        }
    }

    // MARK: - Navigation Helpers (iPad)

    func navigateDetail(to route: Route) {
        detailPath.append(route)
    }

    func popDetailToRoot() {
        detailPath = NavigationPath()
    }

    func switchSidebarItem(to item: SidebarItem) {
        if selectedSidebarItem == item {
            popDetailToRoot()
        } else {
            selectedSidebarItem = item
            detailPath = NavigationPath()
        }
    }
}
