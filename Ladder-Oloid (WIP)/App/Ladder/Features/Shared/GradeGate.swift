import SwiftUI
import SwiftData

// Helpers for deciding which features/content are age-appropriate.
enum GradeFeature {
    case essayHub         // unlock 11th+
    case mockInterview    // unlock 11th+
    case lociGenerator    // unlock 12th post-submission (we gate by 12th for now)
    case thankYouNote     // unlock 12th+
    case applicationTracker // unlock 11th+
    case decisionPortal   // unlock 12th+
    case waitlistStrategy // unlock 12th+
    case financialAid     // unlock 11th+
    case scoreImprovement // unlock 10th+
    case commonApp        // unlock 11th+ (summer)
    case fafsa            // unlock 12th
}

struct GradeGate {
    static func isUnlocked(_ feature: GradeFeature, grade: Int) -> Bool {
        switch feature {
        case .essayHub, .mockInterview, .applicationTracker, .financialAid, .commonApp:
            return grade >= 11
        case .scoreImprovement:
            return grade >= 10
        case .lociGenerator, .thankYouNote, .decisionPortal, .waitlistStrategy, .fafsa:
            return grade >= 12
        }
    }

    static func lockMessage(_ feature: GradeFeature) -> String {
        switch feature {
        case .essayHub: return "Essay Hub unlocks junior year (11th grade). For now, focus on your activities and grades."
        case .mockInterview: return "Mock interviews unlock in 11th grade. Build your story first."
        case .lociGenerator, .waitlistStrategy: return "Available after you've submitted applications (12th grade)."
        case .applicationTracker: return "Application tracking unlocks junior year."
        case .decisionPortal: return "Decision portal unlocks 12th grade when decisions come in."
        case .financialAid: return "Financial aid planning unlocks in 11th grade."
        case .scoreImprovement: return "SAT/ACT planning unlocks 10th grade."
        case .thankYouNote: return "Available for seniors after interviews and acceptances."
        case .commonApp: return "Common App opens for your cycle in summer before senior year."
        case .fafsa: return "FAFSA opens October of senior year."
        }
    }
}

// A reusable "locked feature" card
struct LockedFeatureCard: View {
    let title: String
    let icon: String
    let feature: GradeFeature
    let userGrade: Int

    var body: some View {
        VStack(spacing: LadderSpacing.sm) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Text(title)
                    .font(LadderTypography.titleMedium)
                    .foregroundStyle(LadderColors.onSurfaceVariant)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(LadderColors.onSurfaceVariant)
            }
            Text(GradeGate.lockMessage(feature))
                .font(LadderTypography.bodySmall)
                .foregroundStyle(LadderColors.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(LadderSpacing.md)
        .background(LadderColors.surfaceContainerLow.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: LadderRadius.lg, style: .continuous)
                .stroke(LadderColors.outlineVariant.opacity(0.3), lineWidth: 1)
        )
    }
}
