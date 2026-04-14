import SwiftUI
import SwiftData

// MARK: - Edit Profile Sheet
// Editable fields backed by live StudentProfileModel (writes to SwiftData)

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let profile: StudentProfileModel?

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var grade: Int = 10
    @State private var school: String = ""
    @State private var gpaText: String = ""
    @State private var satText: String = ""
    @State private var actText: String = ""
    @State private var careerPath: String = "Medical Path"
    @State private var isFirstGen: Bool = false
    @State private var didLoad = false

    private let careerOptions = ["Medical Path", "Engineering & STEM", "Business & Finance", "Humanities", "Sports & Athletics", "Law & Public Service", "Creative Arts"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: LadderSpacing.lg) {

                        section("PERSONAL") {
                            field("First Name", text: $firstName)
                            field("Last Name", text: $lastName)
                            HStack {
                                Text("Grade")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Spacer()
                                Picker("", selection: $grade) {
                                    ForEach(9...12, id: \.self) { Text("\($0)th").tag($0) }
                                }
                                .pickerStyle(.segmented)
                                .frame(maxWidth: 220)
                            }
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                            field("School", text: $school)

                            HStack {
                                Text("First-Generation College Student")
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Spacer()
                                Toggle("", isOn: $isFirstGen)
                                    .labelsHidden()
                                    .tint(LadderColors.primary)
                            }
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        section("ACADEMICS") {
                            field("GPA (0.0 - 4.0)", text: $gpaText, keyboard: .decimalPad)
                            field("SAT Score (400 - 1600)", text: $satText, keyboard: .numberPad)
                            field("ACT Score (1 - 36)", text: $actText, keyboard: .numberPad)
                        }

                        section("CAREER") {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Career Path")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)
                                Picker("", selection: $careerPath) {
                                    ForEach(careerOptions, id: \.self) { Text($0).tag($0) }
                                }
                                .pickerStyle(.menu)
                                .tint(LadderColors.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(LadderSpacing.md)
                            .background(LadderColors.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                        }

                        Spacer().frame(height: LadderSpacing.xl)
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        save()
                        dismiss()
                    } label: {
                        Text("Save").bold()
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }
            .onAppear { loadIfNeeded() }
        }
    }

    private func loadIfNeeded() {
        guard !didLoad else { return }
        if let p = profile {
            firstName = p.firstName
            lastName = p.lastName
            grade = p.grade
            school = p.schoolName ?? ""
            gpaText = p.gpa.map { String(format: "%.2f", $0) } ?? ""
            satText = p.satScore.map { "\($0)" } ?? ""
            actText = p.actScore.map { "\($0)" } ?? ""
            careerPath = p.careerPath ?? "Medical Path"
            isFirstGen = p.isFirstGen
        }
        didLoad = true
    }

    @MainActor
    private func save() {
        let target: StudentProfileModel
        if let existing = profile {
            target = existing
        } else {
            target = StudentProfileModel(firstName: firstName, lastName: lastName)
            modelContext.insert(target)
        }
        target.firstName = firstName
        target.lastName = lastName
        target.grade = grade
        target.schoolName = school.isEmpty ? nil : school
        target.gpa = Double(gpaText)
        target.satScore = Int(satText)
        target.actScore = Int(actText)
        target.careerPath = careerPath
        target.isFirstGen = isFirstGen
        // TODO: trigger ConnectionEngine cascades when GPA/SAT/career/grade changes
        try? modelContext.save()
    }

    @ViewBuilder
    private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(title)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()
            content()
        }
    }

    private func field(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            TextField(label, text: text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(label.contains("Name") || label == "School" ? .words : .never)
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurface)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                        .stroke(LadderColors.outlineVariant.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Career Path Picker Sheet
// Quick override without taking the full quiz

struct CareerPathPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let currentPath: String?
    let onSelect: (String) -> Void

    private let options: [(title: String, icon: String, color: Color)] = [
        ("Medical Path", "stethoscope", LadderColors.error),
        ("Engineering & STEM", "atom", LadderColors.primary),
        ("Business & Finance", "chart.line.uptrend.xyaxis", LadderColors.tertiary),
        ("Humanities", "book.closed.fill", LadderColors.accentLime),
        ("Sports & Athletics", "figure.run", LadderColors.secondaryFixed),
        ("Law & Public Service", "scalemass.fill", LadderColors.primaryContainer),
        ("Creative Arts", "paintpalette.fill", LadderColors.accentLime)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Pick the path that best matches you. You can change this anytime or take the full quiz for a deeper analysis.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .padding(.bottom, LadderSpacing.sm)

                        ForEach(options, id: \.title) { opt in
                            Button { onSelect(opt.title) } label: {
                                HStack(spacing: LadderSpacing.md) {
                                    Image(systemName: opt.icon)
                                        .font(.system(size: 18))
                                        .foregroundStyle(opt.color)
                                        .frame(width: 36, height: 36)
                                        .background(opt.color.opacity(0.15))
                                        .clipShape(Circle())
                                    Text(opt.title)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Spacer()
                                    if currentPath == opt.title {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(LadderColors.primary)
                                    }
                                }
                                .padding(LadderSpacing.md)
                                .background(
                                    currentPath == opt.title
                                        ? LadderColors.primary.opacity(0.08)
                                        : LadderColors.surfaceContainerLow
                                )
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(LadderSpacing.lg)
                }
            }
            .navigationTitle("Change Career Path")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }
}

// MARK: - Saved Colleges View
// Lists all colleges whose IDs are in StudentProfileModel.savedCollegeIds

struct SavedCollegesView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [StudentProfileModel]

    private var savedIds: [String] { profiles.first?.savedCollegeIds ?? [] }

    private var savedColleges: [CollegeListItem] {
        let all = CollegeListItem.sampleColleges
        if savedIds.isEmpty {
            // Fallback to first 3 sample colleges so the view isn't empty during testing
            return Array(all.prefix(3))
        }
        return all.filter { savedIds.contains($0.id) }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            if savedColleges.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: LadderSpacing.md) {
                        ForEach(savedColleges) { college in
                            collegeRow(college)
                        }
                    }
                    .padding(LadderSpacing.lg)
                }
            }
        }
        .navigationTitle("Saved Colleges")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
    }

    private func collegeRow(_ college: CollegeListItem) -> some View {
        Button {
            coordinator.navigate(to: .collegeProfile(collegeId: college.id))
        } label: {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    Circle()
                        .fill(LadderColors.primaryContainer.opacity(0.3))
                        .frame(width: 56, height: 56)
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(LadderColors.primary)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(college.name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(college.location)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                    if let match = college.matchPercent {
                        Text("\(match)% Match")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, 2)
                            .background(LadderColors.secondaryFixed)
                            .clipShape(Capsule())
                    }
                }
                Spacer()

                Button {
                    unsave(college.id)
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(LadderColors.error)
                        .font(.system(size: 18))
                }
                .buttonStyle(.plain)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            .padding(LadderSpacing.md)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .ladderShadow(LadderElevation.ambient)
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 100, height: 100)
                Image(systemName: "heart")
                    .font(.system(size: 40))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Saved Colleges Yet")
                .font(LadderTypography.headlineSmall)
                .foregroundStyle(LadderColors.onSurface)

            Text("Browse the Colleges tab and tap the heart icon to save schools you're interested in.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.xl)

            LadderPrimaryButton("Browse Colleges", icon: "arrow.right") {
                coordinator.switchTab(to: .colleges)
                dismiss()
            }
            .padding(.horizontal, LadderSpacing.xl)
            .padding(.top, LadderSpacing.md)

            Spacer()
        }
    }

    @MainActor
    private func unsave(_ id: String) {
        guard let p = profiles.first else { return }
        p.savedCollegeIds.removeAll { $0 == id }
    }
}
