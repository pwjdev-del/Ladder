You are designing iPad screens for Ladder, a college preparation app. This is batch 5 of 12 (screens listed below). Use these exact design tokens for all screens.

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

### E1. APPLICATION TRACKER
Two-panel. Left (45%): "Applications" + count, filter chips (All/In Progress/Submitted/Decision), app cards (name + logo, type EA/ED/RD/Rolling, status badge, deadline + days, progress bar). Right (55%): Selected detail (=E2). Empty state.

### E2. APPLICATION DETAIL
Two-column. Left (55%): Status card (name, location, match %, status badge large, type, submission date). Progress (X/Y + bar). Checklist sections (Personal Info, Essays, Recs, Scores, Financial Aid) with checkbox rows + priority dots. Right (45%): Timeline (started → docs → submitted → review → decision), documents list (✓/⏳/✗), notes textarea, "Submit Application" + "Withdraw".

### E3. DEADLINES CALENDAR
Calendar + sidebar. Left (65%): Month grid, ←Month Year→, view toggles (Month/Week/List), colored dots (red=urgent, amber=soon, green=safe), selected = primary border. Right (35%): Selected date header, deadline cards (college, type, platform, urgent badge), upcoming week, overdue section.

### E4. APPLICATION SEASON DASHBOARD (Kanban)
Full-width. Top: countdown ring + stats (total/submitted/accepted) + "Chat Advisor". 4 Kanban columns (Drafting/Ready/Submitted/Decision) — drag-and-drop cards (name, progress bar, deadline, status). Tap card → drawer. Bottom: "Today's Action Items" chip strip.

### E5. SUBMISSION TRACKER
Single column (700pt). College header. Horizontal stepper (Personal Info ✓, Essays ✓, Recs ◎, Scores ✓, Payment ○, Submit ○). Current step details. Warnings. "Review & Submit" (enabled when complete). Post-submit: confirmation card.

### E6. DECISION PORTAL
Two-column. Left (55%): "Decisions" headline, decision cards (name + logo, decision badge Accepted green/Rejected red/Waitlisted amber/Deferred blue, date, aid summary, "Respond by" countdown, Accept/Decline/View Aid buttons). Right (45%): Summary (counts + donut chart), "Compare Accepted", "Need Help?" → Advisor.

### E7. WAITLIST TRACKER & LOCI
Two-column. Left (55%): "Waitlisted Schools", school cards (name, position, date, LOCI status, "Write LOCI" button, materials checklist, "Remove" button). Right (45%): "Waitlist Strategy" AI card (tips, LOCI checklist, historical insights) + LOCI preview.

### E8. SERVICE HOURS LOG
Two-panel. Left (45%): "Service Hours" + total badge, "Log Hours" button, entries (org, date, hours, category, verified badge). Right (55%): Entry form (org, date, hours, category, description, supervisor, "Save") + monthly hours chart + category breakdown.

---

Design all 8 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 5 of 12.
