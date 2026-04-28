import SwiftUI

// LegalDocumentSheet — modal that shows the actual Terms / Privacy text
// so users can READ what they're agreeing to before they toggle the consent.
//
// Pilot copy is embedded inline. Production should pull from a remote
// source so legal can update without an app release. Phase 4 task.

struct LegalDocumentSheet: View {
    let document: B2CSignupView.LegalDocument
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(document.title)
                        .font(.ladderTitle(28))
                        .foregroundStyle(LadderBrand.ink900)
                        .padding(.bottom, 4)

                    Text("Last updated: April 2026 (pilot)")
                        .font(.ladderBody(13))
                        .foregroundStyle(LadderBrand.ink600)

                    Divider()

                    Text(bodyText)
                        .font(.ladderBody(15))
                        .foregroundStyle(LadderBrand.ink900)
                        .lineSpacing(4)
                }
                .padding(20)
            }
            .background(LadderBrand.paper)
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(LadderBrand.forest700)
                }
            }
        }
    }

    private var bodyText: String {
        switch document {
        case .terms: return termsText
        case .privacy: return privacyText
        }
    }

    private var termsText: String {
        """
        Welcome to Ladder. By creating an account you agree to these terms for the pilot.

        1. WHAT LADDER DOES
        Ladder is an AI college-counselor app for U.S. high-school students. We help you discover careers, track activities, build a college list, and prepare applications. The AI suggestions are guidance, not professional college-counseling advice.

        2. WHO CAN USE LADDER
        You must be at least 13 years old to create an account on your own. If you are under 13, a parent or guardian must consent (we will collect their email after sign-up).

        3. YOUR ACCOUNT
        You are responsible for keeping your password safe. Tell us right away if you think someone else got into your account. You can delete your account at any time from Settings.

        4. WHAT YOU CAN DO WITH LADDER
        You may use Ladder for your own personal college preparation. You may not resell, copy, or scrape the service. You may not use Ladder to harm anyone or break the law.

        5. YOUR DATA IS YOURS
        While you are enrolled at a school through Ladder, that school can see your work in the app (essays, AI chats, college list). When you transfer to a new school, your data follows YOU and your old school loses access. When you switch to a private (B2C) account, no school can see your data.

        6. AI LIMITATIONS
        Ladder uses AI to suggest activities, schools, and essay improvements. AI can make mistakes. You are responsible for verifying any factual claims (deadlines, requirements, scholarships) before acting on them.

        7. SCHOOL PILOT
        These terms are for the closed pilot. Final terms will be published before any public launch.

        8. CHANGES
        We will notify you in-app when these terms change in a meaningful way.

        9. CONTACT
        Questions? Email pilot@ladder.app.
        """
    }

    private var privacyText: String {
        """
        Your privacy matters to us. Here is plainly what we collect and why.

        WHAT WE COLLECT
        - Your email address (to log you in).
        - Your password, stored hashed (we never see the plain version).
        - Your date of birth (to decide if parental consent is required).
        - Your school work in Ladder: career-quiz answers, college list, activities, essays, AI chat history, transcripts you upload.
        - Anonymous usage data so we can fix bugs.

        WHO CAN SEE YOUR DATA
        - YOU: always.
        - YOUR SCHOOL (admin + counselor): only if you are enrolled at a school through Ladder. They see your in-app work to help you. When you transfer schools or go private, their access ends.
        - YOUR PARENT (if linked): can see a summary of your progress. Linking is optional.
        - LADDER STAFF: only when you ask for help, or if a court orders us to.
        - NOBODY ELSE. We do not sell your data. We do not share it with advertisers.

        ENCRYPTION
        We encrypt your most sensitive data (essays, transcripts, AI chat content) at rest using per-tenant encryption keys.

        AI PROVIDERS
        We send your prompts to AI providers (Google Gemini for now) to generate answers. We do NOT train any AI model on your data.

        YOUR CHOICES
        - Delete your account from Settings — we erase your data within 30 days.
        - Export your data anytime as a PDF portfolio.
        - Turn off parent linking from Settings.

        FOR USERS UNDER 13 (COPPA)
        We collect a parent email at sign-up. The parent must verify before the account is fully usable.

        SCHOOL PILOT
        This privacy notice is for the closed pilot. Final notice will be published before any public launch.

        QUESTIONS
        Email pilot@ladder.app.
        """
    }
}
