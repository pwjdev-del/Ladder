import SwiftUI
import SwiftData

// MARK: - School Calendar Upload View
// Admin uploads and manages school calendar events

struct SchoolCalendarUploadView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SchoolCalendarEventModel.eventDate) private var events: [SchoolCalendarEventModel]
    @State private var showAddSheet = false
    @State private var showDeleteConfirmation = false
    @State private var eventToDelete: SchoolCalendarEventModel?
    @State private var selectedMonth = Date()

    private var calendar: Calendar { Calendar.current }

    private var eventsInSelectedMonth: [SchoolCalendarEventModel] {
        events.filter { event in
            calendar.isDate(event.eventDate, equalTo: selectedMonth, toGranularity: .month)
        }
    }

    private var upcomingEvents: [SchoolCalendarEventModel] {
        let now = Date()
        return events.filter { $0.eventDate >= now }
    }

    private var daysWithEvents: Set<Int> {
        var days = Set<Int>()
        for event in eventsInSelectedMonth {
            days.insert(calendar.component(.day, from: event.eventDate))
        }
        return days
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("School Calendar")
                            .font(LadderTypography.headlineMedium)
                            .foregroundStyle(LadderColors.onSurface)

                        Text("Manage school events, holidays, and important dates")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, LadderSpacing.lg)

                    // Event count badge
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(LadderColors.primary)
                        Text("\(events.count) Events")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                    }
                    .padding(LadderSpacing.md)
                    .background(LadderColors.primaryContainer.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))

                    // Month navigation + mini calendar
                    calendarMonthView

                    // Upcoming events list
                    if events.isEmpty {
                        emptyState
                    } else {
                        VStack(alignment: .leading, spacing: LadderSpacing.md) {
                            Text("Upcoming Events")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ForEach(upcomingEvents) { event in
                                eventCard(event)
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
                            Text("Add Event")
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
                Text("School Calendar")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddCalendarEventSheet { event in
                modelContext.insert(event)
            }
        }
        .alert("Delete Event?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let event = eventToDelete {
                    modelContext.delete(event)
                }
            }
        } message: {
            Text("This will permanently remove \"\(eventToDelete?.title ?? "this event")\". This action cannot be undone.")
        }
    }

    // MARK: - Calendar Month View

    private var calendarMonthView: some View {
        VStack(spacing: LadderSpacing.md) {
            // Month navigation
            HStack {
                Button {
                    withAnimation { selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)

                Spacer()

                Button {
                    withAnimation { selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LadderColors.primary)
                }
                .buttonStyle(.plain)
            }

            // Day of week headers
            let weekdaySymbols = calendar.veryShortWeekdaySymbols
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: LadderSpacing.xs) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(LadderTypography.labelSmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day grid
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
        let range = calendar.range(of: .day, in: .month, for: selectedMonth)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = weekday - calendar.firstWeekday
        let adjustedBlanks = leadingBlanks < 0 ? leadingBlanks + 7 : leadingBlanks

        var days: [Int] = Array(repeating: 0, count: adjustedBlanks)
        days.append(contentsOf: range.map { $0 })
        return days
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
                Image(systemName: "calendar")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(LadderColors.primary)
            }

            Text("No Events Yet")
                .font(LadderTypography.titleMedium)
                .foregroundStyle(LadderColors.onSurface)

            Text("Add your school's calendar events so students can stay on top of important dates.")
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LadderSpacing.md)
        }
    }

    // MARK: - Event Card

    private func eventCard(_ event: SchoolCalendarEventModel) -> some View {
        HStack(spacing: LadderSpacing.md) {
            // Date badge
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
            }

            Spacer()

            Button {
                eventToDelete = event
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

// MARK: - Add Calendar Event Sheet

struct AddCalendarEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var eventDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var eventType = "School Event"
    @State private var eventDescription = ""
    @State private var isAllDay = true

    let onSave: (SchoolCalendarEventModel) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: LadderSpacing.xl) {
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Add Event")
                                .font(LadderTypography.headlineMedium)
                                .foregroundStyle(LadderColors.onSurface)
                            Text("Add a new event to the school calendar")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, LadderSpacing.lg)

                        // Event Title
                        formField("Event Title", text: $title, placeholder: "e.g. Spring Break")

                        // Event Type
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Event Type")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: LadderSpacing.sm) {
                                    ForEach(SchoolCalendarEventModel.allEventTypes, id: \.self) { type in
                                        LadderFilterChip(title: type, isSelected: eventType == type) {
                                            eventType = type
                                        }
                                    }
                                }
                            }
                        }

                        // Date
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            DatePicker("Event Date", selection: $eventDate, displayedComponents: .date)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .tint(LadderColors.primary)
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // End Date (optional)
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Toggle(isOn: $hasEndDate) {
                                Text("Multi-day Event")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))

                            if hasEndDate {
                                DatePicker("End Date", selection: $endDate, in: eventDate..., displayedComponents: .date)
                                    .font(LadderTypography.bodyMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                    .tint(LadderColors.primary)
                            }
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // All Day toggle
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Toggle(isOn: $isAllDay) {
                                Text("All Day Event")
                                    .font(LadderTypography.labelMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: LadderColors.primary))
                        }
                        .padding(LadderSpacing.lg)
                        .background(LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))

                        // Description
                        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                            Text("Description (optional)")
                                .font(LadderTypography.labelMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                            TextField("Add details about this event...", text: $eventDescription, axis: .vertical)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)
                                .lineLimit(3...6)
                                .padding(LadderSpacing.sm)
                                .background(LadderColors.surfaceContainer)
                                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.sm, style: .continuous))
                        }

                        // Save button
                        LadderPrimaryButton("Save Event", icon: "checkmark.circle") {
                            saveEvent()
                        }
                        .opacity(title.isEmpty ? 0.5 : 1.0)
                        .disabled(title.isEmpty)

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

    private func saveEvent() {
        let event = SchoolCalendarEventModel(title: title, eventDate: eventDate, eventType: eventType)
        event.endDate = hasEndDate ? endDate : nil
        event.eventDescription = eventDescription.isEmpty ? nil : eventDescription
        event.isAllDay = isAllDay
        onSave(event)
        dismiss()
    }
}
