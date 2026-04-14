You are designing iPad screens for Ladder, a college preparation app. This is batch 8 of 12. Use these exact design tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (Display Large 56pt Bold, Display Medium 45pt, Display Small 36pt, Headline Large 32pt Bold, Headline Medium 28pt SemiBold, Headline Small 24pt Medium). Body/Labels = Manrope (Title Large 22pt Bold, Title Medium 16pt SemiBold, Title Small 14pt SemiBold, Body Large 16pt, Body Medium 14pt, Body Small 12pt, Label Large 14pt Bold, Label Medium 12pt Bold, Label Small 10pt SemiBold). Headlines editorial tracking (-0.5). Labels wide tracking (+2.0).

**Spacing (8pt grid):** xxs 2, xs 4, sm 8, md 16, lg 24, xl 32, xxl 48, xxxl 64, xxxxl 80

**Corner Radius:** sm 8, md 12, lg 16, xl 24, xxl 32, xxxl 40, pill 9999

**Shadows:** Ambient (cards): rgba(31,28,20,0.06) blur 20 y4. Floating: same blur 30 y10. Glow: rgba(201,242,77,0.30) blur 15. Primary Glow: rgba(66,96,63,0.15) blur 20 y4.

**Components:** PrimaryBtn = gradient primary→primaryContainer pill white scale 0.95. AccentBtn = lime bg dark text glow. Cards = SurfaceContainerLow XL radius ambient shadow. Chips = SurfaceContainerHigh pill LabelSmall. TextFields = SurfaceContainerLowest outline border LG radius primary focus. No dividers. Min 44pt touch.

## iPad Navigation
Collapsible sidebar (280pt) replaces tab bar. 9 sections (Home/Tasks/Colleges/Applications/Advisor/Financial/Career/Housing/Reports) with sub-items. Selected = primary bg pill. Portrait = sidebar overlay. Detail area max 800pt single-column, full width for multi-column.

---

# Batch 8: Financial + Test Prep — 10 Screens

---

## Screen I1: Scholarship Search

**Layout:** Two-panel — Left 45%, Right 55%. Sidebar visible.

**Left Panel (45%) — Search & List:**
- Header: "Scholarships" Headline Large. Search field (TextFields component: SurfaceContainerLowest, Outline border, LG radius, Primary focus). Magnifying glass icon left, clear X right.
- **Filter Chips:** Horizontal wrap row. Chips: All | Merit | Need-Based | Local | STEM | Arts | First-Gen | Minority | Athletic. Each = SurfaceContainerHigh pill LabelSmall. Selected = Primary bg + On Primary text. Multi-select enabled.
- **Sort Dropdown:** Right-aligned. "Sort by: Best Match" Body Small with chevron.
- **Scholarship Cards:** Vertical scroll. Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Scholarship name in Title Medium (bold). Provider in Body Small (On Surface Variant).
  - Amount: large text in Accent Lime #A1C621 (Title Large bold). E.g., "$5,000".
  - Deadline: calendar icon + "Due: Mar 15, 2026" Body Small. Red if < 7 days.
  - Match % badge: circular badge (32pt). Green (80%+), Amber (50–79%), Red (<50%). Percentage inside in Label Small white.
  - Eligibility preview: 1-line summary Body Small. "GPA 3.5+, STEM major, Florida resident".
  - Tags: mini chips — "Renewable", "No Essay", "Local".
  - Bookmark star: top-right corner, 44pt touch. Outline = not saved, filled Primary = saved.
  - Selected card: Primary left border 4pt.
- **Empty State:** When no results. Illustration placeholder. "No scholarships match your filters" Body Medium. "Adjust Filters" link.

