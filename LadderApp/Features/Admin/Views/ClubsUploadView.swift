import SwiftUI
import SwiftData

// MARK: - Clubs Upload View
// Admin uploads and manages school clubs

struct ClubsUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SchoolClubModel.name) private var clubs: [SchoolClubModel]
    @State private var showAddSheet = false
    @State private var showDeleteConfirmation = false
    @State private var clubToDelete: SchoolClubModel?

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School Clubs")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Manage your school's clubs and organizations")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Club count badge
                    HStack {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(LadderColors.primary)
                        Text("\(clubs.count) Clubs")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

                    if clubs.isEmpty {
                        // Empty state
                        emptyState
                    } else {
                        // Club list
                        ForEach(clubs) { club in
                            clubCard(club)
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
                            Text("Add Club")
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
                Text("School Clubs")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddClubSheet { club in
                modelContext.insert(club)
            }
        }
        .alert("Delete Club?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let club = clubToDelete {
                    modelContext.delete(club)
                }
            }
        } message: {
            Text("This will permanently remove \(clubToDelete?.name ?? "this club"). This action cannot be undone.")
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
                Image(systemName: "person.3.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Clubs Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("No clubs added yet. Add your school's clubs so students can discover them.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Club Card

    private func clubCard(_ club: SchoolClubModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous)
                    .fill(LadderColors.primaryContainer.opacity(0.3))
                    .frame(width: 44, height: 44)
                Image(systemName: SchoolClubModel.categoryIcons[club.category] ?? "star.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(LadderColors.primary)
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(club.name)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.sm) {
                    LadderTagChip(club.category)

                    if let day = club.meetingDay {
                        Text(day)
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }
            }

            Spacer()

            Button {
                clubToDelete = club
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

// MARK: - Add Club Sheet

struct AddClubSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var category = "Academic"
    @State private var meetingDay = ""
    @State private var meetingTime = ""
    @State private var location = ""
    @State private var advisor = ""
    @State private var hasTryout = false
    @State private var tryoutDate = Date()

    let onSave: (SchoolClubModel) -> Void

    private let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.xl) {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Add New Club")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Fill in the club details below")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, LadderSpacing.lg)

                        // Club Name
                        formField("Club Name", text: $name, placeholder: "e.g. Robotics Club")

                        // Category
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Category")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: LadderSpacing.sm) {
                                    ForEach(SchoolClubModel.allCategories, id: \.self) { cat in
                                        LadderFilterChip(title: cat, isSelected: category == cat) {
                                            category = cat
                                        }
                                    }
                                }
                            }
                        }

                        // Meeting Day
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Meeting Day")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: LadderSpacing.sm) {
                                    ForEach(weekdays, id: \.self) { day in
                                        LadderFilterChip(title: day, isSelected: meetingDay == day) {
                                            meetingDay = meetingDay == day ? "" : day
                                        }
                                    }
                                }
                            }
                        }

                        // Meeting Time
                        formField("Meeting Time", text: $meetingTime, placeholder: "e.g. 3:00 - 4:00 PM")

                        // Location
                        formField("Location", text: $location, placeholder: "e.g. Room 204")

                        // Advisor
                        formField("Advisor Name", text: $advisor, placeholder: "e.g. Ms. Johnson")

                        // Tryout date
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Toggle(isOn: $hasTryout) {
                                Text("Has Tryout/Audition")
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

                        // Save button
                        LadderPrimaryButton("Save Club", icon: "checkmark.circle") {
                            saveClub()
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

    private func saveClub() {
        let club = SchoolClubModel(name: name, category: category)
        club.meetingDay = meetingDay.isEmpty ? nil : meetingDay
        club.meetingTime = meetingTime.isEmpty ? nil : meetingTime
        club.location = location.isEmpty ? nil : location
        club.advisor = advisor.isEmpty ? nil : advisor
        club.tryoutDate = hasTryout ? tryoutDate : nil
        onSave(club)
        dismiss()
    }
}
