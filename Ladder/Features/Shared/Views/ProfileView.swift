import SwiftUI
import SwiftData
import PhotosUI

// MARK: - Profile Tab Root

struct ProfileView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager
    @Environment(\.modelContext) private var context
    @Query var profiles: [StudentProfileModel]
    @State private var showSignOutAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var profileImage: UIImage?

    private var student: StudentProfileModel? { profiles.first }

    var body: some View {
        ZStack(alignment: .top) {
            LadderColors.surface.ignoresSafeArea()

            if let student {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection(student)
                        statsGrid(student)
                        menuSections(student)
                    }
                    .padding(.bottom, 120)
                }
            } else {
                emptyState
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
        .onAppear { loadProfileImage() }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = uiImage
                    saveProfileImage(uiImage)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 100, height: 100)
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 40))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Profile Yet")
                .font(LadderTypography.headlineMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Complete onboarding to set up your student profile and unlock all features.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.xxl)

            LadderPrimaryButton("Get Started", icon: "arrow.right") {
                coordinator.navigate(to: .profileSettings)
            }
            .padding(.horizontal, LadderSpacing.xxl)

            Spacer()
        }
    }

    // MARK: - Header

    private func headerSection(_ student: StudentProfileModel) -> some View {
        VStack(spacing: LadderSpacing.md) {
            Text("PROFILE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.secondaryFixed)
                .labelTracking()
                .frame(maxWidth: .infinity, alignment: .leading)

            // Avatar + info
            HStack(spacing: LadderSpacing.lg) {
                ZStack(alignment: .bottomTrailing) {
                    // Profile photo or initials fallback
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(.white.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Text(initials(for: student))
                                            .font(LadderTypography.headlineMedium)
                                            .foregroundStyle(.white)
                                    )
                            }

                            // Camera badge
                            ZStack {
                                Circle()
                                    .fill(LadderColors.secondaryFixed)
                                    .frame(width: 26, height: 26)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(LadderColors.onSecondaryFixed)
                            }
                            .offset(x: 2, y: 2)
                        }
                    }

                    // Streak badge
                    if student.streak > 0 {
                        Text("\(student.streak)")
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xxs)
                            .background(LadderColors.secondaryFixed)
                            .clipShape(Capsule())
                            .offset(x: 4, y: -10)
                    }
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(student.fullName)
                        .font(LadderTypography.headlineMedium)
                        .foregroundStyle(.white)

                    Text("\(student.careerPath ?? "Undecided") \u{00B7} Grade \(student.grade)")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(.white.opacity(0.7))

                    if let school = student.schoolName {
                        Text(school)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Archetype badge
            if let archetype = student.archetype {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(LadderColors.secondaryFixed)

                    Text(archetype)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(.white.opacity(0.15))
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Level badge
            LevelBadgeView(xp: student.totalXP)
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

    private func statsGrid(_ student: StudentProfileModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            statCard(
                value: student.gpa.map { String(format: "%.1f", $0) } ?? "--",
                label: "GPA",
                icon: "chart.bar.fill"
            )
            statCard(
                value: student.satScore.map { "\($0)" } ?? "--",
                label: "SAT",
                icon: "pencil.line"
            )
            statCard(
                value: "\(student.savedCollegeIds.count)",
                label: "Colleges",
                icon: "building.columns.fill"
            )
            statCard(
                value: student.streak > 0 ? "\(student.streak)d" : "--",
                label: "Streak",
                icon: "flame.fill"
            )
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

    // MARK: - Menu Sections (Simplified: My Info + Tools)

    private func menuSections(_ student: StudentProfileModel) -> some View {
        VStack(spacing: LadderSpacing.lg) {

            // Section 1: My Info
            menuSection("MY INFO") {
                menuRow("Edit Profile", icon: "person.fill", detail: student.fullName) {
                    coordinator.navigate(to: .profileSettings)
                }
                menuRow("Parent Access", icon: "figure.2.circle", detail: "Invite your parent") {
                    coordinator.navigate(to: .parentAccess)
                }
                menuRow("Career Quiz", icon: "sparkle.magnifyingglass", detail: student.careerPath ?? "Take quiz") {
                    coordinator.navigate(to: .careerQuiz)
                }
                menuRow("College Preferences", icon: "slider.horizontal.3", detail: student.preferredSize != nil ? "Set" : "Take quiz") {
                    coordinator.navigate(to: .collegePreferenceQuiz)
                }
                menuRow("Career Radar", icon: "scope", detail: "6 dimensions") {
                    coordinator.navigate(to: .wheelOfCareer)
                }
                menuRow("SAT Score Tracker", icon: "chart.line.uptrend.xyaxis", detail: student.satScore.map { "\($0)" } ?? "Add score") {
                    coordinator.navigate(to: .satScoreTracker)
                }
                menuRow("Graduation Tracker", icon: "checkmark.seal.fill", detail: "FL 24 credits") {
                    coordinator.navigate(to: .graduationTracker)
                }
            }

            // Section 2: Tools
            menuSection("TOOLS") {
                menuRow("My College List", icon: "building.columns", detail: "\(student.savedCollegeIds.count) saved") {
                    coordinator.switchTab(to: .colleges)
                }
                menuRow("4-Year Roadmap", icon: "map.fill", detail: "Grade \(student.grade)") {
                    coordinator.navigate(to: .roadmap)
                }
                menuRow("Bright Futures", icon: "star.circle.fill", detail: "Track hours") {
                    coordinator.navigate(to: .brightFuturesTracker)
                }
                menuRow("Scholarship Search", icon: "banknote.fill", detail: "Find funding") {
                    coordinator.navigate(to: .scholarshipSearch)
                }
                menuRow("Rec Letters", icon: "envelope.badge.person.crop", detail: "Track LoRs") {
                    coordinator.navigate(to: .lorTracker)
                }
                menuRow("Find a Counselor", icon: "person.badge.plus", detail: "Marketplace") {
                    coordinator.navigate(to: .counselorMarketplace)
                }
                menuRow("Notifications", icon: "bell.badge.fill", detail: nil) {
                    coordinator.navigate(to: .notificationCenter)
                }
                menuRow("Sign Out", icon: "rectangle.portrait.and.arrow.right", detail: nil, isDestructive: true) {
                    showSignOutAlert = true
                }
            }

            // Section 3: Coming Up (preview features for this grade)
            comingUpSection(student)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.top, LadderSpacing.lg)
    }

    // MARK: - Coming Up Section

    @ViewBuilder
    private func comingUpSection(_ student: StudentProfileModel) -> some View {
        let previewFeatures = GradeFeatureManager.shared.previewFeatures(for: student.grade)

        if !previewFeatures.isEmpty {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("COMING UP")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .labelTracking()

                VStack(spacing: 1) {
                    ForEach(previewFeatures, id: \.rawValue) { feature in
                        comingUpRow(feature, grade: student.grade)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            }
        }
    }

    @State private var expandedPreviewFeature: String? = nil

    private func comingUpRow(_ feature: GradeFeatureManager.Feature, grade: Int) -> some View {
        let unlockGrade = GradeFeatureManager.shared.unlockGrade(for: feature) ?? (grade + 1)
        let isExpanded = expandedPreviewFeature == feature.rawValue

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if expandedPreviewFeature == feature.rawValue {
                    expandedPreviewFeature = nil
                } else {
                    expandedPreviewFeature = feature.rawValue
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: LadderSpacing.md) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.displayName)
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Unlocks in \(unlockGrade)\(ordinalSuffix(unlockGrade)) grade")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.primary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.md)

                if isExpanded {
                    Text(feature.featureDescription)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.bottom, LadderSpacing.md)
                        .padding(.leading, 24 + LadderSpacing.md)
                }
            }
            .background(LadderColors.surfaceContainerLow)
        }
        .buttonStyle(.plain)
    }

    private func ordinalSuffix(_ n: Int) -> String {
        switch n {
        case 11, 12, 13: return "th"
        default:
            switch n % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }

    // MARK: - Helpers

    private func initials(for student: StudentProfileModel) -> String {
        let f = student.firstName.prefix(1)
        let l = student.lastName.prefix(1)
        return "\(f)\(l)"
    }

    // MARK: - Profile Image Helpers

    private func profileImageURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile_photo.jpg")
    }

    private func saveProfileImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = profileImageURL()
        try? data.write(to: url)
        UserDefaults.standard.set(url.path, forKey: "profile_image_path")
    }

    private func loadProfileImage() {
        guard let path = UserDefaults.standard.string(forKey: "profile_image_path"),
              FileManager.default.fileExists(atPath: path),
              let data = FileManager.default.contents(atPath: path),
              let image = UIImage(data: data) else { return }
        profileImage = image
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

#Preview {
    ProfileView()
        .environment(AppCoordinator())
        .environment(AuthManager())
        .modelContainer(for: StudentProfileModel.self, inMemory: true)
}
