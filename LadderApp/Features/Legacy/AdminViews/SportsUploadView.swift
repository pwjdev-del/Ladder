import SwiftUI
import SwiftData

// MARK: - Sports Upload View
// Admin uploads and manages school athletics programs

struct SportsUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SchoolSportModel.name) private var sports: [SchoolSportModel]
    @State private var showAddSheet = false
    @State private var showDeleteConfirmation = false
    @State private var sportToDelete: SchoolSportModel?

    private func sportsForSeason(_ season: String) -> [SchoolSportModel] {
        sports.filter { $0.season == season }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School Athletics")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Manage your school's sports programs")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Sport count badge
                    HStack {
                        Image(systemName: "figure.run")
                            .foregroundStyle(LadderColors.primary)
                        Text("\(sports.count) Sports")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

                    if sports.isEmpty {
                        emptyState
                    } else {
                        // Grouped by season
                        ForEach(SchoolSportModel.allSeasons, id: \.self) { season in
                            let seasonSports = sportsForSeason(season)
                            if !seasonSports.isEmpty {
                                seasonSection(season: season, sports: seasonSports)
                            }
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Add Sport")
                                .font(LadderTypography.titleSmall)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, LadderSpacing.lg)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primary)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, LadderSpacing.lg)
                    .padding(.bottom, LadderSpacing.xxxl)
                }
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
                Text("School Athletics")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddSportSheet { sport in
                modelContext.insert(sport)
            }
        }
        .alert("Delete Sport?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let sport = sportToDelete {
                    modelContext.delete(sport)
                }
            }
        } message: {
            Text("This will permanently remove \(sportToDelete?.name ?? "this sport"). This action cannot be undone.")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "figure.run")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Sports Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Add your school's athletics programs so students can discover tryout dates and schedules.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Season Section

    private func seasonSection(season: String, sports: [SchoolSportModel]) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.md) {
            HStack(spacing: LadderSpacing.sm) {
                Image(systemName: SchoolSportModel.seasonIcons[season] ?? "calendar")
                    .font(.system(size: 16))
                    .foregroundStyle(LadderColors.primary)
                Text(season)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
                Text("\(sports.count)")
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.horizontal, LadderSpacing.sm)
                    .padding(.vertical, LadderSpacing.xxs)
                    .background(LadderColors.surfaceContainerHighest)
                    .clipShape(Capsule())
                Spacer()
            }

            ForEach(sports) { sport in
                sportCard(sport)
            }
        }
    }

    // MARK: - Sport Card

    private func sportCard(_ sport: SchoolSportModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(sport.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.sm) {
                    LadderTagChip(sport.gender)
                    LadderTagChip(sport.level)
                }

                if let coach = sport.coach, !coach.isEmpty {
                    Text("Coach: \(coach)")
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                if let tryout = sport.tryoutDate {
                    HStack(spacing: LadderSpacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                        Text("Tryouts: \(tryout.formatted(date: .abbreviated, time: .omitted))")
                            .font(LadderTypography.labelSmall)
                    }
                    .foregroundStyle(LadderColors.primary)
                }
            }

            Spacer()

            Button {
                sportToDelete = sport
                showDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(LadderColors.error.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }
}

// MARK: - Add Sport Sheet

struct AddSportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var season = "Fall"
    @State private var gender = "Co-ed"
    @State private var level = "Varsity"
    @State private var coach = ""
    @State private var hasTryout = false
    @State private var tryoutDate = Date()
    @State private var hasFirstGame = false
    @State private var firstGameDate = Date()
    @State private var practiceSchedule = ""
    @State private var location = ""

    let onSave: (SchoolSportModel) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.xl) {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Add New Sport")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Fill in the sport details below")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, LadderSpacing.lg)

                        // Sport Name
                        formField("Sport Name", text: $name, placeholder: "e.g. Varsity Football")

                        // Season picker
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Season")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            HStack(spacing: LadderSpacing.sm) {
                                ForEach(SchoolSportModel.allSeasons, id: \.self) { s in
                                    LadderFilterChip(title: s, isSelected: season == s) {
                                        season = s
                                    }
                                }
                            }
                        }

                        // Gender picker
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Gender")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            HStack(spacing: LadderSpacing.sm) {
                                ForEach(SchoolSportModel.allGenders, id: \.self) { g in
                                    LadderFilterChip(title: g, isSelected: gender == g) {
                                        gender = g
                                    }
                                }
                            }
                        }

                        // Level picker
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Level")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            HStack(spacing: LadderSpacing.sm) {
                                ForEach(SchoolSportModel.allLevels, id: \.self) { l in
                                    LadderFilterChip(title: l, isSelected: level == l) {
                                        level = l
                                    }
                                }
                            }
                        }

                        // Coach
                        formField("Coach Name", text: $coach, placeholder: "e.g. Coach Williams")

                        // Practice Schedule
                        formField("Practice Schedule", text: $practiceSchedule, placeholder: "e.g. Mon-Fri 3:30-5:30 PM")

                        // Location
                        formField("Location", text: $location, placeholder: "e.g. Main Gymnasium")

                        // Tryout date
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Toggle(isOn: $hasTryout) {
                                Text("Has Tryout Date")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))

                            if hasTryout {
                                DatePicker("Tryout Date", selection: $tryoutDate, displayedComponents: .date)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .tint(LadderColors.primary)
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // First game date
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Toggle(isOn: $hasFirstGame) {
                                Text("Has First Game Date")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))

                            if hasFirstGame {
                                DatePicker("First Game", selection: $firstGameDate, displayedComponents: .date)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .tint(LadderColors.primary)
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // Save button
                        LadderPrimaryButton("Save Sport", icon: "checkmark.circle") {
                            saveSport()
                        }
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                        .disabled(name.isEmpty)

                        Spacer().frame(height: LadderSpacing.xl)
                    }
                    .padding(.horizontal, LadderSpacing.lg)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                    }
                }
            }
        }
    }

    private func formField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text(label)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            TextField(placeholder, text: text)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .padding(LadderSpacing.sm)
                .background(LadderColors.surfaceContainer)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
        }
    }

    private func saveSport() {
        let sport = SchoolSportModel(name: name, season: season, gender: gender, level: level)
        sport.coach = coach.isEmpty ? nil : coach
        sport.tryoutDate = hasTryout ? tryoutDate : nil
        sport.firstGameDate = hasFirstGame ? firstGameDate : nil
        sport.practiceSchedule = practiceSchedule.isEmpty ? nil : practiceSchedule
        sport.location = location.isEmpty ? nil : location
        onSave(sport)
        dismiss()
    }
}
