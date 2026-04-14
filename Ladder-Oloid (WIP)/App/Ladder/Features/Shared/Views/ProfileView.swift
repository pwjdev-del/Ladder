import SwiftUI
import SwiftData

// MARK: - Profile Tab Root

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query private var profiles: [StudentProfileModel]
    @Query private var applications: [ApplicationModel]
    @State private var showSignOutAlert = false
    @State private var showEditProfile = false
    @State private var showCareerPicker = false
    @State private var selectedTab: ProfileTab = .activities

    // Live profile from SwiftData (nil for brand-new user pre-onboarding)
    private var liveProfile: StudentProfileModel? { profiles.first }

    // Mapped to existing ProfileData shape — falls back to .sample when no live profile
    private var student: ProfileData {
        guard let p = liveProfile else { return ProfileData.sample }
        return ProfileData(
            firstName: p.firstName.isEmpty ? "Student" : p.firstName,
            lastName: p.lastName,
            grade: p.grade,
            school: p.schoolName ?? "—",
            careerPath: p.careerPath ?? "Not set",
            archetype: p.archetype ?? "Discovering",
            gpa: p.gpa ?? 0.0,
            satScore: p.satScore ?? 0,
            streak: p.streak,
            savedColleges: p.savedCollegeIds.count,
            applications: applications.filter { $0.studentProfile?.userId == liveProfile?.userId }.count,
            apCourses: p.apCourses,
            extracurriculars: p.extracurriculars
        )
    }

    enum ProfileTab: String, CaseIterable, Identifiable {
        case activities = "Activities"
        case saved = "Saved Colleges"
        case achievements = "Achievements"
        case roadmap = "Roadmap"
        var id: String { rawValue }

        var icon: String {
            switch self {
            case .activities: return "star.fill"
            case .saved: return "building.columns.fill"
            case .achievements: return "trophy.fill"
            case .roadmap: return "map.fill"
            }
        }
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .navigationBarHidden(sizeClass != .regular)
        .navigationTitle(sizeClass == .regular ? "Profile" : "")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task { await authManager.signOut() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(profile: liveProfile)
        }
        .sheet(isPresented: $showCareerPicker) {
            CareerPathPickerSheet(currentPath: liveProfile?.careerPath) { newPath in
                if let p = liveProfile {
                    p.careerPath = newPath
                }
                showCareerPicker = false
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                    statsGrid
                    menuSections
                }
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            HStack(alignment: .top, spacing: LadderSpacing.xl) {
                iPadLeftColumn
                    .frame(maxWidth: 360)

                iPadRightColumn
                    .frame(maxWidth: .infinity, alignment: .top)
            }
            .padding(.horizontal, LadderSpacing.xxl)
            .padding(.vertical, LadderSpacing.xl)
        }
    }

    private var iPadLeftColumn: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                // Large avatar card
                VStack(spacing: LadderSpacing.md) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [LadderColors.primary, LadderColors.primaryContainer],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .overlay(
                                Text(student.initials)
                                    .font(LadderTypography.displaySmall)
                                    .foregroundStyle(.white)
                            )

                        Text("\(student.streak)")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(LadderColors.secondaryFixed)
                            .clipShape(Capsule())
                    }

                    VStack(spacing: LadderSpacing.xxs) {
                        Text(student.fullName)
                            .font(LadderTypography.headlineSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("\(student.careerPath) · Grade \(student.grade)")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        Text(student.school)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)
                        Text(student.archetype)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.vertical, LadderSpacing.sm)
                    .background(LadderColors.primaryContainer.opacity(0.3))
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(LadderSpacing.lg)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl, style: .continuous))
                .ladderShadow(LadderElevation.ambient)

                // Stats summary cards (vertical)
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("STATS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    statRow(value: String(format: "%.1f", student.gpa), label: "GPA", icon: "chart.bar.fill")
                    statRow(value: "\(student.satScore)", label: "SAT", icon: "pencil.line")
                    statRow(value: "\(student.savedColleges)", label: "Saved Colleges", icon: "building.columns.fill")
                    statRow(value: "\(student.streak) days", label: "Streak", icon: "flame.fill")
                }

                // Quick actions
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("QUICK ACTIONS")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .labelTracking()

                    quickAction("Edit Profile", icon: "person.fill") {
                        showEditProfile = true
                    }
                    quickAction("My Saved Colleges", icon: "heart.fill") {
                        coordinator.navigate(to: .savedColleges)
                    }
                    quickAction("Retake Career Quiz", icon: "sparkles") {
                        coordinator.navigate(to: .careerQuiz)
                    }
                    quickAction("Change Career Path", icon: "arrow.triangle.swap") {
                        showCareerPicker = true
                    }
                    quickAction("Notifications", icon: "bell.fill") {
                        coordinator.navigate(to: .notificationSettings)
                    }
                    quickAction("4-Year Roadmap", icon: "map.fill") {
                        coordinator.navigate(to: .roadmap)
                    }
                    quickAction("Account Settings", icon: "gearshape.fill") {
                        coordinator.navigate(to: .profileSettings)
                    }
                    quickAction("Sign Out", icon: "rectangle.portrait.and.arrow.right", isDestructive: true) {
                        showSignOutAlert = true
                    }
                }
            }
        }
    }

    private func statRow(value: String, label: String, icon: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 32, height: 32)
                .background(LadderColors.primaryContainer.opacity(0.3))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text(label)
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    private func quickAction(_ title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isDestructive ? LadderColors.error : LadderColors.primary)
                    .frame(width: 24)

                Text(title)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(isDestructive ? LadderColors.error : LadderColors.onSurface)

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var iPadRightColumn: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            // Tabs
            HStack(spacing: LadderSpacing.sm) {
                ForEach(ProfileTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 14))
                            Text(tab.rawValue)
                                .font(LadderTypography.titleSmall)
                        }
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(
                            selectedTab == tab
                                ? LadderColors.primary
                                : LadderColors.surfaceContainerLow
                        )
                        .foregroundStyle(
                            selectedTab == tab
                                ? Color.white
                                : LadderColors.onSurface
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }

            ScrollView(showsIndicators: false) {
                Group {
                    switch selectedTab {
                    case .activities: activitiesTab
                    case .saved: savedCollegesTab
                    case .achievements: achievementsTab
                    case .roadmap: roadmapTab
                    }
                }
                .padding(.bottom, LadderSpacing.xxl)
            }
        }
    }

    private var activitiesTab: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            sectionHeader("AP Courses", count: student.apCourses.count)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                ForEach(student.apCourses, id: \.self) { course in
                    LadderCard {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "book.fill")
                                .foregroundStyle(LadderColors.primary)
                            Text(course)
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                        }
                    }
                }
            }

            sectionHeader("Extracurriculars", count: student.extracurriculars.count)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                ForEach(student.extracurriculars, id: \.self) { ec in
                    LadderCard {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(LadderColors.accentLime)
                            Text(ec)
                                .font(LadderTypography.bodyLarge)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private var savedCollegesTab: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Saved Colleges", count: student.savedColleges)
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    Text("View your full college list")
                        .font(LadderTypography.bodyLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("\(student.savedColleges) schools saved")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    LadderPrimaryButton("Open College List", icon: "arrow.right") {
                        coordinator.switchTab(to: .colleges)
                    }
                }
            }
        }
    }

    private var achievementsTab: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("Achievements", count: 4)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LadderSpacing.md) {
                achievementCard(title: "Streak Starter", subtitle: "7-day streak", icon: "flame.fill", color: LadderColors.accentLime)
                achievementCard(title: "College Explorer", subtitle: "10 colleges saved", icon: "building.columns.fill", color: LadderColors.primary)
                achievementCard(title: "Test Ready", subtitle: "SAT 1250+", icon: "pencil.line", color: LadderColors.secondaryFixed)
                achievementCard(title: "Path Finder", subtitle: "Career quiz done", icon: "sparkles", color: LadderColors.tertiary)
            }
        }
    }

    private func achievementCard(title: String, subtitle: String, icon: String, color: Color) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                Text(title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text(subtitle)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
    }

    private var roadmapTab: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            sectionHeader("4-Year Roadmap", count: nil)
            LadderCard {
                VStack(alignment: .leading, spacing: LadderSpacing.md) {
                    Text("Currently Grade \(student.grade)")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text("Track your high school journey and stay on top of milestones.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    LadderPrimaryButton("Open Roadmap", icon: "map.fill") {
                        coordinator.navigate(to: .roadmap)
                    }
                }
            }
        }
    }

    private func sectionHeader(_ title: String, count: Int?) -> some View {
        HStack {
            Text(title.uppercased())
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
            if let count {
                Text("(\(count))")
                    .font(LadderTypography.labelMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: LadderSpacing.md) {
            Text("PROFILE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()
                .frame(maxWidth: .infinity, alignment: .leading)

            // Avatar + info
            HStack(spacing: LadderSpacing.lg) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(student.initials)
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(.white)
                        )

                    // Streak badge
                    Text("\(student.streak)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSecondaryFixed)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.secondaryFixed)
                        .clipShape(Capsule())
                        .offset(x: 4, y: 4)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(student.fullName)
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(.white)

                    Text("\(student.careerPath) · Grade \(student.grade)")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(student.school)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Archetype badge
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.secondaryFixed)

                Text(student.archetype)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(.white.opacity(0.15))
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(LadderSpacing.lg)
        .padding(.top, LadderSpacing.xxl)
        .padding(.bottom, LadderSpacing.xxxxl)
        .background(
            RoundedRectangle(cornerRadius: LadderRadius.xxxl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        HStack(spacing: LadderSpacing.md) {
            statCard(value: String(format: "%.1f", student.gpa), label: "GPA", icon: "chart.bar.fill")
            statCard(value: "\(student.satScore)", label: "SAT", icon: "pencil.line")
            statCard(value: "\(student.savedColleges)", label: "Colleges", icon: "building.columns.fill")
            statCard(value: "\(student.streak) days", label: "Streak", icon: "flame.fill")
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.top, -LadderSpacing.xl)
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(LadderColors.primary)

            Text(value)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .ladderShadow(LadderElevation.ambient)
    }

    // MARK: - Menu Sections

    private var menuSections: some View {
        VStack(spacing: LadderSpacing.lg) {
            // Achievements (now visible on iPhone too — was iPad-only)
            iPhoneAchievementsSection

            // Academic Info
            menuSection("ACADEMICS") {
                menuRow("AP Courses", icon: "book.fill", detail: "\(student.apCourses.count) courses") {}
                menuRow("Extracurriculars", icon: "star.fill", detail: "\(student.extracurriculars.count) activities") {}
                menuRow("Test Scores", icon: "pencil.and.list.clipboard", detail: "SAT: \(student.satScore)") {}
            }

            // College Planning
            menuSection("COLLEGE PLANNING") {
                menuRow("My Saved Colleges", icon: "heart.fill", detail: "\(student.savedColleges) schools") {
                    coordinator.navigate(to: .savedColleges)
                }
                menuRow("Browse Colleges", icon: "building.columns", detail: nil) {
                    coordinator.switchTab(to: .colleges)
                }
                menuRow("4-Year Roadmap", icon: "map.fill", detail: "Grade \(student.grade)") {
                    coordinator.navigate(to: .roadmap)
                }
                menuRow("Application Tracker", icon: "doc.text.fill", detail: "\(student.applications) apps") {
                    coordinator.navigate(to: .decisionPortal)
                }
            }

            // Career
            menuSection("CAREER") {
                menuRow("Retake Career Quiz", icon: "sparkles", detail: nil) {
                    coordinator.navigate(to: .careerQuiz)
                }
                menuRow("Change Career Path", icon: "arrow.triangle.swap", detail: student.careerPath) {
                    showCareerPicker = true
                }
            }

            // Settings
            menuSection("SETTINGS") {
                menuRow("Edit Profile", icon: "person.fill", detail: nil) {
                    showEditProfile = true
                }
                menuRow("Account Settings", icon: "gearshape.fill", detail: nil) {
                    coordinator.navigate(to: .profileSettings)
                }
                menuRow("Notifications", icon: "bell.fill", detail: nil) {
                    coordinator.navigate(to: .notificationSettings)
                }
                menuRow("Sign Out", icon: "rectangle.portrait.and.arrow.right", detail: nil, isDestructive: true) {
                    showSignOutAlert = true
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.top, LadderSpacing.lg)
    }

    // Achievements section for iPhone (was previously iPad-only)
    private var iPhoneAchievementsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("ACHIEVEMENTS")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LadderSpacing.md) {
                    iPhoneAchievementBadge(title: "Streak Starter", subtitle: "\(student.streak)-day streak", icon: "flame.fill", color: LadderColors.accentLime)
                    iPhoneAchievementBadge(title: "College Explorer", subtitle: "\(student.savedColleges) saved", icon: "building.columns.fill", color: LadderColors.primary)
                    iPhoneAchievementBadge(title: "Test Ready", subtitle: "SAT \(student.satScore)", icon: "pencil.line", color: LadderColors.secondaryFixed)
                    iPhoneAchievementBadge(title: "Path Finder", subtitle: student.careerPath, icon: "sparkles", color: LadderColors.tertiary)
                }
                .padding(.horizontal, 1)
            }
        }
    }

    private func iPhoneAchievementBadge(title: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(color)
            Text(title)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text(subtitle)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .lineLimit(1)
        }
        .padding(LadderSpacing.md)
        .frame(width: 140, alignment: .leading)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
    }

    private func menuSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            VStack(spacing: 1) {
                content()
            }
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    private func menuRow(_ title: String, icon: String, detail: String?, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isDestructive ? LadderColors.error : LadderColors.primary)
                    .frame(width: 24)

                Text(title)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(isDestructive ? LadderColors.error : LadderColors.onSurface)

                Spacer()

                if let detail {
                    Text(detail)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Profile Data (Mock)

struct ProfileData {
    let firstName: String
    let lastName: String
    let grade: Int
    let school: String
    let careerPath: String
    let archetype: String
    let gpa: Double
    let satScore: Int
    let streak: Int
    let savedColleges: Int
    let applications: Int
    let apCourses: [String]
    let extracurriculars: [String]

    var fullName: String { "\(firstName) \(lastName)" }
    var initials: String { "\(firstName.prefix(1))\(lastName.prefix(1))" }

    static let sample = ProfileData(
        firstName: "Kathan",
        lastName: "Patel",
        grade: 10,
        school: "Wharton High School",
        careerPath: "Medical Path",
        archetype: "The Ambitious Healer",
        gpa: 3.8,
        satScore: 1250,
        streak: 14,
        savedColleges: 10,
        applications: 0,
        apCourses: ["AP Biology", "AP Calculus AB", "AP English Language"],
        extracurriculars: ["Volunteering", "Science Club", "Debate Team", "Hospital Shadowing"]
    )
}

#Preview {
    ProfileView()
        .environment(AppCoordinator())
        .environment(AuthManager())
}
