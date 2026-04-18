import SwiftUI
import SwiftData

// MARK: - My School View
// Student views their school's clubs, sports, and calendar data

struct MySchoolView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SchoolClubModel.name) private var clubs: [SchoolClubModel]
    @Query(sort: \SchoolSportModel.name) private var sports: [SchoolSportModel]
    @Query(sort: \SchoolCalendarEventModel.eventDate) private var events: [SchoolCalendarEventModel]

    @State private var selectedTab = 0
    @State private var selectedClubCategory = "All"
    @State private var selectedEventType = "All"
    @State private var selectedCalendarMonth = Date()
    @State private var showJoinConfirmation = false
    @State private var joinItemName = ""

    private let tabs = ["Clubs", "Sports", "Calendar"]
    private var calendar: Calendar { Calendar.current }

    private var hasSchoolData: Bool {
        !clubs.isEmpty || !sports.isEmpty || !events.isEmpty
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("My School")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Discover clubs, sports, and events")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    if !hasSchoolData {
                        noSchoolDataState
                    } else {
                        // Tab switcher
                        tabSwitcher

                        // Tab content
                        switch selectedTab {
                        case 0: clubsTab
                        case 1: sportsTab
                        case 2: calendarTab
                        default: EmptyView()
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to Activities", isPresented: $showJoinConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(joinItemName) has been added to your activity portfolio.")
        }
    }

    // MARK: - Tab Switcher

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
                } label: {
                    VStack(spacing: LadderSpacing.xs) {
                        Text(tab)
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(selectedTab == index ? LadderColors.primary : LadderColors.onSurfaceVariant)

                        Rectangle()
                            .fill(selectedTab == index ? LadderColors.primary : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, LadderSpacing.xs)
    }

    // MARK: - No School Data State

    private var noSchoolDataState: some View {
        VStack(spacing: LadderSpacing.lg) {
            Spacer().frame(height: LadderSpacing.xl)

            ZStack {
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.25))
                    .frame(width: 110, height: 110)
                Circle()
                    .fill(LadderColors.primaryContainer.opacity(0.5))
                    .frame(width: 80, height: 80)
                Image(systemName: "building.2.fill")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No School Data Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Your school hasn't set up their profile yet. Ask your counselor to add clubs, sports, and calendar events.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Clubs Tab

    private var filteredClubs: [SchoolClubModel] {
        if selectedClubCategory == "All" {
            return clubs
        }
        return clubs.filter { $0.category == selectedClubCategory }
    }

    private var clubsTab: some View {
        VStack(spacing: LadderSpacing.md) {
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LadderSpacing.sm) {
                    LadderFilterChip(title: "All", isSelected: selectedClubCategory == "All") {
                        selectedClubCategory = "All"
                    }
                    ForEach(SchoolClubModel.allCategories, id: \.self) { cat in
                        LadderFilterChip(title: cat, isSelected: selectedClubCategory == cat) {
                            selectedClubCategory = cat
                        }
                    }
                }
            }

            if filteredClubs.isEmpty {
                Text("No clubs in this category")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.xl)
            } else {
                ForEach(filteredClubs) { club in
                    studentClubCard(club)
                }
            }
        }
    }

    private func studentClubCard(_ club: SchoolClubModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
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
                    LadderTagChip(club.category)
                }

                Spacer()
            }

            // Details
            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                if let day = club.meetingDay, let time = club.meetingTime {
                    detailRow(icon: "clock", text: "\(day) \(time)")
                } else if let day = club.meetingDay {
                    detailRow(icon: "clock", text: day)
                }

                if let loc = club.location {
                    detailRow(icon: "mappin", text: loc)
                }

                if let advisor = club.advisor {
                    detailRow(icon: "person", text: "Advisor: \(advisor)")
                }

                if let tryout = club.tryoutDate {
                    detailRow(icon: "calendar", text: "Tryout: \(tryout.formatted(date: .abbreviated, time: .omitted))")
                }
            }

            // Join button
            Button {
                joinClub(club)
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Join Club")
                        .font(LadderTypography.labelLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, LadderSpacing.xs)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Sports Tab

    private var sportsTab: some View {
        VStack(spacing: LadderSpacing.lg) {
            ForEach(SchoolSportModel.allSeasons, id: \.self) { season in
                let seasonSports = sports.filter { $0.season == season }
                if !seasonSports.isEmpty {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        HStack(spacing: LadderSpacing.sm) {
                            Image(systemName: SchoolSportModel.seasonIcons[season] ?? "calendar")
                                .font(.system(size: 16))
                                .foregroundStyle(LadderColors.primary)
                            Text(season)
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)
                            Spacer()
                        }

                        ForEach(seasonSports) { sport in
                            studentSportCard(sport)
                        }
                    }
                }
            }

            if sports.isEmpty {
                Text("No sports programs available")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.xl)
            }
        }
    }

    private func studentSportCard(_ sport: SchoolSportModel) -> some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(sport.name)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    HStack(spacing: LadderSpacing.sm) {
                        LadderTagChip(sport.level)
                        LadderTagChip(sport.gender)
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                if let coach = sport.coach, !coach.isEmpty {
                    detailRow(icon: "person", text: "Coach: \(coach)")
                }

                if let tryout = sport.tryoutDate {
                    detailRow(icon: "calendar", text: "Tryouts: \(tryout.formatted(date: .abbreviated, time: .omitted))")
                }

                if let schedule = sport.practiceSchedule, !schedule.isEmpty {
                    detailRow(icon: "clock", text: schedule)
                }

                if let loc = sport.location, !loc.isEmpty {
                    detailRow(icon: "mappin", text: loc)
                }
            }

            // Sign Up button
            Button {
                signUpForSport(sport)
            } label: {
                HStack(spacing: LadderSpacing.sm) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Sign Up")
                        .font(LadderTypography.labelLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, LadderSpacing.sm)
                .background(LadderColors.primary)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .padding(.top, LadderSpacing.xs)
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Calendar Tab

    private var eventsInSelectedMonth: [SchoolCalendarEventModel] {
        events.filter { event in
            calendar.isDate(event.eventDate, equalTo: selectedCalendarMonth, toGranularity: .month)
        }
    }

    private var daysWithEvents: Set<Int> {
        var days = Set<Int>()
        for event in eventsInSelectedMonth {
            days.insert(calendar.component(.day, from: event.eventDate))
        }
        return days
    }

    private var filteredEvents: [SchoolCalendarEventModel] {
        let monthEvents = eventsInSelectedMonth
        if selectedEventType == "All" {
            return monthEvents
        }
        return monthEvents.filter { $0.eventType == selectedEventType }
    }

    private var calendarTab: some View {
        VStack(spacing: LadderSpacing.md) {
            // Month navigation + mini calendar
            calendarMonthView

            // Event type filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: LadderSpacing.sm) {
                    LadderFilterChip(title: "All", isSelected: selectedEventType == "All") {
                        selectedEventType = "All"
                    }
                    ForEach(SchoolCalendarEventModel.allEventTypes, id: \.self) { type in
                        LadderFilterChip(title: type, isSelected: selectedEventType == type) {
                            selectedEventType = type
                        }
                    }
                }
            }

            // Events list
            if filteredEvents.isEmpty {
                Text("No events this month")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                    .padding(.top, LadderSpacing.xl)
            } else {
                ForEach(filteredEvents) { event in
                    studentEventCard(event)
                }
            }
        }
    }

    private var calendarMonthView: some View {
        VStack(spacing: LadderSpacing.md) {
            HStack {
                Button {
                    withAnimation { selectedCalendarMonth = calendar.date(byAdding: .month, value: -1, to: selectedCalendarMonth) ?? selectedCalendarMonth }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(selectedCalendarMonth.formatted(.dateTime.month(.wide).year()))
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                Button {
                    withAnimation { selectedCalendarMonth = calendar.date(byAdding: .month, value: 1, to: selectedCalendarMonth) ?? selectedCalendarMonth }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }
                .buttonStyle(.plain)
            }

            let weekdaySymbols = calendar.veryShortWeekdaySymbols
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: LadderSpacing.xs) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                }
            }

            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: LadderSpacing.xs) {
                ForEach(days, id: \.self) { day in
                    if day == 0 {
                        Text("")
                            .frame(width: 32, height: 32)
                    } else {
                        ZStack {
                            if daysWithEvents.contains(day) {
                                Circle()
                                    .fill(LadderColors.primaryContainer.opacity(0.4))
                                    .frame(width: 32, height: 32)
                            }
                            Text("\(day)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(daysWithEvents.contains(day) ? LadderColors.primary : LadderColors.onSurface)
                        }
                        .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    private func daysInMonth() -> [Int] {
        let range = calendar.range(of: .day, in: .month, for: selectedCalendarMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedCalendarMonth))!
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = weekday - calendar.firstWeekday
        let adjustedBlanks = leadingBlanks < 0 ? leadingBlanks + 7 : leadingBlanks

        var days: [Int] = Array(repeating: 0, count: adjustedBlanks)
        days.append(contentsOf: range.map { $0 })
        return days
    }

    private func studentEventCard(_ event: SchoolCalendarEventModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            VStack(spacing: 2) {
                Text(event.eventDate.formatted(.dateTime.month(.abbreviated)))
                    .font(LadderTypography.labelSmall)
                    .foregroundStyle(LadderColors.primary)
                Text(event.eventDate.formatted(.dateTime.day()))
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
            }
            .frame(width: 48, height: 48)
            .background(LadderColors.primaryContainer.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                Text(event.title)
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                HStack(spacing: LadderSpacing.sm) {
                    LadderTagChip(event.eventType, icon: SchoolCalendarEventModel.eventTypeIcons[event.eventType])

                    if event.isAllDay {
                        Text("All Day")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                }

                if let desc = event.eventDescription, !desc.isEmpty {
                    Text(desc)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Helper Views

    private func detailRow(icon: String, text: String) -> some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Text(text)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    // MARK: - Actions

    private func joinClub(_ club: SchoolClubModel) {
        let activity = ActivityModel(name: club.name, category: "Club")
        activity.organization = club.name
        activity.role = "Member"
        activity.notes = [
            club.meetingDay.map { "Meets: \($0)" },
            club.meetingTime,
            club.location.map { "Location: \($0)" },
            club.advisor.map { "Advisor: \($0)" }
        ].compactMap { $0 }.joined(separator: " | ")
        modelContext.insert(activity)
        joinItemName = club.name
        showJoinConfirmation = true
    }

    private func signUpForSport(_ sport: SchoolSportModel) {
        let activity = ActivityModel(name: sport.name, category: "Athletics")
        activity.organization = sport.name
        activity.role = "\(sport.level) \(sport.gender)"
        activity.notes = [
            "Season: \(sport.season)",
            sport.coach.map { "Coach: \($0)" },
            sport.practiceSchedule,
            sport.location.map { "Location: \($0)" }
        ].compactMap { $0 }.joined(separator: " | ")
        modelContext.insert(activity)
        joinItemName = sport.name
        showJoinConfirmation = true
    }
}
