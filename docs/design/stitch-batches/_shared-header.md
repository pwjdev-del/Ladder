# Ladder Stitch brief — shared header (do not paste this alone)

Every batch file in this folder begins with the same short header block describing brand + hard rules + references. Stitch sees the same brand context on every paste.

---

## Brand tokens (match these exactly — eyedrop from existing Stitch screens)

**Colors**
- `forest-900` `#3F5A3A` — founder dashboard surface, deepest green
- `forest-700` `#527050` — primary background, splash + dashboard hero
- `forest-500` `#6B8A67` — secondary forest
- `lime-500`   `#A8D234` — CTA fill, ring fill, active chip dot
- `lime-300`   `#CCE68A` — focus glow
- `cream-100`  `#F5F0E5` — logo badge, elevated card on dark bg
- `paper`      `#FFFFFF` — body cards on light shell
- `stone-200`  `#E8E2D8` — muted input fill, inactive chip
- `ink-900`    `#1B1F1B` — primary text on light
- `ink-600`    `#4A5346` — secondary text
- `ink-400`    `#8A9082` — placeholder / tertiary
- `status-red`   `#C94A3F` — due-in-N-days, conflict
- `status-amber` `#D9A54A` — warning, Varun-blocked

**Type**
- Display / headline: **Playfair Display**, weight 600–700, tight tracking.
- Body / UI: **Manrope**, weight 400–600.
- Caps labels: 11pt, +10% tracking, UPPER, weight 600.

**Geometry**
- Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals/sheets.
- Space scale: 4 / 8 / 12 / 16 / 24 / 32 / 48 / 64.
- Shadow (dark bg): 12Y / 24blur / 8% black. Shadow (light bg): 4Y / 12blur / 4% black.

**Reuse these components from existing Stitch** — do not recreate:
Pill CTA, outlined secondary pill, cream circular logo badge, step-dot progress, circular progress ring, linear progress bar, 5-tab bottom nav, card-with-right-chevron row, segmented chip row (filled forest for active), radio-pill option row (lime dot when selected), "Due in N days" red pill, daily-tip card, back chevron, skip+continue bottom row.

**Founder backdoor mood:** darker forest-900 surface with lime accents only. Pull tone from `batcave_dashboard` and `utility_bay_&_skill_arsenal` — mono-caps labels, console-style status strips.

---

## Reference screens to eyedrop while designing (open in split pane)

- `~/Downloads/stitch_welcome_to_ladder_splash_screen/welcome_to_ladder_splash_screen/screen.png` — brand primary.
- `~/Downloads/stitch_welcome_to_ladder_splash_screen/student_home_dashboard/screen.png` — dashboard pattern.
- `~/Downloads/stitch_welcome_to_ladder_splash_screen/career_discovery_quiz_question/screen.png` — option pills, progress, skip+continue.
- `~/Downloads/stitch_welcome_to_ladder_splash_screen/student_profile_setup_onboarding/screen.png` — forms, step dots, CTA.
- `~/Downloads/stitch_welcome_to_ladder_splash_screen/ai_academic_advisor_chat/screen.png` — chat bubble style.
- `~/Downloads/stitch_utility_bay_skill_arsenal/batcave_dashboard/screen.png` — founder backdoor mood.
- `~/Downloads/stitch_utility_bay_skill_arsenal/utility_bay_&_skill_arsenal/screen.png` — founder tooling layout.

---

## Do NOT design (hard stops, applies to every batch)

- No teacher login, dashboard, or teacher-facing screen. Teachers are data, not users.
- No counselor/admin/teacher/founder view of student grades.
- No founder view of student data — only aggregates, billing, tokens, flags.
- No shortcut to founder backdoor shorter than 30 seconds — no "dev tools" link, no URL scheme.
- No ads, 3rd-party analytics on student screens, or data-sale integrations.
- No design that lets a student retake the career quiz without counselor override.
- Every AI suggestion that changes state (schedule, class list, grades) must show an explicit human approve step.

**iOS 17+, iPhone only. Dynamic Type supported (clamped to xxxLarge on dense tables).**

---

(Paste this same header at the top of every batch, followed by the batch-specific screen list.)
