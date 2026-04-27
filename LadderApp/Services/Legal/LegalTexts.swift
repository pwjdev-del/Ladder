import Foundation

// MARK: - Legal Texts
// All legal documents for Ladder app — Privacy Policy, Terms of Service,
// FERPA notice, COPPA notice, liability waiver, and data processing agreement.
// These are embedded in-app so users must read + agree before using the app.

enum LegalTexts {

    // MARK: - Company Info (update these when your LLC details change)

    static let companyName = "Purewave Josh LLC"
    static let companyEmail = "legal@ladderapp.com"
    static let supportEmail = "support@ladderapp.com"
    static let companyAddress = "Florida, United States"
    static let lastUpdated = "April 6, 2026"
    static let appName = "Ladder"

    // MARK: - Privacy Policy

    static let privacyPolicy = """
    PRIVACY POLICY

    Last Updated: \(lastUpdated)

    \(companyName) ("we," "our," or "us") operates the \(appName) mobile application (the "App"). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use the App.

    By using the App, you consent to the data practices described in this policy. If you do not agree with the terms of this Privacy Policy, please do not access or use the App.


    1. INFORMATION WE COLLECT

    1.1 Information You Provide Directly
    - Account information: name, email address, date of birth, password
    - Student profile: school name, grade level, student ID (optional), first-generation status
    - Academic data: GPA, SAT/ACT scores, AP/Honors courses, semester grades, transcripts
    - Career and college preferences: career quiz results, dream schools, major interests
    - Application data: college applications, essay drafts, supplemental essays, recommendation letter tracking
    - Financial information: scholarship applications, FAFSA readiness data, financial aid preferences (we do NOT collect bank account numbers, SSN, or tax returns)
    - Activities and achievements: extracurricular activities, awards, volunteer hours, internships, research
    - Housing preferences: dorm preferences, roommate preferences (if using housing features)
    - Communications: messages sent to counselors through the App

    1.2 Information Collected Automatically
    - Device information: device type, operating system version, unique device identifiers
    - Usage data: features accessed, time spent in app, interaction patterns
    - Log data: IP address, access times, app crash reports
    - We do NOT collect location data, contacts, photos (except transcripts you explicitly upload), or microphone/camera data

    1.3 Information from Third Parties
    - If you sign in with Apple or Google, we receive your name and email address as authorized by you
    - If a school counselor creates your account, we receive your name, date of birth, and grade level as provided by your school


    2. HOW WE USE YOUR INFORMATION

    We use the information we collect to:
    - Provide, maintain, and improve the App's features and services
    - Generate personalized college recommendations, career suggestions, and academic guidance
    - Power AI-driven features (essay feedback, mock interviews, class scheduling, admissions probability estimates)
    - Send you notifications about deadlines, reminders, and relevant opportunities
    - Enable communication between students and authorized counselors
    - Generate reports and analytics for your personal use (GPA trends, application progress)
    - If you are part of a school account, provide your assigned counselor with visibility into your academic progress and college planning (as authorized by your school's Data Processing Agreement)
    - Comply with legal obligations

    We do NOT use your information to:
    - Sell your personal data to third parties
    - Serve targeted advertisements
    - Build advertising profiles
    - Share your data with colleges or universities (unless you explicitly request it)


    3. AI-POWERED FEATURES AND DATA PROCESSING

    The App uses Google Gemini AI to provide personalized guidance. When you use AI features:
    - Your academic profile, career interests, and relevant context are sent to Google's Gemini API to generate responses
    - Google processes this data according to their API terms of service and does NOT use API data to train their models
    - AI-generated advice is for informational purposes only and should not be considered professional counseling
    - We cache common AI responses to reduce data transmission and improve performance
    - You can use the App's core features without using AI features


    4. DATA SHARING AND DISCLOSURE

    We share your information only in these circumstances:

    4.1 With Your Consent
    - Parent/guardian access: If you generate a parent invite code, your linked parent can view your academic progress, deadlines, and college list in read-only mode. You can revoke this access at any time.
    - Counselor access: If your school uses Ladder, your assigned school counselor can view your profile, academic data, and college planning progress. This is governed by your school's Data Processing Agreement and FERPA.

    4.2 Service Providers
    We use the following third-party services to operate the App:
    - Amazon Web Services (AWS): Cloud infrastructure, data storage, authentication, and serverless computing. Data is encrypted at rest and in transit. AWS is FERPA-eligible and SOC 2 compliant.
    - Google Gemini API: AI-powered features. Data sent to Gemini is not used to train Google's models and is processed according to Google's API data usage policy.
    - Apple App Store: Payment processing for subscriptions. Apple handles all payment data; we never see your credit card information.

    4.3 Legal Requirements
    We may disclose your information if required to do so by law, court order, or governmental regulation, or if we believe disclosure is necessary to protect our rights, your safety, or the safety of others.

    4.4 We Do NOT
    - Sell your personal information to any third party
    - Share your data with colleges, universities, or admissions offices
    - Provide data to data brokers, advertisers, or marketing companies
    - Transfer your data outside the United States (all AWS infrastructure is in US regions)


    5. DATA SECURITY

    We implement appropriate technical and organizational measures to protect your personal information:
    - All data is encrypted at rest using AES-256 encryption (AWS RDS encryption)
    - All data is encrypted in transit using TLS 1.2+
    - Authentication is handled by AWS Cognito with bcrypt password hashing
    - Access controls enforce role-based permissions (students, parents, counselors, admins)
    - Counselor access to student data is logged in an audit trail
    - Regular security assessments are conducted on our infrastructure
    - We use AWS Comprehend for content moderation in messaging to protect student safety

    No method of transmission over the Internet or electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security.


    6. DATA RETENTION

    - Active accounts: Your data is retained as long as your account is active
    - Inactive accounts: If you do not log in for 24 months, we will send a notification before archiving your account
    - School accounts: Student data is archived (not deleted) 2 years after graduation per FERPA requirements. Archived data is not accessible to counselors.
    - Deleted accounts: When you request account deletion, all personal data is permanently deleted within 30 days. Anonymized, aggregated data (e.g., average GPA statistics with no personally identifiable information) may be retained.
    - Backup data: Encrypted backups are retained for 90 days after deletion for disaster recovery, then permanently destroyed


    7. YOUR RIGHTS

    You have the right to:
    - Access: Request a copy of all personal data we hold about you (Settings > Export My Data)
    - Correction: Update or correct your personal information at any time through the App
    - Deletion: Request permanent deletion of your account and all associated data (Settings > Delete My Data)
    - Portability: Export your data in a standard format (JSON/PDF)
    - Withdraw consent: Revoke consent for data processing at any time (this may limit App functionality)
    - Opt-out of AI: Use the App without AI features if you prefer
    - Revoke parent/counselor access: Remove linked parent or counselor access at any time

    To exercise these rights, contact us at \(supportEmail) or use the in-app settings.


    8. CHILDREN'S PRIVACY (COPPA COMPLIANCE)

    The App is designed for high school students (typically ages 13-18). We comply with the Children's Online Privacy Protection Act (COPPA):
    - Users under 13: If we determine a user is under 13 years old, we require verifiable parental consent before collecting personal information. A parent or legal guardian must provide their email address and confirm consent via a verification link.
    - Users 13-17: We collect information as described in this policy. If a school has enrolled the student through a school account, the school acts as the parent's agent for COPPA purposes as permitted under FERPA.
    - Parental rights: Parents of users under 18 can review their child's data, request corrections, or request deletion by contacting \(supportEmail) or using the parent portal.

    If you believe we have collected information from a child under 13 without proper consent, please contact us immediately at \(supportEmail).


    9. FERPA COMPLIANCE

    When the App is used through a school account:
    - We act as a "school official" with "legitimate educational interest" under FERPA (34 CFR 99.31(a)(1))
    - Student education records are only accessible to the student, their linked parent/guardian, and their assigned school counselor
    - We do not disclose education records to any third party without written consent, except as permitted under FERPA
    - Schools maintain control over their students' education records through the Data Processing Agreement
    - Parents and eligible students (18+) have the right to inspect, review, and request amendment of education records

    For individual (non-school) accounts, FERPA does not apply as we are not acting on behalf of an educational institution.


    10. CHANGES TO THIS PRIVACY POLICY

    We may update this Privacy Policy from time to time. We will notify you of material changes by:
    - Displaying a prominent notice in the App
    - Sending a push notification (if enabled)
    - Requiring re-acceptance for material changes that affect how we use your data

    Your continued use of the App after changes are posted constitutes acceptance of the updated Privacy Policy.


    11. CONTACT US

    If you have questions or concerns about this Privacy Policy:
    - Email: \(companyEmail)
    - Support: \(supportEmail)
    - Address: \(companyAddress)
    """