**Right Panel (55%) — Detail:**
- Scholarship name in Headline Medium. Provider in Title Small (On Surface Variant).
- Amount: Display Small (36pt) in Accent Lime. Below: "per year" or "one-time" Label Medium.
- **Deadline Countdown:** Card (SurfaceContainerLow, LG radius). Calendar icon. "15 days remaining" Title Medium. Date below. Red tint if urgent.
- **Full Eligibility List:** Bulleted list. Each item with status icon: ✓ green (meets), ⚠ amber (close/uncertain), ✗ red (does not meet). "GPA 3.5+ ✓", "Florida Resident ✓", "STEM Major ⚠ (undeclared)".
- **Application Instructions:** Numbered steps. Body Medium.
- **Required Materials:** Checklist — Transcript ☐, Essay ☐, Letter of Rec ☐, Financial Info ☐.
- **Action Buttons:**
  - "Apply Now" AccentBtn (lime bg, glow, full width, 48pt).
  - "Match Breakdown" outline button — expands to show detailed match analysis (✓/⚠/✗ per criterion).

---

## Screen I2: Scholarship Detail (Full Page)

**Layout:** Single centered column (700pt max width). Back arrow top-left.

- **Provider Logo:** 64pt square, rounded md, centered or left-aligned.
- **Scholarship Name:** Headline Large (Noto Serif, 32pt Bold). Full name.
- **Amount:** Display Small (36pt) in Accent Lime #A1C621. "per year" or "one-time" Label Medium beneath.
- **Deadline Countdown:** Inline card (SurfaceContainerLow, LG radius, 48pt height). Calendar icon + "Application closes in 23 days" Title Small. Full date below in Body Small.
- **About Section:** "About This Scholarship" Title Medium. Body Large description, 4–6 lines.
- **Eligibility — Detailed:** "Eligibility Requirements" Title Medium. Each requirement on its own line with checkbox-style indicator:
  - ✓ "Minimum GPA: 3.5 (Your GPA: 3.8)" — green text.
  - ✓ "Florida Resident" — green text.
  - ⚠ "STEM Major (You haven't declared)" — amber text.
  - ✗ "Community Service: 100+ hours (You have: 65 hours)" — red text.
- **Application Process:** "How to Apply" Title Medium. Numbered vertical steps (step circles Primary, connector lines). Each step: title + description Body Medium.
- **Materials Checklist:** "Required Materials" Title Medium. Interactive checklist with checkboxes (Primary fill when checked):
  - ☐ Official Transcript
  - ☐ Personal Essay (500 words)
  - ☐ Two Letters of Recommendation
  - ☐ Financial Aid Documentation
- **Action Buttons Row:**
  - "Apply Now" AccentBtn (lime bg, glow, 48pt, pill).
  - "Save" outline button (bookmark icon, Primary border, pill).
  - "Share" outline button (share icon, Primary border, pill).

---

## Screen I3: Scholarship Match Score

**Layout:** Two-panel — Left 45%, Right 55%.

**Left Panel (45%) — Ranked List:**
- Header: "Your Matches" Headline Large.
- **Total Potential Aid Card:** Featured card (SurfaceContainerLow, XL radius, Accent Lime left border 4pt). "Total Potential Aid" Label Medium. "$47,500" Display Small (Accent Lime). "across 12 scholarships" Body Small.
- **Ranked Scholarship List:** Vertical scroll. Each row (SurfaceContainerLow, LG radius, 12pt padding, 8pt spacing):
  - Rank number (24pt circle, Primary bg, white text, Label Large).
  - Scholarship name (Title Small, flex).
  - Amount (Label Large, Accent Lime).
  - Match % bar: horizontal mini bar (60pt wide, 8pt height). Green fill (80%+), Amber (50–79%), Red (<50%). Percentage label right.
  - Deadline: Body Small.
  - Status chip: "Applied" green, "In Progress" amber, "Not Started" outline, "Expired" red.
  - Selected row: Primary bg tint + elevated shadow.

**Right Panel (55%) — Match Breakdown:**
- Scholarship name in Headline Medium. Match score as large ring chart (120pt, Primary fill, percentage center).
- **Breakdown List:** Each criterion as a row:
  - ✓ "GPA: 3.5+ required — You have 3.8" — Primary text, green left border.
  - ⚠ "Service Hours: 100 required — You have 85 (close!)" — amber text, amber left border.
  - ✗ "Major: Computer Science required — Not listed" — Error text, red left border.
