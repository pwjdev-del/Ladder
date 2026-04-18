# Ladder — Stitch Design Prompt (v2 Spec Additions)

> Paste this whole document into Stitch as a single brief, or use section-by-section. The brand is already established by the existing splash + student dashboard + career quiz + onboarding screens in `/Downloads/stitch_welcome_to_ladder_splash_screen/`. Every new screen below MUST match that brand; do not reinvent colors, type, or button shapes.

---

## 0. Context for the designer

Ladder is an **iOS-only, iPhone-only** (iPad deferred) K–8 school-adoption platform. Dual B2B (schools) + B2C (families). First pilot: Lakewood Ranch Preparatory Academy (LWRPA), Florida. Domain: `purewavejosh.com`.

Users: **students, counselors, school administrators, parents (viewers), founders (hidden)**. **Teachers are NOT users** — teacher data exists, but there is no teacher-facing app surface. Do not design any teacher login, teacher dashboard, or teacher view.

Hard design rules that drive every screen (from `CLAUDE.md`):
- **Grades are student-self-only.** Counselors/admins/teachers/founders never see grades.
- **Founders never see tenant data** — no student names, grades, quizzes, schedules, AI logs, messages. They see only aggregates (counts, balances, token usage, success-rate %).
- **Sandbox per tenant.** One school or one family = one sandbox. No cross-tenant views for non-founder roles.
- **Career quiz is taken once, ever. Locked after completion.** Retake requires counselor override (audited).
- **30-second hidden logo-hold** on Landing opens the founder login. Must be invisible to non-founders up to ~5s, barely perceptible 5–15s, increasingly tactile 15–30s.

Platform specifics: iOS 17+ / iPhone only / SwiftUI + Swift Concurrency. Respect Dynamic Type from L through AX5 on body-text screens; clamp to xxxLarge on dense tables (counselor queue, admin tables, founder dashboard).

---

## 1. Brand tokens — LOCK IN

Derive these by eyedropping the existing `welcome_to_ladder_splash_screen` + `student_home_dashboard` + `student_profile_setup_onboarding` + `career_discovery_quiz_question` mockups. Use the exact same values on every new screen.

### Color
```
--ladder-forest-900        #3F5A3A  (dark-mode accent + deepest card header)
--ladder-forest-700        #527050  (primary background, dashboard hero)
--ladder-forest-500        #6B8A67  (secondary surfaces)
--ladder-lime-500          #A8D234  (primary CTA, progress rings, active chip dot)
--ladder-lime-300          #CCE68A  (focus glow)
--ladder-cream-100         #F5F0E5  (logo badge, elevated card on dark bg)
--ladder-paper             #FFFFFF  (body cards on light shell)
--ladder-stone-200         #E8E2D8  (muted input fill, inactive chip)
--ladder-ink-900           #1B1F1B  (primary text on light surfaces)
--ladder-ink-600           #4A5346  (secondary text)
--ladder-ink-400           #8A9082  (tertiary text / placeholder)
--ladder-status-red        #C94A3F  (due-in-X-days, critical conflict)
--ladder-status-amber      #D9A54A  (warning, Varun-blocked)
```

### Typography

- **Display / headline:** Playfair Display (serif, weight 600–700). Use tight tracking (-1% to -2%). Headlines sit on dark green or cream surfaces.
- **Body / UI:** Manrope or Inter (sans, weight 400–600). Body is 16pt scaled; labels are 12–14pt semi-bold.
- **Labels in small caps:** letter-spacing +8%–10%, all caps, 11–12pt, `--ladder-ink-600`.

Typographic scale (call these the "Ladder type tokens"):
```
display/large   40pt  serif 700
display/medium  32pt  serif 700
headline/large  28pt  serif 600
headline/small  22pt  serif 600
title/large     18pt  sans 700
title/small     15pt  sans 600
body/large      16pt  sans 400
body/small      14pt  sans 400
label/large     13pt  sans 600
caps            11pt  sans 600 +10% tracking, UPPER
```

### Geometry
- **Corner radius:** 12pt for cards, 999pt (pill) for primary CTAs, 8pt for inputs and chip buttons, 24pt for modals/bottom sheets.
- **Spacing scale:** 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64.
- **Shadows:** cards on dark green use a soft 12pt Y, 24pt blur, 8% black. Cards on white use 4pt Y, 12pt blur, 4% black.

### Components already in the Stitch library — REUSE, don't recreate
- Pill CTA (lime fill, dark-green text) + outlined secondary (outlined in cream on green bg, outlined in forest-700 on white bg).
- Cream circular logo badge with the ladder + climber silhouette.
- Step-dot progress (small dots, lime for active, stone-200 for inactive).
- Circular progress ring (60% style — lime stroke on stone-200 track).
- Linear progress bar (lime on stone-200).
- Icon-row bottom nav (5 tabs, forest-700 for active icon + label, ink-400 for inactive).
- Card-with-right-chevron row.
- Segmented grade-level chip row (filled forest-700 for active, stone-200 for inactive) — SAME component as career quiz.
- Radio-pill option row (lime dot fill + lime outline for selected; stone-200 fill + gray outline for unselected) — SAME as career quiz.
- "Due in N days" red pill badge.
- Daily-tip card with forest-700 tinted background + lime location pin.

---

## 2. Mapping: what Stitch has vs what's missing

