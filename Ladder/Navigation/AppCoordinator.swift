import SwiftUI

// MARK: - App Coordinator
// Manages global auth state and per-tab navigation stacks

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

    // MARK: - Tab Navigation

    var selectedTab: Tab = .home

    // Each tab has its own navigation path for independent stacks
    var homePath = NavigationPath()
    var tasksPath = NavigationPath()
    var collegePath = NavigationPath()
    var advisorPath = NavigationPath()
    var profilePath = NavigationPath()

    // MARK: - Navigation Helpers

    func navigate(to route: Route) {
        switch selectedTab {
        case .home: homePath.append(route)
        case .tasks: tasksPath.append(route)
        case .colleges: collegePath.append(route)
        case .advisor: advisorPath.append(route)
        case .profile: profilePath.append(route)
        }
    }

    func popToRoot() {
        switch selectedTab {
        case .home: homePath = NavigationPath()
        case .tasks: tasksPath = NavigationPath()
        case .colleges: collegePath = NavigationPath()
        case .advisor: advisorPath = NavigationPath()
        case .profile: profilePath = NavigationPath()
        }
    }

    func switchTab(to tab: Tab) {
        if selectedTab == tab {
            popToRoot()
        } else {
            selectedTab = tab
        }
    }
}