    // MARK: - Terms of Service

    static let termsOfService = """
    TERMS OF SERVICE

    Last Updated: \(lastUpdated)

    Please read these Terms of Service ("Terms") carefully before using the \(appName) mobile application (the "App") operated by \(companyName) ("we," "our," or "us").

    By creating an account or using the App, you agree to be bound by these Terms. If you do not agree to these Terms, do not use the App.


    1. ELIGIBILITY

    1.1 Age Requirements
    - You must be at least 13 years old to create an account
    - If you are under 13, a parent or legal guardian must create the account on your behalf and provide verifiable consent
    - If you are between 13 and 17, you represent that your parent or legal guardian has reviewed and consents to these Terms
    - If you are 18 or older, you represent that you have the legal capacity to enter into these Terms

    1.2 Account Registration
    - You must provide accurate and complete information when creating your account
    - You are responsible for maintaining the confidentiality of your login credentials
    - You are responsible for all activity that occurs under your account
    - You must notify us immediately of any unauthorized use of your account
    - If your account was created by a school counselor through the bulk enrollment system, you must change your temporary password upon first login


    2. DESCRIPTION OF SERVICE

    \(appName) is a college guidance and academic planning platform that provides:
    - College search, discovery, and comparison tools (6,300+ colleges)
    - AI-powered academic advising, essay feedback, and mock interview practice
    - GPA tracking, class scheduling suggestions, and academic planning
    - Application tracking, deadline management, and checklist tools
    - Career exploration quizzes and major recommendations
    - Scholarship search and financial aid guidance
    - Extracurricular activity portfolio management
    - Communication tools between students and authorized school counselors
    - Parent read-only dashboard access (when invited by student)
    - PDF portfolio export and reporting tools


    3. IMPORTANT DISCLAIMERS — PLEASE READ CAREFULLY

    3.1 Not Professional Counseling
    THE APP PROVIDES INFORMATIONAL GUIDANCE ONLY. \(appName.uppercased()) IS NOT A SUBSTITUTE FOR PROFESSIONAL COLLEGE COUNSELING, ACADEMIC ADVISING, FINANCIAL PLANNING, OR LEGAL ADVICE. The information, recommendations, and AI-generated content in the App are for general informational purposes only.

    3.2 No Guarantee of Admissions Outcomes
    WE DO NOT AND CANNOT GUARANTEE ADMISSION TO ANY COLLEGE OR UNIVERSITY. Acceptance probability percentages, "match" ratings, and admissions estimates are statistical approximations based on publicly available data and should not be relied upon as predictions of actual admissions decisions. College admissions decisions are made solely by the institutions themselves and are influenced by many factors beyond what any app can measure.

    3.3 No Guarantee of Scholarship Awards
    Scholarship information is provided for informational purposes. We do not guarantee eligibility, selection, or receipt of any scholarship or financial aid award.

    3.4 AI-Generated Content
    AI-powered features (essay feedback, mock interviews, career suggestions, class recommendations) are generated by artificial intelligence and may contain errors, inaccuracies, or outdated information. You should independently verify any AI-generated advice before acting on it. AI suggestions do not constitute professional advice.

    3.5 College Data Accuracy
    College information (acceptance rates, tuition, test score ranges, deadlines) is compiled from public sources and updated periodically. Data may not reflect the most current information. Always verify critical information (especially deadlines and requirements) directly with the institution.

    3.6 Financial Information
    FAFSA guidance, scholarship information, and financial aid estimates are for informational purposes only and do not constitute financial advice. Consult a qualified financial advisor for financial planning decisions.


    4. ACCEPTABLE USE

    You agree NOT to:
    - Use the App for any unlawful purpose
    - Provide false or misleading information in your profile or applications
    - Impersonate another person or misrepresent your identity
    - Attempt to gain unauthorized access to other users' accounts or data
    - Use the AI features to generate content for academic dishonesty (e.g., submitting AI-generated essays as your own work to colleges without disclosure)
    - Harass, threaten, or send inappropriate messages to counselors or other users
    - Use automated scripts, bots, or scrapers to access the App
    - Reverse engineer, decompile, or disassemble any part of the App
    - Circumvent any rate limits, feature gates, or access controls
    - Share your account credentials with others
    - Use the App in any way that could damage, disable, or impair the service


    5. SUBSCRIPTIONS AND PAYMENTS

    5.1 Free Tier
    Basic features are available for free with usage limits (e.g., limited AI requests per day).

    5.2 Paid Subscriptions
    - Pro subscriptions are billed through the Apple App Store
    - Pricing is displayed in the App before purchase
    - Subscriptions automatically renew unless canceled at least 24 hours before the end of the current billing period
    - You can manage and cancel subscriptions through your Apple ID settings
    - Apple handles all payment processing; we do not collect or store payment information

    5.3 School/District Accounts
    School and district subscriptions are billed directly to the institution under a separate agreement. Individual students within a school account are not charged.

    5.4 Refunds
    Refund requests for App Store purchases are handled by Apple according to their refund policy. For school/district accounts, refund terms are governed by the institutional agreement.


    6. INTELLECTUAL PROPERTY

    6.1 Our Content
    The App, including its design, features, text, graphics, logos, and software, is owned by \(companyName) and protected by intellectual property laws. You may not copy, modify, distribute, or create derivative works from our content without written permission.

    6.2 Your Content
    You retain ownership of all content you create in the App (essays, activity descriptions, notes, etc.). By using the App, you grant us a limited license to store, process, and display your content solely for the purpose of providing the service to you. We do not claim ownership of your essays, academic work, or personal content.

    6.3 AI-Generated Content
    Content generated by AI features (essay feedback, suggestions, career narratives) is provided for your personal use. You may use AI-generated suggestions to inform your own writing, but you are responsible for ensuring any content you submit to colleges or institutions is your own original work.


    7. PRIVACY

    Your use of the App is also governed by our Privacy Policy, which is incorporated into these Terms by reference. Please review the Privacy Policy carefully.


    8. LIMITATION OF LIABILITY

    TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW:

    8.1 \(companyName.uppercased()) SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO:
    - Loss of admission to any educational institution
    - Loss of scholarship opportunities
    - Academic consequences resulting from reliance on App recommendations
    - Emotional distress related to college admissions outcomes
    - Loss of data (except as caused by our gross negligence)
    - Any damages arising from AI-generated content or recommendations

    8.2 OUR TOTAL LIABILITY FOR ANY CLAIM ARISING FROM YOUR USE OF THE APP SHALL NOT EXCEED THE AMOUNT YOU PAID US IN THE TWELVE (12) MONTHS PRECEDING THE CLAIM, OR $100, WHICHEVER IS GREATER.

    8.3 SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF CERTAIN DAMAGES. IF THESE LAWS APPLY TO YOU, SOME OR ALL OF THE ABOVE EXCLUSIONS MAY NOT APPLY, AND YOU MAY HAVE ADDITIONAL RIGHTS.


    9. INDEMNIFICATION

    You agree to indemnify and hold harmless \(companyName), its officers, directors, employees, and agents from any claims, damages, losses, or expenses (including reasonable attorney's fees) arising from:
    - Your use of the App
    - Your violation of these Terms
    - Your violation of any rights of another party
    - Content you submit through the App


    10. DISPUTE RESOLUTION

    10.1 Informal Resolution
    Before filing any formal legal action, you agree to first contact us at \(companyEmail) and attempt to resolve the dispute informally for at least 30 days.

    10.2 Binding Arbitration
    Any dispute that cannot be resolved informally shall be resolved by binding arbitration administered by the American Arbitration Association (AAA) under its Consumer Arbitration Rules. Arbitration shall take place in the State of Florida. The arbitrator's decision shall be final and binding.

    10.3 Class Action Waiver
    YOU AGREE THAT ANY DISPUTE RESOLUTION PROCEEDINGS WILL BE CONDUCTED ONLY ON AN INDIVIDUAL BASIS AND NOT IN A CLASS, CONSOLIDATED, OR REPRESENTATIVE ACTION. If this class action waiver is found to be unenforceable, then the entirety of this arbitration provision shall be null and void.

    10.4 Small Claims Exception
    Notwithstanding the above, either party may bring an individual action in small claims court.

    10.5 Governing Law
    These Terms shall be governed by and construed in accordance with the laws of the State of Florida, without regard to its conflict of law provisions.


    11. TERMINATION

    11.1 By You
    You may delete your account at any time through the App (Settings > Delete My Data). Upon deletion, your personal data will be permanently removed within 30 days.

    11.2 By Us
    We may suspend or terminate your account if you violate these Terms, engage in harmful behavior, or if required by law. We will provide notice when possible.

    11.3 Effect of Termination
    Upon termination, your right to use the App ceases immediately. Provisions that by their nature should survive termination (including disclaimers, limitations of liability, and dispute resolution) shall survive.


    12. MODIFICATIONS TO TERMS

    We may modify these Terms at any time. We will notify you of material changes through the App. Your continued use of the App after changes are posted constitutes acceptance. If you do not agree to modified Terms, you must stop using the App and delete your account.


    13. MISCELLANEOUS

    13.1 Entire Agreement: These Terms, together with the Privacy Policy, constitute the entire agreement between you and \(companyName) regarding the App.
    13.2 Severability: If any provision of these Terms is found unenforceable, the remaining provisions shall remain in full force and effect.
    13.3 Waiver: Our failure to enforce any provision of these Terms shall not constitute a waiver of that provision.
    13.4 Assignment: You may not assign or transfer these Terms. We may assign our rights and obligations without restriction.


    14. CONTACT

    Questions about these Terms? Contact us:
    - Email: \(companyEmail)
    - Support: \(supportEmail)
    - Address: \(companyAddress)
    """

