import SwiftUI

// CLAUDE.md §3 — unauthenticated landing.
// Visual source of truth: `docs/design/stitch-deliverables/batch-11-full-v2-spec/landing_page_v2/`
// Three affordances + hidden 30s logo-hold founder trigger.
// Feedback states (§3.2 spec in landing_interaction_states_spec):
//   0s idle · 5s desaturate · 15s soft haptic + faint ring · 25s medium + bright ring · 30s success + full ring → FounderLogin

public struct LandingView: View {
    @State private var holdProgress: Double = 0
    @State private var isHolding = false
    @State private var holdStartedAt: Date?

    @State private var goFounderLogin = false
    @State private var goB2CLogin = false
    @State private var goSchoolPicker = false
    @State private var goB2CSignup = false
    @State private var goSchoolPartnerForm = false

    private let holdTarget: TimeInterval = 30

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                LadderBrand.forest700.ignoresSafeArea()
                BrandGradient.heroGlow

                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 32) {
                        logoBadge
                        slogan
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()

                    ctaStack
                        .padding(.horizontal, 24)

                    createAccountLink
                        .padding(.top, 16)

                    partnerFooterLink
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                }
            }
            .navigationDestination(isPresented: $goFounderLogin) { FounderLoginView() }
            .navigationDestination(isPresented: $goB2CLogin) { B2CLoginView() }
            .navigationDestination(isPresented: $goSchoolPicker) { SchoolPickerView() }
            .navigationDestination(isPresented: $goB2CSignup) { B2CSignupView() }
            .navigationDestination(isPresented: $goSchoolPartnerForm) { SchoolPartnerInquiryView() }
        }
        .tint(LadderBrand.cream100)
    }

    // MARK: - Logo (hidden 30s founder trigger)

    private var logoBadge: some View {
        ZStack {
            // Real Ladder logo — circular asset (climber + ladder + hills).
            LadderLogoMark(size: 260, withShadow: true)
                .saturation(climberSaturation)
                .scaleEffect(holdProgress >= 1 ? 1.02 : 1.0)
                .animation(.easeOut(duration: 0.12), value: holdProgress >= 1)

            Circle()
                .trim(from: 0, to: holdProgress)
                .stroke(
                    LadderBrand.lime500.opacity(ringOpacity),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: holdProgress)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .gesture(holdGesture)
        .accessibilityLabel("Ladder")
        .accessibilityHint("Press and hold for founder access")
    }

    /// Logo desaturates up to ~15% between 5s and 15s of the founder hold.
    private var climberSaturation: Double {
        guard let start = holdStartedAt else { return 1.0 }
        let elapsed = Date().timeIntervalSince(start)
        if elapsed < 5 { return 1.0 }
        let mix = min((elapsed - 5) / 10, 1.0) * 0.15
        return 1.0 - mix
    }

    private var ringOpacity: Double {
        if holdProgress <= 0 { return 0 }
        if holdProgress < 0.5 { return 0.05 }
        if holdProgress < 0.83 { return 0.4 }
        return 1.0
    }

    private var ringWidth: CGFloat {
        if holdProgress < 0.5 { return 2 }
        if holdProgress < 0.83 { return 3 }
        return 3.5
    }

    // MARK: - Slogan

    private var slogan: some View {
        Text("Every kid needs a ladder to success.")
            .font(.custom("PlayfairDisplay-SemiBold", size: 32, relativeTo: .largeTitle))
            .foregroundStyle(LadderBrand.cream100)
            .tracking(-0.64)
            .lineSpacing(4)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 280)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }

    // MARK: - Primary CTAs (only two — no school-self-signup, no student-button-at-this-level)

    private var ctaStack: some View {
        VStack(spacing: 14) {
            Button(action: { goB2CLogin = true }) {
                Text("Log in with your ID")
                    .font(.custom("Manrope-SemiBold", size: 16, relativeTo: .body))
                    .foregroundStyle(LadderBrand.ink900)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LadderBrand.lime500)
                    .clipShape(Capsule())
                    .shadow(color: LadderBrand.lime500.opacity(0.3), radius: 12, y: 4)
            }

            Button(action: { goSchoolPicker = true }) {
                Text("Sign in through your school")
                    .font(.custom("Manrope-SemiBold", size: 16, relativeTo: .body))
                    .foregroundStyle(LadderBrand.cream100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .overlay(Capsule().stroke(LadderBrand.cream100.opacity(0.4), lineWidth: 1))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - B2C signup link (secondary, underlined)

    private var createAccountLink: some View {
        HStack(spacing: 6) {
            Text("New to Ladder?")
                .font(.custom("Manrope-Regular", size: 14, relativeTo: .body))
                .foregroundStyle(LadderBrand.cream100.opacity(0.75))
            Button(action: { goB2CSignup = true }) {
                Text("Create an account")
                    .font(.custom("Manrope-SemiBold", size: 14, relativeTo: .body))
                    .foregroundStyle(LadderBrand.lime500)
                    .underline()
            }
        }
    }

    // MARK: - Schools are NOT self-service — tiny bottom link only (§7, §14.3)

    private var partnerFooterLink: some View {
        HStack(spacing: 6) {
            Text("A school representative?")
                .font(.custom("Manrope-Regular", size: 12, relativeTo: .caption))
                .foregroundStyle(LadderBrand.cream100.opacity(0.55))
            Button(action: { goSchoolPartnerForm = true }) {
                Text("Get in touch")
                    .font(.custom("Manrope-SemiBold", size: 12, relativeTo: .caption))
                    .foregroundStyle(LadderBrand.cream100.opacity(0.85))
                    .underline()
            }
        }
    }

    // MARK: - 30s hold gesture

    private var holdGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                if !isHolding {
                    isHolding = true
                    holdStartedAt = Date()
                    startProgressTimer()
                }
            }
            .onEnded { _ in
                isHolding = false
                if holdProgress >= 1.0 { fireFounderTrigger() }
                resetHold()
            }
    }

    private func startProgressTimer() {
        Task { @MainActor in
            var lastMilestone = 0
            while isHolding {
                try? await Task.sleep(nanoseconds: 50_000_000)
                guard let start = holdStartedAt else { break }
                let elapsed = Date().timeIntervalSince(start)
                let newProgress = min(elapsed / holdTarget, 1.0)
                holdProgress = newProgress

                if elapsed >= 15 && lastMilestone < 15 { softHaptic(); lastMilestone = 15 }
                if elapsed >= 25 && lastMilestone < 25 { mediumHaptic(); lastMilestone = 25 }
                if newProgress >= 1.0 { break }
            }
        }
    }

    private func resetHold() {
        Task { @MainActor in
            withAnimation(.easeOut(duration: 0.4)) { holdProgress = 0 }
            holdStartedAt = nil
        }
    }

    private func fireFounderTrigger() {
        successHaptic()
        goFounderLogin = true
    }

    #if canImport(UIKit)
    private func softHaptic()    { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
    private func mediumHaptic()  { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    private func successHaptic() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    #else
    private func softHaptic() {}
    private func mediumHaptic() {}
    private func successHaptic() {}
    #endif
}
