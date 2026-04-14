import SwiftUI

struct CounselorDashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("COUNSELOR DASHBOARD")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.secondaryFixed)
                            .labelTracking()
                        Text("Welcome, Counselor")
                            .font(LadderTypography.headlineLarge)
                            .foregroundStyle(.white)
                            .editorialTracking()
                        Text("Guide your students to their next chapter")
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

                    // Feature previews (stubs)
                    featureCard(icon: "person.3.fill", title: "My Caseload (120 students)", subtitle: "View and manage assigned students")
                    featureCard(icon: "person.crop.rectangle.fill", title: "Student Detail Views", subtitle: "Deep dive into each student's profile")
                    featureCard(icon: "checkmark.seal.fill", title: "Class Approval Queue", subtitle: "Review pending course requests")
                    featureCard(icon: "exclamationmark.triangle.fill", title: "At-Risk Alerts", subtitle: "Students who need intervention")
                    featureCard(icon: "message.fill", title: "Messaging Center", subtitle: "Communicate with students and parents")
                    featureCard(icon: "square.and.arrow.down.fill", title: "Bulk Import", subtitle: "Upload student rosters from CSV")
                    featureCard(icon: "chart.bar.doc.horizontal.fill", title: "Impact Report", subtitle: "See outcomes for your cohort")
                    featureCard(icon: "arrow.clockwise.circle.fill", title: "Year Rollover", subtitle: "Advance students to next grade")

                    // Sign out
                    Button("Sign Out") { Task { await authManager.signOut() } }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.error)
                        .padding(.top, LadderSpacing.xl)
                }
                .padding(LadderSpacing.lg)
            }
        }
        .navigationTitle("Counselor")
        .navigationBarTitleDisplayMode(.inline)
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
