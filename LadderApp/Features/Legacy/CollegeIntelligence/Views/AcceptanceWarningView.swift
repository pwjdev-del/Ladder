import SwiftUI

// MARK: - Acceptance Revocation Warning

struct AcceptanceWarningView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()

            ScrollView {
                VStack(spacing: LadderSpacing.lg) {
                    // Warning icon
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 80, height: 80)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.orange)
                    }
                    .padding(.top, LadderSpacing.xl)

                    Text("Protect Your Acceptance")
                        .font(LadderTypography.headlineSmall)
                        .foregroundStyle(LadderColors.onSurface)

                    Text("Colleges can revoke your acceptance. Here's what to avoid.")
                        .font(LadderTypography.bodyMedium)
                        .foregroundStyle(LadderColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // Warning items
                    ForEach(warningItems, id: \.title) { item in
                        LadderCard {
                            HStack(alignment: .top, spacing: LadderSpacing.md) {
                                Image(systemName: item.icon)
                                    .font(.title3)
                                    .foregroundStyle(.orange)
                                    .frame(width: 30)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(LadderTypography.titleSmall)
                                        .foregroundStyle(LadderColors.onSurface)
                                    Text(item.detail)
                                        .font(LadderTypography.bodySmall)
                                        .foregroundStyle(LadderColors.onSurfaceVariant)
                                }
                            }
                        }
                    }

                    LadderPrimaryButton("I Understand", icon: "checkmark.shield") {
                        dismiss()
                    }
                    .padding(.top, LadderSpacing.md)
                }
                .padding(LadderSpacing.lg)
                .padding(.bottom, 120)
            }
        }
    }

    private var warningItems: [(title: String, detail: String, icon: String)] {
        [
            (title: "Senior Year Grades", detail: "A significant GPA drop (especially below a 2.0 or failing grades) can trigger a review. Colleges require your final transcript.", icon: "chart.line.downtrend.xyaxis"),
            (title: "Disciplinary Issues", detail: "Suspensions, expulsions, or academic dishonesty incidents must be reported and can lead to rescission.", icon: "hand.raised"),
            (title: "Course Load Changes", detail: "Dropping AP or honors courses without approval can raise red flags. Maintain the rigor you applied with.", icon: "book.closed"),
            (title: "Social Media", detail: "Inappropriate posts or content can be discovered. Admissions offices do check.", icon: "iphone"),
            (title: "Legal Issues", detail: "Any criminal charges or legal troubles must be reported to the admissions office.", icon: "exclamationmark.shield"),
        ]
    }
}
