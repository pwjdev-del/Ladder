# Batch 1 of 12 — Auth & Onboarding (16 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 1 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (56/45/36/32/28/24pt). Body/Labels = Manrope (22/16/14pt titles, 16/14/12pt body, 14/12/10pt labels). Editorial tracking -0.5 on headlines, wide +2.0 on labels.

**Spacing (8pt):** xxs2 xs4 sm8 md16 lg24 xl32 xxl48 xxxl64 xxxxl80. Radius: sm8 md12 lg16 xl24 xxl32 xxxl40 pill9999.

**Shadows:** Ambient rgba(31,28,20,.06) blur20 y4. Floating blur30 y10. Glow rgba(201,242,77,.30) blur15. PrimaryGlow rgba(66,96,63,.15) blur20 y4.

**Components:** PrimaryBtn = gradient primary→primaryContainer pill white, hover brightness+5% + glow. AccentBtn = lime bg dark text glow. Cards = SurfaceContainerLow XL radius ambient, hover lift. Chips = SurfaceContainerHigh pill, hover outline. TextFields = SurfaceContainerLowest outline LG radius, focus primary glow. TableRows = hover SurfaceContainerHigh bg. Links = primary color underline on hover. No dividers. Tooltips on all icon buttons. Right-click context menus on cards/items.

## Desktop Navigation
Top bar (64px): Logo + sidebar toggle | breadcrumbs center | search (⌘K) + notification bell + theme toggle + profile dropdown right.
Left sidebar (240px, collapsible to 64px icons): 9 sections (Dashboard/Tasks/Colleges/Applications/Advisor/Financial/Career/Housing/Reports) with sub-items. Selected = primary bg pill. Collapsed = icons + tooltips.
Content area: max 1200px centered, xl padding. Keyboard: ⌘K search, ⌘N new, ⌘/ sidebar, Esc close.

---

## Screens

