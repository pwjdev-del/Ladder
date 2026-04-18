import SwiftUI
import SwiftData

// MARK: - Academic Resume View
// Auto-populates from StudentProfileModel. Matches academic_resume_preview Stitch design.

struct AcademicResumeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = AcademicResumeViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    resumePreview
                    editSections
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.sm)
                .padding(.bottom, 160)
            }

            // Fixed bottom actions
            VStack {
                Spacer()
                VStack(spacing: LadderSpacing.sm) {
                    ShareLink(item: viewModel.resumeText) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 16, weight: .bold))
                            Text("SHARE AS PDF")
                                .font(LadderTypography.labelLarge)
                                .labelTracking()
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.lg)
                        .background(
                            LinearGradient(
                                colors: [LadderColors.primary, LadderColors.primaryContainer],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                        .ladderShadow(LadderElevation.primaryGlow)
                    }

                    Button {
                        UIPasteboard.general.string = viewModel.resumeText
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 16))
                            Text("Copy Text")
                                .font(LadderTypography.titleSmall)
                        }
                        .foregroundStyle(LadderColors.onSurface)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.sm)
                    }
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.md)
                .background(LadderColors.surface.opacity(0.9))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Academic Resume")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear {
            viewModel.loadFromProfile(context: modelContext)
        }
    }

    // MARK: - Resume Preview (Paper Card)

    private var resumePreview: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                // Header
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(viewModel.studentName)
                        .font(LadderTypography.headlineLarge)
                        .foregroundStyle(LadderColors.onSurface)
                    if !viewModel.email.isEmpty {
                        Text(viewModel.email)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                .padding(.bottom, LadderSpacing.sm)

                // Education
                if viewModel.showEducation {
                    resumeSection("EDUCATION") {
                        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                            HStack {
                                Text(viewModel.schoolName)
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                Text("2021 - Present")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                            HStack(spacing: LadderSpacing.xs) {
                                Text("High School Diploma")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                if !viewModel.gpa.isEmpty {
                                    Text("GPA \(viewModel.gpa)")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.primary)
                                }
                            }
                            if !viewModel.apCourses.isEmpty {
                                Text("AP: \(viewModel.apCourses.joined(separator: ", "))")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }

                // Activities
                if viewModel.showActivities {
                    resumeSection("ACTIVITIES") {
                        ForEach(viewModel.extracurriculars) { activity in
                            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                HStack {
                                    Text(activity.name)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                    Text(activity.role)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                                if !activity.description.isEmpty {
                                    Text(activity.description)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                }

                // Awards + Skills bento
                if viewModel.showAwards || viewModel.showSkills {
                    HStack(alignment: .top, spacing: LadderSpacing.md) {
                        if viewModel.showAwards && !viewModel.awards.isEmpty {
                            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                                Text("AWARDS")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.tertiary)
                                    .labelTracking()
                                ForEach(viewModel.awards, id: \.self) { award in
                                    Text(award)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                }
                            }
                            .padding(LadderSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                        }

                        if viewModel.showSkills && !viewModel.skills.isEmpty {
                            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                                Text("SKILLS")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.tertiary)
                                    .labelTracking()
                                Text(viewModel.skills.joined(separator: ", "))
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            .padding(LadderSpacing.sm)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm))
                        }
                    }
                }
            }
            .padding(LadderSpacing.xl)
            .background(LadderColors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .ladderShadow(LadderElevation.ambient)

            // Badge
            Text("Updated from your profile")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSecondaryFixed)
                .labelTracking()
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xs)
                .background(LadderColors.secondaryFixed)
                .clipShape(Capsule())
                .offset(x: -LadderSpacing.md, y: -LadderSpacing.sm)
        }
    }

    private func resumeSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.primary)
                .labelTracking()
            content()
        }
    }

    // MARK: - Edit Sections

    private var editSections: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            Text("Edit Sections")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            VStack(spacing: LadderSpacing.xxs) {
                sectionToggle("Education", icon: "graduationcap", isOn: $viewModel.showEducation)
                sectionToggle("Activities", icon: "person.3", isOn: $viewModel.showActivities)
                sectionToggle("Leadership", icon: "brain.head.profile", isOn: $viewModel.showLeadership)
                sectionToggle("Awards", icon: "medal", isOn: $viewModel.showAwards)
                sectionToggle("Skills", icon: "wrench.and.screwdriver", isOn: $viewModel.showSkills)
            }
            .padding(LadderSpacing.xxs)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
    }

    private func sectionToggle(_ title: String, icon: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(isOn.wrappedValue ? LadderColors.primary : LadderColors.onSurfaceVariant)
                .frame(width: 40, height: 40)
                .background(isOn.wrappedValue ? LadderColors.primaryContainer.opacity(0.3) : LadderColors.surfaceVariant)
                .clipShape(Circle())

            Text(title)
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(LadderColors.primary)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        AcademicResumeView()
    }
}
