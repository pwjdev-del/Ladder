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

// MARK: - College Gradient Hero
// Deterministic gradient per school — zero cost, works for all 6,900 colleges

struct CollegeGradientHero: View {
    let name: String
    let height: CGFloat

    private static let gradientPairs: [(Color, Color)] = [
        (Color(red: 0.16, green: 0.38, blue: 0.15), Color(red: 0.55, green: 0.75, blue: 0.25)), // Forest → Lime
        (Color(red: 0.08, green: 0.18, blue: 0.45), Color(red: 0.20, green: 0.52, blue: 0.80)), // Navy → Sky
        (Color(red: 0.45, green: 0.08, blue: 0.15), Color(red: 0.75, green: 0.25, blue: 0.35)), // Burgundy → Rose
        (Color(red: 0.55, green: 0.25, blue: 0.05), Color(red: 0.90, green: 0.65, blue: 0.10)), // Rust → Gold
        (Color(red: 0.22, green: 0.10, blue: 0.50), Color(red: 0.55, green: 0.30, blue: 0.75)), // Indigo → Violet
        (Color(red: 0.05, green: 0.40, blue: 0.45), Color(red: 0.15, green: 0.70, blue: 0.65)), // Teal → Cyan
        (Color(red: 0.15, green: 0.15, blue: 0.20), Color(red: 0.40, green: 0.45, blue: 0.55)), // Charcoal → Steel
        (Color(red: 0.12, green: 0.35, blue: 0.25), Color(red: 0.35, green: 0.60, blue: 0.40)), // Forest → Sage
    ]

    private var gradientIndex: Int {
        let hash = name.unicodeScalars.reduce(0) { acc, scalar in
            (acc &* 31 &+ Int(scalar.value)) & 0x7FFFFFFF
        }
        return abs(hash) % Self.gradientPairs.count
    }

    private var initials: String {
        let words = name.split(separator: " ").prefix(2)
        return words.compactMap { $0.first.map { String($0) } }.joined()
    }

    var body: some View {
        let (start, end) = Self.gradientPairs[gradientIndex]
        ZStack {
            LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
            Text(initials)
                .font(.system(size: height * 0.28, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.30))
        }
        .frame(height: height)
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
                // Hero image or gradient fallback
                ZStack(alignment: .topTrailing) {
                    Group {
                        if let url = imageURL.flatMap({ URL(string: $0) }) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fill)
                                default:
                                    CollegeGradientHero(name: name, height: 140)
                                }
                            }
                        } else {
                            CollegeGradientHero(name: name, height: 140)
                        }
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
