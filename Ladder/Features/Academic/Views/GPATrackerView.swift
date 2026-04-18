import SwiftUI
import SwiftData

// MARK: - GPA Tracker View
// Per-semester GPA tracking with weighted/unweighted toggle,
// trend chart, and add/edit semester sheets

struct GPATrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var viewModel = GPATrackerViewModel()

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.lg) {
                    // Cumulative GPA hero
                    gpaHeroCard

                    // Weighted / Unweighted toggle
                    weightedToggle

                    // GPA trend chart
                    if viewModel.chartData.count >= 2 {
                        gpaChartCard
                    }

                    // Semester list
                    semesterList

                    // Add semester button
                    LadderPrimaryButton("Add Semester", icon: "plus") {
                        viewModel.startAddSemester()
                    }
                    .padding(.horizontal, LadderSpacing.md)
                    .padding(.bottom, 100)
                }
                .padding(.top, LadderSpacing.sm)
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
                Text("GPA Tracker")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .onAppear {
            viewModel.fetchEntries(context: context)
        }
        .sheet(isPresented: $viewModel.showAddSemester) {
            addSemesterSheet
        }
    }

    // MARK: - GPA Hero Card

    private var gpaHeroCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.sm) {
                Text(viewModel.showWeighted ? "WEIGHTED GPA" : "UNWEIGHTED GPA")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.accentLime)
                    .labelTracking()

                HStack(alignment: .firstTextBaseline, spacing: LadderSpacing.sm) {
                    Text(viewModel.entries.isEmpty ? "--" : viewModel.currentGPAFormatted)
                        .font(LadderTypography.displayMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .editorialTracking()

                    if viewModel.trend != .insufficient {
                        HStack(spacing: LadderSpacing.xxs) {
                            Image(systemName: viewModel.trend.icon)
                                .font(.system(size: 14, weight: .semibold))
                            Text(viewModel.trend.label)
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(trendColor)
                    }
                }

                if !viewModel.entries.isEmpty {
                    Text("\(viewModel.sortedEntries.count) semester\(viewModel.sortedEntries.count == 1 ? "" : "s") tracked")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    private var trendColor: Color {
        switch viewModel.trend {
        case .improving: return LadderColors.accentLime
        case .declining: return LadderColors.error
        case .stable: return LadderColors.onSurfaceVariant
        case .insufficient: return LadderColors.onSurfaceVariant
        }
    }

    // MARK: - Weighted Toggle

    private var weightedToggle: some View {
        HStack(spacing: LadderSpacing.sm) {
            LadderFilterChip(title: "Weighted", isSelected: viewModel.showWeighted) {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.showWeighted = true }
            }
            LadderFilterChip(title: "Unweighted", isSelected: !viewModel.showWeighted) {
                withAnimation(.easeInOut(duration: 0.2)) { viewModel.showWeighted = false }
            }
            Spacer()
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Chart Card

    private var gpaChartCard: some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("GPA Trend")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                LineChartView(
                    data: viewModel.chartData,
                    targetLine: 4.0,
                    lineColor: LadderColors.primary,
                    fillGradient: true,
                    showPoints: true
                )
                .frame(height: 180)

                // Semester labels
                HStack {
                    ForEach(viewModel.sortedEntries, id: \.semester) { entry in
                        Text(shortSemester(entry.semester))
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        if entry.semester != viewModel.sortedEntries.last?.semester {
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Semester List

    private var semesterList: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Semesters")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
                .padding(.horizontal, LadderSpacing.md)

            if viewModel.sortedEntries.isEmpty {
                LadderCard {
                    VStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "graduationcap")
                            .font(.system(size: 32))
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("No semesters yet")
                            .font(LadderTypography.bodyLarge)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text("Add your first semester to start tracking your GPA.")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, LadderSpacing.md)
            } else {
                ForEach(viewModel.sortedEntries, id: \.semester) { entry in
                    semesterRow(entry)
                }
            }
        }
    }

    private func semesterRow(_ entry: GPAEntryModel) -> some View {
        Button {
            viewModel.startEditSemester(entry)
        } label: {
            LadderCard {
                HStack(spacing: LadderSpacing.md) {
                    // Semester icon
                    ZStack {
                        RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                            .fill(LadderColors.primaryContainer.opacity(0.3))
                            .frame(width: 44, height: 44)
                        Image(systemName: entry.semester.hasPrefix("Fall") ? "leaf" : entry.semester.hasPrefix("Spring") ? "flower" : "sun.max")
                            .font(.system(size: 18))
                            .foregroundStyle(LadderColors.primary)
                    }

                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text(entry.semester)
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("\(entry.courses.count) course\(entry.courses.count == 1 ? "" : "s")")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: LadderSpacing.xxs) {
                        Text(String(format: "%.2f", viewModel.showWeighted ? entry.weightedGPA : entry.unweightedGPA))
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(viewModel.showWeighted ? "weighted" : "unweighted")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, LadderSpacing.md)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteSemester(entry, context: context)
            } label: {
                Label("Delete Semester", systemImage: "trash")
            }
        }
    }

    // MARK: - Add Semester Sheet

    private var addSemesterSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        // Semester picker
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("Semester")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)

                                HStack(spacing: LadderSpacing.sm) {
                                    ForEach(GPATrackerViewModel.seasons, id: \.self) { season in
                                        LadderFilterChip(title: season, isSelected: viewModel.selectedSeason == season) {
                                            viewModel.selectedSeason = season
                                        }
                                    }
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: LadderSpacing.sm) {
                                        ForEach(GPATrackerViewModel.availableYears, id: \.self) { year in
                                            LadderFilterChip(title: "\(year)", isSelected: viewModel.selectedYear == year) {
                                                viewModel.selectedYear = year
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)

                        // Live GPA preview
                        LadderCard {
                            HStack {
                                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                    Text("Weighted")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Text(String(format: "%.2f", viewModel.editingWeightedGPA))
                                        .font(LadderTypography.headlineSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: LadderSpacing.xxs) {
                                    Text("Unweighted")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Text(String(format: "%.2f", viewModel.editingUnweightedGPA))
                                        .font(LadderTypography.headlineSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                }
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)

                        // Course list
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Courses")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .padding(.horizontal, LadderSpacing.md)

                            ForEach(Array(viewModel.editingCourses.enumerated()), id: \.element.id) { index, _ in
                                courseRow(index: index)
                            }

                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    viewModel.addCourse()
                                }
                            } label: {
                                HStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(LadderColors.primary)
                                    Text("Add Course")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.primary)
                                }
                                .padding(.horizontal, LadderSpacing.md)
                            }
                        }

                        // Save button
                        LadderPrimaryButton("Save Semester", icon: "checkmark") {
                            viewModel.saveSemester(context: context)
                        }
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.bottom, LadderSpacing.xxl)
                    }
                    .padding(.top, LadderSpacing.md)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        viewModel.showAddSemester = false
                    }
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.editingEntry != nil ? "Edit Semester" : "Add Semester")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Course Row

    private func courseRow(index: Int) -> some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    Text("Course \(index + 1)")
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    Spacer()
                    if viewModel.editingCourses.count > 1 {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.removeCourse(at: index)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundStyle(LadderColors.error)
                        }
                    }
                }

                // Course name
                TextField("Course Name", text: Binding(
                    get: { viewModel.editingCourses[safe: index]?.name ?? "" },
                    set: { if index < viewModel.editingCourses.count { viewModel.editingCourses[index].name = $0 } }
                ))
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurface)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

                HStack(spacing: LadderSpacing.md) {
                    // Credit hours
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Credits")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Picker("Credits", selection: Binding(
                            get: { viewModel.editingCourses[safe: index]?.creditHours ?? 3.0 },
                            set: { if index < viewModel.editingCourses.count { viewModel.editingCourses[index].creditHours = $0 } }
                        )) {
                            ForEach([1.0, 2.0, 3.0, 4.0, 5.0], id: \.self) { credits in
                                Text("\(Int(credits))").tag(credits)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Grade
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Grade")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Picker("Grade", selection: Binding(
                            get: { viewModel.editingCourses[safe: index]?.grade ?? "A" },
                            set: { if index < viewModel.editingCourses.count { viewModel.editingCourses[index].grade = $0 } }
                        )) {
                            ForEach(CourseGrade.allGrades, id: \.self) { grade in
                                Text(grade).tag(grade)
                            }
                        }
                        .tint(LadderColors.primary)
                    }
                }

                // AP / Honors toggles
                HStack(spacing: LadderSpacing.md) {
                    Toggle(isOn: Binding(
                        get: { viewModel.editingCourses[safe: index]?.isAP ?? false },
                        set: { newVal in
                            if index < viewModel.editingCourses.count {
                                viewModel.editingCourses[index].isAP = newVal
                                if newVal { viewModel.editingCourses[index].isHonors = false }
                            }
                        }
                    )) {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.accentLime)
                            Text("AP (+1.0)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: LadderColors.accentLime))

                    Toggle(isOn: Binding(
                        get: { viewModel.editingCourses[safe: index]?.isHonors ?? false },
                        set: { newVal in
                            if index < viewModel.editingCourses.count {
                                viewModel.editingCourses[index].isHonors = newVal
                                if newVal { viewModel.editingCourses[index].isAP = false }
                            }
                        }
                    )) {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: "medal")
                                .font(.system(size: 12))
                                .foregroundStyle(LadderColors.primary)
                            Text("Honors (+0.5)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurface)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))
                }
            }
        }
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - Helpers

    private func shortSemester(_ semester: String) -> String {
        let parts = semester.split(separator: " ")
        guard parts.count == 2 else { return semester }
        let season = String(parts[0].prefix(1)) // F, S, or S
        let year = String(parts[1].suffix(2))    // e.g. "24"
        return "\(season)'\(year)"
    }
}

// Safe Array Subscript defined in SATScoreTrackerView.swift

#Preview {
    NavigationStack {
        GPATrackerView()
    }
    .modelContainer(for: GPAEntryModel.self, inMemory: true)
}
