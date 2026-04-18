import SwiftUI
import SwiftData

// MARK: - What If Simulator View
// "What if my GPA was 3.8?" — Adjust sliders and see real-time match status

struct WhatIfSimulatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var vm = WhatIfSimulatorViewModel()
    @State private var showingCollegePicker = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // College selector
                    collegeSelector

                    if vm.selectedCollege != nil {
                        // Competitiveness Meter
                        competitivenessMeter

                        // Sliders
                        slidersSection

                        // Use my stats button
                        LadderSecondaryButton("Compare with Your Actual Stats") {
                            vm.fillFromProfile(context: context)
                            vm.recalculate()
                        }

                        // Results card
                        resultsCard
                    } else {
                        emptyState
                    }
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("What If Simulator")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showingCollegePicker) {
            collegePickerSheet
        }
        .task {
            vm.loadColleges(from: context)
        }
    }

    // MARK: - College Selector

    private var collegeSelector: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                HStack {
                    Image(systemName: "building.columns")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.primary)

                    if let college = vm.selectedCollege {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(college.name)
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)
                            if let city = college.city, let state = college.state {
                                Text("\(city), \(state)")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                            }
                        }
                    } else {
                        Text("Select a College")
                            .font(LadderTypography.titleMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }

                    Spacer()

                    Button { showingCollegePicker = true } label: {
                        Image(systemName: "chevron.down.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(LadderColors.primary)
                    }
                }
            }
        }
    }

    // MARK: - Competitiveness Meter

    private var competitivenessMeter: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                Text("Competitiveness Meter")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)

                ZStack {
                    Circle()
                        .stroke(LadderColors.surfaceContainerLow, lineWidth: 14)
                        .frame(width: 140, height: 140)
                    Circle()
                        .trim(from: 0, to: vm.chancePercent / 100)
                        .stroke(
                            meterColor,
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: vm.chancePercent)

                    VStack(spacing: 2) {
                        Text("\(Int(vm.chancePercent))%")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)
                        Text(vm.matchCategory.rawValue)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(meterColor)
                    }
                }

                // Category labels
                HStack(spacing: LadderSpacing.lg) {
                    categoryLabel("Reach", color: LadderColors.error, active: vm.matchCategory == .reach)
                    categoryLabel("Match", color: LadderColors.secondaryFixedDim, active: vm.matchCategory == .match)
                    categoryLabel("Safety", color: LadderColors.primary, active: vm.matchCategory == .safety)
                }
            }
        }
    }

    private func categoryLabel(_ text: String, color: Color, active: Bool) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(active ? LadderColors.onSurface : LadderColors.onSurfaceVariant)
        }
        .opacity(active ? 1.0 : 0.5)
    }

    // MARK: - Sliders

    private var slidersSection: some View {
        VStack(spacing: LadderSpacing.md) {
            // GPA Slider
            sliderCard(
                title: "GPA",
                icon: "graduationcap",
                value: $vm.gpa,
                range: 2.0...4.0,
                step: 0.1,
                displayValue: String(format: "%.1f", vm.gpa),
                collegeValue: collegeGPAEstimate
            )

            // SAT Slider
            sliderCard(
                title: "SAT Score",
                icon: "doc.text",
                value: $vm.satScore,
                range: 400...1600,
                step: 10,
                displayValue: "\(Int(vm.satScore))",
                collegeValue: vm.collegeSATRange
            )

            // AP Count Slider
            sliderCard(
                title: "AP Courses",
                icon: "book.closed",
                value: $vm.apCount,
                range: 0...15,
                step: 1,
                displayValue: "\(Int(vm.apCount))",
                collegeValue: nil
            )

            // Extracurricular Rating Slider
            sliderCard(
                title: "Extracurricular Rating",
                icon: "star",
                value: $vm.extracurricularRating,
                range: 1...5,
                step: 1,
                displayValue: "\(Int(vm.extracurricularRating))/5",
                collegeValue: nil
            )
        }
    }

    private func sliderCard(
        title: String,
        icon: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        displayValue: String,
        collegeValue: String?
    ) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(LadderColors.primary)
                    Text(title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Spacer()
                    Text(displayValue)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.primary)
                }

                Slider(value: value, in: range, step: step)
                    .tint(LadderColors.primary)
                    .onChange(of: value.wrappedValue) { _, _ in
                        vm.recalculate()
                    }

                if let collegeValue {
                    HStack {
                        Text("College avg/range:")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Text(collegeValue)
                            .font(LadderTypography.labelMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                }
            }
        }
    }

    // MARK: - Results Card

    private var resultsCard: some View {
        LadderCard(elevated: true) {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: resultIcon)
                    .font(.system(size: 32))
                    .foregroundStyle(meterColor)

                Text(vm.summaryText)
                    .font(LadderTypography.bodyLarge)
                    .foregroundStyle(LadderColors.onSurface)
                    .multilineTextAlignment(.center)

                // College stats row
                if let college = vm.selectedCollege {
                    HStack(spacing: LadderSpacing.lg) {
                        statPill("Acceptance", vm.collegeAcceptanceRate)
                        statPill("SAT Range", vm.collegeSATRange)
                    }

                    if let policy = college.testingPolicy {
                        LadderTagChip(policy, icon: "checkmark.seal")
                    }
                }
            }
        }
    }

    private func statPill(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(LadderTypography.labelLarge)
                .foregroundStyle(LadderColors.onSurface)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.horizontal, LadderSpacing.md)
        .padding(.vertical, LadderSpacing.sm)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.primary)
                Text("Select a college above to start exploring \"what if\" scenarios")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - College Picker Sheet

    private var collegePickerSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                VStack(spacing: 0) {
                    LadderSearchBar(placeholder: "Search colleges...", text: $vm.searchText)
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.vertical, LadderSpacing.md)

                    if !vm.savedColleges.isEmpty && vm.searchText.isEmpty {
                        HStack {
                            Text("SAVED COLLEGES")
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .labelTracking()
                            Spacer()
                        }
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.bottom, LadderSpacing.sm)
                    }

                    List {
                        ForEach(vm.filteredColleges, id: \.self) { college in
                            Button {
                                vm.selectedCollege = college
                                vm.recalculate()
                                showingCollegePicker = false
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(college.name)
                                            .font(LadderTypography.titleSmall)
                                            .foregroundStyle(LadderColors.onSurface)
                                        if let city = college.city, let state = college.state {
                                            Text("\(city), \(state)")
                                                .font(LadderTypography.bodySmall)
                                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                        }
                                    }
                                    Spacer()
                                    if college === vm.selectedCollege {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(LadderColors.primary)
                                    }
                                }
                            }
                            .listRowBackground(LadderColors.surfaceContainerLow)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Choose College")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingCollegePicker = false }
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - Helpers

    private var meterColor: Color {
        switch vm.matchCategory {
        case .reach: return LadderColors.error
        case .match: return LadderColors.secondaryFixedDim
        case .safety: return LadderColors.primary
        }
    }

    private var resultIcon: String {
        switch vm.matchCategory {
        case .reach: return "exclamationmark.triangle"
        case .match: return "checkmark.seal"
        case .safety: return "shield.checkered"
        }
    }

    private var collegeGPAEstimate: String {
        guard let rate = vm.selectedCollege?.acceptanceRate else { return "N/A" }
        if rate < 0.1 { return "3.9+" }
        if rate < 0.2 { return "3.8+" }
        if rate < 0.3 { return "3.7+" }
        if rate < 0.5 { return "3.5+" }
        if rate < 0.7 { return "3.2+" }
        return "3.0+"
    }
}