### Already designed (reuse verbatim, with light copy tweaks)
| Existing Stitch screen | Maps to spec role |
|---|---|
| `welcome_to_ladder_splash_screen` | Replace with new Landing (see §3.1) — the existing splash only has Get Started / I Already Have an Account, we need 3 affordances + hidden trigger |
| `student_profile_setup_onboarding` | Student B2C signup profile step (keep; restyle fields to match §3 of CLAUDE.md — grade level now K–8, not 8th–12th) |
| `career_discovery_quiz_question` | Career quiz question screen — reuse pattern for ALL 3 age-band variants (K-2, 3-5, 6-8) |
| `student_home_dashboard` | Student home — repurpose for K–8 (drop SAT registration, drop volunteering hours as "next up"; replace with schedule builder + class suggester shortcuts) |
| `ai_academic_advisor_chat` | Help-surface chat inside any feature — reuse verbatim |
| `activity_roadmap_checklist_1` + `_2` | Student tasks tab |
| `add_custom_reminder_modal` | Generic add-reminder modal |
| `user_profile_settings` | Settings |
| `connect_messaging` | Counselor↔student 1-to-1 messaging (if enabled) |
| `milestone_celebration_modal` | Generic celebration (e.g., quiz completed, schedule approved) |
| `today's_learning_agenda` | Student home alt — daily agenda card |
| `batcave_dashboard` + `utility_bay_&_skill_arsenal` | **Founder backdoor inspiration** — keep the dark + tooling mood |

### SKIP / do NOT ship in v2
These are college-admissions-era screens from the prototype. They do not belong in the K–8 Ladder. Leave them out of the app entirely.

`admissions_decision_portal`, `application_deadlines_calendar_1/2`, `application_submission_success`, `college_comparison_tool`, `college_discovery_hub`, `college_hub_profile_rit`, `college_impact_report_summary`, `dorm_comparison_tool`, `financial_aid_comparison_tool`, `housing_preference_selection`, `interview_preparation_hub`, `loci_generator_tool`, `match_score_analysis`, `mock_interview_feedback_report`, `pdf_report_export_preview`, `post_application_next_steps_guide`, `roommate_finder_discovery`, `roommate_intro_guide`, `roommate_profile_detail`, `scholarship_search_results`, `score_improvement_recommendations`, `thank_you_note_generator`, `university_enrollment_checklist`, `updated_home_dashboard_applied_status`, `waitlist_management_strategy_guide`, `ai_mock_interview_session`.

