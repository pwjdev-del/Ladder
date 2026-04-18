import SwiftUI
import SwiftData
import MapKit

// MARK: - College Visit Planner View
// Plan and track campus visits with map, calendar integration, and notes

struct VisitPlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var vm = VisitPlannerViewModel()
    @State private var showingMap = false
    @State private var editingNotes: CollegeModel? = nil
    @State private var editNoteText = ""
    @State private var calendarSuccess = false

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Stats header
                    statsHeader

                    // Toggle: List / Map
                    viewToggle

                    if showingMap {
                        mapSection
                    } else {
                        // Search + filters
                        searchAndFilters

                        // Sort
                        sortControl

                        // Colleges list
                        if vm.displayColleges.isEmpty {
                            emptyState
                        } else {
                            collegeList
                        }
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
                Text("Visit Planner")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $vm.showingPlanSheet) {
            planVisitSheet
        }
        .sheet(item: $editingNotes) { college in
            visitNotesSheet(college)
        }
        .task {
            vm.loadData(from: context)
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        HStack(spacing: LadderSpacing.sm) {
            statBadge("\(vm.savedColleges.count)", "Total", LadderColors.onSurfaceVariant)
            statBadge("\(vm.plannedCount)", "Planned", LadderColors.secondaryFixedDim)
            statBadge("\(vm.visitedCount)", "Visited", LadderColors.primary)
        }
    }

    private func statBadge(_ count: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: LadderSpacing.xs) {
            Text(count)
                .font(LadderTypography.titleLarge)
                .foregroundStyle(color)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
    }

    // MARK: - View Toggle

    private var viewToggle: some View {
        HStack(spacing: 0) {
            toggleButton("List", icon: "list.bullet", isSelected: !showingMap) {
                showingMap = false
            }
            toggleButton("Map", icon: "map", isSelected: showingMap) {
                showingMap = true
            }
        }
        .background(LadderColors.surfaceContainerLow)
        .clipShape(Capsule())
    }

    private func toggleButton(_ title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(LadderTypography.labelMedium)
            }
            .foregroundStyle(isSelected ? .white : LadderColors.onSurfaceVariant)
            .frame(maxWidth: .infinity)
            .padding(.vertical, LadderSpacing.sm)
            .background(isSelected ? LadderColors.primary : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Search & Filters

    private var searchAndFilters: some View {
        VStack(spacing: LadderSpacing.sm) {
            LadderSearchBar(placeholder: "Search saved colleges...", text: $vm.searchText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LadderSpacing.sm) {
                    LadderFilterChip(title: "All", isSelected: vm.filterStatus == nil) {
                        vm.filterStatus = nil
                    }
                    ForEach(VisitPlannerViewModel.VisitStatus.allCases, id: \.self) { status in
                        LadderFilterChip(title: status.rawValue, isSelected: vm.filterStatus == status) {
                            vm.filterStatus = vm.filterStatus == status ? nil : status
                        }
                    }
                }
            }
        }
    }

    // MARK: - Sort Control

    private var sortControl: some View {
        HStack {
            Text("\(vm.displayColleges.count) COLLEGES")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            Spacer()

            Menu {
                ForEach(VisitPlannerViewModel.SortOrder.allCases, id: \.self) { order in
                    Button {
                        vm.sortOrder = order
                    } label: {
                        HStack {
                            Text(order.rawValue)
                            if vm.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: LadderSpacing.xs) {
                    Text(vm.sortOrder.rawValue)
                        .font(LadderTypography.labelMedium)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundStyle(LadderColors.primary)
            }
        }
    }

    // MARK: - College List

    private var collegeList: some View {
        VStack(spacing: LadderSpacing.sm) {
            ForEach(vm.displayColleges) { item in
                collegeVisitCard(item)
            }
        }
    }

    private func collegeVisitCard(_ item: CollegeVisitItem) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                        Text(item.college.name)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                            .lineLimit(1)
                        if let city = item.college.city, let state = item.college.state {
                            Text("\(city), \(state)")
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    Spacer()

                    statusBadge(item.status)
                }

                // Visit date if planned
                if let visit = item.visit {
                    HStack(spacing: LadderSpacing.sm) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                            .foregroundStyle(LadderColors.primary)

                        Text(visit.visitDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurface)

                        if let tourTime = visit.tourTime {
                            Text(tourTime.formatted(date: .omitted, time: .shortened))
                                .font(LadderTypography.bodySmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                    }

                    if let notes = visit.notes, !notes.isEmpty {
                        Text(notes)
                            .font(LadderTypography.bodySmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }

                // Action buttons
                HStack(spacing: LadderSpacing.sm) {
                    switch item.status {
                    case .notPlanned:
                        actionButton("Plan Visit", icon: "calendar.badge.plus") {
                            vm.beginPlanVisit(for: item.college)
                        }
                    case .planned:
                        actionButton("Edit", icon: "pencil") {
                            vm.beginPlanVisit(for: item.college)
                        }
                        actionButton("Mark Visited", icon: "checkmark.circle") {
                            vm.markAsVisited(item.college, context: context)
                        }
                    case .visited:
                        actionButton("View Notes", icon: "note.text") {
                            editNoteText = item.visit?.notes ?? ""
                            editingNotes = item.college
                        }
                        actionButton("Edit Visit", icon: "pencil") {
                            vm.beginPlanVisit(for: item.college)
                        }
                    }
                }
            }
        }
    }

    private func statusBadge(_ status: VisitPlannerViewModel.VisitStatus) -> some View {
        Text(status.rawValue)
            .font(LadderTypography.labelSmall)
            .foregroundStyle(statusColor(status) == LadderColors.onSurfaceVariant ? LadderColors.onSurfaceVariant : .white)
            .padding(.horizontal, LadderSpacing.sm)
            .padding(.vertical, LadderSpacing.xxs)
            .background(statusColor(status) == LadderColors.onSurfaceVariant ? LadderColors.surfaceContainerHighest : statusColor(status))
            .clipShape(Capsule())
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: LadderSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                Text(title)
                    .font(LadderTypography.labelSmall)
            }
            .foregroundStyle(LadderColors.primary)
            .padding(.horizontal, LadderSpacing.md)
            .padding(.vertical, LadderSpacing.sm)
            .background(LadderColors.surfaceContainerHighest)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Map Section

    private var mapSection: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Map(coordinateRegion: $vm.mapRegion, annotationItems: vm.mapAnnotations) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        VStack(spacing: 2) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(statusColor(pin.status))
                            Text(pin.name)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))

                // Legend
                HStack(spacing: LadderSpacing.lg) {
                    legendItem("Not Planned", LadderColors.onSurfaceVariant)
                    legendItem("Planned", LadderColors.secondaryFixedDim)
                    legendItem("Visited", LadderColors.primary)
                }
            }
        }
    }

    private func legendItem(_ label: String, _ color: Color) -> some View {
        HStack(spacing: LadderSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Plan Visit Sheet

    private var planVisitSheet: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        if let college = vm.planningCollege {
                            LadderCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(college.name)
                                            .font(LadderTypography.titleMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                        if let city = college.city, let state = college.state {
                                            Text("\(city), \(state)")
                                                .font(LadderTypography.bodySmall)
                                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "building.columns")
                                        .font(.system(size: 24))
                                        .foregroundStyle(LadderColors.primary)
                                }
                            }
                        }

                        // Date picker
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                                Text("Visit Date")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)

                                DatePicker("Date", selection: $vm.visitDate, displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .tint(LadderColors.primary)

                                Toggle(isOn: $vm.includeTime) {
                                    HStack(spacing: LadderSpacing.sm) {
                                        Image(systemName: "clock")
                                            .foregroundStyle(LadderColors.primary)
                                        Text("Include tour time")
                                            .font(LadderTypography.bodyMedium)
                                            .foregroundStyle(LadderColors.onSurface)
                                    }
                                }
                                .tint(LadderColors.primary)

                                if vm.includeTime {
                                    DatePicker("Tour Time", selection: $vm.visitTime, displayedComponents: .hourAndMinute)
                                        .font(LadderTypography.bodyMedium)
                                        .tint(LadderColors.primary)
                                }
                            }
                        }

                        // Notes
                        LadderCard {
                            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                Text("Notes")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.onSurface)

                                TextEditor(text: $vm.visitNotes)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .scrollContentBackground(.hidden)
                                    .frame(minHeight: 100)
                                    .padding(LadderSpacing.sm)
                                    .background(LadderColors.surfaceContainerHighest)
                                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                            }
                        }

                        // Save button
                        LadderPrimaryButton("Save Visit", icon: "checkmark") {
                            vm.saveVisit(context: context)
                        }

                        // Add to calendar
                        if let college = vm.planningCollege {
                            LadderSecondaryButton("Add to Calendar") {
                                Task {
                                    calendarSuccess = await vm.addToCalendar(college: college)
                                }
                            }
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, LadderSpacing.xxl)
                }
            }
            .navigationTitle("Plan Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.showingPlanSheet = false }
                        .foregroundStyle(LadderColors.primary)
                }
            }
            .alert("Added to Calendar", isPresented: $calendarSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("The campus visit has been added to your calendar with reminders.")
            }
        }
    }

    // MARK: - Visit Notes Sheet

    private func visitNotesSheet(_ college: CollegeModel) -> some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                VStack(spacing: LadderSpacing.lg) {
                    LadderCard {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Visit Notes for \(college.name)")
                                .font(LadderTypography.titleMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            TextEditor(text: $editNoteText)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 200)
                                .padding(LadderSpacing.sm)
                                .background(LadderColors.surfaceContainerHighest)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                        }
                    }

                    LadderPrimaryButton("Save Notes", icon: "checkmark") {
                        vm.updateNotes(for: college, notes: editNoteText, context: context)
                        editingNotes = nil
                    }

                    Spacer()
                }
                .padding(LadderSpacing.lg)
            }
            .navigationTitle("Visit Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { editingNotes = nil }
                        .foregroundStyle(LadderColors.primary)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        LadderCard {
            VStack(spacing: LadderSpacing.md) {
                Image(systemName: "mappin.slash")
                    .font(.system(size: 44))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text("No colleges to show")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Save colleges from the Discovery Hub to start planning campus visits.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Helpers

    private func statusColor(_ status: VisitPlannerViewModel.VisitStatus) -> Color {
        switch status {
        case .notPlanned: return LadderColors.onSurfaceVariant
        case .planned: return LadderColors.secondaryFixedDim
        case .visited: return LadderColors.primary
        }
    }
}

// MARK: - Make CollegeModel Identifiable for sheet(item:)

extension CollegeModel: @retroactive Identifiable {
    public var id: String { supabaseId ?? String(scorecardId ?? 0) }
}
