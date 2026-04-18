# Ladder — Stitch Prompt for v2 Spec (new screens only)

> **How to use this file.** Paste the sections you need into Stitch. The brand is already locked by the existing 45 screens in `~/Downloads/stitch_welcome_to_ladder_splash_screen/` and `~/Downloads/stitch_utility_bay_skill_arsenal/` — Stitch should match them exactly. This brief only describes the **new screens** the v2 spec adds that are missing from Stitch today. Do NOT redesign the existing screens; keep their colors, type, buttons, cards.

---

## 0 — Who this is for

Ladder is an iPhone-only (iPad deferred) K–8 school-adoption platform. Dual B2B (schools) + B2C (families). First pilot: Lakewood Ranch Preparatory Academy, Florida.

Roles: **students, counselors, school administrators, parents, founders (hidden).**
**Teachers are NOT users** — do not design teacher-facing screens.

Hard design rules (from `CLAUDE.md`, every new screen must respect):
- Grades: **student-self-only.** Never shown to counselor/admin/teacher/founder.
- Founder backdoor: founders see **aggregates only** — no student names, grades, quizzes, schedules, AI logs, or messages.
- Teachers are data, not users.
- Career quiz: once-ever, locked after completion.
- Founder login: reached only by a **30-second press-and-hold on the landing logo.**

---

## 1 — Brand tokens (eyedrop from the existing Stitch screens — do not reinvent)

Match these exactly from `welcome_to_ladder_splash_screen`, `student_home_dashboard`, `student_profile_setup_onboarding`, `career_discovery_quiz_question`:

**Color**
```
--forest-900       #3F5A3A   deepest green (founder dashboard surface)
--forest-700       #527050   primary background (splash, dashboard hero)
--forest-500       #6B8A67   secondary forest
--lime-500         #A8D234   CTA fill, ring fill, active chip dot
--lime-300         #CCE68A   focus glow
--cream-100        #F5F0E5   logo badge, elevated card on dark bg
--paper            #FFFFFF   body cards on light shell
--stone-200        #E8E2D8   muted input fill, inactive chip
--ink-900          #1B1F1B   primary text on light
--ink-600          #4A5346   secondary text
--ink-400          #8A9082   placeholder, tertiary
--status-red       #C94A3F   due-in-N-days, conflict
--status-amber     #D9A54A   warning, Varun-blocked state
```

**Type**
- Display / headline: Playfair Display (serif, 600–700), tight tracking.
- Body / UI: Manrope (sans, 400–600).
- Caps labels: 11pt, +10% tracking, UPPER, weight 600.

**Geometry**
- Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals/sheets.
- Space: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64.
- Shadow (dark bg): 12Y / 24blur / 8% black. Shadow (light bg): 4Y / 12blur / 4% black.

**Components already in Stitch — reuse, don't recreate**
Pill CTA, outlined secondary pill, cream circular logo badge, step-dot progress, circular progress ring, linear progress bar, 5-tab bottom nav, card with right-chevron row, grade-level segmented chip row (filled forest for active), radio-pill option row, "Due in N days" red pill, daily-tip card with location pin, back chevron, skip + continue bottom row.

**Founder backdoor mood** — darker / utilitarian, pull from `batcave_dashboard` and `utility_bay_&_skill_arsenal`. Keep the lime accent, swap background to forest-900 / near-black, use mono-caps labels and console-style status strips.

---

## 2 — What Stitch already covers (do not redesign these)

Every screen in this list exists already. Reuse verbatim, only tweak copy for K–8 context where noted. Never change the look.