    // MARK: - FERPA Notice

    static let ferpaNotice = """
    FAMILY EDUCATIONAL RIGHTS AND PRIVACY ACT (FERPA) NOTICE

    When \(appName) is used through a school or district account, student data is protected under the Family Educational Rights and Privacy Act (FERPA), 20 U.S.C. \u{00A7} 1232g.

    YOUR RIGHTS UNDER FERPA:

    1. Right to Inspect: You (and your parents, if you are under 18) have the right to inspect and review your education records maintained by the App.

    2. Right to Amend: You may request amendment of education records you believe to be inaccurate, misleading, or in violation of your privacy rights.

    3. Right to Consent: The school must generally obtain your written consent before disclosing personally identifiable information from your education records. However, FERPA allows disclosure without consent to school officials with legitimate educational interest, which includes \(appName) as a service provider operating under the school's Data Processing Agreement.

    4. Right to Complain: You have the right to file a complaint with the U.S. Department of Education concerning alleged failures to comply with FERPA:
       Family Policy Compliance Office
       U.S. Department of Education
       400 Maryland Avenue, SW
       Washington, DC 20202

    HOW \(appName.uppercased()) COMPLIES:
    - We act as a "school official" under a Data Processing Agreement with your school
    - We only access student data for legitimate educational purposes
    - We do not re-disclose student data to third parties without consent
    - All counselor access to student data is logged in an audit trail
    - Student data is archived (not deleted) for 2 years after graduation, then permanently deleted
    - Parents and eligible students (18+) can request data access or deletion at any time

    By using \(appName) through a school account, you acknowledge this FERPA notice and understand your rights.
    """

