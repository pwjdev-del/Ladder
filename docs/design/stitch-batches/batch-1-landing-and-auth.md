# Ladder Stitch — Batch 1 of 6: Landing + core auth (10 screens)

Paste this whole file into Stitch as one brief.

---

## Brand tokens (match these exactly)

Colors: forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · ink-400 `#8A9082` · status-red `#C94A3F` · status-amber `#D9A54A`.

Type: **Playfair Display** serif (600–700) for display / headlines. **Manrope** sans (400–600) for body / UI. Caps labels 11pt, +10% tracking, UPPER, weight 600.

Geometry: 12pt card radius · 999pt pills · 8pt input/chip radius · 24pt modal radius. Space: 4/8/12/16/24/32/48/64.

Reuse existing Stitch components: pill CTA, outlined secondary pill, cream logo badge, step-dot progress, circular ring, linear bar, 5-tab bottom nav, card-with-chevron row, segmented chip row, radio-pill option row, "Due in N days" pill, back chevron, skip+continue row.

Founder mood: darker forest-900 surface, lime accent only, mono-caps labels. Pull from `batcave_dashboard` + `utility_bay_&_skill_arsenal`.

## Do NOT design

No teacher UI. No grades for non-student. No founder view of student data. No shortcut to founder backdoor under 30 seconds. No ads / 3rd-party analytics on student screens. Every AI suggestion that changes state needs a visible human approve step.

## Reference screens (open side by side)

- `welcome_to_ladder_splash_screen/screen.png` (brand source)
- `student_profile_setup_onboarding/screen.png` (form patterns, step dots)
- `career_discovery_quiz_question/screen.png` (radio pills, progress, skip+continue)
- `student_home_dashboard/screen.png` (dashboard cards, bottom nav)

---

# Screens to design in this batch (10)

## 1. `landing_v2` — new landing

Replaces the existing splash. The only unauthenticated entry point.

- Background: forest-700 solid.
- Centered cream circular logo badge (120pt) at top — same badge used in the existing splash.
- Serif display/medium 32pt centered: **"Every kid needs a ladder to success."**
- CTA stack, 16pt gaps, 24pt side padding:
  1. Primary pill lime fill, dark-green text, 56pt tall, full width: **"Log in with your ID"**
  2. Secondary outlined pill (cream outline on green), 56pt tall, full width: **"Sign in through your school"**
  3. Two-up row (stone-200 fill, forest-700 text, 12pt radius, 48pt tall): **"Sign up as a student"** | **"Partner as a school"**
- Footer: 4 small line icons at 40% opacity (ribbon / grad cap / student / stairs) as in existing splash.
- **No visible hint** of the hidden founder trigger. The logo badge IS the 30-second press-and-hold target. Do not add any label revealing this.
- States: default, primary pressed (darker lime), keyboard/VoiceOver focus rings on each CTA.

## 2. `landing_v2_hold_states` — 30-second founder trigger animation spec

One artboard showing 5 frames of the logo badge during a press-and-hold. The iOS dev implements the animation from this sheet.

Five frames in a row, same cream logo badge, different decoration:

- **Frame at 0s (idle):** cream badge, climber silhouette forest-700, no ring, no glow.
- **Frame at 5s:** climber silhouette desaturates ~15% (slight gray-green shift). No ring.
- **Frame at 15s:** climber fully desaturated. Faint 2pt ring at 5% lime opacity, arcing clockwise from 12 o'clock to roughly 50% of the circle.
- **Frame at 25s:** ring at ~85%, 40% lime opacity, 3pt width.
- **Frame at 30s:** ring complete 100% bright lime, small 102%→100% scale pulse, brief inner-glow flash.

Caption strip under the frames: "0s nothing · 5s desaturate · 15s soft haptic · 25s medium haptic · 30s success haptic → founder login." Background: forest-700 to match the landing context.

## 3. `school_picker` — searchable partner-school list

Reached from landing → "Sign in through your school".