| Existing Stitch screen | v2 role |
|---|---|
| `welcome_to_ladder_splash_screen` | Splash tone reference (but see §3.1 — Landing is being redesigned) |
| `student_profile_setup_onboarding` | Reuse for student profile (change grade range to K–8) |
| `career_discovery_quiz_question` | Reuse for all quiz question screens (3 age bands) |
| `student_home_dashboard` | Reuse for student home (swap SAT / volunteer cards for Schedule + Classes + Activities) |
| `ai_academic_advisor_chat` | Reuse as generic help-surface chat |
| `activity_roadmap_checklist_1` / `_2` | Reuse for student tasks |
| `add_custom_reminder_modal` | Generic reminder modal |
| `user_profile_settings` | Settings |
| `connect_messaging` | Counselor↔student messaging |
| `milestone_celebration_modal` | Quiz-complete / schedule-approved celebration |
| `today's_learning_agenda` | Student home variant |
| `batcave_dashboard` | Founder backdoor mood reference (see §7) |
| `utility_bay_&_skill_arsenal` | Founder tooling layout reference |
| `evergreen_ascent` | Progress / gamification moments — reuse if needed |

**Skip entirely** — these are college-admissions-era screens that don't belong in K–8 Ladder. Leave them in your Downloads folder for reference but do not route to them: `admissions_decision_portal`, `application_deadlines_calendar_1/2`, `application_submission_success`, `college_comparison_tool`, `college_discovery_hub`, `college_hub_profile_rit`, `college_impact_report_summary`, `dorm_comparison_tool`, `financial_aid_comparison_tool`, `housing_preference_selection`, `interview_preparation_hub`, `loci_generator_tool`, `match_score_analysis`, `mock_interview_feedback_report`, `pdf_report_export_preview`, `post_application_next_steps_guide`, `roommate_finder_discovery`, `roommate_intro_guide`, `roommate_profile_detail`, `scholarship_search_results`, `score_improvement_recommendations`, `thank_you_note_generator`, `university_enrollment_checklist`, `updated_home_dashboard_applied_status`, `waitlist_management_strategy_guide`, `ai_mock_interview_session`, `social_media_share_preview`.

---

## 3 — NEW screens to design (this is the ask)

Every screen below must match the brand tokens in §1. Deliver each as `{screen_name}/screen.png` + `{screen_name}/code.html` + `{screen_name}/notes.md`. Group the deliverables by the clusters below.

---

### Cluster A — Landing + Auth (11 screens)

#### A1. `landing_v2` — replaces the current splash

Purpose: the only unauthenticated entry point. Three visible affordances + one hidden 30-second trigger.

- Background: forest-700 solid.
- Centered cream circular logo badge (120pt) — SAME badge used on the existing splash.
- Serif display headline below the badge: **"Every kid needs a ladder to success."**
- CTA stack, 16pt gaps:
  1. Primary pill lime fill, dark-green text: **"Log in with your ID"**
  2. Secondary outlined pill (cream outline on green): **"Sign in through your school"**
  3. Two-up row (stone-200 fill, forest-700 text): **"Sign up as a student"** | **"Partner as a school"**
- Footer: the 4 small line icons from the existing splash at 40% opacity.
- **No visible hint** of the hidden founder trigger. The logo badge IS the target.

#### A2. `landing_v2_hold_states` — animation spec sheet

Purpose: one artboard showing the 5 visual states of the logo badge during a press-and-hold. Dev implements the animation from this sheet.

Five frames side-by-side, same badge, different decoration:
- **0s (idle):** cream badge, climber silhouette forest-700, no ring.
- **5s:** climber desaturates ~15%. No ring.
- **15s:** climber fully desaturated. Faint 2pt ring at 5% lime opacity, arcing clockwise from 12 o'clock to ~50%.
- **25s:** ring ~85%, 40% lime opacity, 3pt width.
- **30s:** ring at 100%, bright lime, small 102%→100% scale pulse + inner glow flash.

Caption strip underneath: "0s nothing · 5s desaturate · 15s soft haptic · 25s medium haptic · 30s success haptic → founder login."

#### A3. `school_picker`

Purpose: searchable list of partnered schools.
- White shell. Back chevron + "Your school" title.
- Search bar (stone-200), placeholder "Search your school".
- Result rows (56pt): square tint chip of school primary color · display name · caps slug · chevron.
- Empty state: lime ladder illustration + "Don't see your school? **Partner as a school →**".
- Tap-to-push animation: header bar color transitions from white → school primary color over 300ms ease-out as it pushes §A4.

