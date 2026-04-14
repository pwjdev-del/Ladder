You are designing iPad screens for Ladder, a college preparation app. This is batch 4 of 12 (screens listed below). Use these exact design tokens for all screens.

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

### D8. AI-GENERATED COLLEGE PAGE
Same as College Profile layout but with prominent "AI-Generated Page" banner (secondary bg, sparkles). "May contain inaccuracies" disclaimer. Sections with "unverified" badges. "Report Inaccuracy" + "Request Official Page" buttons.

### D9. WHAT-IF ADMISSIONS SIMULATOR
Interactive split. Left (50%): "What If..." headline + sparkles. Sliders: GPA (0-5), SAT (400-1600), ACT (1-36), APs (0-15), Activities (0-20), Service Hours (0-500). Current values shown. "Reset to Current" link. Right (50%): Live-updating college cards (name, current match %, projected % with ↑/↓ delta arrows, Reach/Match/Safety badge). AI Insight card at bottom.

### D10. MY CHANCES CALCULATOR
Dashboard. Top: Three large rings (Reach=tertiary, Match=primary, Safety=lime/secondary). Below: Three column sections with college cards (name, probability bar, key factor, expandable). AI summary ("balanced list" or suggestions). Methodology note.

### D11. WHY THIS SCHOOL ESSAY SEED
Two-column. Left (45%): College selector dropdown + AI connection cards (4-6: Research Focus, Hands-On Learning, First-Gen Support, Bright Futures, Campus Community, Career Services — each with "Use This" toggle + explanation). "Generate More" button. Right (55%): "Your Essay Outline" — selected seeds as building blocks, sections (Hook, Why School, Why You, Conclusion), "Copy Outline" + "Open in Editor" + word count.

### D12. DEADLINE HEATMAP CALENDAR
Full calendar + sidebar. Left (65%): Month grid, cell bg intensity = deadline count (cream 0, light green 1, medium green 2-3, dark green 4+). Selected day primary border. Month nav. Dots below day numbers for types. Right (35%): Selected date header + deadline cards (college, type EA/ED/RD/Rolling, platform tag, urgent badge) + "Urgency This Week" bar chart.

### D13. COLLEGE VISIT PLANNER + MAP
Map + itinerary. Left (55%): Interactive map with college pins (Green=Visited, Blue=Scheduled, Gray=Not Scheduled), route line, driving time labels. Right (45%): "Campus Visit Plan" header, ordered visit cards (name, date picker, status badge, notes, "Schedule Tour"), drag to reorder, trip summary (schools/miles/days), "Optimize Route" + "Export to Calendar".

### D14. MY COLLEGE LIST
Two-column. Left (60%): "My College List" + count, sort (Match/Date/Name/Deadline), college cards (image, name, location, match %, tags, app status badge, deadline countdown, heart, compare checkbox). "Compare Selected" button. Right (40%): Summary card (total, Reach/Match/Safety bar, earliest deadline, submitted count) + "List Health" AI card.

---

Design all 7 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 4 of 12.