- **Your Profile Tags:** Chips showing relevant profile data used for matching. E.g., "GPA: 3.8", "SAT: 1420", "Florida", "First-Gen".
- **AI Improvement Suggestions Card:** Card (SurfaceContainerLow, XL radius, sparkles icon). "How to Improve Your Match" Title Small. Bullet list: "Log 15 more service hours to meet the requirement", "Declare your intended major in your profile". Body Medium.
- **"Apply" Button:** AccentBtn full width, 48pt.

---

## Screen I4: Scholarship Action Plan

**Layout:** Single column with timeline — full width content area.

- **Header:** "Your Scholarship Plan" Headline Large with sparkles icon. Subtitle: "AI-prioritized by return on investment" Body Medium (On Surface Variant).
- **Total Potential Earnings Summary Card:** Top featured card (SurfaceContainerLow, XL radius, Accent Lime top border 4pt). Three stats side by side: "Scholarships: 8" | "Potential: $32,000" (Accent Lime, Title Large) | "Hours Needed: ~45". Body Small note: "Estimated time to complete all applications."

- **Monthly Timeline:** Vertical timeline visualization. Left side: month labels (Label Large, bold). Right side: task cards per month.
  - **Month Header:** "January 2026" Label Large, Primary color. Horizontal line separator.
  - **Scholarship Task Cards:** Per scholarship within that month (SurfaceContainerLow, LG radius, 12pt padding):
    - Scholarship name (Title Small bold). Deadline date (Body Small, red if < 14 days).
    - "Essays" link chip → opens essay editor. "Documents" chip → opens checklist.
    - Time estimate: clock icon + "~3 hours" Body Small.
    - Priority indicator: "High ROI" green chip, "Medium" amber, "Low" outline.
    - Checkbox: ☐ / ☑ to mark complete.
  - Timeline connector: vertical line (Primary, 2pt) connecting months. Circle nodes at each month (Primary fill = past, Primary outline = current, Outline Variant = future).

---

## Screen I5: Financial Aid Comparison

**Layout:** Full width. Side-by-side comparison of 2–3 schools.

- **Header:** "Financial Aid Comparison" Headline Large. "Add School" outline button (plus icon, pill).
- **School Headers:** Top row. Each column (equal width): school logo (48pt), school name (Title Medium), location (Body Small).

- **Comparison Table:** Full-width table. Alternating row backgrounds (Surface / SurfaceContainerLow).
  - **Row Categories** (left labels column, 180pt):
    - Cost of Attendance section: Tuition, Room & Board, Fees, Books & Supplies, **Total COA** (bold row).
    - Financial Aid section: Grants & Scholarships, Federal Aid, Institutional Aid, Loans, Work-Study, **Total Aid** (bold row).
    - Bottom Line: **Net Cost** (bold, larger text), **4-Year Total Net Cost** (bold, Display Small size).
  - Each cell: dollar amount right-aligned. Body Medium for regular rows, Title Medium for bold rows.
  - **Green highlight:** Lowest value in Net Cost and 4-Year Total gets green background tint (Primary at 10%) + checkmark icon.
  - Red tint on highest cost cells.

- **AI Recommendation Card:** Below table (SurfaceContainerLow, XL radius, sparkles icon). "Based on your financial profile, [School X] offers the best value with $X,XXX lower net cost over 4 years." Body Large.

- **"Export" Button:** Outline button (download icon, pill). "Export as PDF".

---

## Screen I6: FAFSA Readiness / Net Cost Calculator

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — FAFSA Readiness:**
- Header: "FAFSA Readiness" Headline Large.
- **Score Ring:** Large ring chart (160pt diameter) centered. Score 0–100 inside (Display Small, Primary if >70, Amber if 40–70, Error if <40). Primary fill proportional. "Readiness Score" Label Medium below.
- **Checklist:** Vertical list of items, each in a card row (SurfaceContainerLow, LG radius, 12pt padding):
  - ☑ / ☐ checkbox (Primary fill). Item name (Title Small). Status chip (Complete green / In Progress amber / Not Started outline).
  - Items: "FSA ID Created", "Tax Returns Ready", "W-2 Forms Collected", "Bank Statements Gathered", "CSS Profile (if needed)", "Submission Deadline Noted".
  - Each item has "Learn More" link (Primary text, Body Small) that expands inline with a 3-line explanation.
