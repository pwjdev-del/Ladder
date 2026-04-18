import SwiftUI

// MARK: - App Coordinator
// Manages global auth state and per-tab navigation stacks for all roles

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

    // MARK: - Student Tab Navigation

    var selectedTab: Tab = .home

    // Each tab has its own navigation path for independent stacks
    var homePath = NavigationPath()
    var tasksPath = NavigationPath()
    var collegePath = NavigationPath()
    var advisorPath = NavigationPath()
    var profilePath = NavigationPath()

    // MARK: - Parent Tab Navigation

    var selectedParentTab: ParentTab = .overview

    var overviewPath = NavigationPath()
    var financesPath = NavigationPath()
    var parentSettingsPath = NavigationPath()

    // MARK: - Counselor Tab Navigation

    var selectedCounselorTab: CounselorTab = .caseload

    var caseloadPath = NavigationPath()
    var classesPath = NavigationPath()
    var deadlinesPath = NavigationPath()
    var counselorProfilePath = NavigationPath()

    // MARK: - Admin Tab Navigation

    var selectedAdminTab: AdminTab = .dashboard

    var dashboardPath = NavigationPath()
    var studentsPath = NavigationPath()
    var reportsPath = NavigationPath()

    // MARK: - Student Navigation Helpers

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

    // MARK: - Role-Aware Navigation

    func navigateForRole(to route: Route, role: UserRole) {
        switch role {
        case .student:
            navigate(to: route)

        case .parent:
            switch selectedParentTab {
            case .overview: overviewPath.append(route)
            case .finances: financesPath.append(route)
            case .settings: parentSettingsPath.append(route)
            }

        case .counselor:
            switch selectedCounselorTab {
            case .caseload: caseloadPath.append(route)
            case .classes: classesPath.append(route)
            case .deadlines: deadlinesPath.append(route)
            case .profile: counselorProfilePath.append(route)
            }

        case .schoolAdmin:
            switch selectedAdminTab {
            case .dashboard: dashboardPath.append(route)
            case .students: studentsPath.append(route)
            case .reports: reportsPath.append(route)
            }
        }
    }

    // MARK: - Parent Navigation Helpers

    func popToRootParent() {
        switch selectedParentTab {
        case .overview: overviewPath = NavigationPath()
        case .finances: financesPath = NavigationPath()
        case .settings: parentSettingsPath = NavigationPath()
        }
    }

    func switchParentTab(to tab: ParentTab) {
        if selectedParentTab == tab {
            popToRootParent()
        } else {
            selectedParentTab = tab
        }
    }

    // MARK: - Counselor Navigation Helpers

    func popToRootCounselor() {
        switch selectedCounselorTab {
        case .caseload: caseloadPath = NavigationPath()
        case .classes: classesPath = NavigationPath()
        case .deadlines: deadlinesPath = NavigationPath()
        case .profile: counselorProfilePath = NavigationPath()
        }
    }

    func switchCounselorTab(to tab: CounselorTab) {
        if selectedCounselorTab == tab {
            popToRootCounselor()
        } else {
            selectedCounselorTab = tab
        }
    }

    // MARK: - Admin Navigation Helpers

    func popToRootAdmin() {
        switch selectedAdminTab {
        case .dashboard: dashboardPath = NavigationPath()
        case .students: studentsPath = NavigationPath()
        case .reports: reportsPath = NavigationPath()
        }
    }

    func switchAdminTab(to tab: AdminTab) {
        if selectedAdminTab == tab {
            popToRootAdmin()
        } else {
            selectedAdminTab = tab
        }
    }
}