#### A4. `school_login_themed`

Purpose: per-school login. App rebrands to school color + logo.
- 120pt top hero strip in the school's primary color + 60pt circular logo + serif display school name.
- Body on cream:
  - Section 1 "Sign in" — email · password · primary pill "Sign in".
  - Divider caps label "OR".
  - Section 2 "First time? Join with your invite code" — uppercase-auto input, placeholder "INVITE-CODE", outlined pill "Join with invite code".
- Footer: "Forgot your password?" · "Use a different school" link.

#### A5. `invite_redemption`

Purpose: redeem a one-time code.
- Keeps school color strip from §A4.
- Card: "Code" row showing masked prefix `LDR-X…`, school email input.
- Primary pill "Join" with loading spinner variant.
- Error strip (single uniform message): "We couldn't use that code. Ask your counselor to issue a new one." DO NOT vary copy by reason — backend returns the same code.
- Success: confetti milestone + "Welcome to {School Name}!" + continue.

#### A6. `invite_code_display`

Purpose: shown-once code card. Used by counselor, admin, and student-to-parent flows.
- Status-amber border, soft yellow-tint fill.
- 48pt mono code. Pill "Copy" button with checkmark on-tap.
- Amber helper line: "Shown once. Write it down or paste it now."
- Lime countdown micro-bar along bottom edge (10 seconds) → code blurs 8pt after countdown.
- Extra buttons: "Email this code", "Share via Messages".

#### A7. `b2c_signup_with_coppa_gate`

Purpose: student self-signup (B2C).
- Serif headline "Create your account".
- Fields: email, password (secure, 12+ with strength dots), DOB date wheel.
- **Conditional COPPA inline card** (shows only if calculated age < 13): cream card with lime-left border, grown-up-and-kid icon, copy: "Because you're under 13, a grown-up needs to say it's OK. We'll ask for their email next." DO NOT block signup here — backend enforces consent before quiz/grades writes.
- Agreements: toggle rows "I have read and accept the **Terms**" / "I have read the **Privacy Notice**". Each opens a bottom sheet (see §A9).
- Primary pill "Create account" disabled until all three fields valid and both toggles on.

#### A8. `parental_co_sign_sheet`

Purpose: full-screen sheet shown when an under-13 student opens the quiz or grades the first time; parent must type their own password to unlock.
- Serif headline: **"Grown-up, it's your turn."**
- Body: "Before {FirstName} takes the career quiz, a parent or guardian needs to sign in here. This confirms you agree to let Ladder use {FirstName}'s answers to suggest classes and activities."
- Parent email (pre-filled if linked) · parent password.
- Primary pill "Unlock for my child".
- Footer link: "Not a parent? Close and ask one to help."
- Illustration: adult + child sharing a phone, brand style.

#### A9. `consent_sheets` — 5 variants

Purpose: T&Cs / Privacy / Parental Consent / AI Addendum / DPA — each as a bottom sheet.
Shared pattern:
- Sheet covers 92% of screen. Close-X top-right. Serif headline = doc name.
- **Plain-language summary card at top** (4 bullets, lime left border): "What we collect · What we don't · Who sees what · How to delete."
- Expandable sections below, tap-to-expand inline.
- "Read the full text →" opens the canonical doc in WebView.
- Bottom: primary pill "Continue" (disabled until required checkboxes ticked).

Variants:
- `consent_terms` — one global checkbox.
- `consent_privacy` — one checkbox.
- `consent_parental` — per-section checkboxes (data collection · AI usage · sharing with school · marketing opt-in). Parent signs.
- `consent_ai_addendum` — schools opt-in for AI features that touch student data.
- `consent_dpa_summary` — for school admins at onboarding; plain-language summary + "View full DPA (PDF)".