(Leave these files in place in `/Downloads/…` as reference. They simply won't map to any route in the new app.)

### MISSING — Stitch, please design these 45 new screens

All grouped into Clusters A–F below. Each carries layout specs, states, copy, and which existing components to reuse.

---

## 3. Cluster A — Landing & Auth (11 screens)

### 3.1 `landing_v2` — new Landing (REPLACES existing splash)

**Purpose:** The sole unauthenticated entry point. Three primary affordances + one hidden founder trigger.

**Layout:**
- Top: cream circular logo badge at ~120pt, centered, top margin ~72pt.
- Slogan below logo, serif display/medium 32pt, centered, single line: "Every kid needs a ladder to success." (NOT "Leading Students to Their Own Success" — that was the old mock).
- Spacing: 48pt gap down to CTAs.
- CTA stack, 16pt between rows:
  1. **Primary pill:** `Log in with your ID` — lime fill, dark-green text, 56pt tall, full-width.
  2. **Secondary outlined pill:** `Sign in through your school` — forest-700 outline + text, 56pt tall, full-width.
  3. **Sign-up row (2 equal buttons side-by-side):** `Sign up as a student` (left) | `Partner as a school` (right) — stone-200 fill, forest-700 text, 12pt radius, 48pt tall.
- Bottom safe-area: the 4 footer icons from the existing splash (ribbon / grad cap / student / stairs) at 40% opacity.

**Hidden trigger — do NOT add visible hint.** The big cream logo badge at top is the press-and-hold target. Design these 5 visual states the logo cycles through (see §3.2). Do not add any text label revealing the trigger.

**Background:** Forest-700 solid, same as existing splash.

**Accessibility:** VoiceOver reads the logo as "Ladder." Dynamic Type scales slogan up through accessibility5.

### 3.2 `landing_v2_hold_states` — founder trigger feedback spec (5 frames)

**Purpose:** Design sheet showing the logo's appearance at 0s, 5s, 15s, 25s, 30s so the iOS dev can implement the SwiftUI animation faithfully.

Each frame is the same logo badge, different decoration:
- **0s (idle):** cream badge + climber silhouette in forest-700, no ring.
- **5s:** climber silhouette desaturates ~15% (becomes slightly gray-green). No ring yet. Casual presser releases and never notices.
- **15s:** climber fully desaturated; faint 2pt ring at 5% lime opacity begins to appear, arcing from 12 o'clock clockwise, currently at ~50% of the circle.
- **25s:** ring now at ~85%, 40% lime opacity, 3pt width.
- **30s:** ring completes the full circle, 100% lime, plus a tiny scale-punch (102% → 100%) and brief inner-glow flash.

Include a caption strip at the bottom of the sheet: "0s nothing · 5s desaturate · 15s soft haptic + faint ring · 25s medium haptic + bright ring · 30s success haptic + ring complete → founder login."

### 3.3 `school_picker` — searchable partnered-school list

**Purpose:** After tapping "Sign in through your school", user picks their school from a searchable list.

**Layout:**
- White background (light shell).
- Top: back chevron (forest-700) on the left, "Your school" title centered.
- Search bar: stone-200 fill, magnifier icon, placeholder "Search your school".
- Result list rows: 56pt tall. Left: tiny square logo thumbnail (school primary color as placeholder tint). Middle: display name + (caps label underneath) "LWRPA" slug. Right: chevron.
- Empty state when query has no matches: lime ladder illustration + "Don't see your school? Ask them to partner with us." + link "Partner as a school →" (routes to B2B inquiry).

**Interaction:** Tapping a row pushes to §3.4 **with a theme swap animation** — the header bar's background transitions from white to the school's primary color over 300ms ease-out, and the logo pulses in.

### 3.4 `school_login_themed` — per-school login

**Purpose:** Tenant-scoped login. App shell rebrands to the chosen school's color + logo.

**Layout:**
- Top hero strip (120pt tall) uses the school's primary color (default LWRPA `#0A4B8F`), with the school's logo (60pt circle) + display name in serif display/medium.
- Below hero on cream surface:
  - Section 1: "Sign in" — email field + password field + primary pill CTA "Sign in".
  - Divider with caps label "OR" centered.
  - Section 2: "First time? Join with your invite code" — input capsule that auto-uppercases, placeholder "INVITE-CODE", + secondary pill "Join with invite code" (routes to §3.5).
- Tiny footer: "Forgot your password?" + "Use a different school" link that routes back to §3.3.

### 3.5 `invite_redemption` — redeem invite code

**Purpose:** Join a school with a one-time code issued by a counselor/admin.

**Layout:**
- Header: school color strip with logo + name (carries from §3.4).
- Card: `LabeledContent("Code", value: "LDR-X…")` showing only the 4-char prefix + ellipsis (plaintext was shown once to the counselor and is already pasted).
- Email field: "Your school email".
- Primary CTA pill: "Join". Loading state: pill shrinks to a progress ring.
- Inline error strip: "We couldn't use that code. Ask your counselor to issue a new one." (backend returns uniform error — do NOT distinguish expired / revoked / wrong-domain in copy).
- Success state: confetti milestone modal + "Welcome to {School Name}!" → routes to student onboarding.

### 3.6 `b2c_signup_with_coppa_gate` — student self-signup (age-aware)

**Purpose:** Student creates a B2C account. If DOB indicates <13, signup creates only a minimal record and blocks data collection until parent consents.

**Layout:**
- Serif headline: "Create your account".
- Fields stacked:
  - Email (keyboard: email).
  - Password (secure entry, with inline strength dots — require 12 chars).
  - DOB — date picker wheel.
- **COPPA inline card** (conditional, only when age < 13 calculated from DOB): card on cream surface with lime-left border, icon of grown-up + kid, copy: "Because you're under 13, a grown-up needs to say it's OK. We'll ask for their email after you sign up." DO NOT block signup here; backend will enforce parental_consent before quiz/grades writes.
- Agreements block: toggle rows for "I have read and accept the **Terms**" and "I have read the **Privacy Notice**". Each opens a bottom sheet (see §3.9).
- Primary pill CTA: "Create account" — disabled until all 3 fields valid + both toggles on.

### 3.7 `parental_co_sign_sheet` — parent co-presence gate (for under-13 first-use)

**Purpose:** When an under-13 student opens the quiz or grades entry for the first time, the app presents a full-screen sheet requiring the parent to enter their own password to unlock the session. Audits the dual-ID.

**Layout:**
- Serif headline: "Grown-up, it's your turn."
- Body copy: "Before {FirstName} takes the career quiz, a parent or guardian needs to sign in here. This confirms you agree to let Ladder use {FirstName}'s answers to suggest classes and activities."
- Parent email field (pre-filled if linked).
- Parent password field.
- Primary CTA pill: "Unlock for my child". Success closes sheet and lets child proceed.
- Bottom helper link: "Not a parent? Close and ask one to help."
- Visual: small illustration of an adult and child sharing a device, drawn in the same brand style.

### 3.8 `invite_code_display` — shown-once code card

**Purpose:** Any time a counselor/admin/student generates an invite code, the plaintext is shown ONCE. After 10 seconds the code blurs; refreshing or revisiting does not re-reveal it.

**Layout:**
- Card with yellow-tinted background + orange-amber border (status-amber token at 40%).
- Large monospaced code text (48pt). Next to it: `Copy` pill button with checkmark on-tap.
- Helper line in status-amber: "Shown once. Write it down or paste it now."
- 10-second countdown micro-bar along the card's bottom edge (lime filling down to nothing, then auto-blurs the code with 8pt blur).
- Export options below: "Email this code" + "Share via Messages" buttons.

### 3.9 `consent_sheets` — T&Cs / Privacy / Parental Consent / AI Addendum / DPA

**Purpose:** Each legal doc gets a bottom-sheet presentation with progressive disclosure; dwell-time on each section is tracked for legal defensibility.

**Layout (shared):**
- Bottom sheet covers 92% of screen.
- Top: serif headline of the doc name, small close-X on the right.
- **Plain-language summary card at top** (150 words Lawyer-AI-drafted): lime-left-border card with the 4 bullets "What we collect / What we don't / Who sees what / How to delete".
- Expandable sections below — each with its own checkbox on the right edge for the parental-consent variant. Sections tap-to-expand inline (not modal).
- "Read the full text" bottom link opens the canonical doc as a WebView.
- **Continue pill (dark green)** at bottom; disabled until required checkboxes are ticked.

Variants:
- `consent_terms` — general Terms, single global checkbox.
- `consent_privacy` — Privacy Notice, single checkbox.
- `consent_parental` — per-section checkboxes (data collection / AI usage / sharing with school / marketing opt-in). Parent signs.
- `consent_ai_addendum` — school-opt-in gate for AI features that process student data.
- `consent_dpa_summary` — for school admins at onboarding; plain-language summary of the DPA with "View full DPA (PDF)".

### 3.10 `b2b_inquiry_form` — Partner as a school

**Purpose:** Non-self-service B2B lead form. Founders review leads in the backdoor.

**Layout:**
- Serif headline: "Bring Ladder to your school."
- Subcopy: "Tell us a bit about your school. We'll reach out within a week to schedule onboarding."
- Fields (all stacked, stone-200 fill):
  - School name
  - Contact name + role dropdown (Principal / Counselor / Administrator / Other)
  - Contact email (+ optional phone)
  - State (pill picker; US states)
  - Approx student count (stepper or text)
  - Desired features (multi-select chips: Scheduling · Class suggester · Extracurriculars · Career quiz · Parent communication)
- Primary pill CTA: "Submit inquiry".
- Post-submit screen: brand-consistent confirmation with cream checkmark badge + "We'll be in touch soon" + link "Back to Ladder".

### 3.11 `founder_login` — hidden founder sign-in

**Purpose:** Only reachable via the 30s logo hold. Separate visual universe from tenant UI — darker, more utilitarian.

**Layout:**
- Background: forest-900 (near-black green).
- Top: tiny "LADDER · FOUNDER" caps label, stone-200 color.
- Card centered on dark surface:
  - Founder ID input (monospace-ish).
  - Password (secure).
  - TOTP code input OR "Use passkey" button (if Platform Authenticator available).
  - Primary CTA pill in lime: "Enter".
- Helper strip at bottom, small caps: "This surface does not render tenant data. Every action is audited."
- No forgot-password link (founders rotate creds out-of-band).

---

## 4. Cluster B — Student (7 screens)

### 4.1 `quiz_grade_band_picker` — pick K-2 / 3-5 / 6-8 before starting the career quiz

**Purpose:** The quiz UX differs dramatically by reading level. Before first question, auto-detect from DOB and let student confirm.

**Layout:**
- Serif headline: "Let's find what you love."
- Subcopy: "Pick your grade. The quiz changes to match your age."
- 3 large cards (stacked):
  - **K-2 card:** picture-book style illustration, "K–2 (pictures)" label, small-caps helper "6 short sittings, grown-up please sit with me".
  - **3-5 card:** simpler text illustration, "3–5 (easy words)" label.
  - **6-8 card:** notebook illustration, "6–8 (full quiz)" label.
- Primary pill "Start": lime fill.

### 4.2 `quiz_k2_picture_pair` — K-2 picture question

**Purpose:** K-2 variant of `career_discovery_quiz_question`. Two-up picture cards: "Which do you like more?"

**Layout:**
- Forest-700 top strip with back chevron, "Q1 of 3 today" caps label.
- Serif display/medium question: "Which do you like more?"
- Two large cards side-by-side (or stacked on narrow width):
  - Card 1: paintbrush illustration + "Making art" label.
  - Card 2: rocket illustration + "Building rockets" label.
- Bottom strip: "Grown-up, tap the mic for read-aloud." + audio mic button.
- Progress ladder visualization instead of progress bar — 6 ladder rungs, filled lime for completed, stone-200 for pending.

### 4.3 `quiz_locked` — quiz-once-ever empty state

**Purpose:** Student returns to career quiz after they've already completed it.

**Layout:**
- Centered empty-state illustration: a climber at the top of a ladder with a gold star.
- Serif headline: "You've already climbed this ladder."
- Body copy: "The career quiz is a one-time trip. Your results still power your class suggestions and activities. Ask your counselor if you need to take it again."
- Secondary link: "How Ladder uses my quiz →" opens info sheet.

### 4.4 `grades_self_entry` — student-only grades

**Purpose:** Student enters their own grades. Header reinforces that NO ONE else sees these.

**Layout:**
- Serif headline: "My grades".
- **Trust banner** (cream card, lime-left border): "Only you see your grades. We use them to suggest next year's classes. [Learn more →]". Always visible at the top.
- Empty state: illustration of a notebook + pencil + "Add your first grade to get personalized class suggestions."
- Populated state: list rows — subject (left) + score mono (middle) + period pill (right). Long-press reveals delete.
- Bottom floating + button (forest-700 fill) opens the add-grade sheet.

**Add-grade sheet:**
- Serif headline: "Add a grade".
- Subject text field.
- Score input (stone-200 fill).
- Period segmented pill (Q1 / Q2 / Q3 / Q4 / Final).
- Save button (pill, lime).

### 4.5 `class_suggester_results` — AI-recommended classes with "why this fits" + sources

**Purpose:** After quiz + grades, AI suggests next year's class picks.

**Layout:**
- Serif headline: "Classes that fit you."
- Lime top-ribbon small-caps: "AI SUGGESTIONS · REVIEW & CHOOSE".
- Each suggestion is a card (white on light shell; or cream on dark):
  - Class code caps label (e.g., "MA-105") + rigor badge ("STANDARD" / "HONORS" / "AP") on right.
  - Class title serif headline/small.
  - "Why this fits you" body text — 2–3 sentences grounded in quiz + grades.
  - Source chip row: "🔗 Florida BOE pathway" | "🔗 U.S. BLS career outlook" (tap opens sheet).
  - Primary pill "Add to my plan" + secondary ghost "Not for me".
- Bottom summary strip: "3 of 5 added • Tap to review your picks →"
- Empty / loading state: skeleton cards + "Consulting Gemini via Ladder's AI gateway…" — same ring pattern as the existing loading components.

### 4.6 `extracurriculars_ai_session` — iterative AI session with suggestion cards inline

**Purpose:** Not a list — a conversation. Chat-style, resumable. Reuse `ai_academic_advisor_chat` pattern but with inline structured SuggestionCards mixed into the transcript.

**Layout:**
- Top: back chevron + "Things to try" title. Right-top: "Resume later" text button.
- Chat transcript:
  - Student bubble: lime pill bg, dark-green text, right-aligned.
  - AI bubble: cream pill bg, ink-900 text, left-aligned, with a small Ladder monogram avatar.
  - **Inline SuggestionCard:** full-width white card with title, fit-rationale, clock + dollar icon row ("2 hrs/wk · Free"), bold CTA "Here's how to join →". Appears inside the transcript when AI proposes a concrete program.
- Bottom: rounded text composer + mic button + lime send button.

### 4.7 `schedule_builder` — 7-period grid with gates

**Purpose:** Student picks their classes for next year during the scheduling window.

**3 states in one screen spec:**

1. **Quiz-stale empty:**
   - Illustration: notebook + pencil.
   - Serif: "Take the career quiz first."
   - Body: "Your quiz needs to be from this school year before you can plan classes."
   - Primary pill: "Go to quiz" → career quiz.

2. **Window-closed empty:**
   - Illustration: calendar with a lock.
   - Serif: "Scheduling isn't open yet."
   - Body: "Your counselor opens scheduling when it's time to plan."
   - Secondary link: "Email my counselor".

3. **Active builder:**
   - Header: "Next year — Fall 2027" serif headline + small-caps subcopy "Ends {date} at {time}".
   - 7 period rows (P1–P7). Each row is a large tappable cell. Empty state: "— pick a class —" in ink-400. Filled state: class title + small code caps label + "change" ghost button.
   - Right-rail bottom sheet (tap a period): AI-suggested picks (from §4.5) at top, then full catalog below.
   - Bottom bar: 7-period progress pill ("5 of 7") + primary pill "Submit for review" (disabled if <7 picks).
   - On submit: confetti + "Sent to your counselor" + route to a "Waiting for approval" status screen with the 3-state pip (DRAFT → SUBMITTED → APPROVED / SENT_BACK).

### 4.8 `parent_invite_flow` — student invites a parent

**Purpose:** After first login, student can invite a parent; code generated server-side, shown once.

**Layout:**
- Serif headline: "Add a grown-up."
- Body: "Your parent or guardian can watch your progress and help with big decisions."
- Parent email input + relationship picker (Parent / Guardian / Other).
- Primary CTA: "Send invite".
- Post-success: `invite_code_display` card (§3.8) + secondary ghost "I'll share it with them later".
- Side link: "Manage my parents" opens list of already-linked parents with the option to remove.

---

## 5. Cluster C — Counselor (6 screens)

### 5.1 `counselor_home` — counselor dashboard

**Purpose:** Counselor at LWRPA opens the app; sees queue depth + quick actions.

**Layout:**
- Top hero strip (forest-700): small-caps "COUNSELOR DASHBOARD", serif "Good morning, {CounselorFirstName} 👋", school pill chip underneath ("LWRPA · K-8").
- Next-up card (white, prominent): "12 schedules waiting for review" + primary pill "Open queue →".
- Quick actions row (4 cards, equal width, scrollable): `Invite students` / `Upload class list` / `Open scheduling window` / `Messages`.
- Caseload stats row below: 3 KPI tiles — Students / Quiz completion / Schedules approved — each with a tiny sparkline.
- Recent activity list (last 10 items: "Alice submitted her schedule", "Bob redeemed invite", "Carol completed quiz").
- Bottom nav: Home / Queue / Classes / Invites / Profile.

### 5.2 `counselor_student_queue` — split-view approval queue

**Purpose:** Flight-control panel for approving student schedules.

**Layout (iPhone: stack with selectable list on top, detail pushed on tap; iPad: split):**
- Left rail (or full screen on iPhone): list rows sorted by conflict count desc. Row = student initials avatar + display name + conflict pip (red dot if conflicts, green if clean) + submitted time ago.
- Filter chips above list: All / With conflicts / Approved today.

**Detail view (`schedule_review_detail`):**
- Top: student card — avatar + name + grade + "Submitted 2 hrs ago".
- Full-width `ScheduleGrid` (7 periods × 5 days). Conflicting cells have red border + red-tinted fill.
- Issue panel card below grid:
  - If no issues: cream card with checkmark + "No conflicts, prereqs, or capacity issues."
  - If issues: red-left-bordered card listing each issue ("P3 conflict: Algebra 2 and Biology both period 3" with AI-suggested fix chip below: "Try Biology in P5 (capacity available)").
- Bottom action bar (sticky):
  - Outlined secondary: "Send back" (opens note sheet pre-filled with AI draft).
  - Outlined with modify icon: "Modify and approve" (requires second confirm since it's audited).
  - Primary pill: "Approve" (disabled when issues exist).

### 5.3 `counselor_class_list_upload` — CSV/XLSX/PDF intake with AI parse

**Purpose:** Upload the class catalog for the year.

**Layout:**
- Serif headline: "Upload your class list".
- Input method selector chips: `Paste` / `Upload CSV` / `Upload XLSX` / `Upload PDF` / `Scan photo`.
- Active method area:
  - Paste: large text area with stone-200 fill + "Paste rows here — we'll parse them" helper.
  - File upload: drag-n-drop zone (lime dashed border).
- Primary CTA: "Parse with Gemini" (routes through ai-gateway).
- After parse: table review — rows with code / title / grade / capacity, each with an inline edit pencil. Red rows = AI low-confidence; highlight for counselor to verify.
- Confirm bar: "Confirm and save 42 classes" pill.

### 5.4 `counselor_scheduling_window_control` — open/close window

**Purpose:** Gate when students can build schedules.

**Layout:**
- Serif headline: "Open scheduling for {academicYear}".
- **Preconditions checklist card** — 3 rows, each with green check or empty circle:
  - "Teacher schedules uploaded" (admin-only)
  - "Class catalog uploaded"
  - "Prereqs confirmed"
- If any unchecked: the Open CTA is disabled with helper "Ask the admin to complete the missing steps first."
- Academic year text field.
- "Opens at" + "Closes at" date pickers (side by side).
- Primary CTA: "Open scheduling window". Confirm modal: "{N} students will be able to build schedules starting {date}. Continue?"
- Below the CTA, a log of past windows (collapsed list).

### 5.5 `counselor_invite_codes` — generate student invites

**Purpose:** Counselor issues invite codes (single / bulk / class-level). Plaintext shown once via `invite_code_display`.

**Layout:**
- Mode segmented picker: `Single` / `Bulk` / `Class-level`.
- Options card (changes by mode):
  - Single: intended student name/email optional, expected grade stepper.
  - Bulk: quantity stepper (1–200) + optional CSV download of codes after issue.
  - Class-level: grade-level + max uses + window.
- Shared fields: `Allowed email domain` (optional), `Expires in N days`.
- Primary pill "Generate".
- After generate: cards list — each is an `invite_code_display` card. Single CTA "Export all" (email / share / CSV).

### 5.6 `counselor_messages` — 1:1 with students (light reuse of `connect_messaging`)

**Purpose:** Counselor sends a student a note about their schedule, an invite reminder, or a quiz gentle nudge.

Reuse `connect_messaging` Stitch screen patterns. Tweak copy for counselor-to-student. Add a "Scheduling note" quick-template button above the composer.

---

## 6. Cluster D — Admin (6 screens)

Admins are a superset of counselors plus exclusive access to teacher data and success metrics.

### 6.1 `admin_home` — admin dashboard

**Purpose:** Admin sees school-wide pulse + prompts for periodic success metrics.

**Layout:**
- Top hero strip (forest-700): "ADMIN DASHBOARD" caps + "Good morning, {AdminFirstName}" serif + "LWRPA · K-8" pill.
- **Mandatory banner** (status-amber left border) when success metrics are stale (≥ 3 months): "It's time to update your school's annual metrics. [Update now →]" — tapping opens §6.5.
- KPI tiles row (4 tiles): Students / Counselors / Teachers / Active windows.
- Quick actions: `Upload teacher schedules` / `Invite counselor` / `Open window` / `View teacher reviews`.
- Sections below: "Teacher data" card (count + "→ Manage"), "Classes" card (count + "→ Manage"), "Scheduling" card (state + "→ Open window").
- Bottom nav: Home / Teachers / Classes / Invites / Profile.

### 6.2 `admin_teacher_profiles` — list + detail

**Purpose:** Admin-only CRUD for teacher profiles. Remember: teachers are NOT app users; this is HR data.

**List view:**
- Search + filter chips (all / active / on leave).
- Rows: avatar initials + name + subject tags chip row + grade-band chip.
- + button (bottom floating) to add a new teacher.

**Detail view:**
- Headshot placeholder (initials circle).
- Name + "Admin-only" lime-pill chip.
- Tabs: `Profile` / `Schedule` / `Reviews` (admin exclusive).
- Profile tab: name fields, subject tags, teaching-style tags (e.g., "Project-based", "Direct instruction"), notes.
- Save pill.

### 6.3 `admin_teacher_schedules` — bulk upload + per-period assignment

**Purpose:** Upload which teacher teaches which section + period + room. Prerequisite for opening a scheduling window (§5.4).

**Layout:**
- Upload section (reuse §5.3 patterns): CSV/XLSX with columns teacher_id, class_id, period, room.
- Review table: rows with teacher name + class + period chip + room + edit.
- After save: confirmation card + "You can now open a scheduling window." deep-link.

### 6.4 `admin_teacher_reviews` — admin-exclusive performance reviews

**Purpose:** Admin records periodic reviews of teachers. No other role ever sees these.

**Layout:**
- Serif headline: "Teacher reviews".
- **Privacy banner** (red-left border): "This is admin-only. Counselors, teachers, and founders never see these notes."
- Teacher picker row.
- Period label field (e.g., "2025–2026 mid-year").
- Body textarea (expandable).
- Save pill.
- History list below: past reviews as collapsed rows (teacher + period + first line).

### 6.5 `admin_success_metrics_popup` — mandatory periodic metrics

**Purpose:** Modal that blocks admin from the rest of the app when success metrics are stale (≥ 3 months since last update). Data flows to founder's School card as an aggregate %.

**Layout:**
- Full-screen sheet (not dismissable without "Remind me later" bottom link which delays by 48h max).
- Serif headline: "Update your school's metrics."
- Subcopy with small-caps helper: "WHY · Founders use these aggregates (never student data) to show impact to stakeholders."
- Period label text field.
- Core metric rows:
  - "College acceptance count" stepper (0–5000).
  - "Graduation rate" slider 0–100% with mono number badge.
- Custom fields card: admin can add key-value rows per school (e.g., "SAT median", "AP pass rate").
- Primary pill "Submit" + bottom ghost "Remind me later".

### 6.6 `admin_invite_codes` — (reuse §5.5, same component, admin can also issue counselor invites)

---

## 7. Cluster E — Founder backdoor (9 screens)

Darker, utilitarian mood. Pull from `batcave_dashboard` + `utility_bay_&_skill_arsenal` existing Stitch designs for tone. NEVER render student names, grades, quiz answers, schedules, AI logs. The UI literally has no component that accepts a student-PII prop.

### 7.1 `founder_dashboard_overview` — post-login landing

**Purpose:** Founder's home after login. Two sections: Schools · Solo people. Lower stats strip with system-wide token usage / cost / alerts.

**Layout:**
- Background: forest-900.
- Top caps bar: "FOUNDER · LADDER" + tiny avatar menu.
- Two big cards (side by side on wide, stacked on phone):
  - Schools card: lime count badge ("4 tenants"), "Go to schools →".
  - Solo People card: lime count badge ("22 families"), "Go to solo →".
- Below: system-wide tiles (this month): AI tokens total / AI cost total / Active windows / New leads.
- Bottom: tab bar styled dark — Schools / Solo / Flags / Varun (no tenant-data tabs).

### 7.2 `founder_schools_grid` — grid of school cards

**Purpose:** One card per school tenant. Never renders any student-level data.

**Card content (never more than these 7 metrics):**
1. School name + small square of their primary color.
2. Student count (integer).
3. Billing balance (USD).
4. AI tokens used this month.
5. AI cost this month.
6. Success rate % (from admin's periodic metric popup, §6.5).
7. Feature-flag summary ("7 on / 2 off") with link.

Sort chips: Newest · Balance desc · Tokens desc · Alert first.
Top bar: search + "+ Add a new school" primary CTA → §7.4.

### 7.3 `founder_school_detail` — per-tenant aggregates

**Purpose:** Click a card → detail with aggregates + contract links. NO student-level widget.

**Layout:**
- Header: school color strip + name.
- Section A — Enrollment + billing: 2 rows.
- Section B — AI usage: tokens this month + cost this month + sparkline.
- Section C — Success metrics: % + link to history.
- Section D — Contracts: DPA link, Liability ack link, AI Addendum signed (checkmark).
- Section E — Feature flags: link to §7.6 scoped to this tenant.
- Section F — Audit timeline (metadata only, NO payload): "Admin opened a scheduling window {ts}", "Counselor issued 12 invites {ts}", ...
- Footer helper: "Founders never see student data. This surface enforces §14.4 at the API, DB, and UI layers."

### 7.4 `founder_add_new_school` — provisioning form

**Purpose:** Founder spins up a new tenant. Backend generates per-tenant DEK + default flags + emails seed admin creds.

**Layout:**
- Serif headline: "New school".
- Fields:
  - Display name
  - Slug (auto-derived; editable)
  - Primary color (hex input + swatch preview)
  - Logo URL upload
  - Plan picker (Pilot / Standard / Custom)
  - Seed admin email
- Primary pill "Provision tenant". During provisioning, show a 4-step progress stepper: "Creating tenant → Generating DEK → Seeding default flags → Emailing admin".

### 7.5 `founder_solo_people` — B2C family list (anonymized)

**Purpose:** Per §14.4, founders see only family *structure* and billing, never names.

**Layout:**
- Rows: "Family #A7C3 · 1 parent · 2 kids · Paid" — display as monospace family hash, then structure counts, then billing chip (paid / trial / past_due).
- Filter chips: All / Trial / Past due / New this week.
- Tap a row: detail sheet with billing history + the same family hash + "Export payment receipts" — no names, no child data.

### 7.6 `founder_feature_flags_per_tenant` — toggle with Varun block state

**Purpose:** Enable/disable features per school. Every proposed change routes through Varun; rejected changes show inline.

**Layout:**
- Tenant picker strip at top (pulls from schools grid).
- Flag rows — each with:
  - Mono key label ("feature.scheduling")
  - Description sub-line.
  - Right-side 3-state toggle: **ON** (lime fill) / **OFF** (stone-200 fill) / **BLOCKED BY VARUN** (amber border + small "Varun says…" inline panel with violated rule + "Apply fix" button).
- Save pill at bottom; disabled if any blocked state.

### 7.7 `founder_varun_panel` — rule explainer + "why can't I?"

**Purpose:** Explain the 10 rules; allow "why can't I turn this off?" trace.

**Layout:**
- Serif headline: "Varun".
- Sub-copy small-caps: "Feature dependency validator · Not an AI · Does not read student data."
- Rule list (10 rows) — each row: "Rule {N}" caps label + rule text. Tap to expand and see example violations.
- Bottom card: "Ask Varun" — input "Why can't I turn off {flag_key}?" → text area showing the trace chain.

### 7.8 `founder_impersonation_banner` — red full-width banner + detail

**Purpose:** When an admin-initiated impersonation grant is active, every founder screen shows this banner.

**Layout:**
- Status-red full-width bar at top of screen (ignores safe area).
- Content left: triangle-warning icon + "Impersonation active" title + grantReason subtext.
- Right: mono countdown `MM:SS` + "Audit" ghost pill.
- Tap opens the full impersonation audit detail.

### 7.9 `founder_blocked_from_tenant_data` — §14.4 blocked state

**Purpose:** If for any reason a founder session reaches a tenant-data view, the UI refuses to render it. This is the screen shown in its place.

**Layout:**
- Background: forest-900.
- Centered: lock + shield icon in lime.
- Serif headline: "Not available for founder sessions."
- Subcopy: "§14.4 — founder sessions are denied tenant data at the API, DB, and UI layers."
- Link: "View audit trail" → opens the attempted route's audit entry.

---

## 8. Cluster F — New shared components (8 components)

All should match existing Stitch styling. Ship as reusable mockups with states.

1. **InviteCodeDisplay** — §3.8 above.
2. **ScheduleGrid** — 7 periods × 5 days, with cells: empty / filled / conflict-overlay. Three density variants: student-builder (generous), counselor-review (dense), admin-view (dense + teacher initials overlay).
3. **DataDenseTable** — 44pt rows, sortable caps headers, sticky first column, clamped Dynamic Type. For counselor queue + admin tables.
4. **FeatureFlagToggle** — 3 states (ON, OFF, BLOCKED BY VARUN). On-tap ripple.
5. **ImpersonationBanner** — §7.8.
6. **SiblingSwitcher** — segmented capsule picker with avatar circles + first name — used in parent view.
7. **KidFriendlyButton** — oversized tap target (56pt+), rounded 20pt, emoji slot, used across K-2 quiz + grades + extracurriculars for young students.
8. **ConsentRow** — inline agreement row with checkbox (lime when checked) + inline "read more" chevron that expands the full paragraph underneath.

---

## 9. Output format

Stitch: for each screen listed above, produce:
- `{screen_name}/screen.png` — full screen render at @3x iPhone 15 (393×852) minimum.
- `{screen_name}/code.html` — the HTML/CSS Stitch normally exports.
- A short sidecar `{screen_name}/notes.md` calling out interactive states (pressed, disabled, loading, success, empty, error, locked) and any animation timing.

Group deliverables into 6 Stitch projects matching Clusters A–F.

---

## 10. Do NOT design

Hard stops from `CLAUDE.md` §20 — if any of these sneak into a mock, redo the mock.

- **No teacher login, teacher dashboard, or teacher-facing screen of any kind.** Teachers are data, not users.
- **No counselor/admin view of student grades.** Period.
- **No founder view of student data.** Founders see aggregates, billing, tokens, flags. Never a student name, grade, quiz answer, schedule, AI log, or parent message.
- **No shortcut to the founder backdoor shorter than 30 seconds.** Do not add a "dev tools" link or a URL scheme.
- **No ads, behavioral tracking, third-party analytics on student-facing screens, or data-sale integrations.**
- **No teacher performance rating UI for non-admin roles.** Reviews are admin-exclusive.
- **No design that lets a student retake the career quiz without counselor override.** The locked state in §4.3 is the right behavior.
- **No direct LLM/chat UI that bypasses the "AI is suggester, not decider" contract.** Every AI suggestion that changes state (schedule, class list, grades) needs a human-approve button explicitly shown.

---

## 11. Deliverable priority order

If Stitch needs to sequence the work, do it in this order so engineering can wire screens as they land:

1. **Cluster A §3.1 Landing + §3.2 hold states** — unblocks the first impression.
2. **Cluster A §3.3 School picker + §3.4 School login + §3.5 Invite redemption + §3.8 InviteCodeDisplay** — unblocks the pilot onboarding loop.
3. **Cluster B §4.5 Class suggester + §4.7 Schedule builder + §4.4 Grades self-entry + §4.1 Quiz grade-band picker** — student primary value.
4. **Cluster C §5.1 Counselor home + §5.2 Student queue + §5.4 Scheduling window control + §5.5 Invite codes** — counselor pilot value.
5. **Cluster D §6.1 Admin home + §6.5 Success metrics popup + §6.3 Teacher schedules** — admin completeness.
6. **Cluster E §7.1–7.9 Founder backdoor** — last; infra-gated.
7. **Cluster A §3.6, §3.7, §3.9, §3.10** — signup, COPPA, consents, B2B inquiry. Needed before real users sign up but not blocking design iteration.
8. **Cluster F shared components** — ship alongside whichever cluster first consumes them.

---

## 12. Reference screens Stitch should look at before starting

Open these existing files in a split pane while designing — they are the visual source of truth:

- `/stitch_welcome_to_ladder_splash_screen/welcome_to_ladder_splash_screen/screen.png` — primary brand reference.
- `/stitch_welcome_to_ladder_splash_screen/student_profile_setup_onboarding/screen.png` — form patterns + step dots + primary CTA.
- `/stitch_welcome_to_ladder_splash_screen/career_discovery_quiz_question/screen.png` — radio-pill option pattern + progress bar + skip/continue row.
- `/stitch_welcome_to_ladder_splash_screen/student_home_dashboard/screen.png` — dashboard card stack + circular progress + bottom nav.
- `/stitch_welcome_to_ladder_splash_screen/ai_academic_advisor_chat/screen.png` — chat transcript bubble style.
- `/stitch_utility_bay_skill_arsenal/batcave_dashboard/screen.png` — founder backdoor mood reference (darker, more utilitarian).
- `/stitch_utility_bay_skill_arsenal/utility_bay_&_skill_arsenal/screen.png` — founder tooling layout.

---

End of brief. Questions → Kathan (Director of Technical Foundations).
