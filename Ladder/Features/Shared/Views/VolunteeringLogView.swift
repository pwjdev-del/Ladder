import SwiftUI

// MARK: - Volunteering Log View

struct VolunteeringLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entries: [VolunteerEntry] = []
    @State private var showingAddSheet = false

    // Bright Futures thresholds
    let fasThreshold = 100.0
    let fmsThreshold = 75.0

    var totalHours: Double {
        entries.reduce(0) { $0 + $1.hours }
    }

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Progress toward Bright Futures
                    LadderCard {
                        VStack(spacing: LadderSpacing.md) {
                            Text("Volunteer Hours")
                                .font(LadderTypography.titleSmall)
                                .foregroundStyle(LadderColors.onSurface)

                            ZStack {
                                Circle()
                                    .stroke(LadderColors.surfaceContainerLow, lineWidth: 14)
                                    .frame(width: 130, height: 130)
                                Circle()
                                    .trim(from: 0, to: min(totalHours / fasThreshold, 1.0))
                                    .stroke(LadderColors.primary, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                                    .frame(width: 130, height: 130)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut, value: totalHours)
                                VStack(spacing: 2) {
                                    Text("\(Int(totalHours))")
                                        .font(LadderTypography.headlineMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text("hours")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }

                            // Thresholds
                            HStack(spacing: LadderSpacing.lg) {
                                VStack {
                                    Image(systemName: totalHours >= fmsThreshold ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(totalHours >= fmsThreshold ? LadderColors.primary : LadderColors.outlineVariant)
                                    Text("FMS (75h)")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                                VStack {
                                    Image(systemName: totalHours >= fasThreshold ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(totalHours >= fasThreshold ? LadderColors.primary : LadderColors.outlineVariant)
                                    Text("FAS (100h)")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }

                            if totalHours < fasThreshold {
                                Text("\(Int(fasThreshold - totalHours)) hours to FAS eligibility")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(.orange)
                            } else {
                                Text("FAS requirement met!")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.primary)
                            }
                        }
                    }

                    // Log entries
                    HStack {
                        Text("Activity Log")
                            .font(LadderTypography.titleSmall)
                            .foregroundStyle(LadderColors.onSurface)
                        Spacer()
                        Button { showingAddSheet = true } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(LadderColors.primary)
                        }
                    }

                    ForEach(entries) { entry in
                        LadderCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.organization)
                                        .font(LadderTypography.bodyMedium)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text(entry.activity)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(LadderColors.outlineVariant)
                                }
                                Spacer()
                                Text("\(String(format: "%.1f", entry.hours))h")
                                    .font(LadderTypography.titleSmall)
                                    .foregroundStyle(LadderColors.primary)
                            }
                        }
                    }

                    if entries.isEmpty {
                        VStack(spacing: LadderSpacing.md) {
                            Image(systemName: "heart.circle")
                                .font(.system(size: 48))
                                .foregroundStyle(LadderColors.outlineVariant)
                            Text("Start logging your volunteer hours")
                                .font(LadderTypography.bodyMedium)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                        }
                        .padding(.top, 40)
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
                    Image(systemName: "chevron.left").foregroundStyle(LadderColors.onSurface)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Volunteering").font(LadderTypography.titleSmall)
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddVolunteerSheet { entry in
                entries.append(entry)
            }
        }
    }
}

struct VolunteerEntry: Identifiable {
    let id = UUID()
    let organization: String
    let activity: String
    let hours: Double
    let date: Date
}

struct AddVolunteerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var org = ""
    @State private var activity = ""
    @State private var hours = ""
    @State private var date = Date()
    let onSave: (VolunteerEntry) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()
                VStack(spacing: LadderSpacing.md) {
                    LadderTextField("Organization", text: $org)
                    LadderTextField("Activity Description", text: $activity)
                    LadderTextField("Hours", text: $hours).keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .font(LadderTypography.bodyMedium)
                    LadderPrimaryButton("Log Hours", icon: "plus") {
                        let entry = VolunteerEntry(organization: org, activity: activity, hours: Double(hours) ?? 0, date: date)
                        onSave(entry)
                        dismiss()
                    }
                    .disabled(org.isEmpty || hours.isEmpty)
                    Spacer()
                }
                .padding(LadderSpacing.lg)
            }
            .navigationTitle("Log Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