#### A10. `b2b_inquiry_form`

Purpose: "Partner as a school" inquiry; not self-service.
- Serif headline "Bring Ladder to your school."
- Subcopy "Tell us a bit about your school. We'll reach out within a week."
- Fields (stone-200 fill): School name · Contact name + role dropdown (Principal / Counselor / Administrator / Other) · Contact email · Phone (optional) · State pill picker · Student count stepper · Desired features multi-select chips (Scheduling · Class suggester · Extracurriculars · Career quiz · Parent communication).
- Primary pill "Submit inquiry".
- Post-submit confirmation: cream checkmark badge + "We'll be in touch soon" + "Back to Ladder".

#### A11. `founder_login`

Purpose: hidden founder sign-in. Only reachable via 30s hold.
- Background: forest-900 (near-black).
- Tiny "LADDER · FOUNDER" caps label, stone-200.
- Card centered on dark surface:
  - Founder ID input (mono feel).
  - Password.
  - TOTP code input OR "Use passkey" button.
  - Primary lime pill "Enter".
- Small helper strip: "This surface does not render tenant data. Every action is audited."
- No forgot-password link.

---

### Cluster B — Student (7 screens — NEW, not in existing Stitch)

#### B1. `quiz_grade_band_picker`

Purpose: before first quiz question, student confirms their age band because the quiz UX changes dramatically (K-2 pictures, 3-5 easy words, 6-8 full text).

- Serif headline "Let's find what you love."
- Subcopy "Pick your grade. The quiz changes to match your age."
- Three large stacked cards:
  - "K–2 (pictures)" — picture-book illustration + caps "6 short sittings · grown-up sits with me".
  - "3–5 (easy words)" — simpler text illustration.
  - "6–8 (full quiz)" — notebook illustration.
- Primary pill "Start" lime.

#### B2. `quiz_k2_picture_pair`

Purpose: K-2 variant of the existing `career_discovery_quiz_question`. Two large picture cards instead of text options.

- Forest-700 top strip: back chevron · caps label "Q1 of 3 today".
- Serif display question: "Which do you like more?"
- Two large picture cards (side-by-side or stacked on narrow): illustration + caption ("Making art" · "Building rockets").
- Bottom helper strip: "Grown-up, tap the mic for read-aloud." + audio mic button.
- Progress: **climbing-ladder visualization** instead of a bar — 6 ladder rungs, lime for completed, stone for pending.

#### B3. `quiz_locked`

Purpose: empty state shown when the student returns to the career quiz after completing it.
- Centered illustration: climber at the top of a ladder with a gold star.
- Serif headline "You've already climbed this ladder."
- Body: "The career quiz is a one-time trip. Your results still power your class suggestions and activities. Ask your counselor if you need to take it again."
- Secondary link "How Ladder uses my quiz →".

#### B4. `grades_self_entry`

Purpose: student enters their own grades. Design must loudly reinforce that no one else sees them.
- Serif headline "My grades".
- **Always-visible trust banner** (cream card with lime left border): "Only you see your grades. We use them to suggest next year's classes. [Learn more →]"
- Empty state: notebook + pencil illustration + "Add your first grade to get personalized class suggestions."
- Populated list rows: subject (left) · mono score (middle) · period pill (right). Long-press → delete.
- Bottom floating + button (forest-700) opens the add-grade sheet.
- Add sheet: serif "Add a grade" + subject · score · period segmented pill (Q1/Q2/Q3/Q4/Final) · save pill.

#### B5. `class_suggester_results`

Purpose: AI-suggested class picks with "why this fits" + cited sources.
- Serif headline "Classes that fit you."
- Lime ribbon caps: "AI SUGGESTIONS · REVIEW & CHOOSE".
- Suggestion cards (white on light):
  - Code caps label (e.g., MA-105) + rigor badge right (STANDARD / HONORS / AP).
  - Class title in serif headline/small.
  - 2–3 sentences "Why this fits you" grounded in quiz + grades.
  - Source chip row: "🔗 Florida BOE pathway" · "🔗 U.S. BLS career outlook" (tap opens sheet).
  - Primary pill "Add to my plan" + ghost "Not for me".
