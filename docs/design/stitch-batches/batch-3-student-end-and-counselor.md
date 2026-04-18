# Ladder Stitch — Batch 3 of 6: Student finish + Counselor (10 screens)

Paste this whole file into Stitch as one brief.

---

## Brand tokens

forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · status-red `#C94A3F` · status-amber `#D9A54A`.
Playfair Display serif (600–700) headline. Manrope sans (400–600) body. Caps 11pt +10% tracking UPPER.
Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals.

## Do NOT design

No teacher UI. No grades for non-student. No founder view of student data. No backdoor shortcut <30s. No ads on student screens. Every AI state-changing suggestion needs visible human approve.

## Reference

`student_home_dashboard` · `ai_academic_advisor_chat` · `career_discovery_quiz_question` · `activity_roadmap_checklist_1`/`_2`.

---

# Screens (10)

## 1. `class_suggester_results` — AI-suggested next-year classes

For the student after they complete quiz + grades.

- Serif headline "Classes that fit you."
- Under the headline: lime ribbon caps "AI SUGGESTIONS · REVIEW & CHOOSE".
- List of suggestion cards (white, 12pt radius, 16pt padding). Each card:
  - Top row: code caps label (e.g., "MA-105") left · rigor badge right (STANDARD / HONORS / AP — lime/amber/red tinted respectively).
  - Serif headline/small class title (e.g., "Algebra Foundations").
  - 2–3 sentence body "Why this fits you" grounded in the student's quiz + grades.
  - Source chip row (tap opens bottom sheet with full citation): "🔗 Florida BOE pathway" · "🔗 U.S. BLS career outlook".
  - Footer row: primary pill "Add to my plan" + ghost text button "Not for me".
- Sticky bottom strip: "3 of 5 added · Review my picks →" (lime fill bar, forest-700 text).
- Loading state (first artboard): skeleton cards + caps helper "CONSULTING GEMINI VIA LADDER'S AI GATEWAY…" using the existing ring pattern from the splash.

## 2. `extracurriculars_ai_session` — iterative chat + inline suggestion cards

Reuses `ai_academic_advisor_chat` bubble style but mixes inline structured cards into the transcript.

- Top bar: back chevron + serif small headline "Things to try" + right text button "Resume later".
- Transcript area:
  - Student bubbles: lime pill fill, dark-green text, right-aligned, 70% max width.
  - AI bubbles: cream pill fill, ink-900 text, left-aligned with a small Ladder monogram avatar.
  - **Inline SuggestionCard** (full-width, appears when AI proposes a concrete program): white card, 12pt radius.
    - Title serif headline/small.
    - Fit rationale body (2–3 sentences).
    - Row of meta icons: clock `2 hrs/wk` · dollar-sign `Free` · map-pin `at your school`.
    - Bold CTA "Here's how to join →" opens a bottom sheet with step-by-step.
- Bottom composer: rounded text field + mic icon + lime send button (paper-plane glyph).
- States: default, AI thinking (3 lime dots animating in the cream bubble), error ("Ladder's AI hit a snag. Try again in a moment.").

## 3. `schedule_builder` — 3 states in one artboard spec

Student's screen for picking next year's classes during the scheduling window. Deliver **3 artboards**:

**State 1 — quiz-stale empty:**
- Illustration: notebook + pencil.
- Serif display "Take the career quiz first."
- Body: "Your quiz needs to be from this school year before you can plan classes."
- Primary pill "Go to quiz" routes to the career quiz flow.

**State 2 — window-closed empty:**
- Illustration: calendar with a lock overlay.
- Serif "Scheduling isn't open yet."
- Body: "Your counselor opens scheduling when it's time to plan."
- Secondary ghost "Email my counselor" (if messaging is enabled).

**State 3 — active builder:**
- Top: serif headline "Next year — Fall 2027" + caps sub "ENDS {date} at {time}".
- 7 stacked period rows (P1–P7). Each row, 64pt tall, card-style with left period label caps. Cell states:
  - Empty: "— pick a class —" in ink-400, tap opens the pick sheet.
  - Filled: class title + code caps · right: ghost "change".
- Tap a period opens a bottom sheet with AI suggestions at top + full catalog below.
- Bottom bar sticky: "5 of 7" pill · primary pill "Submit for review" disabled if <7 picks.
- After submit (fourth mini artboard): confetti + 3-pip status (DRAFT · SUBMITTED · APPROVED/SENT_BACK) with the current state highlighted lime.

## 4. `parent_invite_flow` — student invites a parent

- Serif headline "Add a grown-up."
- Body ink-600: "Your parent or guardian can watch your progress and help with big decisions."
- Parent email field + relationship picker (Parent / Guardian / Other) — segmented chips.
- Primary pill "Send invite".
- Post-success state (second artboard): `invite_code_display` card above + ghost "I'll share it with them later" below. Keep the 10s countdown + copy pattern (see Batch 1 screen 6).
- Side link "Manage my parents" routes to a list of already-linked parents with a "Remove" swipe action.

## 5. `counselor_home` — counselor dashboard landing

