import SwiftUI

// MARK: - Custom Reminder View

struct CustomReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var notes = ""
    @State private var reminderDate = Date().addingTimeInterval(86400)
    @State private var selectedCategory = "General"
    @State private var saved = false

    let categories = ["General", "Deadline", "Test Prep", "Financial Aid", "Housing", "Interview"]

    var body: some View {
        NavigationStack {
            ZStack {
                LadderColors.surface.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: LadderSpacing.lg) {
                        if saved {
                            // Success state
                            VStack(spacing: LadderSpacing.md) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(LadderColors.primary)
                                Text("Reminder Set!")
                                    .font(LadderTypography.titleMedium)
                                    .foregroundStyle(LadderColors.onSurface)
                                Text("We'll remind you on \(reminderDate.formatted(date: .abbreviated, time: .shortened))")
                                    .font(LadderTypography.bodySmall)
                                    .foregroundStyle(LadderColors.onSurfaceVariant)

                                LadderPrimaryButton("Done", icon: "checkmark") {
                                    dismiss()
                                }
                            }
                            .padding(.top, 60)
                        } else {
                            LadderTextField("Reminder Title", text: $title)

                            // Category
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                    Text("Category")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: LadderSpacing.xs) {
                                            ForEach(categories, id: \.self) { cat in
                                                LadderFilterChip(title: cat, isSelected: selectedCategory == cat) {
                                                    selectedCategory = cat
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Date
                            LadderCard {
                                DatePicker("Remind me on", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                    .font(LadderTypography.bodyMedium)
                                    .tint(LadderColors.primary)
                            }

                            // Notes
                            LadderCard {
                                VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                                    Text("Notes (optional)")
                                        .font(LadderTypography.labelMedium)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                    TextEditor(text: $notes)
                                        .frame(minHeight: 80)
                                        .font(LadderTypography.bodyMedium)
                                        .scrollContentBackground(.hidden)
                                        .padding(8)
                                        .background(LadderColors.surfaceContainerLow)
                                        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.md))
                                }
                            }

                            LadderPrimaryButton("Set Reminder", icon: "bell.badge") {
                                saved = true
                            }
                            .disabled(title.isEmpty)
                            .opacity(title.isEmpty ? 0.5 : 1)
                        }
                    }
                    .padding(LadderSpacing.lg)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }
            }
        }
    }
}
