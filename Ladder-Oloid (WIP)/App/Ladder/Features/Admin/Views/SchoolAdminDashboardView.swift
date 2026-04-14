import SwiftUI

struct SchoolAdminDashboardView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            LadderColors.surface.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: LadderSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: LadderSpacing.sm) {
                        Text("SCHOOL ADMIN DASHBOARD")
                            .font(LadderTypography.labelSmall)
                            .foregroundStyle(LadderColors.secondaryFixed)
                            .labelTracking()
                        Text("Welcome, Administrator")
                            .font(LadderTypography.headlineLarge)
                            .foregroundStyle(.white)
                            .editorialTracking()
                        Text("Oversee your school's college readiness")
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
                    featureCard(icon: "chart.pie.fill", title: "School Analytics", subtitle: "Enrollment, outcomes, engagement")
                    featureCard(icon: "books.vertical.fill", title: "Class Catalog", subtitle: "Manage courses offered school-wide")
                    featureCard(icon: "checkmark.shield.fill", title: "Approve Counselors", subtitle: "Review and authorize staff access")
                    featureCard(icon: "scalemass.fill", title: "Equity Metrics", subtitle: "Track access across demographics")
                    featureCard(icon: "square.and.arrow.up.fill", title: "Data Export", subtitle: "Download reports for district")
                    featureCard(icon: "flag.fill", title: "Content Moderation", subtitle: "Review flagged student content")
                    featureCard(icon: "doc.text.fill", title: "DPA Management", subtitle: "Data privacy agreements and compliance")
                    featureCard(icon: "megaphone.fill", title: "Announcements", subtitle: "School-wide messages to students")

                    // Sign out
                    Button("Sign Out") { Task { await authManager.signOut() } }
                        .font(LadderTypography.labelLarge)
                        .foregroundStyle(LadderColors.error)
                        .padding(.top, LadderSpacing.xl)
                }
                .padding(LadderSpacing.lg)
            }
        }
        .navigationTitle("School Admin")
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