    // MARK: - COPPA Notice

    static let coppaNotice = """
    CHILDREN'S ONLINE PRIVACY PROTECTION ACT (COPPA) NOTICE

    \(appName) complies with the Children's Online Privacy Protection Act (COPPA), 15 U.S.C. \u{00A7}\u{00A7} 6501-6506.

    FOR USERS UNDER 13:
    - We require verifiable parental consent before collecting personal information from children under 13
    - A parent or legal guardian must provide their email address and confirm consent via a verification link before the child can use the App
    - Parents can review their child's information, request changes, or request deletion at any time by contacting \(supportEmail)
    - Parents can revoke consent at any time, which will result in deletion of the child's account and data

    FOR SCHOOL ACCOUNTS:
    - When a school enrolls students under 13, the school acts as the parent's agent for providing consent under COPPA, as permitted when the information is used solely for educational purposes
    - Schools must have proper authorization from parents to enroll students under 13
    - The school's Data Processing Agreement governs how student data is handled

    WHAT WE COLLECT FROM CHILDREN UNDER 13:
    - Same categories as described in our Privacy Policy (name, school, grade, academic data)
    - We collect the minimum information necessary to provide the educational service
    - We do NOT collect geolocation, photos, videos, or audio from any user

    PARENTAL RIGHTS:
    - Review your child's personal information
    - Request deletion of your child's information
    - Refuse further collection of your child's information
    - Contact us: \(supportEmail)
    """