- Forest-700 hero strip (top 220pt): caps "COUNSELOR DASHBOARD" · serif display "Good morning, {FirstName} 👋" · school chip pill "LWRPA · K-8".
- Next-up card on cream: "12 schedules waiting for review" in serif headline/small + primary pill "Open queue →" right-aligned.
- Quick actions scroll row (4 cards, 120pt wide each, 88pt tall, horizontally scrollable):
  - "Invite students" · "Upload class list" · "Open scheduling window" · "Messages".
- Caseload KPI tiles row (3 tiles equal width): Students count · Quiz completion % · Schedules approved — each with a tiny sparkline.
- Recent activity list (last 10 rows, metadata only — "Alice submitted her schedule", "Bob redeemed invite", etc.): left date stamp · middle activity text · right chevron.
- Bottom nav: Home / Queue / Classes / Invites / Profile. Icon + label, forest-700 for active, ink-400 for inactive.

## 6. `counselor_student_queue_list` — approval queue

The left half of a split-view on iPad; on iPhone this is a full-screen list that pushes to the review detail.

- Top bar: back chevron + "Queue" title + filter chip row directly below: All · With conflicts · Approved today.
- List rows (64pt tall): initials avatar (left) · student display name + caps subtitle "GRADE 5" · red or green pip dot (right of name if conflicts) · time ago ("2h ago") · chevron.
- Sorted conflict count desc by default.
- Empty state: confetti illustration + serif "Queue is clear. Nice work."

## 7. `counselor_schedule_review_detail` — review + approve

Pushed from the queue list.

- Top: small student card — initials avatar · name · caps "GRADE 5 · LWRPA" · "Submitted 2 hrs ago".
- **Full-width `ScheduleGrid`** (7 periods × 5 days) using the shared component. Conflicting cells have red 2pt border + red-tinted fill. Tap a cell to see the conflict detail below.
- Issue panel card:
  - If no issues: cream card + green checkmark + "No conflicts, prerequisite issues, or capacity problems."
  - If issues: red 4pt left-border card. List each issue ("P3 conflict: Algebra 2 and Biology both in period 3") + an AI-suggested fix chip underneath ("Try Biology in P5 (capacity available)"). Tapping the chip previews the change.
- Sticky action bar at bottom, 72pt tall:
  - Outlined secondary "Send back" (opens a note sheet with AI-drafted text).
  - Outlined "Modify and approve" (requires a second confirm modal because it's audited).
  - Primary pill "Approve" — disabled while issues exist.

## 8. `counselor_class_list_upload` — AI parse + review

- Serif headline "Upload your class list".
- Method chip row (horizontally scrollable): Paste · CSV · XLSX · PDF · Scan photo.
- Active-method area:
  - Paste: large text area, stone-200 fill, 280pt tall, placeholder "Paste rows here — we'll parse them with Gemini".
  - Upload: lime 2pt dashed drag-drop zone + file icon.
- Primary pill "Parse with Gemini" (routes through the AI gateway).
- After parse (second artboard): review table with 5 columns — code · title · grade · capacity · edit pencil. Rows where AI confidence was low are highlighted red-tint for manual verify.
- Confirm bar sticky: lime pill "Confirm and save 42 classes" + ghost "Back to upload".

## 9. `counselor_scheduling_window_control` — open / close the window

- Serif headline "Open scheduling for {academicYear}".
- **Preconditions checklist card** (cream, 16pt padding). Three rows, each with either green check or empty circle left of the label:
  - "Teacher schedules uploaded" (admin-only; if missing, row says "Ask your admin →" link).
  - "Class catalog uploaded".
  - "Prereqs confirmed".
- If any box is unchecked, the "Open scheduling window" CTA is disabled with a red helper underneath: "Complete the steps above to open scheduling."
- Academic year text input.
- Opens-at + Closes-at date pickers side-by-side.
- Primary pill "Open scheduling window" full-width.
- On tap, confirm modal: "{N} students will be able to build schedules starting {date}. Continue?" with Cancel + Confirm (lime) buttons.
- Below the controls, a collapsed list "Past windows" that can be expanded.

## 10. `counselor_invite_codes` — generate student invites

- Mode segmented picker top (full width): Single · Bulk · Class-level.
- Options card changes by mode:
  - Single: optional student name + email · expected grade stepper.
  - Bulk: quantity stepper (1–200) · post-issue CSV download toggle.
  - Class-level: grade-level picker · max uses stepper · window date range.
- Shared fields below the mode-specific card: "Allowed email domain (optional)" (e.g., `lwrpa.org`) · "Expires in N days" stepper.
- Primary pill "Generate" full-width.
- Post-issue artboard (state 2): list of `invite_code_display` cards (Batch 1 screen 6 component) + bottom bar "Export all (Email · Share · CSV)".

---

Deliver `{screen_name}/screen.png` + `{screen_name}/code.html` + `{screen_name}/notes.md`. For screen 3 deliver 4 sub-artboards (quiz-stale, window-closed, active builder, submitted status).
