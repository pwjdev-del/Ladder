import SwiftUI
import SwiftData

// MARK: - Scholarship Search View

struct ScholarshipSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var selectedFilter: ScholarshipFilter = .all
    @State private var showAddSheet = false

    @Query(sort: \ScholarshipModel.name) var scholarships: [ScholarshipModel]
    @Query var studentProfiles: [StudentProfileModel]

    private var studentState: String? {
        studentProfiles.first?.state
    }

    /// Abbreviation for the student's state (e.g. "Florida" -> "FL")
    private var studentStateAbbreviation: String? {
        guard let state = studentState else { return nil }
        return stateAbbreviation(state)
    }

    enum ScholarshipFilter: String, CaseIterable {
        case all = "All"
        case merit = "Merit"
        case need = "Need-Based"
        case myState = "My State"
        case saved = "Saved"
    }

    private var filteredScholarships: [ScholarshipModel] {
        var result = scholarships
        switch selectedFilter {
        case .all: break
        case .merit: result = result.filter(\.isMeritBased)
        case .need: result = result.filter(\.isNeedBased)
        case .myState:
            if let abbrev = studentStateAbbreviation {
                result = result.filter { ($0.stateTag ?? "").uppercased() == abbrev.uppercased() }
            }
        case .saved: result = result.filter(\.isSaved)
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) || ($0.provider ?? "").localizedCaseInsensitiveContains(searchText) }
        }

        // Sort: push out-of-state scholarships to bottom when student has a state set
        if let abbrev = studentStateAbbreviation {
            result.sort { lhs, rhs in
                let lhsMatch = (lhs.stateTag ?? "").isEmpty || lhs.stateTag?.uppercased() == abbrev.uppercased()
                let rhsMatch = (rhs.stateTag ?? "").isEmpty || rhs.stateTag?.uppercased() == abbrev.uppercased()
                if lhsMatch != rhsMatch { return lhsMatch }
                return lhs.name < rhs.name
            }
        }
        return result
    }

    private func stateAbbreviation(_ state: String) -> String {
        let map: [String: String] = [
            "Florida": "FL", "Texas": "TX", "California": "CA",
            "New York": "NY", "Georgia": "GA", "Pennsylvania": "PA",
            "Illinois": "IL", "Ohio": "OH", "North Carolina": "NC",
            "New Jersey": "NJ", "Virginia": "VA", "Washington": "WA",
            "Massachusetts": "MA", "Arizona": "AZ", "Colorado": "CO"
        ]
        // If already an abbreviation, return as-is
        if state.count <= 2 { return state.uppercased() }
        return map[state] ?? state.prefix(2).uppercased()
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.md) {
                    // Search
                    LadderSearchBar(placeholder: "Search scholarships...", text: $searchText)
                        .padding(.horizontal, LadderSpacing.md)

                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: LadderSpacing.sm) {
                            ForEach(ScholarshipFilter.allCases, id: \.self) { filter in
                                LadderFilterChip(
                                    title: filter.rawValue,
                                    isSelected: selectedFilter == filter
                                ) { selectedFilter = filter }
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)
                    }

                    // Results or empty state
                    if scholarships.isEmpty {
                        emptyState
                    } else if filteredScholarships.isEmpty {
                        noResultsState
                    } else {
                        ForEach(filteredScholarships) { scholarship in
                            scholarshipCard(scholarship)
                        }
                    }
                }
                .padding(.top, LadderSpacing.md)
                .padding(.bottom, 120)
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
                Text("Scholarships")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { showAddSheet = true } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddScholarshipSheet(modelContext: modelContext)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.md) {
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 48))
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
            Text("No Scholarships Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)
            Text("Tap the + button to add scholarships you find. Track deadlines, amounts, and eligibility all in one place.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)

            Button {
                showAddSheet = true
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus")
                    Text("Add Your First Scholarship")
                }
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.primary)
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primaryContainer.opacity(0.3))
                .clipShape(Capsule())
            }
        }
        .padding(LadderSpacing.xl)
        .padding(.top, LadderSpacing.xl)
    }

    // MARK: - No Results for Filter

    private var noResultsState: some View {
        VStack(spacing: LadderSpacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 36))
                .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
            Text("No matching scholarships")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)
            Text("Try adjusting your search or filters.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(LadderSpacing.xl)
        .padding(.top, LadderSpacing.lg)
    }

    // MARK: - Scholarship Card

    private func scholarshipCard(_ scholarship: ScholarshipModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(scholarship.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)

                    if let provider = scholarship.provider, !provider.isEmpty {
                        Text(provider)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                Spacer()

                Button {
                    scholarship.isSaved.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: scholarship.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(LadderColors.primary)
                }
            }

            HStack(spacing: LadderSpacing.md) {
                if let amount = scholarship.amount {
                    Label("$\(amount)", systemImage: "dollarsign.circle.fill")
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.accentLime)
                }

                if let deadline = scholarship.deadline {
                    Label(deadline.formatted(.dateTime.month(.abbreviated).day().year()), systemImage: "calendar")
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                if let match = scholarship.matchPercent {
                    Text("\(match)% match")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.primary)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(LadderColors.primaryContainer.opacity(0.3))
                        .clipShape(Capsule())
                }
            }

            if let eligibility = scholarship.eligibilityCriteria, !eligibility.isEmpty {
                Text(eligibility)
                    .font(LadderTypography.bodySmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .lineLimit(2)
            }

            HStack(spacing: LadderSpacing.sm) {
                if scholarship.isMeritBased {
                    LadderTagChip("Merit")
                }
                if scholarship.isNeedBased {
                    LadderTagChip("Need-Based")
                }
                if let tag = scholarship.stateTag, !tag.isEmpty {
                    Text("\(tag.uppercased()) Only")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(isScholarshipInStudentState(scholarship) ? LadderColors.primary : LadderColors.onSurfaceVariant)
                        .padding(.horizontal, LadderSpacing.sm)
                        .padding(.vertical, LadderSpacing.xxs)
                        .background(
                            isScholarshipInStudentState(scholarship)
                                ? LadderColors.primaryContainer.opacity(0.3)
                                : LadderColors.surfaceContainerHighest
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
        .opacity(isScholarshipDimmed(scholarship) ? 0.5 : 1.0)
        .padding(.horizontal, LadderSpacing.md)
    }

    // MARK: - State Helpers

    /// Check if a scholarship's state tag matches the student's state
    private func isScholarshipInStudentState(_ scholarship: ScholarshipModel) -> Bool {
        guard let tag = scholarship.stateTag, !tag.isEmpty,
              let abbrev = studentStateAbbreviation else { return true }
        return tag.uppercased() == abbrev.uppercased()
    }

    /// Dim scholarships that are state-specific but NOT the student's state
    private func isScholarshipDimmed(_ scholarship: ScholarshipModel) -> Bool {
        guard let tag = scholarship.stateTag, !tag.isEmpty,
              let abbrev = studentStateAbbreviation else { return false }
        return tag.uppercased() != abbrev.uppercased()
    }
}

// MARK: - Add Scholarship Sheet

struct AddScholarshipSheet: View {
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var provider = ""
    @State private var amountText = ""
    @State private var deadline = Date()
    @State private var hasDeadline = false
    @State private var url = ""
    @State private var eligibility = ""
    @State private var isNeedBased = false
    @State private var isMeritBased = false
    @State private var stateTag = ""

    private static let stateTagOptions = ["", "FL", "TX", "CA", "NY", "GA", "PA", "IL", "OH", "NC", "NJ", "VA", "WA", "MA", "AZ", "CO"]

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.lg) {
                        // Header icon
                        ZStack {
                            Circle()
                                .fill(LadderColors.primaryContainer.opacity(0.3))
                                .frame(width: 56, height: 56)
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(LadderColors.primary)
                        }
                        .padding(.top, LadderSpacing.md)

                        VStack(spacing: LadderSpacing.md) {
                            LadderTextField("Scholarship Name *", text: $name, icon: "textformat")
                            LadderTextField("Provider / Organization", text: $provider, icon: "building.2")
                            LadderTextField("Amount ($)", text: $amountText, icon: "dollarsign.circle")

                            // Deadline toggle + picker
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Toggle(isOn: $hasDeadline) {
                                    HStack(spacing: LadderSpacing.sm) {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(LadderColors.onSurfaceVariant)
                                        Text("Has deadline")
                                            .font(LadderTypography.bodyMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                                .tint(LadderColors.primary)

                                if hasDeadline {
                                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                        .tint(LadderColors.primary)
                                }
                            }
                            .padding(.vertical, LadderSpacing.xs)

                            LadderTextField("URL (optional)", text: $url, icon: "link")
                            LadderTextField("Eligibility Criteria", text: $eligibility, icon: "person.crop.circle.badge.checkmark")

                            // Type toggles
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("TYPE")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)

                                HStack(spacing: LadderSpacing.sm) {
                                    LadderFilterChip(title: "Merit-Based", isSelected: isMeritBased) {
                                        isMeritBased.toggle()
                                    }
                                    LadderFilterChip(title: "Need-Based", isSelected: isNeedBased) {
                                        isNeedBased.toggle()
                                    }
                                }
                            }

                            // State restriction
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("STATE RESTRICTION")
                                    .font(LadderTypography.labelSmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                    .labelTracking()

                                HStack(spacing: LadderSpacing.md) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                        .frame(width: 20)
                                    Picker("State", selection: $stateTag) {
                                        Text("Any State").tag("")
                                        ForEach(Self.stateTagOptions.filter { !$0.isEmpty }, id: \.self) { st in
                                            Text(st).tag(st)
                                        }
                                    }
                                    .tint(LadderColors.primary)
                                }
                            }
                        }
                        .padding(.horizontal, LadderSpacing.md)

                        // Save button
                        Button {
                            saveScholarship()
                        } label: {
                            Text("Save Scholarship")
                                .font(LadderTypography.labelLarge)
                                .foregroundStyle(canSave ? LadderColors.onPrimary : LadderColors.onSurfaceVariant)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, LadderSpacing.md)
                                .background(canSave ? LadderColors.primary : LadderColors.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
                        }
                        .disabled(!canSave)
                        .padding(.horizontal, LadderSpacing.md)
                    }
                    .padding(.bottom, LadderSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Text("Cancel")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Add Scholarship")
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
    }

    private func saveScholarship() {
        let scholarship = ScholarshipModel(name: name.trimmingCharacters(in: .whitespaces))
        scholarship.provider = provider.trimmingCharacters(in: .whitespaces).isEmpty ? nil : provider.trimmingCharacters(in: .whitespaces)
        scholarship.amount = Int(amountText)
        scholarship.deadline = hasDeadline ? deadline : nil
        scholarship.url = url.trimmingCharacters(in: .whitespaces).isEmpty ? nil : url.trimmingCharacters(in: .whitespaces)
        scholarship.eligibilityCriteria = eligibility.trimmingCharacters(in: .whitespaces).isEmpty ? nil : eligibility.trimmingCharacters(in: .whitespaces)
        scholarship.isNeedBased = isNeedBased
        scholarship.isMeritBased = isMeritBased
        scholarship.stateTag = stateTag.isEmpty ? nil : stateTag
        scholarship.isSaved = true

        modelContext.insert(scholarship)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ScholarshipSearchView()
    }
}
