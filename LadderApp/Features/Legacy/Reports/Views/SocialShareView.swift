import SwiftUI

// MARK: - Social Share View

struct SocialShareView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTemplate = 0

    private let templates = [
        ("I got accepted! 🎓", "Celebrating my acceptance to [School Name]! The journey was worth it.", "checkmark.seal.fill"),
        ("Application Complete ✅", "Just submitted all my college applications! Feeling accomplished.", "paperplane.fill"),
        ("Scholarship Winner 💰", "Grateful to receive the [Scholarship Name]! Hard work pays off.", "banknote.fill"),
    ]

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    Text("Share Your Achievement")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    // Template picker
                    ForEach(Array(templates.enumerated()), id: \.offset) { index, template in
                        LadderCard {
                            HStack(spacing: LadderSpacing.md) {
                                Image(systemName: template.2)
                                    .font(.title2)
                                    .foregroundStyle(LadderColors.primary)
                                    .frame(width: 40)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.0)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text(template.1)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }

                                Spacer()

                                Image(systemName: selectedTemplate == index ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedTemplate == index ? LadderColors.primary : LadderColors.outlineVariant)
                            }
                        }
                        .onTapGesture { selectedTemplate = index }
                    }

                    // Preview card
                    LadderCard {
                        VStack(spacing: LadderSpacing.md) {
                            // Mock social card
                            ZStack {
                                RoundedRectangle(cornerRadius: LadderRadius.xl)
                                    .fill(
                                        LinearGradient(
                                            colors: [LadderColors.primary, LadderColors.primaryContainer],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 200)

                                VStack(spacing: LadderSpacing.sm) {
                                    Image(systemName: "graduationcap.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(.white)
                                    Text(templates[selectedTemplate].0)
                                        .font(LadderTypography.titleMedium)
                                        .foregroundStyle(.white)
                                    Text("Made with Ladder 🪜")
                                        .font(LadderTypography.labelSmall)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                            }
                        }
                    }

                    ShareLink(item: templates[selectedTemplate].1) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .font(LadderTypography.labelMedium)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, LadderSpacing.md)
                        .background(LadderColors.primary)
                        .clipShape(Capsule())
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
        }
    }
}
