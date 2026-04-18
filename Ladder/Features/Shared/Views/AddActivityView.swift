import SwiftUI
import SwiftData

// MARK: - Add / Edit Activity View
// Sheet for creating or editing an extracurricular activity.

struct AddActivityView: View {
    @Environment(\.dismiss) private var dismiss

    let modelContext: ModelContext
    let activity: ActivityModel?
    let prefillCategory: String?
    let prefillName: String?

    // Form state
    @State private var name = ""
    @State private var category = "Club"
    @State private var role = ""
    @State private var organization = ""
    @State private var hoursPerWeek = ""
    @State private var weeksPerYear = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasStartDate = false
    @State private var hasEndDate = false
    @State private var gradeYears: Set<Int> = []
    @State private var isLeadership = false
    @State private var tier = 4
    @State private var impactStatement = ""
    @State private var notes = ""
    @State private var showingDeleteConfirmation = false

    private var isEditing: Bool { activity != nil }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(modelContext: ModelContext, activity: ActivityModel? = nil, prefillCategory: String? = nil, prefillName: String? = nil) {
        self.modelContext = modelContext
        self.activity = activity
        self.prefillCategory = prefillCategory
        self.prefillName = prefillName
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        // Activity name
                        LadderTextField("Activity Name", text: $name)

                        // Category picker
                        categorySection

                        // Role and organization
                        LadderTextField("Role / Position", text: $role)
                        LadderTextField("Organization", text: $organization)

                        // Time commitment
                        timeSection

                        // Date range
                        dateSection

                        // Grade years
                        gradeYearsSection

                        // Tier picker
                        tierSection

                        // Leadership toggle
                        leadershipSection

                        // Impact statement
                        impactStatementSection

                        // Notes
                        notesSection

                        // Save
                        LadderPrimaryButton(isEditing ? "Save Changes" : "Add Activity", icon: "checkmark") {
                            save()
                        }
                        .disabled(!canSave)
                        .opacity(canSave ? 1.0 : 0.5)

                        // Delete (edit mode only)
                        if isEditing {
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                Text("Delete Activity")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.error)
                            }
                            .padding(.top, LadderSpacing.sm)
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, LadderSpacing.xxl)
                }
            }
            .navigationTitle(isEditing ? "Edit Activity" : "Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                populateFromActivity()
                if activity == nil {
                    if let cat = prefillCategory {
                        category = cat
                    }
                    if let prefillName, !prefillName.isEmpty {
                        name = prefillName
                    }
                }
            }
            .confirmationDialog("Delete Activity", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteAndDismiss()
                }
            } message: {
                Text("Are you sure you want to delete this activity? This cannot be undone.")
            }
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Category")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]

            LazyVGrid(columns: columns, spacing: LadderSpacing.sm) {
                ForEach(ActivityModel.allCategories, id: \.self) { cat in
                    LadderFilterChip(title: cat, isSelected: category == cat) {
                        withAnimation { category = cat }
                    }
                }
            }
        }
    }

    // MARK: - Time Section

    private var timeSection: some View {
        HStack(spacing: LadderSpacing.md) {
            VStack(alignment: .leading) {
                LadderTextField("Hours / Week", text: $hoursPerWeek)
                    .keyboardType(.decimalPad)
            }
            VStack(alignment: .leading) {
                LadderTextField("Weeks / Year", text: $weeksPerYear)
                    .keyboardType(.decimalPad)
            }
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Duration")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            LadderCard {
                VStack(spacing: LadderSpacing.md) {
                    Toggle(isOn: $hasStartDate) {
                        Text("Start Date")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .tint(LadderColors.primary)

                    if hasStartDate {
                        DatePicker("", selection: $startDate, displayedComponents: .date)
                            .labelsHidden()
                    }

                    Toggle(isOn: $hasEndDate) {
                        Text("End Date")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurface)
                    }
                    .tint(LadderColors.primary)

                    if hasEndDate {
                        DatePicker("", selection: $endDate, displayedComponents: .date)
                            .labelsHidden()
                    }
                }
            }
        }
    }

    // MARK: - Grade Years Section

    private var gradeYearsSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Grade Years")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            HStack(spacing: LadderSpacing.sm) {
                ForEach([9, 10, 11, 12], id: \.self) { grade in
                    LadderFilterChip(title: "Grade \(grade)", isSelected: gradeYears.contains(grade)) {
                        withAnimation {
                            if gradeYears.contains(grade) {
                                gradeYears.remove(grade)
                            } else {
                                gradeYears.insert(grade)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tier Section

    private var tierSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Activity Tier")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            VStack(spacing: LadderSpacing.sm) {
                ForEach(1...4, id: \.self) { t in
                    Button {
                        withAnimation { tier = t }
                    } label: {
                        LadderCard {
                            HStack {
                                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                                    Text("Tier \(t)")
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text(ActivityModel.tierDescriptions[t] ?? "")
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                                Spacer()
                                Image(systemName: tier == t ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(tier == t ? LadderColors.primary : LadderColors.outlineVariant)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Leadership Section

    private var leadershipSection: some View {
        LadderCard {
            Toggle(isOn: $isLeadership) {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(isLeadership ? LadderColors.secondary : LadderColors.onSurfaceVariant)
                    VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                        Text("Leadership Role")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Mark if you held a leadership position")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }
            .tint(LadderColors.primary)
        }
    }

    // MARK: - Impact Statement Section

    private var impactStatementSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                Text("Impact Statement")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Spacer()
                Text("\(impactStatement.count)/150")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(impactStatement.count > 150 ? LadderColors.error : LadderColors.onSurfaceVariant)
            }

            LadderCard {
                VStack(spacing: LadderSpacing.sm) {
                    TextEditor(text: $impactStatement)
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .frame(minHeight: 80)
                        .scrollContentBackground(.hidden)
                        .onChange(of: impactStatement) { _, newValue in
                            if newValue.count > 150 {
                                impactStatement = String(newValue.prefix(150))
                            }
                        }

                    Button {
                        generateImpactStatement()
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14))
                            Text("Generate Impact Statement")
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(LadderColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(LadderColors.surfaceContainerHigh)
                        .clipShape(Capsule())
                    }
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                }
            }

            Text("Common App activities have a 150-character limit for descriptions.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Notes")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            LadderCard {
                TextEditor(text: $notes)
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurface)
                    .frame(minHeight: 60)
                    .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Actions

    private func populateFromActivity() {
        guard let activity else { return }
        name = activity.name
        category = activity.category
        role = activity.role ?? ""
        organization = activity.organization ?? ""
        hoursPerWeek = activity.hoursPerWeek.map { String(format: "%.0f", $0) } ?? ""
        weeksPerYear = activity.weeksPerYear.map { String(format: "%.0f", $0) } ?? ""
        if let sd = activity.startDate {
            startDate = sd
            hasStartDate = true
        }
        if let ed = activity.endDate {
            endDate = ed
            hasEndDate = true
        }
        gradeYears = Set(activity.gradeYears)
        isLeadership = activity.isLeadership
        tier = activity.tier
        impactStatement = activity.impactStatement ?? ""
        notes = activity.notes ?? ""
    }

    private func save() {
        if let activity {
            // Update existing
            activity.name = name.trimmingCharacters(in: .whitespaces)
            activity.category = category
            activity.role = role.isEmpty ? nil : role
            activity.organization = organization.isEmpty ? nil : organization
            activity.hoursPerWeek = Double(hoursPerWeek)
            activity.weeksPerYear = Double(weeksPerYear)
            activity.startDate = hasStartDate ? startDate : nil
            activity.endDate = hasEndDate ? endDate : nil
            activity.gradeYears = gradeYears.sorted()
            activity.isLeadership = isLeadership
            activity.tier = tier
            activity.impactStatement = impactStatement.isEmpty ? nil : impactStatement
            activity.notes = notes.isEmpty ? nil : notes
            try? modelContext.save()
        } else {
            // Create new
            let newActivity = ActivityModel(name: name.trimmingCharacters(in: .whitespaces), category: category)
            newActivity.role = role.isEmpty ? nil : role
            newActivity.organization = organization.isEmpty ? nil : organization
            newActivity.hoursPerWeek = Double(hoursPerWeek)
            newActivity.weeksPerYear = Double(weeksPerYear)
            newActivity.startDate = hasStartDate ? startDate : nil
            newActivity.endDate = hasEndDate ? endDate : nil
            newActivity.gradeYears = gradeYears.sorted()
            newActivity.isLeadership = isLeadership
            newActivity.tier = tier
            newActivity.impactStatement = impactStatement.isEmpty ? nil : impactStatement
            newActivity.notes = notes.isEmpty ? nil : notes
            modelContext.insert(newActivity)
            try? modelContext.save()
        }
        dismiss()
    }

    private func deleteAndDismiss() {
        if let activity {
            modelContext.delete(activity)
            try? modelContext.save()
        }
        dismiss()
    }

    private func generateImpactStatement() {
        // Build a locally-generated impact statement from available fields
        var parts: [String] = []

        if isLeadership, let r = role.nilIfEmpty {
            parts.append("As \(r)")
        } else if let r = role.nilIfEmpty {
            parts.append(r)
        }

        if let org = organization.nilIfEmpty {
            parts.append("at \(org)")
        }

        let verb: String
        switch category {
        case "Athletics": verb = "competed"
        case "Volunteering": verb = "volunteered"
        case "Research": verb = "conducted research"
        case "Job", "Internship": verb = "worked"
        case "Award": verb = "earned recognition"
        case "Leadership": verb = "led initiatives"
        default: verb = "participated"
        }

        if parts.isEmpty {
            parts.append("\(verb) in \(name)")
        } else {
            parts.append(verb)
        }

        if let hours = Double(hoursPerWeek), hours > 0 {
            parts.append("dedicating \(Int(hours)) hrs/wk")
        }

        if !gradeYears.isEmpty {
            let grades = gradeYears.sorted().map { "\($0)" }.joined(separator: ",")
            parts.append("grades \(grades)")
        }

        var statement = parts.joined(separator: ", ")
        if statement.count > 150 {
            statement = String(statement.prefix(147)) + "..."
        }
        impactStatement = statement
    }
}

// MARK: - String Helper

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
