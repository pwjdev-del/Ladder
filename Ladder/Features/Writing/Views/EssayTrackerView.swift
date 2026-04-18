import SwiftUI
import SwiftData

// MARK: - Essay Tracker View

struct EssayTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = EssayTrackerViewModel()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Saved colleges missing essays banner
                    if !viewModel.collegesToPrompt.isEmpty {
                        savedCollegeBanners
                    }

                    // Progress header
                    progressHeader

                    // Grouped essay list
                    if viewModel.essays.isEmpty {
                        emptyState
                    } else {
                        collegeGroupList
                    }

                    Spacer().frame(height: LadderSpacing.xxxxl)
                }
                .padding(.horizontal, LadderSpacing.md)
                .padding(.top, LadderSpacing.md)
            }

            // FAB
            addButton
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
                Text("Essay Tracker")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .task {
            viewModel.loadData(context: context)
        }
        .sheet(isPresented: $viewModel.showAddSheet) {
            addEssaySheet
        }
        .sheet(isPresented: $viewModel.showEditorSheet) {
            if let essay = viewModel.selectedEssay {
                essayEditorSheet(essay: essay)
            }
        }
    }

    // MARK: - Saved College Banners

    private var savedCollegeBanners: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(viewModel.collegesToPrompt, id: \.name) { college in
                let essayCount = Int(college.supplementalEssaysCount ?? "0") ?? 0
                Button {
                    viewModel.autoCreateEssays(for: college, context: context)
                } label: {
                    HStack(spacing: LadderSpacing.md) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.primary)

                        VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                            Text(college.name)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Text(essayCount > 0
                                 ? "Has \(essayCount) supplemental essay\(essayCount == 1 ? "" : "s"). Tap to create tracking slots."
                                 : "Saved college. Tap to create essay tracking slots.")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: LadderSpacing.md, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        LadderCard(elevated: true) {
            HStack(spacing: LadderSpacing.lg) {
                CircularProgressView(
                    progress: viewModel.progressPercentage,
                    label: "\(viewModel.completedEssays)/\(viewModel.totalEssays)",
                    sublabel: "Done",
                    size: 72
                )

                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text("Essay Progress")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    Text(viewModel.totalEssays == 0
                         ? "Add your first essay to get started"
                         : "\(viewModel.completedEssays) of \(viewModel.totalEssays) essays complete")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                Spacer()
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xxl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 90, height: 90)
                Image(systemName: "doc.text")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No essays yet")
                .font(LadderTypography.titleLarge)
                .foregroundStyle(LadderColors.onSurface)

            Text("Tap the + button to add supplemental essays\nfor your college applications.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - College Group List

    private var collegeGroupList: some View {
        VStack(spacing: LadderSpacing.lg) {
            ForEach(viewModel.groupedByCollege, id: \.collegeName) { group in
                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                    // College section header
                    HStack(spacing: LadderSpacing.xs) {
                        Text(group.collegeName)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("(\(group.essays.count) essay\(group.essays.count == 1 ? "" : "s"))")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    VStack(spacing: LadderSpacing.xs) {
                        ForEach(group.essays) { essay in
                            essayCard(essay)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Essay Card

    private func essayCard(_ essay: EssayModel) -> some View {
        Button {
            viewModel.openEditor(for: essay)
        } label: {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                // Prompt text
                Text(essay.prompt)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                HStack(spacing: LadderSpacing.md) {
                    // Word count progress
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "text.word.spacing")
                            .font(.system(size: 12))
                            .foregroundStyle(LadderColors.onSurfaceVariant)

                        Text("\(essay.wordCount)/\(essay.wordLimit) words")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    // Status chip
                    statusChip(for: essay)
                }

                // Word count bar
                LinearProgressBar(
                    progress: min(Double(essay.wordCount) / Double(max(essay.wordLimit, 1)), 1.0),
                    height: 4
                )
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Status Chip

    private func statusChip(for essay: EssayModel) -> some View {
        let (bgColor, fgColor) = statusColors(essay.status)
        return Text(essay.statusLabel)
            .font(LadderTypography.labelSmall)
            .foregroundStyle(fgColor)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(bgColor)
            .clipShape(Capsule())
    }

    private func statusColors(_ status: String) -> (Color, Color) {
        switch status {
        case "not_started":
            return (LadderColors.surfaceContainerHighest, LadderColors.onSurfaceVariant)
        case "drafting":
            return (LadderColors.primaryContainer.opacity(0.3), LadderColors.primary)
        case "reviewing":
            return (Color.orange.opacity(0.15), Color.orange)
        case "complete":
            return (LadderColors.accentLime.opacity(0.2), LadderColors.primary)
        default:
            return (LadderColors.surfaceContainerHighest, LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - FAB

    private var addButton: some View {
        Button {
            viewModel.showAddSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [LadderColors.primary, LadderColors.primaryContainer],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .ladderShadow(LadderElevation.primaryGlow)
        }
        .padding(.trailing, LadderSpacing.lg)
        .padding(.bottom, LadderSpacing.xxl)
    }

    // MARK: - Add Essay Sheet

    private var addEssaySheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        // College picker
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("COLLEGE")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            if viewModel.colleges.isEmpty {
                                Text("No colleges saved yet. Add colleges from the Colleges tab first.")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .padding(LadderSpacing.md)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(LadderColors.surfaceContainerLow)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: LadderSpacing.sm) {
                                        ForEach(viewModel.colleges) { college in
                                            collegeChip(college)
                                        }
                                    }
                                }
                            }
                        }

                        // Prompt
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("ESSAY PROMPT")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextEditor(text: $viewModel.newPrompt)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .padding(LadderSpacing.sm)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        // Word limit
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("WORD LIMIT")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextField("650", text: $viewModel.newWordLimit)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .keyboardType(.numberPad)
                                .padding(LadderSpacing.md)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        LadderPrimaryButton("Add Essay", icon: "plus") {
                            viewModel.addEssay(context: context)
                        }
                        .padding(.top, LadderSpacing.sm)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationTitle("New Essay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showAddSheet = false
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - College Chip

    private func collegeChip(_ college: CollegeModel) -> some View {
        let isSelected = viewModel.selectedCollege?.persistentModelID == college.persistentModelID
        return Button {
            viewModel.selectedCollege = college
        } label: {
            Text(college.name)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(isSelected ? LadderColors.onPrimary : LadderColors.onSurface)
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(isSelected ? LadderColors.primary : LadderColors.surfaceContainerLow)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Essay Editor Sheet

    private func essayEditorSheet(essay: EssayModel) -> some View {
        EssayEditorSheet(essay: essay) {
            viewModel.saveEssay(essay, context: context)
            viewModel.showEditorSheet = false
        } onCancel: {
            viewModel.showEditorSheet = false
        }
    }
}

// MARK: - Essay Editor Sheet (separate view for clean state management)

struct EssayEditorSheet: View {
    @Bindable var essay: EssayModel
    let onSave: () -> Void
    let onCancel: () -> Void

    private let statusOptions = ["not_started", "drafting", "reviewing", "complete"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                        // College name (read-only)
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("COLLEGE")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            Text(essay.collegeName)
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .padding(LadderSpacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(LadderColors.surfaceContainerHighest.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        // Essay prompt (editable)
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("PROMPT")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            TextEditor(text: $essay.prompt)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 80)
                                .padding(LadderSpacing.sm)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        // Draft editor
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            HStack {
                                Text("DRAFT")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .labelTracking()

                                Spacer()

                                Text("\(essay.wordCount)/\(essay.wordLimit) words")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(
                                        essay.wordCount > essay.wordLimit
                                            ? LadderColors.error
                                            : LadderColors.onSurfaceVariant
                                    )
                            }

                            TextEditor(text: $essay.draft)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 220)
                                .padding(LadderSpacing.sm)
                                .background(LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                            LinearProgressBar(
                                progress: min(Double(essay.wordCount) / Double(max(essay.wordLimit, 1)), 1.0),
                                height: 4
                            )
                        }

                        // Status picker
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("STATUS")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()

                            HStack(spacing: LadderSpacing.sm) {
                                ForEach(statusOptions, id: \.self) { option in
                                    statusPickerChip(option)
                                }
                            }
                        }

                        // Save button
                        LadderPrimaryButton("Save Draft", icon: "checkmark") {
                            onSave()
                        }
                        .padding(.top, LadderSpacing.sm)

                        Spacer().frame(height: LadderSpacing.xxl)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationTitle("Edit Essay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .presentationDetents([.large])
    }

    private func statusPickerChip(_ status: String) -> some View {
        let isSelected = essay.status == status
        let label: String = {
            switch status {
            case "not_started": return "Not Started"
            case "drafting": return "Drafting"
            case "reviewing": return "Reviewing"
            case "complete": return "Complete"
            default: return status
            }
        }()

        return Button {
            essay.status = status
        } label: {
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(isSelected ? LadderColors.onPrimary : LadderColors.onSurface)
                .padding(.horizontal, LadderSpacing.sm)
                .padding(.vertical, LadderSpacing.xs)
                .background(isSelected ? LadderColors.primary : LadderColors.surfaceContainerLow)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        EssayTrackerView()
    }
    .environment(AppCoordinator())
}