- FAFSA deadline prominently displayed: "FAFSA Opens: Oct 1 | Priority Deadline: Feb 1" in a banner card (Accent Lime bg tint).

**Right Column (45%) — Net Cost Calculator:**
- Header: "Estimate Your Cost" Headline Small.
- **Input Form:**
  - "Household Income" — Slider (Primary track, 0–$200,000, increment $5,000). Current value displayed. Also accepts typed input.
  - "Total Assets" — Slider (0–$500,000).
  - "Family Size" — Stepper (1–10).
  - "Select College" — Dropdown (TextFields style). Populated from student's college list.
- **Output Card:** Card (SurfaceContainerLow, XL radius, Accent Lime top border 4pt). Animates in after calculation.
  - "Estimated Net Cost" Title Medium. "$XX,XXX / year" Display Small (Primary).
  - Aid breakdown: "Grants: $X,XXX" | "Loans: $X,XXX" | "Work-Study: $X,XXX". Bar chart mini visualization.
- **Disclaimer:** Body Small, Outline color. "These are estimates based on published data. Actual aid may vary."
- **"Compare Across Schools" Button:** PrimaryBtn full width (pill, 48pt). Navigates to I5.

---

## Screen J1: Test Prep Resources Hub

**Layout:** Card grid — 2 columns. Full width content area.

- **Header:** "Test Prep Resources" Headline Large. Subtitle: "Everything you need to prepare" Body Medium.

- **Resource Cards (2-column grid, 16pt gap):** Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - **Khan Academy SAT:** KA logo placeholder (48pt). "Khan Academy SAT Prep" Title Medium. "Free, comprehensive SAT prep with personalized practice." Body Medium. Cost badge: "Free" green chip. "Open" PrimaryBtn small (pill, 36pt).
  - **College Board Practice:** CB logo. "Official SAT Practice" Title Medium. "6 full-length practice tests from the makers of the SAT." Body Medium. "Free" green chip. "Open" button.
  - **ACT Academy:** ACT logo. "ACT Academy" Title Medium. "Free ACT prep tool with practice questions and full tests." Body Medium. "Free" chip. "Open" button.
  - **Fee Waiver Info:** Dollar-circle icon. "Fee Waivers" Title Medium. "Learn if you qualify for free SAT/ACT registration." Body Medium. "Check Eligibility" outline button.
  - **Local Programs:** Map-pin icon. "Local Prep Programs" Title Medium. "Find free or low-cost test prep in your area." Body Medium. "Search" outline button.
  - **Ladder Study Plan:** Sparkles icon. "Your AI Study Plan" Title Medium. "Personalized study schedule based on your target score." Body Medium. "View Plan" outline button.

- **"View Your Study Plan" Button:** AccentBtn full width at bottom (lime bg, glow, 48pt). "View Your Study Plan" with sparkles icon. Navigates to J4.

---

## Screen J2: SAT/PSAT Registration Reminders

**Layout:** Timeline — centered single column (700pt max width).

- **Header:** "Test Date Calendar" Headline Large. Subtitle: "Upcoming 12 months" Body Medium.

- **Registration Banner (if applicable):** Top banner card (Accent Lime bg tint, XL radius). Alert icon. "SAT Registration closes in 5 days!" Title Small. "Register Now" PrimaryBtn small. Dismissible X.

