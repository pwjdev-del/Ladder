import SwiftUI

// MARK: - Class Difficulty Picker View
// Reusable view for selecting class difficulty preference
// Used in onboarding Step 2 and Profile settings

struct ClassDifficultyPickerView: View {
    @Binding var selectedDifficulty: String

    private let options: [(id: String, title: String, icon: String, description: String)] = [
        (
            id: "balanced",
            title: "Balanced",
            icon: "scale.3d",
            description: "A mix of regular and honors classes. 0-1 AP per year."
        ),
        (
            id: "challenging",
            title: "Challenging",
            icon: "flame",
            description: "Honors track with strategic APs. 2-3 AP per year."
        ),
        (
            id: "maximum",
            title: "Maximum Rigor",
            icon: "bolt.fill",
            description: "All honors/AP when available. 4+ AP per year."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: LadderSpacing.sm) {
            Text("CLASS DIFFICULTY PREFERENCE")
                .font(LadderTypography.labelSmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .labelTracking()

            Text("Helps us tailor course recommendations to your goals")
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)

            VStack(spacing: LadderSpacing.sm) {
                ForEach(options, id: \.id) { option in
                    difficultyCard(option)
                }
            }
        }
    }

    private func difficultyCard(_ option: (id: String, title: String, icon: String, description: String)) -> some View {
        let isSelected = selectedDifficulty == option.id

        return Button {
            withAnimation(.spring(response: 0.25)) {
                selectedDifficulty = option.id
            }
        } label: {
            HStack(spacing: LadderSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                        .fill(isSelected ? LadderColors.primaryContainer.opacity(0.3) : LadderColors.surfaceContainerHigh)
                        .frame(width: 48, height: 48)
                    Image(systemName: option.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? LadderColors.primary : LadderColors.onSurfaceVariant)
                }

                VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                    Text(option.title)
                        .font(LadderTypography.titleSmall)
                        .foregroundStyle(LadderColors.onSurface)
                    Text(option.description)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(isSelected ? LadderColors.primary : LadderColors.outlineVariant, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(LadderColors.primary)
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(LadderSpacing.md)
            .background(isSelected ? LadderColors.primaryContainer.opacity(0.1) : LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous)
                    .stroke(isSelected ? LadderColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var difficulty = "balanced"
        var body: some View {
            ClassDifficultyPickerView(selectedDifficulty: $difficulty)
                .padding()
        }
    }
    return PreviewWrapper()
}