- Bottom summary strip: "3 of 5 added · Review my picks →".
- Loading state: skeleton cards + text "Consulting Gemini via Ladder's AI gateway…" with the existing ring pattern.

#### B6. `extracurriculars_ai_session`

Purpose: iterative chat-style AI session. Reuse `ai_academic_advisor_chat` bubble style, but with inline structured SuggestionCards mixed into the transcript.
- Top: back chevron + "Things to try" + right "Resume later" text button.
- Transcript: student lime bubbles right, AI cream bubbles left with Ladder monogram avatar.
- **Inline SuggestionCard (full-width) when AI proposes a real program:** white card · title · fit rationale · clock + $ icon row ("2 hrs/wk · Free") · bold CTA "Here's how to join →".
- Bottom: rounded text composer + mic + lime send button.

#### B7. `schedule_builder` — 3 states in one spec

Purpose: student picks classes during the scheduling window.

State 1 — **quiz-stale empty:** notebook illustration + serif "Take the career quiz first." + body + primary pill "Go to quiz".

State 2 — **window-closed empty:** calendar-with-lock illustration + serif "Scheduling isn't open yet." + body + secondary link "Email my counselor".

State 3 — **active builder:**
- Serif headline "Next year — Fall 2027" + caps subcopy "Ends {date} at {time}".
- 7 period rows (P1–P7), each a large tappable cell. Empty: "— pick a class —" ink-400. Filled: class title + code caps + "change" ghost.
- Tap a period → bottom sheet with AI suggestions (from B5) at top, then full catalog below.
- Bottom bar: "5 of 7" pill + primary pill "Submit for review" (disabled if <7 picks).
- After submit: confetti + status screen with 3-pip progress (DRAFT → SUBMITTED → APPROVED / SENT_BACK).

#### B8. `parent_invite_flow`

Purpose: student invites a parent.
- Serif "Add a grown-up." + body "Your parent or guardian can watch your progress and help with big decisions."
- Parent email · relationship picker (Parent / Guardian / Other).
- Primary "Send invite".
- Post-success: `invite_code_display` card (A6) + ghost "I'll share it with them later".
- Side link "Manage my parents" → list of already-linked parents with "Remove" action.

---

### Cluster C — Counselor (6 screens)

#### C1. `counselor_home`

- Forest-700 hero: caps "COUNSELOR DASHBOARD" + serif "Good morning, {FirstName} 👋" + school chip "LWRPA · K-8".
- Next-up card (white, prominent): "12 schedules waiting for review" + primary pill "Open queue →".
- Quick-actions row (4 cards scrollable): Invite students · Upload class list · Open scheduling window · Messages.
- KPI tiles: Students · Quiz completion · Schedules approved (tiny sparklines each).
- Recent activity list (last 10, metadata only): "Alice submitted her schedule", "Bob redeemed invite", etc.
- Bottom nav: Home / Queue / Classes / Invites / Profile.

#### C2. `counselor_student_queue` + `schedule_review_detail`

Queue (list):
- Sorted by conflict count desc. Row: initials avatar · name · conflict pip (red/green) · time ago.
- Filter chips: All · With conflicts · Approved today.

Detail:
- Student card: avatar · name · grade · "Submitted 2 hrs ago".
- Full-width `ScheduleGrid` (7 × 5). Conflict cells: red border + red-tint fill.
- Issue panel card: cream with checkmark "No conflicts" OR red-left-border list of issues, each with an AI-suggested-fix chip ("Try Biology in P5 (capacity available)").
- Sticky action bar: outlined "Send back" (opens note sheet with AI-drafted text) · outlined "Modify and approve" (second-confirm) · primary pill "Approve" (disabled when issues exist).

#### C3. `counselor_class_list_upload`

