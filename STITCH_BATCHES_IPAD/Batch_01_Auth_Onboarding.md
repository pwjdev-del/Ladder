You are designing iPad screens for Ladder, a college preparation app. This is batch 1 of 12 (screens listed below). Use these exact design tokens for all screens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (Display Large 56pt Bold, Display Medium 45pt, Display Small 36pt, Headline Large 32pt Bold, Headline Medium 28pt SemiBold, Headline Small 24pt Medium). Body/Labels = Manrope (Title Large 22pt Bold, Title Medium 16pt SemiBold, Title Small 14pt SemiBold, Body Large 16pt, Body Medium 14pt, Body Small 12pt, Label Large 14pt Bold, Label Medium 12pt Bold, Label Small 10pt SemiBold). Headlines use editorial tracking (-0.5). Labels use wide tracking (+2.0).

**Spacing (8pt grid):** xxs 2, xs 4, sm 8, md 16, lg 24, xl 32, xxl 48, xxxl 64, xxxxl 80

**Corner Radius:** sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 40, pill 9999

**Shadows:** Ambient (cards): rgba(31,28,20, 0.06) blur 20 y-offset 4. Floating (modals): same blur 30 y-offset 10. Glow (CTAs): rgba(201,242,77, 0.30) blur 15 no offset. Primary Glow: rgba(66,96,63, 0.15) blur 20 y-offset 4.

**Components:** Primary Button = gradient primary→primaryContainer, pill, white text, scale 0.95 on press. Accent Button = Accent Lime bg, dark text, glow shadow. Cards = Surface Container Low bg, XL radius, ambient shadow. Chips = Surface Container High bg, pill, Label Small. Text Fields = Surface Container Lowest bg, outline border, LG radius, primary border on focus. No divider lines — use spacing and elevation. Min 44pt touch targets.

## iPad Navigation
Collapsible sidebar (280pt) replaces iPhone tab bar. Sidebar: Ladder logo top, 9 nav sections (Home, Tasks, Colleges, Applications, Advisor, Financial, Career, Housing, Reports) with expandable sub-items. Selected = primary bg pill. Bottom = avatar + name + grade. Portrait = sidebar overlays. Detail area max-width 800pt for single-column views. Landscape = sidebar always visible.

---

## Screens to Design

### A1. SPLASH SCREEN
Full-screen gradient (primary → surface). Centered Ladder logo: Graduation cap icon inside rotated square. "Ladder" wordmark in Noto Serif Headline Large. Subtle lime glow animation. Loading indicator at bottom.

### A2. LOGIN
Centered card (480pt) on blurred gradient background with two decorative blurred circles (secondary & lime). Card contains: Logo badge (rotated square + grad cap), "Welcome Back" headline, email field (envelope icon), password field (lock icon, show/hide), "Forgot Password?" link, error area, "Log In" accent button (full width), divider "Or continue with", Google + Apple buttons side by side, "Don't have an account? Create Account" link.

### A3. SIGN UP
Same centered card layout. "Create Account" headline. Email, password (with strength bar red→amber→green), confirm password, terms checkbox with links, "Create Account" accent button, "Already have an account?" link.

### A4. FORGOT PASSWORD
Centered card. "Reset Password" headline, description, email field, "Send Reset Link" button, "Back to Login" link. Success state: checkmark icon, "Check your email", "Open Mail App" button.

### A5. ROLE SELECTION
Centered card with 2x2 grid of role tiles (160pt each, touch-friendly): Student (grad cap icon), Parent (heart), Counselor (person.badge.plus), School Admin (building). Each: icon + title + description. Selected = primary border + checkmark. "Continue" button.

### A6. ONBOARDING STEP 1 — WELCOME
Progress bar (5 steps, step 1). Two-panel: Left 50% = gradient green hero with sparkles icon. Right 50% = "Your Future, Designed by You" (Display Small), subtitle, "Let's Get Started" accent button.

### A7. ONBOARDING STEP 2 — BASIC INFO
Progress bar step 2. Centered form (600pt). Two-column: First + Last Name. Full width: School (autocomplete), Student ID. Grade: 4 large buttons (9th-12th). First-gen toggle. Continue + Back.

### A8. ONBOARDING STEP 3 — ACADEMIC PROFILE
Progress bar step 3. Centered form. GPA slider (0-5.0, large touch), SAT + ACT side by side, AP/Honors chips with remove X + "Add Course" button (3-4 column chip wrap on iPad). Continue + Back.

### A9. ONBOARDING STEP 4 — DREAM SCHOOLS
Progress bar step 4. Centered (700pt). Search bar + autocomplete. Selected colleges as removable chips above grid. 3-column college grid: building icon, name, location, checkmark + lime border if selected. Continue + Back.

### A10. ONBOARDING STEP 5 — READY TO LEAD
Progress bar complete. Trophy icon in gradient circle. "Ready to Lead?" headline. Horizontal profile summary card: avatar+name+grade | GPA+SAT+career | milestones+targets. "Enter Dashboard" accent button + "Review Full Profile" secondary.

### A11. PARENT ONBOARDING / INVITE CODE
Centered card. "Join Your Child on Ladder" headline. Parent-student connection illustration. 6-digit code input (6 separate large boxes). Helper text. "Connect" button. Success: animated checkmark + "Connected to [Name]!" + "Go to Dashboard". Error: shake + "Invalid code".

### A12. COUNSELOR ONBOARDING / SCHOOL CODE
Centered card. "Welcome, Counselor" headline + subtitle. School code field. "Join School" button. "I'm a freelance counselor" link → verification. Success: school name + logo + count + "Enter Dashboard".

### A13. COPPA AGE GATE
Centered card. "Before We Begin" headline. "What is your date of birth?" date picker (month/day/year wheels). "Continue". Under 13: "Parental Consent Required" — parent email field, "Send Consent Request" button.

### A14. FERPA CONSENT FLOW
Centered card. "Data Sharing Consent" headline. Scrollable legal text. Bullet points (what shared, who sees, how to revoke). Consent checkbox. "I Agree" + "Decline" buttons. Digital signature field.

### A15. FORCE PASSWORD CHANGE
Centered card. Lock icon. "Set Your New Password". "Your counselor created your account." Temp password (read-only). New password (strength indicator). Confirm password. "Update Password" button.

### A16. COUNSELOR VERIFICATION FLOW
Multi-step card. Step 1: Name, email, phone, school/org, role dropdown. Step 2: Drag-and-drop credential upload area, file list, accepted formats. Step 3: Hourglass icon, "Reviewing (1-2 days)", email notification note, "Contact Support" link.

---

Design all 16 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 1 of 12.