- **Timeline:** Vertical timeline. Left: month labels. Right: test date cards.
  - **Month Marker:** "January 2026" Label Large (Primary). Horizontal rule (Outline Variant).
  - **Test Date Cards:** Each card (SurfaceContainerLow, XL radius, 16pt padding):
    - Test type badge: "SAT" blue chip, "PSAT" green chip, "ACT" amber chip.
    - Test date: "March 8, 2026" Title Medium (bold).
    - Registration deadline: "Deadline: Feb 7, 2026" Body Medium. Countdown: "23 days left" Label Small. Red if < 7 days.
    - "Register Now" link (Primary text, arrow-right icon). Opens external registration.
    - Fee: "$60" Body Small. Fee waiver note: "Fee waiver available" green text if eligible.
    - "Set Reminder" toggle switch (Primary when on). Label: "Remind me 7 days before deadline".
  - Timeline connector: vertical line (Outline Variant, 2pt). Circle nodes (Primary fill = past dates, Primary outline = upcoming, Outline Variant = far future).

---

## Screen J3: Practice Test Score Log

**Layout:** Two-panel — Left 55%, Right 45%.

**Left Panel (55%) — Chart:**
- Header: "Score Tracker" Headline Large.
- **Main Trend Chart:** Full-width line chart. X-axis = dates. Y-axis = scores (SAT 400–1600 or ACT 1–36). Two lines: SAT (Primary, solid) and ACT (Accent Lime, solid). Target score = horizontal dashed line (Error color) with label "Target: 1450". Data points = tappable circles (8pt). Tooltip on tap shows date, score, type.
- **Section Mini Charts:** Below main chart. 2x2 grid of smaller charts:
  - SAT Math trend (small line chart, Primary).
  - SAT Reading/Writing trend.
  - ACT English trend.
  - ACT Math trend.
  Each 120pt × 80pt with score labels.

**Right Panel (45%) — Entries:**
- Header: "Score History" Title Large.
- **Score Entry List:** Vertical scroll. Each entry (SurfaceContainerLow, LG radius, 12pt padding):
  - Date (Label Medium). Type chip: "SAT" blue / "ACT" amber / "PSAT" green.
  - Total score (Title Medium, bold). Section scores below: "Math: 720 | R/W: 680" Body Small.
  - Source: "Official" / "Practice" / "Khan Academy" Label Small chip.
  - Selected entry highlighted with Primary left border.
- **"Log New Score" Button:** AccentBtn full width (lime bg, glow, 48pt). Plus icon + "Log New Score".
  - Tap opens form overlay (SurfaceContainerLowest, xxxl top radius, floating shadow): Test type selector, Date picker, Total score, Section scores, Source dropdown. "Save" PrimaryBtn + "Cancel" outline.

---

## Screen J4: Study Schedule Planner

**Layout:** Two-panel — Left 60%, Right 40%.

**Left Panel (60%) — Calendar:**
- Header: "Study Planner" Headline Large. Month navigation (< Month Year >).
- **Monthly Calendar Grid:** 7-column (Sun–Sat), 5–6 rows. Day cells (48pt × 48pt min):
  - Regular day: number in Body Medium.
  - Study day: Accent Lime background tint. Number in bold.
  - AI study block: Primary background tint + sparkles mini icon.
  - Today: Primary circle behind number, white text.
  - Selected day: Primary border ring.
  - Tap day → updates right panel.
- **Legend:** Below calendar. Color dots: "Study Day" (lime), "AI Recommended" (primary + sparkles), "Test Date" (red), "Today" (primary circle).

**Right Panel (40%) — Day Detail:**
- Selected date in Headline Small. Day of week in Body Medium.
- **Study Sessions:** Vertical list of session cards (SurfaceContainerLow, LG radius, 12pt padding):
  - Subject (Title Small, bold). Focus area: "Quadratic Equations" Body Medium.
  - Duration: clock icon + "45 min" Label Medium.
  - Resource link: "Khan Academy Lesson 3.2" Body Small, Primary link text, external icon.
  - "Completed" checkbox (Primary fill when checked). Strikethrough on title when done.
- **"Add Study Session" Button:** Outline button (plus icon, Primary border, LG radius, 44pt).
- **Weekly Stats Card:** Card (SurfaceContainerLow, XL radius) at bottom of right panel.
  - "This Week" Title Small. Stats: "Sessions: 4/6" | "Hours: 3.5" | "Streak: 5 days". Mini progress bar for sessions (Primary fill).

---

**Deliverable:** Design all 10 screens. Batch 8 of 12.
