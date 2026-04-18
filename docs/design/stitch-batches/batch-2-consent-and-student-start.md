# Ladder Stitch — Batch 2 of 6: Consent sheets + student start (10 screens)

Paste this whole file into Stitch as one brief.

---

## Brand tokens (match exactly)

forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · status-red `#C94A3F` · status-amber `#D9A54A`.
Playfair Display serif (600–700) display/headline. Manrope sans (400–600) body/UI. Caps labels 11pt +10% tracking UPPER.
Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals. Space: 4/8/12/16/24/32/48/64.

## Do NOT design

No teacher UI. No grades for non-student. No founder view of student data. No backdoor shortcut <30s. No ads on student screens. Every AI state-changing suggestion needs visible human approve.

## Reference

`welcome_to_ladder_splash_screen` · `career_discovery_quiz_question` · `student_profile_setup_onboarding` · `student_home_dashboard`.

---

# Screens (10)

## 1. `consent_terms` — Terms of Service bottom sheet

- Sheet covers 92% of screen. Close-X top-right. Serif display headline: **"Terms of Service"**.
- **Plain-language summary card** at the top (lime 4pt left border on cream): four bullets, each 1–2 sentences:
  - "What we collect"
  - "What we don't"
  - "Who sees what"
  - "How to delete your data"
- Expandable sections below (tap-to-expand inline, not modal): "Acceptable use" · "Your rights" · "Data retention" · "Disputes + jurisdiction". Each row has a right chevron that rotates to ˅ when open.
- One checkbox row at the bottom: "I have read and accept the Terms."
- "Read the full legal text →" link that opens the canonical doc in a WebView.
- Primary pill "Continue" (disabled until checkbox is on). Full-width, 56pt tall.

## 2. `consent_privacy` — Privacy Notice bottom sheet

Same pattern as `consent_terms`. Summary card bullets:
- "Student data is encrypted with a key unique to your school"
- "We never sell or advertise on your kid's screen"
- "Gemini sees only what's needed, and only for this session"
- "Delete any time from Settings → Privacy"

Expandable sections: "What we collect and why" · "How AI uses your data" · "Sharing with your school" · "Your rights under FERPA/COPPA" · "How to delete".

Single checkbox: "I have read the Privacy Notice." Primary pill "Continue" disabled until ticked.

## 3. `consent_parental` — Parental Consent sheet

For parents of students under 13. Required before quiz / grades write.

- Serif headline "Parental Consent".
- Summary card: "We're asking you to consent because your child is under 13. You can undo this at any time."
- **Per-section checkboxes** (not a single global one). Each section has its own expandable row + a checkbox on the right edge:
  - "Data collection (required)" — name, DOB, grade, self-entered grades, quiz answers.
  - "AI usage (required for AI features)" — Gemini-powered class suggestions + extracurriculars.
  - "Sharing with your school (required for B2B students)" — schedule + class picks only.
  - "Marketing communications (optional)" — monthly progress emails.
- Primary pill "Sign consent" disabled until all required boxes are ticked.
- At the bottom of the sheet, dwell-time helper in caps ink-400: "READ TIME: 00:00" (tracks how long the sheet has been open for audit purposes).

## 4. `consent_ai_addendum` — school AI features opt-in

Shown once to an admin when they first enable AI features.

- Serif headline "AI Features Addendum".
- Body: "Ladder uses Google Gemini to power career quizzes, class suggestions, and extracurricular recommendations. This addendum covers how student data flows through that integration."
- Expandable sections: "What Gemini sees" · "What Gemini does NOT see" · "Retention" · "Opt-out per student".
- Toggle: "Enable AI features for {SchoolName}" (lime when on).
- Primary pill "Agree and enable" disabled until toggle is on.
- Secondary ghost "Don't enable AI features" at the bottom.

## 5. `consent_dpa_summary` — Data Processing Agreement summary

Shown to school admins at provisioning.

- Serif headline "Data Processing Agreement".
- Summary card: "You (the school) are the data controller. Ladder is the processor. If a student brings a claim, the school is the responsible party under FERPA."
- Expandable sections: "Data categories processed" · "Sub-processors (Supabase, AWS KMS, Google Gemini)" · "Security measures" · "Breach notification (72 hours)" · "Term + termination".
- Two CTAs at the bottom:
  - Primary pill "View full DPA (PDF)"
  - Outlined pill "Email this to our legal team"
