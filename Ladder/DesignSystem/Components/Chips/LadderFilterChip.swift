import SwiftUI

// MARK: - Filter Chip
// Unselected: surfaceContainerHigh bg, onSurfaceVariant text
// Selected: primary bg, onPrimary text

struct LadderFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(isSelected ? .white : LadderColors.onSurfaceVariant)
                .padding(.horizontal, LadderSpacing.md)
                .padding(.vertical, LadderSpacing.sm)
                .background(isSelected ? LadderColors.primary : LadderColors.surfaceContainerHigh)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Tag Chip (display-only, not interactive)

struct LadderTagChip: View {
    let title: String
    let icon: String?

    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: LadderSpacing.xs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 10))
            }
            Text(title)
                .font(LadderTypography.labelSmall)
        }
        .foregroundStyle(LadderColors.onSurfaceVariant)
        .padding(.horizontal, LadderSpacing.sm)
        .padding(.vertical, LadderSpacing.xs)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(Capsule())
    }
}

// MARK: - Removable Chip (for AP courses, interests)

struct LadderRemovableChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: LadderSpacing.xs) {
            Text(title)
                .font(LadderTypography.labelMedium)
                .foregroundStyle(LadderColors.onSurface)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }
        .padding(.horizontal, LadderSpacing.sm)
        .padding(.vertical, LadderSpacing.xs)
        .background(LadderColors.surfaceContainerHighest)
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 16) {
        HStack {
            LadderFilterChip(title: "All", isSelected: true) {}
            LadderFilterChip(title: "Ivy League", isSelected: false) {}
            LadderFilterChip(title: "Engineering", isSelected: false) {}
        }

        HStack {
            LadderTagChip("STEM", icon: "flask")
            LadderTagChip("Co-op")
            LadderTagChip("Private")
        }

        HStack {
            LadderRemovableChip(title: "AP Calculus") {}
            LadderRemovableChip(title: "AP Physics") {}
        }
    }
    .padding(24)
    .background(LadderColors.surface)
}