- Serif "Upload your class list".
- Method chips: Paste · CSV · XLSX · PDF · Scan photo.
- Active area: paste-textarea OR drag-drop zone (lime dashed border).
- Primary pill "Parse with Gemini".
- Review table: rows with code / title / grade / capacity + inline pencil. Low-confidence rows highlighted red for manual verify.
- Confirm bar: "Confirm and save 42 classes".

#### C4. `counselor_scheduling_window_control`

- Serif "Open scheduling for {academicYear}".
- **Preconditions checklist card** (3 rows with green-check or empty circle): Teacher schedules uploaded · Class catalog uploaded · Prereqs confirmed.
- If any unchecked → Open CTA is disabled with helper "Ask the admin to complete the missing steps first."
- Academic-year text field · Opens-at + Closes-at date pickers side-by-side.
- Primary pill "Open scheduling window". Confirm modal: "{N} students will be able to build schedules starting {date}. Continue?"
- Log of past windows collapsed below.

#### C5. `counselor_invite_codes`

- Mode segmented picker: Single · Bulk · Class-level.
- Options card changes by mode:
  - Single: intended student (optional) + expected grade stepper.
  - Bulk: quantity stepper (1–200) + CSV export after issue.
  - Class-level: grade-level · max uses · window.
- Shared: Allowed email domain (optional) · Expires in N days.
- Primary pill "Generate".
- After: list of `invite_code_display` cards (A6) + bar "Export all" (email / share / CSV).

#### C6. `counselor_messages`

Reuse `connect_messaging` verbatim. Add a "Scheduling note" quick-template chip above the composer.

---

### Cluster D — Admin (6 screens)

Admin is a superset of counselor plus exclusive teacher-data and success-metrics access.

#### D1. `admin_home`

- Forest-700 hero: caps "ADMIN DASHBOARD" + serif "Good morning, {FirstName}" + "LWRPA · K-8" chip.
- **Mandatory banner** (status-amber left border) when success metrics are stale ≥3 months: "It's time to update your school's annual metrics. [Update now →]" → opens D5.
- KPI tiles row: Students · Counselors · Teachers · Active windows.
- Quick actions: Upload teacher schedules · Invite counselor · Open window · View teacher reviews.
- Sections: Teacher data · Classes · Scheduling (each as card + "→ Manage").
- Bottom nav: Home / Teachers / Classes / Invites / Profile.

#### D2. `admin_teacher_profiles` — list + detail

List: search · filter chips (all/active/on leave) · rows with initials avatar + name + subject chips + grade-band chip · bottom + button.

Detail: initials headshot · name · lime "Admin-only" chip · tabs (Profile · Schedule · Reviews) · profile form (name, subject tags, style tags like "Project-based", notes) · save pill.

#### D3. `admin_teacher_schedules`

Reuse C3 upload patterns: CSV/XLSX with columns teacher_id · class_id · period · room. Review table with pencil. After save: confirmation + "You can now open a scheduling window." deep-link.

#### D4. `admin_teacher_reviews`

- Serif "Teacher reviews".
- **Privacy banner** (red left border): "This is admin-only. Counselors, teachers, and founders never see these notes."
- Teacher picker row · period label · body textarea (expandable) · save pill.
- History list below (past reviews as collapsed rows: teacher + period + first line).

#### D5. `admin_success_metrics_popup`

Full-screen sheet, mandatory after ≥3 months stale. Not dismissable except by "Remind me later" (48h delay max).
- Serif "Update your school's metrics."
- Small-caps subcopy "WHY · Founders use these aggregates (never student data) to show impact."
- Period label text field.
- Core rows: College acceptance count stepper · Graduation rate 0–100% slider with mono % badge.
- Custom fields card: admin can add key-value rows (e.g., "SAT median", "AP pass rate").
- Primary pill "Submit" + ghost "Remind me later".

#### D6. `admin_invite_codes`

Reuse C5 verbatim; admin can additionally issue counselor invites.