- Tiny helper "Signed copy will be emailed to the seed admin and archived in your school's compliance folder."

## 6. `quiz_grade_band_picker` — student picks age band before quiz

Reached before the first quiz question, auto-detected from DOB and confirmed.

- Serif headline "Let's find what you love."
- Subcopy ink-600: "Pick your grade. The quiz changes to match your age."
- Three big stacked cards, 16pt gaps. Each card: illustration left + label + caps sub-helper:
  - "K–2 (pictures)" — picture-book illustration + "6 short sittings · grown-up sits with me".
  - "3–5 (easy words)" — simpler text illustration + "5 quick rounds".
  - "6–8 (full quiz)" — notebook illustration + "One sitting, about 15 minutes".
- Primary pill "Start" (lime) at bottom, disabled until a card is selected.
- Selected card state: lime 3pt outer stroke + lime fill dot in top-right corner.

## 7. `quiz_k2_picture_pair` — K-2 picture-based question

Two-up picture cards, "Which do you like more?"

- Forest-700 top strip: back chevron · caps label "Q1 OF 3 TODAY".
- Serif display question centered: "Which do you like more?"
- Two large picture cards (stacked vertically on phone), full-width, 160pt tall each:
  - Card 1: illustration of a paintbrush + caption "Making art" + audio mic icon (tap for read-aloud).
  - Card 2: illustration of a rocket + caption "Building rockets" + audio mic icon.
- Tap a card → card scales 102%→100% + lime border fades in.
- Bottom helper strip ink-600: "Grown-up, tap the mic if you'd like me to read aloud."
- Progress: **climbing-ladder visualization** at the very bottom — 6 rungs, lime for completed, stone-200 for pending. Replace the existing linear bar for the K-2 variant.
- Continue pill bottom-right (lime, forest text).

## 8. `quiz_locked` — quiz-once-ever empty state

Shown when a student who has already completed the quiz revisits the screen.

- Paper background.
- Centered illustration (240pt tall): climber standing at the top of a ladder, a gold star above them.
- Serif display headline: **"You've already climbed this ladder."**
- Body copy ink-600: "The career quiz is a one-time trip. Your results still power your class suggestions and activities. Ask your counselor if you need to take it again."
- Secondary ghost link "How Ladder uses my quiz →" opens an info sheet.
- No primary CTA. Footer: the student's existing bottom nav.

## 9. `grades_self_entry` — student-only grades

Design must loudly reinforce that no one else sees these.

- Serif headline "My grades".
- **Always-visible trust banner** at the top: cream card with lime 4pt left border. Copy: "Only you see your grades. We use them to suggest next year's classes. [Learn more →]"
- Two artboards to deliver:
  - **Empty state:** notebook + pencil illustration + "Add your first grade to get personalized class suggestions." + lime pill "+ Add a grade".
  - **Populated state:** list rows — subject name (left) · mono score center · period pill right (Q1/Q2/Q3/Q4/Final). Long-press on a row reveals a delete action.
- Bottom floating + button (56pt, forest-700 fill, lime plus glyph) opens the add-grade sheet.
- Do NOT show any teacher / counselor / admin view. This is a student-only screen; no role picker.

## 10. `grades_self_entry_add_sheet` — add-grade bottom sheet

Opens from the + button on `grades_self_entry`.

- Bottom sheet, 50% screen height. 24pt corner radius. Handle bar at top.
- Serif display "Add a grade".
- Fields:
  - Subject — text field, stone-200 fill, placeholder "e.g., Math".
  - Score — text field, placeholder "e.g., A, 92, Pass".
  - Period — segmented chip row (5 chips): Q1 · Q2 · Q3 · Q4 · Final. Selected chip: filled forest-700, white text.
- Primary pill "Save" (lime fill, full width, 56pt tall).
- Secondary ghost "Cancel" as an X in the top-right.
- States: default, invalid (red helper under the offending field), saving (pill spinner), success (pill shows checkmark for 300ms then sheet dismisses).

---

Deliver `{screen_name}/screen.png` + `{screen_name}/code.html` + `{screen_name}/notes.md` for each.
