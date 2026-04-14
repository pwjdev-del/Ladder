# Ladder — Agent Onboarding (READ FIRST)

## Hard rules (lint-enforced)

1. **NO hardcoded user data.** Never write "Kathan", "Medical Path", `gpa = 3.78`, `satScore = 1250` in any view or view model. Always read from `@Query StudentProfileModel`.
2. **NO empty Button closures.** Every Button must have a real action or be `.disabled(true)` with a tooltip.
3. **NO hardcoded years.** Use `Calendar.current.component(.year, from: Date())` — never `"2026"` or `"2027"`.
4. **NO direct NavigationPath pushes.** All navigation goes through `coordinator.navigate(to: .someRoute)`.
5. **All SwiftData writes must be `@MainActor`.**
6. **Sandbox sacred.** When users sign up/out, `wipeAllUserData()` runs. Never bypass this.

## Architecture

- `Navigation/` — Route enum + AppCoordinator + adaptive iPhone/iPad shells
- `Features/<Domain>/Views/` — SwiftUI views
- `Features/<Domain>/ViewModels/` — `@Observable` view models
- `Core/Auth/` — AuthManager + UserRole
- `Core/Data/` — SwiftData container
- `Core/Engines/` — domain logic (CollegeMatchCalculator, etc.)
- `Core/AI/` — AIService + chat
- `DesignSystem/` — `LadderColors`, `LadderTypography`, `LadderSpacing`, `LadderRadius`, components

## Adaptive layouts

Every view that lives in both iPhone and iPad uses:
```swift
@Environment(\.horizontalSizeClass) private var sizeClass

var body: some View {
    if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
}
```

## Grade gating

Use `GradeGate.isUnlocked(.feature, grade: profile.grade)` and show `LockedFeatureCard` for locked features. Don't expose senior features (LOCI, Mock Interview, Common App, FAFSA) to 9th/10th graders.

## Role gating

`UserRole` is set at sign-up. `LadderApp.swift` routes to:
- `.student` → `MainTabView`
- `.parent` → `ParentDashboardView`
- `.counselor` → `CounselorDashboardView`
- `.schoolAdmin` → `SchoolAdminDashboardView`

## Testing

Run `LadderTests` before merging. Add a test for any new route, engine, or wipe-affected entity.