    // MARK: - Liability Waiver

    static let liabilityWaiver = """
    ACKNOWLEDGMENT AND WAIVER

    By using \(appName), I acknowledge and agree to the following:

    1. INFORMATIONAL PURPOSE ONLY
    \(appName) provides college guidance, academic planning tools, and AI-powered recommendations for informational purposes only. The App is NOT a substitute for professional college counseling, academic advising, legal advice, or financial planning.

    2. NO ADMISSIONS GUARANTEES
    I understand that \(appName) does not and cannot guarantee admission to any college or university. Acceptance probability percentages and "match" ratings are statistical estimates only. Actual admissions decisions are made solely by educational institutions based on many factors.

    3. NO SCHOLARSHIP GUARANTEES
    I understand that scholarship information and matching is for informational purposes only. \(appName) does not guarantee eligibility for or receipt of any financial aid or scholarship.

    4. AI LIMITATIONS
    I understand that AI-generated content (essay feedback, career suggestions, class recommendations, mock interview responses) may contain errors or inaccuracies. I will independently verify AI-generated advice before making important decisions.

    5. ACADEMIC RESPONSIBILITY
    I understand that all academic decisions (course selection, college applications, essay submissions) are my own responsibility. \(appName) provides suggestions and tools, but I am responsible for my own academic work and decisions.

    6. DATA ACCURACY
    I understand that college data (deadlines, acceptance rates, tuition, requirements) is compiled from public sources and may not be current. I will verify critical information directly with educational institutions.

    7. ASSUMPTION OF RISK
    I assume all risk associated with reliance on information provided by the App, including but not limited to missed deadlines, inaccurate college data, or AI-generated errors.
    """

