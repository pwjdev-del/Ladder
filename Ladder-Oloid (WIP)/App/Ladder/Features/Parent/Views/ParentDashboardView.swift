import SwiftUI

struct ParentDashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("PARENT DASHBOARD")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.secondaryFixed)
                            .labelTracking()
                        Text("Welcome, Parent")
                            .font(LadderTypography.headlineLarge)
                            .foregroundStyle(.white)
                            .editorialTracking()
                        Text("Track your child's college journey")
                            .font(LadderTypography.bodyMedium)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(LadderSpacing.xl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [LadderColors.primary, LadderColors.primaryContainer],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: LadderRadius.xxl))

                    // Invite code CTA
                    inviteCodeCard

                    // Feature previews (stubs)
                    featureCard(icon: "person.fill", title: "Your Child's Profile", subtitle: "GPA, courses, activities, career path")
                    featureCard(icon: "calendar", title: "Upcoming Deadlines", subtitle: "SAT, applications, financial aid")
                    featureCard(icon: "dollarsign.circle.fill", title: "Financial Overview", subtitle: "Scholarship apps, aid estimates")
                    featureCard(icon: "message.fill", title: "Message Counselor", subtitle: "Direct line to school counselor")
                    featureCard(icon: "chart.bar.fill", title: "Peer Comparison", subtitle: "Anonymized benchmarks")

                    // Sign out
                    Button("Sign Out") { Task { await authManager.signOut() } }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.error)
                        .padding(.top, LadderSpacing.xl)
                }
                .padding(LadderSpacing.lg)
            }
        }
        .navigationTitle("Parent")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var inviteCodeCard: some View {
        LadderCard(elevated: true) {
            VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                Text("Link to Your Child")
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurface)
                Text("Ask your child to share their invite code from the app.")
                    .font(LadderTypography.bodyMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                LadderPrimaryButton("Enter Invite Code", icon: "link") {}
            }
        }
    }

    private func featureCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: LadderSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(LadderColors.primary)
                .frame(width: 44, height: 44)
                .background(LadderColors.primaryContainer.opacity(0.2))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: LadderSpacing.xxs) {
                Text(title).font(LadderTypography.titleSmall).foregroundStyle(LadderColors.onSurface)
                Text(subtitle).font(LadderTypography.bodySmall).foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Spacer()
            LadderTagChip("Coming Soon", icon: "sparkles")
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg))
    }
}