- White shell. Top bar: back chevron left, "Your school" title centered, nothing right.
- Search bar below: stone-200 fill, magnifier icon, placeholder "Search your school".
- Result rows, 56pt tall: square tint chip (school's primary color) · display name · caps slug underneath · chevron.
- Empty state when search has no matches: small lime ladder illustration + "Don't see your school?" + link "Partner as a school →" that routes to the B2B inquiry form.
- Pull-to-refresh supported.
- On row tap, header bar animates from white → school's primary color over 300ms ease-out as it pushes to `school_login_themed`.

## 4. `school_login_themed` — per-school login with theme swap

App rebrands to the selected school.

- 120pt top hero strip in the school's primary color. Inside the strip: 60pt circular logo (top-left), then serif display/medium school name.
- Body on cream surface, 24pt horizontal padding:
  - Section 1 title caps "SIGN IN" + email field + password field (stone-200 fill) + primary pill "Sign in" (full width).
  - Divider: caps label "OR" centered.
  - Section 2 title caps "FIRST TIME? JOIN WITH YOUR INVITE CODE" + input capsule that auto-uppercases, placeholder "INVITE-CODE" + outlined pill "Join with invite code".
- Footer: "Forgot your password?" link · "Use a different school" link routes back to the school picker.
- States: loading (primary pill compresses to spinner), error (inline red helper under the offending field).

## 5. `invite_redemption` — redeem a one-time invite code

After "Join with invite code" is tapped. Carries the school color strip from the prior screen.

- Header strip same as `school_login_themed`.
- Card on cream surface, 16pt padding:
  - Row "Code" with masked prefix shown: `LDR-X…` (we received the code on the prior screen; display masked).
  - Email field: label "Your school email", stone-200 fill.
- Primary pill "Join" full-width. Loading state: pill shrinks to a lime ring.
- Inline error band below the card (uniform message only — backend intentionally does not distinguish between expired / revoked / wrong-domain): "We couldn't use that code. Ask your counselor to issue a new one."
- Success state: confetti burst + serif headline "Welcome to {School Name}!" + continue button that routes to student onboarding.

## 6. `invite_code_display` — shown-once code card (shared component)

Used by counselors, admins, and the student-to-parent flow. Plaintext is visible ONE time only.

- Card: yellow-tinted fill (`#FFF7E6`-ish), status-amber 1pt border.
- 48pt mono code display (e.g., `LDR-X8K9-QR4T`). To its right: pill button "Copy" that shows a checkmark on tap.
- Small amber helper line under the code: "Shown once. Write it down or paste it now."
- **10-second countdown bar** along the bottom edge of the card, lime filling down to nothing. When the countdown finishes, the code blurs 8pt and cannot be revealed again.
- Under the card: two ghost buttons "Email this code" + "Share via Messages".
- States: just-revealed (crisp), countdown running (bar shrinking), post-countdown (code blurred, amber helper updates to "Code hidden. Generate a new one if needed.").

## 7. `b2c_signup_with_coppa_gate` — student self-signup

- Serif headline "Create your account".
- Stacked fields, 16pt gaps:
  - Email (keyboard email).
  - Password (secure entry, with inline strength dots; require 12+ characters).
  - Date of birth (date picker wheel).
- **COPPA inline card** conditional, appears when the calculated age from DOB is under 13: cream card with lime 4pt left border. Icon of a grown-up + kid. Copy: "Because you're under 13, a grown-up needs to say it's OK. We'll ask for their email after you sign up." This does NOT block the form — the backend enforces consent before quiz / grades writes.
- Agreements block: two toggle rows, stacked:
  - "I have read and accept the **Terms**"
  - "I have read the **Privacy Notice**"
  Tapping each opens a bottom sheet (batch 2 designs those).
- Primary pill "Create account" full-width. Disabled until all three fields are valid and both toggles on. Error state for invalid password: red inline helper.

## 8. `parental_co_sign_sheet` — parent unlocks under-13 session

Full-screen sheet shown when an under-13 student opens career quiz or grades for the first time.

- Background: paper white.
- Serif display/medium headline: **"Grown-up, it's your turn."**
- Body copy, ink-600: "Before {FirstName} takes the career quiz, a parent or guardian needs to sign in here. This confirms you agree to let Ladder use {FirstName}'s answers to suggest classes and activities."
- Illustration at top (~160pt tall): adult and child sharing a phone, brand style, warm.
- Fields:
  - Parent email (pre-filled if a parent account is already linked).
  - Parent password (secure).
- Primary pill "Unlock for my child" full-width.
- Bottom helper link: "Not a parent? Close and ask one to help." Closes the sheet and returns the child to a "Come back with a grown-up" empty state.
- States: default, loading, error ("That password didn't match — try again or reset from the parent account.").

## 9. `b2b_inquiry_form` — "Partner as a school" lead form

Not self-service. Founders review inquiries in the backdoor.

- Serif headline "Bring Ladder to your school."
- Subcopy ink-600: "Tell us a bit about your school. We'll reach out within a week to schedule onboarding."
- Fields stacked, stone-200 fills:
  - School name
  - Contact name
  - Role dropdown (Principal / Counselor / Administrator / Other)
  - Contact email
  - Phone (optional)
  - State — pill picker showing US state abbreviations.
  - Approx student count — stepper.
  - Desired features — multi-select chip row: Scheduling · Class suggester · Extracurriculars · Career quiz · Parent communication.
- Primary pill "Submit inquiry" full-width.
- Post-submit screen as a second artboard: cream checkmark badge + serif "We'll be in touch soon." + helper "We usually respond within 5 business days." + link "Back to Ladder".

## 10. `founder_login` — hidden founder sign-in

Reached only from the 30-second logo hold. Different visual universe from the tenant shell — darker, more utilitarian.

- Background: forest-900 (near-black green).
- Tiny caps label top-center: "LADDER · FOUNDER", stone-200 color.
- Card centered on dark surface (forest-700 card fill, 24pt radius):
  - "Founder ID" input (monospace feel).
  - "Password" input, secure.
  - "TOTP code" input (6-digit) OR a secondary button "Use passkey" (shown when Platform Authenticator is available).
  - Primary pill lime-fill: "Enter".
- Small helper strip at the bottom of the screen, caps, stone-200: "This surface does not render tenant data. Every action is audited."
- No "Forgot password" link. Founders rotate credentials out-of-band.
- States: default, loading, error ("That didn't match. Check the TOTP clock.").

---

Deliver each as `{screen_name}/screen.png` (iPhone 15 Pro frame, 393×852 @3x) + `{screen_name}/code.html` + short `{screen_name}/notes.md` listing pressed / disabled / loading / success / empty / error / locked states.