---

### Cluster E — Founder backdoor (9 screens — darker utilitarian mood)

Use the `batcave_dashboard` / `utility_bay_&_skill_arsenal` aesthetic as the mood reference: dark forest-900 surface, mono-caps labels, console-style status strips, lime accents only.

#### E1. `founder_dashboard_overview`

- Background: forest-900.
- Top caps bar: "FOUNDER · LADDER" + tiny avatar.
- Two big cards (side-by-side wide, stacked narrow):
  - **Schools card** — lime count badge "4 tenants" + "Go to schools →".
  - **Solo People card** — lime count badge "22 families" + "Go to solo →".
- System-wide tiles (this month): AI tokens total · AI cost total · Active windows · New leads.
- Dark-tab bar: Schools · Solo · Flags · Varun. NO tenant-data tabs.

#### E2. `founder_schools_grid`

Grid of school cards (per tenant). **Each card renders ONLY these 7 metrics — never student data:**
1. School name + primary color chip.
2. Student count.
3. Billing balance ($).
4. AI tokens this month.
5. AI cost this month.
6. Success rate % (from D5).
7. Feature-flag summary ("7 on / 2 off") with link.

Sort chips: Newest · Balance desc · Tokens desc · Alert first. Top bar: search + primary CTA "+ Add a new school" → E4.

#### E3. `founder_school_detail`

Per-tenant aggregates + contracts. No student-level widget anywhere.
- Header: school color strip + name.
- Sections: Enrollment + billing · AI usage (tokens + cost + sparkline) · Success metrics (%) · Contracts (DPA / Liability ack / AI Addendum signed checkmark) · Feature flags link (E6) · Audit timeline (metadata only — "Admin opened a scheduling window {ts}", never payload).
- Footer helper: "Founders never see student data. This surface enforces §14.4 at the API, DB, and UI layers."

#### E4. `founder_add_new_school`

Provisioning form.
- Fields: Display name · Slug (auto, editable) · Primary color (hex + swatch preview) · Logo URL upload · Plan picker (Pilot / Standard / Custom) · Seed admin email.
- Primary pill "Provision tenant".
- During provisioning: 4-step stepper — Creating tenant → Generating DEK → Seeding default flags → Emailing admin.

#### E5. `founder_solo_people`

B2C families list. **NEVER names — only family hashes + structure + billing.**
- Rows: "Family #A7C3 · 1 parent · 2 kids · Paid" — family hash mono + counts + billing chip (paid / trial / past_due).
- Filter chips: All · Trial · Past due · New this week.
- Tap row: detail sheet with billing history + same family hash + "Export payment receipts". No names, no child data.

#### E6. `founder_feature_flags_per_tenant`

- Tenant picker at top (pulled from E2).
- Flag rows — each:
  - Mono key label ("feature.scheduling")
  - Description sub-line
  - 3-state toggle: **ON** (lime fill) · **OFF** (stone-200 fill) · **BLOCKED BY VARUN** (amber border + inline panel showing the violated rule + "Apply fix" button).
- Save pill at bottom, disabled if any blocked state remains.

#### E7. `founder_varun_panel`

- Serif "Varun".
- Small-caps subcopy: "Feature dependency validator · Not an AI · Does not read student data."
- 10 rule rows, caps label + rule text; tap-to-expand with example violation.
- Bottom card "Ask Varun": input "Why can't I turn off {flag_key}?" → text area returns trace chain.

#### E8. `founder_impersonation_banner`

Red full-width bar (above safe area) for when an admin-initiated impersonation grant is active.
- Left: warning triangle + "Impersonation active" title + grantReason subtext.
- Right: mono countdown `MM:SS` + "Audit" ghost pill → opens full impersonation audit detail.

#### E9. `founder_blocked_from_tenant_data`

