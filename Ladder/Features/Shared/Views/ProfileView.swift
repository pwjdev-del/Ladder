import SwiftUI

// MARK: - Profile Tab Root

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager
    @State private var showSignOutAlert = false

    // Mock student data
    private let student = ProfileData.sample

    var body: some View {
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
        .navigationBarHidden(true)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task { await authManager.signOut() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
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
            // Academic Info
            menuSection("ACADEMICS") {
                menuRow("AP Courses", icon: "book.fill", detail: "\(student.apCourses.count) courses") {}
                menuRow("Extracurriculars", icon: "star.fill", detail: "\(student.extracurriculars.count) activities") {}
                menuRow("Test Scores", icon: "pencil.and.list.clipboard", detail: "SAT: \(student.satScore)") {}
            }

            // Career & Planning
            menuSection("CAREER & PLANNING") {
                menuRow("Career Radar", icon: "scope", detail: "6 dimensions") {
                    coordinator.navigate(to: .wheelOfCareer)
                }
                menuRow("Upload Transcript", icon: "doc.text.magnifyingglass", detail: "AI analysis") {
                    coordinator.navigate(to: .transcriptUpload)
                }
                menuRow("Bright Futures", icon: "star.circle.fill", detail: "\(Int(47)) hrs logged") {
                    coordinator.navigate(to: .brightFuturesTracker)
                }
            }

            // College Planning
            menuSection("COLLEGE PLANNING") {
                menuRow("My College List", icon: "building.columns", detail: "\(student.savedColleges) schools") {
                    coordinator.switchTab(to: .colleges)
                }
                menuRow("4-Year Roadmap", icon: "map.fill", detail: "Grade \(student.grade)") {
                    coordinator.navigate(to: .roadmap)
                }
                menuRow("Application Tracker", icon: "doc.text.fill", detail: "\(student.applications) apps") {
                    coordinator.navigate(to: .decisionPortal)
                }
            }

            // Settings
            menuSection("SETTINGS") {
                menuRow("Edit Profile", icon: "person.fill", detail: nil) {
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