### A1. SPLASH / LOADING
- Full-screen gradient from Primary (#42603f) to Surface (#fff8f2), flowing diagonally top-left to bottom-right.
- Centered Ladder logo (vector, 120px) + wordmark below in Noto Serif Display 36pt, On Primary color.
- Lime glow pulse animation (Accent Lime #A1C621, glow shadow rgba(201,242,77,.30) blur15) radiating outward from the logo on a 2-second loop.
- Loading progress bar below wordmark: 280px wide, 4px height, SurfaceContainerHigh track, Accent Lime fill animating left to right.
- Subtle floating decorative leaf/ascent shapes in the background at 5% opacity.
- Web context: this is the initial load screen shown while the JS bundle hydrates.

### A2. LOGIN
- Split-screen layout, 50/50.
- **Left panel (50%):** Full-height gradient from Primary (#42603f) to Primary Container (#5a7956). Large Ladder logo centered vertically (80px). Below logo: "Your Future, Designed by You" in Noto Serif Display Small (36pt), On Primary (#ffffff), tracking -0.5. Decorative abstract geometric shapes (circles, arcs, lines) in Accent Lime at 15% opacity scattered across panel. Bottom area: student testimonial card — Surface Container Lowest bg, xl radius, ambient shadow — with quote text (Manrope 14pt), student name, school, and small avatar.
- **Right panel (50%):** Surface (#fff8f2) background. Centered form container, 420px max-width.
  - "Welcome Back" — Noto Serif Headline Medium (28pt), On Surface, mb lg24.
  - Email text field: SurfaceContainerLowest bg, Outline border, LG radius (16px), Manrope 16pt, placeholder "you@school.edu". Focus: Primary border + PrimaryGlow shadow.
  - Password text field: same styling + show/hide toggle icon button (eye) on right side with tooltip "Show password". sm8 gap between fields.
  - "Forgot Password?" — Primary color link, Manrope 12pt label, right-aligned below password field. Underline on hover.
  - Error message area: 8px below fields, Error (#ba1a1a) text, Manrope 12pt, hidden by default.
  - "Log In" — AccentBtn (Secondary Fixed #caf24d bg, On Surface dark text, pill radius, full width, Manrope 16pt title bold). Hover: glow rgba(201,242,77,.30) blur15.
  - Divider area: horizontal line with "Or continue with" label centered, Outline Variant color, Manrope 12pt label, mt lg24 mb lg24.
  - Google + Apple sign-in buttons: side by side, equal width, SurfaceContainerLow bg, Outline border, pill radius, icon + label. Hover: lift shadow.
  - "Don't have an account? **Create Account**" — Manrope 14pt, On Surface Variant, link portion in Primary color. mt xl32.

### A3. SIGN UP
- Same split-screen layout as A2. Left panel identical.
- **Right panel form (420px centered):**
  - "Create Account" — Noto Serif Headline Medium (28pt), On Surface, mb lg24.
  - Email text field (same styling as Login).
  - Password text field + strength bar below (4-segment bar: gray default, Error red for weak, amber for fair, Accent Lime for strong, Primary for excellent). Strength label right-aligned (Manrope 10pt label).
  - Confirm password text field.
  - Terms checkbox: custom styled checkbox (Primary fill when checked, check icon On Primary) + "I agree to the **Terms of Service** and **Privacy Policy**" (links in Primary, underline on hover). Manrope 12pt.
  - "Create Account" — AccentBtn, full width, same styling as Login button.
  - "Already have an account? **Log In**" — Manrope 14pt, link in Primary. mt xl32.

### A4. FORGOT PASSWORD
- Full-screen brand background: gradient Primary → Primary Container, subtle geometric shapes.
- Centered card: 420px width, SurfaceContainerLowest bg, xxl radius (32px), floating shadow, xxxl64 padding.
  - "Reset Password" — Noto Serif Headline Small (24pt), On Surface, centered.
  - Description: "Enter your email and we'll send you a reset link." Manrope 14pt, On Surface Variant, centered, mt sm8.
  - Email text field, mt lg24.
  - "Send Reset Link" — PrimaryBtn (gradient Primary → Primary Container, pill, white text, full width). mt lg24.
  - "Back to Login" — Primary link, Manrope 14pt, centered, mt md16.
- **Success state (same card, content swaps):**
  - Large green check icon (48px) in a circle, Primary bg, centered.
  - "Check Your Email" — Noto Serif Headline Small (24pt), centered, mt md16.
  - "We sent a reset link to [email]." Manrope 14pt, On Surface Variant, centered.
  - "Open Mail App" — AccentBtn, full width, mt lg24.
  - "Back to Login" link below.

### A5. ROLE SELECTION
- Surface background. Centered container, 600px max-width, xxxl64 vertical padding.
- "How will you use Ladder?" — Noto Serif Display Small (36pt), On Surface, centered, mb xxl48.
- 2x2 grid of role cards, md16 gap:
  - **Student** — graduation cap icon (32px, Primary). "Student" Manrope 16pt title bold. "Track your college journey from start to finish." Manrope 14pt body, On Surface Variant.
  - **Parent** — family icon. "Parent/Guardian". "Stay connected and support your child's path."
  - **Counselor** — briefcase icon. "Counselor". "Guide students with tools and insights."
  - **Admin** — shield icon. "Administrator". "Manage your school's Ladder program."
  - Each card: SurfaceContainerLow bg, xl radius (24px), ambient shadow, xl32 padding, cursor pointer.
  - Hover: border Outline, lift shadow (floating).
  - Selected: Primary border (2px), small check badge top-right corner (Primary bg, white check, 24px circle), PrimaryGlow shadow.
- "Continue" — PrimaryBtn, centered below grid, mt xxl48. Disabled until selection made (50% opacity, no pointer).

### A6. ONBOARDING STEP 1 — Welcome
- Surface background. Centered wizard container, 680px max-width.
- **Step indicator bar** at top: 5 steps, horizontal, connected by lines. Each step: circle (24px) + label below (Manrope 10pt label, tracking +2.0). Step 1 active: Primary fill, white number. Steps 2-5: Outline Variant fill, On Surface Variant number. Connecting lines: completed = Primary, upcoming = Outline Variant.
- Hero area: full-width card within container, gradient Primary → Primary Container, xxl radius, xxxl64 padding. Decorative sparkle/star shapes in Accent Lime at 20% opacity.
  - "Welcome to Ladder" — Noto Serif Display Small (36pt), On Primary, centered.
  - "Your personalized path to college starts here." — Manrope 16pt, On Primary at 80% opacity, centered, mt sm8.
  - "Let's Get Started" — AccentBtn (lime bg, dark text), centered, mt xl32.

### A7. ONBOARDING STEP 2 — Personal Info
- Same wizard container + step bar (step 2 active).
- Card: SurfaceContainerLowest bg, xxl radius, xl32 padding.
  - "Tell Us About You" — Noto Serif Headline Small (24pt), On Surface, mb lg24.
  - Two-column row: First Name + Last Name text fields, md16 gap.
  - School field: autocomplete text field with dropdown suggestions list (SurfaceContainerLowest bg, floating shadow, max 5 items visible, hover SurfaceContainerHigh).
  - Student ID field: standard text field.
  - Grade level: 4 toggle buttons in a row ("9th", "10th", "11th", "12th"). SurfaceContainerHigh bg default, pill radius, Manrope 14pt. Selected: Primary bg, On Primary text. Hover (unselected): Outline border.
  - First-generation student toggle: label left ("First-generation college student?") + toggle switch right. Track: Outline Variant default, Primary when on. Thumb: white circle.
- Navigation: "Back" text button left, "Continue" PrimaryBtn right, mt xxl48.

### A8. ONBOARDING STEP 3 — Academics
- Same wizard container + step bar (step 3 active).
- Card: SurfaceContainerLowest bg, xxl radius, xl32 padding.
  - "Your Academics" — Noto Serif Headline Small (24pt), mb lg24.
  - GPA stepper: label "Current GPA", number display (Noto Serif Headline Medium 28pt), minus/plus icon buttons (SurfaceContainerHigh, circle, 40px, hover Outline border). Range 0.0–4.0, step 0.1.
  - SAT + ACT scores: side-by-side text fields (number input), md16 gap. Label + field + helper text ("Leave blank if not taken").
  - AP Courses: section label "AP Courses Taken". Chip flow layout of selected APs (SurfaceContainerHigh bg, pill, Manrope 12pt, X remove icon on hover). Below: autocomplete text field "Add AP course..." with dropdown. Added chips appear above the input.
- Navigation: "Back" + "Continue" buttons.

### A9. ONBOARDING STEP 4 — College Interests
- Same wizard container + step bar (step 4 active).
- Card: SurfaceContainerLowest bg, xxl radius, xl32 padding.
  - "Colleges That Interest You" — Noto Serif Headline Small (24pt), mb lg24.
  - Search field with autocomplete: "Search colleges..." with magnifying glass icon. Dropdown list shows college name + location + type.
  - Selected colleges as removable chips below search (pill, SurfaceContainerHigh, X icon, hover border).
  - Four-column college suggestion grid below: small cards (SurfaceContainerLow bg, lg radius, sm8 padding) with college mini-logo/initials circle, name (Manrope 14pt bold), location (Manrope 12pt, On Surface Variant). Hover: Primary border (1px), lift.
- Navigation: "Back" + "Continue" buttons.

### A10. ONBOARDING STEP 5 — Ready
- Same wizard container + step bar (step 5 active, all previous completed/green).
- Centered content:
  - Trophy icon (64px) in a circular Accent Lime bg with glow, centered.
  - "Ready to Lead?" — Noto Serif Display Small (36pt), On Surface, centered, mt lg24.
  - Horizontal profile summary card: SurfaceContainerLow bg, xl radius, ambient shadow, lg24 padding. Displays: avatar placeholder circle (48px, Primary bg, initials) | Name + School (Manrope 14pt) | GPA + Scores (Manrope 14pt) | College count (Manrope 14pt). Separated by thin vertical lines (Outline Variant). mt xl32.
  - Two buttons side by side, centered, mt xxl48:
    - "Enter Dashboard" — AccentBtn (primary action).
    - "Review Profile" — outlined button (transparent bg, Primary border, Primary text, pill radius). Hover: PrimaryGlow.

### A11. PARENT ONBOARDING
- Surface background. Centered card, 450px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
  - "Join Your Child" — Noto Serif Headline Small (24pt), On Surface, centered.
  - Illustration area: simple graphic of two connected figures, Primary + Accent Lime colors, 120px height, centered, mt md16.
  - 6-digit code input: 6 individual square boxes in a row (48px each, SurfaceContainerLowest bg, Outline border, lg radius, md16 gap). Each holds one character, Manrope 22pt title, centered. Auto-advance on input. Focus: Primary border + PrimaryGlow.
  - Helper text: "Enter the 6-digit code your child shared with you." Manrope 12pt, On Surface Variant, centered, mt sm8.
  - "Connect" — PrimaryBtn, full width, mt lg24.
  - **Success state:** card content swaps to green check circle + "Connected!" + child's name + avatar + "Go to Dashboard" AccentBtn.
  - **Error state:** code boxes get Error border, error message below in Error color.

### A12. COUNSELOR ONBOARDING
- Surface background. Centered card, 450px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
  - "Welcome, Counselor" — Noto Serif Headline Small (24pt), On Surface, centered.
  - School code text field: "Enter your school code" placeholder. Standard text field styling.
  - "Join School" — PrimaryBtn, full width, mt lg24.
  - "I'm a freelance counselor" — Primary link, Manrope 14pt, centered, mt md16. Underline on hover.
  - **Success state:** card content swaps to school logo (48px circle placeholder) + school name (Manrope 16pt title bold) + "42 students enrolled" (Manrope 14pt, On Surface Variant) + "Get Started" AccentBtn.

### A13. COPPA AGE GATE
- Surface background. Centered card, 450px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
  - Shield icon (40px, Primary), centered.
  - "Verify Your Age" — Noto Serif Headline Small (24pt), centered, mt md16.
  - Date of birth: 3 dropdown selectors side by side (Month / Day / Year), SurfaceContainerLowest bg, Outline border, lg radius. Manrope 14pt.
  - **Under-13 state:** additional fields appear with smooth animation:
    - "A parent or guardian must provide consent." Manrope 14pt, On Surface Variant.
    - Parent/guardian email text field.
    - "Send Consent Request" — PrimaryBtn, full width.
    - Info note: "We'll email your parent to approve your account." Manrope 12pt, On Surface Variant.

### A14. FERPA CONSENT
- Surface background. Centered card, 600px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
  - "Data Privacy Consent" — Noto Serif Headline Small (24pt), On Surface.
  - Legal text area: scrollable container (max 300px height), SurfaceContainerLow bg, lg radius, md16 padding. Manrope 14pt body text.
  - Bullet points summary below the scroll area: 4-5 key points with green check icons, Manrope 14pt, md16 spacing.
  - Consent checkbox: "I have read and agree to the above terms." Manrope 14pt. Custom checkbox (Primary fill when checked).
  - Signature field: text field labeled "Type your full name as signature", Manrope 16pt italic when filled.
  - Two buttons, mt lg24:
    - "I Agree" — PrimaryBtn (enabled only when checkbox checked + signature filled).
    - "Decline" — text button, Error color. Hover: Error Container bg.

### A15. FORCE PASSWORD CHANGE
- Surface background. Centered card, 420px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
  - Lock icon (48px, Primary) in a circle bg, centered.
  - "Update Your Password" — Noto Serif Headline Small (24pt), centered, mt md16.
  - "Your temporary password must be changed before continuing." Manrope 14pt, On Surface Variant, centered.
  - Temporary password field: read-only, SurfaceContainerHigh bg, monospace font, text obscured with show toggle. mt lg24.
  - New password field + strength bar (same as Sign Up). mt md16.
  - Confirm new password field. mt md16.
  - "Update Password" — PrimaryBtn, full width, mt lg24.

### A16. COUNSELOR VERIFICATION
- Surface background. Centered card, 500px max-width, SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
- **Multi-step indicator** at top: 3 steps (Identity / Credentials / Review), horizontal with connecting lines.
- **Step 1 — Identity:**
  - "Verify Your Identity" — Noto Serif Headline Small (24pt).
  - Full name text field.
  - Institution text field with autocomplete.
  - Role dropdown (Head Counselor / Counselor / Independent).
  - Professional email text field.
  - "Next" — PrimaryBtn, right-aligned.
- **Step 2 — Credentials:**
  - "Upload Credentials" — Noto Serif Headline Small (24pt).
  - Drag-and-drop upload zone: dashed Outline border, xxl radius, xxxl64 padding, centered. Icon (upload cloud, 40px, On Surface Variant). "Drag files here or **browse**" (Manrope 14pt, link in Primary). "PDF, JPG, PNG up to 10MB" helper text. Hover: border Primary, SurfaceContainerLow bg. Active drag: Accent Lime border, lime glow.
  - Uploaded file chips below zone (file icon + name + size + X remove).
  - "Back" + "Submit" buttons.
- **Step 3 — Pending Review:**
  - Hourglass icon (48px, Primary), centered, with slow rotation animation.
  - "Verification Pending" — Noto Serif Headline Small (24pt), centered.
  - "We'll review your credentials within 1-2 business days. You'll receive an email when approved." Manrope 14pt, On Surface Variant, centered.
  - "Return to Login" — outlined button, centered.

---

**Deliverable:** Design all 16 screens at 1440px width. Batch 1 of 12.
