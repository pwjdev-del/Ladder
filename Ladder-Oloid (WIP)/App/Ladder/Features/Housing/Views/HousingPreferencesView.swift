import SwiftUI

// MARK: - Housing Preferences Quiz
// Batch_09_Housing_Profile K1 — multi-select quiz that captures a student's
// living preferences. Mock-only; persistence is wired later.

struct HousingPreferencesView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(\.dismiss) private var dismiss

    // MARK: - Answer State

    @State private var socialStyle: String? = nil
    @State private var sleepSchedule: String? = nil
    @State private var roomType: String? = nil
    @State private var genderPref: String? = nil
    @State private var distancePref: String? = nil
    @State private var cleanliness: String? = nil
    @State private var showSavedToast = false

    // MARK: - Question Bank

    private let socialOptions = ["Quiet", "Balanced", "Social"]
    private let sleepOptions = ["Early Bird", "Flexible", "Night Owl"]
    private let roomOptions = ["Single", "Double", "Suite", "No preference"]
    private let genderOptions = ["Co-ed", "Single-gender", "No preference"]
    private let distanceOptions = ["Near campus core", "Mid-campus", "Quieter perimeter"]
    private let cleanlinessOptions = ["Very tidy", "Average", "Relaxed"]

    // MARK: - Body

    var body: some View {
        Group {
            if sizeClass == .regular { iPadLayout } else { iPhoneLayout }
        }
        .background(LadderColors.surface.ignoresSafeArea())
        .navigationTitle("Housing Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LadderColors.onSurface)
                }
            }
        }
        .overlay(alignment: .top) {
            if showSavedToast {
                savedToast
                    .padding(.top, LadderSpacing.md)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                header
                questionBlocks
                saveButton
            }
            .padding(LadderSpacing.lg)
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        ScrollView {
            HStack(alignment: .top, spacing: LadderSpacing.xl) {
                // Left rail: summary
                LadderCard(elevated: true) {
                    VStack(alignment: .leading, spacing: LadderSpacing.md) {
                        Text("Your Profile")
                            .font(LadderTypography.titleLarge)
                            .foregroundStyle(LadderColors.onSurface)
                        Text("Answer a few questions so we can match you to dorms and roommates.")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(LadderColors.onSurfaceVariant)
                        Divider().background(LadderColors.outlineVariant)
                        summaryRow("Vibe", socialStyle)
                        summaryRow("Sleep", sleepSchedule)
                        summaryRow("Room", roomType)
                        summaryRow("Building", genderPref)
                        summaryRow("Location", distancePref)
                        summaryRow("Cleanliness", cleanliness)
                    }
                }
                .frame(width: 320)

                // Right column: quiz
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    header
                    questionBlocks
                    saveButton
                }
                .frame(maxWidth: 720)
            }
            .padding(LadderSpacing.xxl)
            .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.xs) {
            Text("FIND YOUR FIT")
                .font(LadderTypography.labelMedium)
                .labelTracking()
                .foregroundStyle(LadderColors.primary)
            Text("Housing Preferences")
                .font(LadderTypography.headlineLarge)
                .editorialTracking()
                .foregroundStyle(LadderColors.onSurface)
            Text("Tell us how you like to live. We'll use this to rank dorms and suggest roommates.")
                .font(LadderTypography.bodyLarge)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
    }

    private var questionBlocks: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.lg) {
            questionCard(
                title: "Social Style",
                subtitle: "How lively do you want your floor?",
                options: socialOptions,
                selection: $socialStyle
            )
            questionCard(
                title: "Sleep Schedule",
                subtitle: "When are you most alert?",
                options: sleepOptions,
                selection: $sleepSchedule
            )
            questionCard(
                title: "Room Type",
                subtitle: "Single, double, or something bigger?",
                options: roomOptions,
                selection: $roomType
            )
            questionCard(
                title: "Building Type",
                subtitle: "Pick your preferred community.",
                options: genderOptions,
                selection: $genderPref
            )
            questionCard(
                title: "Distance to Campus",
                subtitle: "How close should you be to classes?",
                options: distanceOptions,
                selection: $distancePref
            )
            questionCard(
                title: "Cleanliness",
                subtitle: "How tidy do you keep things?",
                options: cleanlinessOptions,
                selection: $cleanliness
            )
        }
    }

    private var saveButton: some View {
        VStack(spacing: LadderSpacing.sm) {
            LadderPrimaryButton("Save Preferences", icon: "checkmark") {
                withAnimation(.easeOut(duration: 0.25)) { showSavedToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    withAnimation(.easeIn(duration: 0.2)) { showSavedToast = false }
                }
            }
            Text("You can update these any time.")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
        }
        .padding(.top, LadderSpacing.md)
    }

    private var savedToast: some View {
        HStack(spacing: LadderSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(LadderColors.accentLime)
            Text("Preferences saved")
                .font(LadderTypography.labelLarge)
                .foregroundStyle(LadderColors.onSurface)
        }
        .padding(.horizontal, LadderSpacing.lg)
        .padding(.vertical, LadderSpacing.md)
        .background(LadderColors.surfaceContainerHigh)
        .clipShape(Capsule())
        .ladderShadow(LadderElevation.floating)
    }

    // MARK: - Reusable Pieces

    private func questionCard(
        title: String,
        subtitle: String,
        options: [String],
        selection: Binding<String?>
    ) -> some View {
        LadderCard {
            VStack(alignment: .leading, spacing: LadderSpacing.md) {
                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(title)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(subtitle)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                }

                FlowRow(spacing: LadderSpacing.sm) {
                    ForEach(options, id: \.self) { option in
                        LadderFilterChip(
                            title: option,
                            isSelected: selection.wrappedValue == option
                        ) {
                            selection.wrappedValue = option
                        }
                    }
                }
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
            Spacer()
            Text(value ?? "—")
                .font(LadderTypography.labelMedium)
                .foregroundStyle(value == nil ? LadderColors.onSurfaceVariant : LadderColors.onSurface)
        }
    }
}

// MARK: - Flow Row (wraps chips without Grid)

private struct FlowRow<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        _FlowLayout(spacing: spacing) { content() }
    }
}

private struct _FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
