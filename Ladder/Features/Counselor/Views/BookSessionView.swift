import SwiftUI

// MARK: - Book Session View
// Student books a session with a selected counselor

struct BookSessionView: View {
    @Environment(\.dismiss) private var dismiss
    let counselorName: String
    let counselorSpecialty: String?

    @State private var sessionDate = Date()
    @State private var selectedTimeSlot = "Morning"
    @State private var selectedSessionType = "College List Review"
    @State private var notes = ""
    @State private var showConfirmation = false

    private let timeSlots = ["Morning", "Afternoon", "Evening"]
    private let sessionTypes = ["College List Review", "Essay Review", "Test Prep Strategy", "Financial Aid Help"]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: LadderSpacing.xl) {

                    // Counselor header
                    counselorHeader

                    // Date picker
                    dateSection

                    // Time slot picker
                    timeSlotSection

                    // Session type picker
                    sessionTypeSection

                    // Notes
                    notesSection

                    // Request button
                    LadderPrimaryButton("Request Session", icon: "calendar.badge.plus") {
                        saveSession()
                        showConfirmation = true
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, LadderSpacing.lg)
                .padding(.top, LadderSpacing.lg)
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
                Text("Book Session")
                    .font(LadderTypography.titleSmall)
                    .foregroundStyle(LadderColors.onSurface)
            }
        }
        .alert("Session Requested", isPresented: $showConfirmation) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your session request with \(counselorName) has been submitted. You'll receive a confirmation once they accept.")
        }
    }

    // MARK: - Counselor Header

    private var counselorHeader: some View {
        HStack(spacing: LadderSpacing.md) {
            Circle()
                .fill(LadderColors.primaryContainer)
                .frame(width: 56, height: 56)
                .overlay {
                    Text(String(counselorName.split(separator: " ").last?.prefix(1) ?? "?"))
                        .font(LadderTypography.titleLarge)
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(counselorName)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                if let specialty = counselorSpecialty {
                    Text(specialty)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.primary)
                }
            }

            Spacer()
        }
        .padding(LadderSpacing.lg)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Session Date")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            DatePicker("Select date", selection: $sessionDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(LadderColors.primary)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        }
    }

    // MARK: - Time Slot Section

    private var timeSlotSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Preferred Time")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            HStack(spacing: LadderSpacing.sm) {
                ForEach(timeSlots, id: \.self) { slot in
                    Button {
                        selectedTimeSlot = slot
                    } label: {
                        HStack(spacing: LadderSpacing.xs) {
                            Image(systemName: iconForTimeSlot(slot))
                                .font(.system(size: 14))
                            Text(slot)
                                .font(LadderTypography.labelMedium)
                        }
                        .foregroundStyle(selectedTimeSlot == slot ? .white : LadderColors.onSurfaceVariant)
                        .padding(.horizontal, LadderSpacing.md)
                        .padding(.vertical, LadderSpacing.sm)
                        .background(selectedTimeSlot == slot ? LadderColors.primary : LadderColors.surfaceContainerLow)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Session Type Section

    private var sessionTypeSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Session Type")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            VStack(spacing: LadderSpacing.sm) {
                ForEach(sessionTypes, id: \.self) { type in
                    Button {
                        selectedSessionType = type
                    } label: {
                        HStack {
                            Image(systemName: iconForSessionType(type))
                                .font(.system(size: 16))
                                .foregroundStyle(selectedSessionType == type ? LadderColors.primary : LadderColors.onSurfaceVariant)
                                .frame(width: 28)

                            Text(type)
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurface)

                            Spacer()

                            Image(systemName: selectedSessionType == type ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundStyle(selectedSessionType == type ? LadderColors.primary : LadderColors.outlineVariant)
                        }
                        .padding(LadderSpacing.md)
                        .background(selectedSessionType == type ? LadderColors.primaryContainer.opacity(0.15) : LadderColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("Notes (Optional)")
                .font(LadderTypography.titleSmall)
                .foregroundStyle(LadderColors.onSurface)

            TextEditor(text: $notes)
                .font(LadderTypography.bodyMedium)
                .foregroundStyle(LadderColors.onSurface)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100)
                .padding(LadderSpacing.md)
                .background(LadderColors.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
                .overlay(alignment: .topLeading) {
                    if notes.isEmpty {
                        Text("Anything specific you'd like to discuss...")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant.opacity(0.5))
                            .padding(LadderSpacing.md)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Helpers

    private func iconForTimeSlot(_ slot: String) -> String {
        switch slot {
        case "Morning": return "sun.horizon"
        case "Afternoon": return "sun.max"
        case "Evening": return "moon.stars"
        default: return "clock"
        }
    }

    private func iconForSessionType(_ type: String) -> String {
        switch type {
        case "College List Review": return "building.columns"
        case "Essay Review": return "doc.text"
        case "Test Prep Strategy": return "chart.line.uptrend.xyaxis"
        case "Financial Aid Help": return "dollarsign.circle"
        default: return "questionmark.circle"
        }
    }

    private func saveSession() {
        let session: [String: String] = [
            "counselorName": counselorName,
            "date": sessionDate.formatted(date: .abbreviated, time: .omitted),
            "timeSlot": selectedTimeSlot,
            "sessionType": selectedSessionType,
            "notes": notes,
            "status": "pending"
        ]
        var sessions = UserDefaults.standard.array(forKey: "ladder_booked_sessions") as? [[String: String]] ?? []
        sessions.append(session)
        UserDefaults.standard.set(sessions, forKey: "ladder_booked_sessions")
    }
}
