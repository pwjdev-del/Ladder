# Ladder Stitch — Batch 6 of 6: remaining shared components (4 components)

Paste this whole file into Stitch as one brief.

---

## Brand tokens

forest-900 `#3F5A3A` · forest-700 `#527050` · forest-500 `#6B8A67` · lime-500 `#A8D234` · cream-100 `#F5F0E5` · paper `#FFFFFF` · stone-200 `#E8E2D8` · ink-900 `#1B1F1B` · ink-600 `#4A5346` · status-red `#C94A3F` · status-amber `#D9A54A`.
Playfair Display serif (600–700) headline. Manrope sans (400–600) body. Caps 11pt +10% tracking UPPER.
Radius: 12 cards · 999 pill · 8 inputs/chips · 24 modals.

## Do NOT design

No teacher UI. No grades for non-student. No founder view of student data. Every AI state-changing suggestion needs visible human approve.

## Reference

`student_home_dashboard` for bottom nav feel · `career_discovery_quiz_question` for picker feel.

---

# Components (4)

## 1. `component_sibling_switcher` — parent chooses between linked kids

Used at the top of parent screens when a parent has more than one linked student account.

- Horizontally scrollable capsule row, 48pt tall.
- Each chip: 40pt circular avatar (initials or photo if uploaded) + first name caps label (11pt).
- Selected chip state: lime fill, forest-900 text, 2pt lime outer glow.
- Unselected: stone-200 fill, ink-600 text.
- Include an "+ Add" chip at the end that routes to the parent-add-child flow.
- Deliver three states:
  - 1 child linked (show the chip plus the + chip).
  - 2–3 children linked (scrollable).
  - 5+ children linked (demonstrates horizontal scroll with scroll shadow edges).

## 2. `component_kid_friendly_button` — oversized button for K-2 flows

Used across K-2 career quiz, K-2 grades entry (if ever exposed to K-2 directly), K-2 extracurriculars.

- Minimum 56pt tap target, 64pt preferred.
- Radius: 20pt (softer than the normal 12pt).
- Typography: Manrope 18pt weight 700, ink-900 on lime or forest-900 on cream.
- Left emoji slot (optional): 28pt emoji glyph on the left side.
- Right chevron (optional) for navigation-style buttons.
- Deliver 4 variants on one artboard:
  - **Primary lime:** lime-500 fill, ink-900 text.
  - **Secondary cream:** cream-100 fill, forest-700 text.
  - **Ghost:** transparent, forest-700 text + 2pt forest-700 border.
  - **Disabled:** stone-200 fill, ink-400 text, 60% opacity.
- All variants show a pressed state (3% scale down) + a focused state (3pt lime glow).

## 3. `component_consent_row` — inline agreement row

Used inside `consent_terms`, `consent_privacy`, `consent_parental` in Batch 2.

- 56pt tall row, 16pt horizontal padding.
- Left: 24pt square checkbox — stone-200 unchecked, lime-500 filled with white checkmark when checked.
- Middle: label text ink-900 + optional sub-helper ink-400 below.
- Right: "read more" chevron (rotates to ˅ when expanded).
- Expanded state: full paragraph content appears below the row in a cream-tinted subsection, with its own 1pt left border in lime.
- States: default, checked, expanded, expanded-and-checked, disabled (for rows that depend on other rows being checked first — e.g., the marketing opt-in stays disabled until "Data collection" is checked).

## 4. `component_bottom_nav_per_role` — 5-tab bottom nav variants

Ladder has different bottom nav for each role. Stitch existing splash already has the student variant; deliver the other 3.

**Variant A — student:** Home / Tasks / Classes / Activities / Profile. (Reuse existing.)

**Variant B — counselor:**
- Home (house glyph)
- Queue (tray glyph with badge for count)
- Classes (books glyph)
- Invites (envelope glyph)
- Profile (person glyph)

**Variant C — admin:**
- Home (house)
- Teachers (person-2 glyph)
- Classes (books)
- Invites (envelope)
- Profile (person)

**Variant D — parent:**
- Home (house)
- Grades (graph-line glyph)
- Schedule (calendar)
- Messages (speech-bubble)
- Settings (gear)

Shared specs: 88pt tall bar on paper with 1pt top stone-200 hairline. Active tab: forest-700 icon + label + lime 3pt top pip. Inactive: ink-400 icon + label. Badges: red pill with white number, max "9+".

Note for founder: there is NO bottom nav for founder; the founder backdoor uses the dark tab bar shown in Batch 4 `founder_dashboard_overview`. Do not design a founder bottom nav here.

---

Deliver `{component_name}/screen.png` (as a component sheet with all states/variants on one artboard) + `{component_name}/code.html` + `{component_name}/notes.md`.

## End of Stitch brief

That's the full v2 spec coverage across 6 batches:
- Batch 1 · Landing + core auth (10 screens)
- Batch 2 · Consent + student start (10 screens)
- Batch 3 · Student finish + counselor (10 screens)
- Batch 4 · Admin + founder start (10 screens)
- Batch 5 · Founder finish + components start (10 screens / components)
- Batch 6 · Remaining components (4 components)

Total: 54 new artifacts. Paste each batch separately into Stitch.
