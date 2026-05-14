import SwiftUI

// MARK: - SiaNudgeCard
//
// Warm, non-alarming card for proactive SIA nudges on the Home tab urgency section.
// Per SIA_PERSONA_RESEARCH.md: low-pressure tone, no red warnings, conversational framing.
//
// Usage:
//   SiaNudgeCard(
//     nudge: nudgeIntent,
//     index: 0,
//     total: 2,
//     onTellMeMore: { ... },
//     onNotNow: { ... },
//     onShowNext: { ... }   // nil when index == total - 1
//   )

struct SiaNudgeCard: View {

    let nudge: NudgeIntent
    let index: Int
    let total: Int
    let onTellMeMore: () -> Void
    let onNotNow: () -> Void
    /// Nil when this is the only nudge or the last in the stack.
    let onShowNext: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            messageBody
            actions

            if total > 1 {
                paginationFooter
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: LadderBrand.radiusCard + 4, style: .continuous))
        .overlay(cardBorder)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 8) {
            // SIA avatar — matches the chat surface avatar style.
            ZStack {
                Circle()
                    .fill(LadderBrand.lime500.opacity(0.18))
                    .frame(width: 30, height: 30)
                Image(systemName: "sparkles")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LadderBrand.lime500)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("SIA")
                    .font(.ladderCaps(10))
                    .tracking(0.7)
                    .foregroundStyle(LadderBrand.lime500)
                Text("for you")
                    .font(.ladderBody(11))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))
            }

            Spacer()

            // Priority badge — only for critical/high so it doesn't feel alarming.
            if nudge.priority == .critical || nudge.priority == .high {
                priorityBadge
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }

    private var priorityBadge: some View {
        Text(nudge.priority == .critical ? "Urgent" : "Soon")
            .font(.ladderCaps(9))
            .tracking(0.6)
            .foregroundStyle(
                nudge.priority == .critical ? LadderBrand.statusRed : LadderBrand.statusAmber
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                (nudge.priority == .critical ? LadderBrand.statusRed : LadderBrand.statusAmber)
                    .opacity(0.15)
            )
            .clipShape(Capsule())
    }

    // MARK: - Message body

    private var messageBody: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(nudge.title)
                .font(.ladderDisplay(16, relativeTo: .callout))
                .foregroundStyle(LadderBrand.cream100)
                .fixedSize(horizontal: false, vertical: true)

            Text(nudge.rawMessage)
                .font(.ladderBody(14))
                .foregroundStyle(LadderBrand.cream100.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(2)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    // MARK: - Action buttons

    private var actions: some View {
        HStack(spacing: 8) {
            // "Tell me more" — primary CTA, opens AdvisorChat with seed message.
            Button(action: onTellMeMore) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Tell me more")
                        .font(.ladderLabel(13))
                }
                .foregroundStyle(LadderBrand.ink900)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(LadderBrand.lime500)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            // "Not now" — ghost dismiss.
            Button(action: onNotNow) {
                Text("Not now")
                    .font(.ladderLabel(13))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(LadderBrand.cream100.opacity(0.08))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.bottom, total > 1 ? 10 : 14)
    }

    // MARK: - Pagination footer (only when total > 1)

    private var paginationFooter: some View {
        HStack {
            // Dot indicator.
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { i in
                    Circle()
                        .fill(i == index
                              ? LadderBrand.lime500
                              : LadderBrand.cream100.opacity(0.25))
                        .frame(width: 5, height: 5)
                }
            }

            Spacer()

            if let showNext = onShowNext {
                Button(action: showNext) {
                    HStack(spacing: 4) {
                        Text("Show me the next one")
                            .font(.ladderBody(12))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundStyle(LadderBrand.cream100.opacity(0.55))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 12)
    }

    // MARK: - Background & border

    private var cardBackground: some ShapeStyle {
        // Warm dark surface — distinct from the brutal forest900 background but not a bright card.
        // Subtle gradient from forest700 to forest900 keeps it warm, not alarming.
        LinearGradient(
            colors: [LadderBrand.forest700.opacity(0.85), LadderBrand.forest900.opacity(0.95)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: LadderBrand.radiusCard + 4, style: .continuous)
            .stroke(LadderBrand.lime500.opacity(0.18), lineWidth: 1)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.23, green: 0.34, blue: 0.22)
            .ignoresSafeArea()

        VStack(spacing: 16) {
            SiaNudgeCard(
                nudge: NudgeIntent(
                    title: "Build your college list",
                    rawMessage: "Aim for 8-12 schools by summer. You're at 3 — now's the time to add safeties and a few reaches.",
                    priority: .normal,
                    specialist: nil,
                    deepLink: "colleges",
                    topic: "college-list"
                ),
                index: 0,
                total: 2,
                onTellMeMore: {},
                onNotNow: {},
                onShowNext: {}
            )

            SiaNudgeCard(
                nudge: NudgeIntent(
                    title: "File FAFSA",
                    rawMessage: "FAFSA is open. Filing Oct-Nov = ~2x the grant money vs late filers.",
                    priority: .critical,
                    specialist: nil,
                    deepLink: "financial/fafsa",
                    topic: "fafsa"
                ),
                index: 1,
                total: 2,
                onTellMeMore: {},
                onNotNow: {},
                onShowNext: nil
            )
        }
        .padding()
    }
}