Shown if a founder session somehow reaches a tenant-data view. The guard that renders in its place.
- Background: forest-900.
- Centered: lock+shield icon in lime.
- Serif "Not available for founder sessions."
- Sub: "§14.4 — founder sessions are denied tenant data at the API, DB, and UI layers."
- Link: "View audit trail" → opens the attempted route's audit entry.

---

### Cluster F — New shared components (8)

Each as a small component sheet with all states (default · pressed · disabled · loading · success · error · empty · locked).

1. **InviteCodeDisplay** — §A6.
2. **ScheduleGrid** — 7×5 cells, 3 density variants: student-builder (roomy) · counselor-review (dense + conflict overlay) · admin-view (dense + teacher initials overlay).
3. **DataDenseTable** — 44pt rows · sortable caps headers · sticky first column · Dynamic Type clamped to xxxLarge.
4. **FeatureFlagToggle** — ON / OFF / BLOCKED-BY-VARUN states.
5. **ImpersonationBanner** — §E8.
6. **SiblingSwitcher** — segmented capsule picker with avatar circles + first names (used in parent view).
7. **KidFriendlyButton** — 56pt+ tap target · 20pt radius · emoji slot · for K-2 quiz / grades / activities.
8. **ConsentRow** — inline agreement row with checkbox (lime when checked) + "read more" chevron expanding the paragraph below.

---

## 4 — Do NOT design (hard stops from `CLAUDE.md` §20)

If any of these sneak into a mock, please redo it:

- No teacher login, dashboard, or teacher-facing screen of any kind.
- No counselor/admin/teacher/founder view of student grades.
- No founder view of student data (names, grades, quizzes, schedules, AI logs, messages).
- No shortcut to the founder backdoor shorter than 30 seconds — no "dev tools" link, no URL scheme.
- No ads, behavioral tracking, third-party analytics on student-facing screens, or data-sale integrations.
- No teacher performance rating UI for non-admin roles.
- No design that lets a student retake the career quiz without counselor override.
- No direct LLM chat UI that bypasses "AI is suggester, not decider" — every AI suggestion that changes state (schedule, class list, grades) must have an explicit human approve step visible.

---

## 5 — Deliver in this priority order (so engineering can wire as designs arrive)

1. **A1 Landing + A2 Hold states** — unblocks first impression.
2. **A3 School picker · A4 School login · A5 Invite redemption · A6 InviteCodeDisplay** — unblocks the pilot onboarding loop.
3. **B5 Class suggester · B7 Schedule builder · B4 Grades self-entry · B1 Grade-band picker** — student primary value.
4. **C1 Counselor home · C2 Student queue · C4 Scheduling window · C5 Invite codes** — counselor pilot value.
5. **D1 Admin home · D5 Success metrics · D3 Teacher schedules** — admin completeness.
6. **E1–E9 Founder backdoor** — last; infra-gated.
7. **A7 Signup · A8 Parental co-sign · A9 Consent sheets · A10 B2B inquiry** — real users sign up here but not blocking design iteration.
8. **F shared components** — ship alongside whichever cluster first consumes them.

---

## 6 — Reference screens (open these in a split pane while designing)

- `/stitch_welcome_to_ladder_splash_screen/welcome_to_ladder_splash_screen/screen.png` — primary brand reference.
- `/stitch_welcome_to_ladder_splash_screen/student_profile_setup_onboarding/screen.png` — form patterns + step dots + CTA.
- `/stitch_welcome_to_ladder_splash_screen/career_discovery_quiz_question/screen.png` — radio-pill option + progress + skip/continue row.
- `/stitch_welcome_to_ladder_splash_screen/student_home_dashboard/screen.png` — dashboard card stack + circular progress + bottom nav.
- `/stitch_welcome_to_ladder_splash_screen/ai_academic_advisor_chat/screen.png` — chat bubbles.
- `/stitch_utility_bay_skill_arsenal/batcave_dashboard/screen.png` — founder backdoor mood.
- `/stitch_utility_bay_skill_arsenal/utility_bay_&_skill_arsenal/screen.png` — founder tooling layout.

End of brief.
