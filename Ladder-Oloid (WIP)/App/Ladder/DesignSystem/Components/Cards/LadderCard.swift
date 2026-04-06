import SwiftUI

// MARK: - Base Card
// No borders ever. Tonal surface shifts only. xl corner radius.

struct LadderCard<Content: View>: View {
    let elevated: Bool
    @ViewBuilder let content: () -> Content

    init(elevated: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.elevated = elevated
        self.content = content
    }

    var body: some View {
        content()
            .padding(LadderSpacing.lg)
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .if(elevated) { view in
                view.ladderShadow(LadderElevation.ambient)
            }
    }
}

// MARK: - College Card (Discovery Hub)

struct CollegeCard: View {
    let name: String
    let location: String
    let matchPercent: Int?
    let imageURL: String?
    let tags: [String]
    let isFavorite: Bool
    let onFavorite: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero image
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: imageURL ?? "")) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        LadderColors.surfaceContainerHigh
                    }
                    .frame(height: 140)
                    .clipped()

                    // Favorite button
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(isFavorite ? LadderColors.error : .white)
                            .padding(8)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding(LadderSpacing.sm)

                    // Match badge
                    if let matchPercent {
                        Text("\(matchPercent)% Match")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.onSecondaryFixed)
                            .padding(.horizontal, LadderSpacing.sm)
                            .padding(.vertical, LadderSpacing.xs)
                            .background(LadderColors.secondaryFixed)
                            .clipShape(Capsule())
                            .padding(LadderSpacing.sm)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                }

                // Info section
                VStack(alignment: .leading, spacing: LadderSpacing.xs) {
                    Text(name)
                        .font(LadderTypography.titleMedium)
                        .foregroundStyle(LadderColors.onSurface)
                        .lineLimit(1)

                    Text(location)
                        .font(LadderTypography.bodySmall)
                        .foregroundStyle(LadderColors.onSurfaceVariant)

                    // Tag chips
                    HStack(spacing: LadderSpacing.xs) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(LadderTypography.labelSmall)
                                .foregroundStyle(LadderColors.onSurfaceVariant)
                                .padding(.horizontal, LadderSpacing.sm)
                                .padding(.vertical, LadderSpacing.xxs)
                                .background(LadderColors.surfaceContainerHighest)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(LadderSpacing.md)
            }
            .background(LadderColors.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xl, style: .continuous))
            .ladderShadow(LadderElevation.ambient)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Conditional View Modifier

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Checklist Progress")
                    .font(LadderTypography.titleMedium)
                Text("6 of 10 tasks completed")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
        }

        CollegeCard(
            name: "Rochester Institute of Technology",
            location: "Rochester, NY",
            matchPercent: 92,
            imageURL: nil,
            tags: ["Engineering", "Co-op", "STEM"],
            isFavorite: true,
            onFavorite: {},
            onTap: {}
        )
    }
    .padding(24)
    .background(LadderColors.surface)
}
