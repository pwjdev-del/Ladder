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
                    // Logo + slogan block, horizontally + vertically centered
                    // in the top half of the screen.
                    VStack(spacing: 28) {
                        logoBadge
                        slogan
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()

                    ctaStack
                    footerIcons
                        .padding(.top, 20)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
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
            Image("LadderLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .saturation(climberSaturation)
                .shadow(color: Color.black.opacity(0.16), radius: 16, x: 0, y: 10)
                .scaleEffect(holdProgress >= 1 ? 1.02 : 1.0)
                .animation(.easeOut(duration: 0.12), value: holdProgress >= 1)

            Circle()
                .trim(from: 0, to: holdProgress)
                .stroke(
                    LadderBrand.lime500.opacity(ringOpacity),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: 188, height: 188)
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

    // MARK: - CTA stack

    private var ctaStack: some View {
        VStack(spacing: 16) {
            Button(action: { goB2CLogin = true }) {
                Text("Log in with your ID")
                    .font(.custom("Manrope-SemiBold", size: 16, relativeTo: .body))
                    .foregroundStyle(LadderBrand.ink900)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(LadderBrand.lime500)
                    .clipShape(Capsule())
            }

            Button(action: { goSchoolPicker = true }) {
                Text("Sign in through your school")
                    .font(.custom("Manrope-SemiBold", size: 16, relativeTo: .body))
                    .foregroundStyle(LadderBrand.cream100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.clear)
                    .overlay(
                        Capsule().stroke(LadderBrand.cream100.opacity(0.15), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                Button(action: { goB2CSignup = true }) {
                    Text("Sign up as a student")
                        .font(.custom("Manrope-SemiBold", size: 14, relativeTo: .callout))
                        .foregroundStyle(LadderBrand.forest700)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LadderBrand.stone200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)
                }

                Button(action: { goSchoolPartnerForm = true }) {
                    Text("Partner as a school")
                        .font(.custom("Manrope-SemiBold", size: 14, relativeTo: .callout))
                        .foregroundStyle(LadderBrand.forest700)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(LadderBrand.stone200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 1)
                }
            }
            .padding(.top, 8)
        }
    }

    // MARK: - Footer icons (40% opacity per Stitch)

    private var footerIcons: some View {
        HStack(spacing: 24) {
            Image(systemName: "rosette")
            Image(systemName: "graduationcap.fill")
            Image(systemName: "face.smiling")
            Image(systemName: "stairs")
        }
        .font(.system(size: 22, weight: .regular))
        .foregroundStyle(LadderBrand.cream100.opacity(0.4))
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