    // MARK: - Data Processing Agreement Summary (for school admins)

    static let dpaeSummary = """
    DATA PROCESSING AGREEMENT — SUMMARY

    This summary outlines the key terms of the Data Processing Agreement between your school/district and \(companyName).

    1. PURPOSE: \(companyName) processes student education records solely to provide the \(appName) college guidance service.

    2. ROLE: \(companyName) acts as a "school official" with "legitimate educational interest" under FERPA.

    3. DATA HANDLED: Student names, dates of birth, grades, GPA, test scores, course data, college preferences, application data, and counselor communications.

    4. SECURITY: All data encrypted at rest (AES-256) and in transit (TLS 1.2+). AWS infrastructure in US regions only. Role-based access controls. Audit logging of all counselor data access.

    5. NO SALE OF DATA: We will NEVER sell, rent, or lease student data to any third party.

    6. NO ADVERTISING: Student data is NEVER used for advertising or marketing purposes.

    7. SUBPROCESSORS: AWS (infrastructure), Google Gemini API (AI features, data not used for training).

    8. DATA RETENTION: Active during enrollment. Archived 2 years post-graduation. Permanently deleted after archive period.

    9. DATA RETURN/DELETION: Upon contract termination, school can export all data within 30 days. All data deleted within 60 days of contract end.

    10. BREACH NOTIFICATION: In the event of a data breach involving student records, we will notify the school within 72 hours and cooperate with notification requirements.

    11. COMPLIANCE: We comply with FERPA, COPPA, Florida Statute 1002.22, and applicable state student privacy laws.

    The full DPA is available upon request at \(companyEmail).
    """

    // MARK: - Consent Checkbox Labels

    static let consentCheckboxToS = "I have read and agree to the Terms of Service"
    static let consentCheckboxPrivacy = "I have read and agree to the Privacy Policy"
    static let consentCheckboxAge = "I confirm that I am at least 13 years old, or my parent/guardian has provided consent"
    static let consentCheckboxWaiver = "I understand that Ladder provides guidance only and does not guarantee admissions outcomes"
    static let consentCheckboxFERPA = "I acknowledge the FERPA notice regarding my education records"
    static let consentCheckboxAI = "I understand that AI features provide suggestions, not professional advice, and may contain errors"
}
