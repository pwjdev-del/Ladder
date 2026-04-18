# Ladder Stitch — Batch 4 of 6: Admin + Founder backdoor start (10 screens)

Paste this whole file into Stitch as one brief.

---

## Brand tokens

forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · status-red `#C94A3F` · status-amber `#D9A54A`.
Playfair Display serif (600–700) headline. Manrope sans (400–600) body. Caps 11pt +10% tracking UPPER.
Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals.

**Founder backdoor mood:** darker forest-900 surface, lime accent only, mono-caps labels, console-style status strips. Pull tone from `batcave_dashboard` + `utility_bay_&_skill_arsenal`. No cream badge, no playful illustrations — utilitarian.

## Do NOT design

No teacher UI. No counselor/admin/teacher/founder view of student grades. No founder view of student names / grades / quizzes / schedules / AI logs / messages. Every founder screen renders ONLY aggregates (counts, balances, token usage, success-rate %).

## Reference

Admin: `student_home_dashboard` structure · `student_profile_setup_onboarding` form patterns.
Founder: `batcave_dashboard`, `utility_bay_&_skill_arsenal`.

---

# Screens (10)

## 1. `admin_home` — admin dashboard landing

- Forest-700 hero strip (top 220pt): caps "ADMIN DASHBOARD" · serif display "Good morning, {FirstName}" · school chip pill "LWRPA · K-8".
- **Mandatory metrics banner** (conditional, shows only when success metrics are stale ≥ 3 months): status-amber 4pt left border on cream card. Copy: "It's time to update your school's annual metrics." + inline CTA chip "Update now →".
- KPI tiles row (4 equal-width tiles, 88pt tall): Students · Counselors · Teachers · Active windows. Each tile shows a big number + tiny caps label.
- Quick actions row (scrollable cards): "Upload teacher schedules" · "Invite counselor" · "Open scheduling window" · "View teacher reviews".
- Below: three big section cards — Teacher data (count + "→ Manage") · Classes (count + "→ Manage") · Scheduling (state + "→ Open window").
- Bottom nav: Home / Teachers / Classes / Invites / Profile.

## 2. `admin_teacher_profiles_list` — teachers list

Admin-only. Teachers are data, not users. No login button, no student-facing copy.

- Top bar: back chevron · "Teachers" title · search icon right.
- Search bar below: stone-200 fill, placeholder "Search teachers by name or subject".
- Filter chip row: All · Active · On leave.
- List rows (64pt): initials circle avatar · teacher name serif small · caps subtitle "SUBJECT TAGS" · grade-band chip (e.g., "K–2", "3–5", "6–8") · chevron.
- Bottom floating + button (forest-700 fill) opens add-teacher flow.
- Empty state: book-and-apple illustration + "Add your first teacher to enable scheduling."

## 3. `admin_teacher_profile_detail` — single teacher detail

- Top: large initials circle (96pt) + teacher name serif display/small + lime "ADMIN-ONLY" chip.
- Tab bar under header: Profile · Schedule · Reviews. Active tab has a lime 3pt bottom underline.
- **Profile tab** (default):
  - Fields: First name · Last name · Subject tags (multi-select chip picker) · Teaching style tags (e.g., "Project-based", "Direct instruction") · Notes (textarea).
  - Save pill bottom sticky.
- **Schedule tab:** read-only summary of the teacher's current period assignments (link opens the upload screen).
- **Reviews tab:** routes to `admin_teacher_reviews` (screen 5 below).

## 4. `admin_teacher_schedules_upload` — bulk upload teacher×class×period×room

Structural reuse of `counselor_class_list_upload` from Batch 3.

- Serif "Upload teacher schedules".
- Method chip row: Paste · CSV · XLSX.
- Expected columns caps helper: "TEACHER ID · CLASS ID · PERIOD · ROOM".
- Primary pill "Parse with Gemini".
- Review table (second artboard): columns teacher · class · period chip · room · edit. Save pill at bottom.
- Post-save confirmation card: "You can now open a scheduling window" + deep-link chip to `counselor_scheduling_window_control`.

## 5. `admin_teacher_reviews` — admin-exclusive teacher reviews

- Serif headline "Teacher reviews".
- **Privacy banner** — red 4pt left border on cream card. Copy: "This is admin-only. Counselors, teachers, and founders never see these notes."
- Teacher picker row (tap opens a bottom sheet with search + teacher list).
- Period label text field (e.g., "2025–2026 mid-year").
- Body textarea (expandable, ink-900 text on stone-200 fill).
- Save pill bottom sticky.
- History list below: past reviews as collapsed rows — teacher name · period · first line preview · chevron to expand.

## 6. `admin_success_metrics_popup` — mandatory periodic update

Full-screen sheet. Not dismissible except by a "Remind me later" bottom link (48h delay max).

- Serif display "Update your school's metrics."
- Small-caps subcopy: "WHY · Founders use these aggregates (never student data) to show impact to stakeholders."
- Period label text field (e.g., "2025–2026 annual").
- Core metric rows:
  - "College acceptance count" stepper (0–5000).
  - "Graduation rate" slider 0–100% with mono % badge right.
- Custom fields card: admin can add key-value rows (e.g., "SAT median" → "1280"; "AP pass rate" → "78%"). "+ Add custom metric" ghost link.
- Primary pill "Submit" full-width.
- Bottom ghost link: "Remind me later" (disabled if this has already been delayed once in the past 48h).

## 7. `founder_dashboard_overview` — post-login founder landing

Enter the backdoor. Darker utilitarian mood.

- Background: forest-900. All text cream or stone-200.
- Top caps bar: "FOUNDER · LADDER" left · tiny circular avatar right.
- Two big cards side-by-side on wide, stacked on phone. Card fill: forest-700. Card radius 16pt.
  - **Schools card**: lime count badge "4 TENANTS" + serif headline "Schools" + right chevron "Go to schools →".
  - **Solo People card**: lime count badge "22 FAMILIES" + serif "Solo people" + chevron "Go to solo →".
- System-wide tiles row underneath (4 tiles, equal width, 96pt tall, forest-700 fill):
  - "AI tokens this month" + big lime number
  - "AI cost this month" + big lime dollar number
  - "Active windows" + big number
  - "New leads" + big number
- Dark tab bar at bottom: Schools · Solo · Flags · Varun. Active tab: lime label + 3pt underline. NO tenant-data tabs.

## 8. `founder_schools_grid` — grid of school cards

Each card renders ONLY these 7 metrics. **Never student data. Never student names.**

- Top bar on forest-900: "Schools" title caps + search magnifier icon + primary pill "+ Add a new school" right.
- Sort chips row: Newest · Balance desc · Tokens desc · Alert first. Selected chip: lime fill, forest-900 text.
- Grid of cards, 2-up on wide, 1-up on phone. Card fill: forest-700, 16pt radius, 16pt padding. Per card:
  1. School name (serif headline/small) + small color chip left of the name showing the school's primary color.
  2. Row: "Students" label + count mono.
  3. Row: "Balance" label + $ mono.
  4. Row: "AI tokens (30d)" label + count mono.
  5. Row: "AI cost (30d)" label + $ mono.
  6. Row: "Success rate" label + % mono.
  7. Footer: "Flags 7 on / 2 off →" link.
- Card hover/press: subtle lime 1pt border glow.

## 9. `founder_school_detail` — per-tenant aggregates

Click a card from the grid → detail with aggregates + contracts. NO student-level widget anywhere.

- Header strip using the school's primary color (120pt tall) + 60pt circular school logo + serif school name.
- Scrollable body on forest-900 background, sections stacked with 24pt gaps:
  - **Enrollment + billing** — two rows (Students count, Balance $).
  - **AI usage** — tokens this month, cost this month, small sparkline (last 30 days).
  - **Success metrics** — big % + link "View history".
  - **Contracts** — three rows with checkmark icons: DPA signed · Liability ack signed · AI Addendum signed.
  - **Feature flags** — summary "7 on / 2 off" + "Manage →" link (routes to Batch 5's flags editor).
  - **Audit timeline** — metadata only: "Admin opened a scheduling window {ts}", "Counselor issued 12 invites {ts}". Never payload.
- Footer helper caps, stone-200: "FOUNDERS NEVER SEE STUDENT DATA. THIS SURFACE ENFORCES §14.4 AT THE API, DB, AND UI LAYERS."

## 10. `founder_add_new_school` — provisioning form

Modal sheet on forest-900 background. 24pt radius. Handle bar at top.

- Serif display "New school".
- Fields stacked (stone-200 fills with ink-900 text; on dark bg, card is lightened forest-700):
  - "Display name" text.
  - "Slug" text — auto-derived from display name, editable.
  - "Primary color" row: hex input left + live swatch preview right (48×48 square rounded 8pt).
  - "Logo" upload row: file picker chip + "Upload" button.
  - "Plan" picker: Pilot · Standard · Custom (segmented chips).
  - "Seed admin email" text.
- Primary pill lime "Provision tenant" full-width.
- After-submit state (second artboard): 4-step progress stepper on the same sheet:
  1. Creating tenant…
  2. Generating DEK…
  3. Seeding default flags…
  4. Emailing admin…
  Each step has a spinner → checkmark transition.
- On success: checkmark burst + "Provisioned. Seed admin email sent to {email}." + ghost "Back to schools".

---

Deliver `{screen_name}/screen.png` + `{screen_name}/code.html` + `{screen_name}/notes.md` for each.
