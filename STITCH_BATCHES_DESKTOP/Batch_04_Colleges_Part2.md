# Batch 4 of 12 — Colleges Part 2 (7 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 4 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Display/Headlines = Noto Serif (56/45/36/32/28/24pt). Body/Labels = Manrope (22/16/14pt titles, 16/14/12pt body, 14/12/10pt labels). Editorial tracking -0.5 on headlines, wide +2.0 on labels.

**Spacing (8pt):** xxs2 xs4 sm8 md16 lg24 xl32 xxl48 xxxl64 xxxxl80. Radius: sm8 md12 lg16 xl24 xxl32 xxxl40 pill9999.

**Shadows:** Ambient rgba(31,28,20,.06) blur20 y4. Floating blur30 y10. Glow rgba(201,242,77,.30) blur15. PrimaryGlow rgba(66,96,63,.15) blur20 y4.

**Components:** PrimaryBtn = gradient primary→primaryContainer pill white, hover brightness+5% + glow. AccentBtn = lime bg dark text glow. Cards = SurfaceContainerLow XL radius ambient, hover lift. Chips = SurfaceContainerHigh pill, hover outline. TextFields = SurfaceContainerLowest outline LG radius, focus primary glow. TableRows = hover SurfaceContainerHigh bg. Links = primary color underline on hover. No dividers. Tooltips on all icon buttons. Right-click context menus on cards/items.

## Desktop Navigation
Top bar (64px): Logo + sidebar toggle | breadcrumbs center | search (⌘K) + notification bell + theme toggle + profile dropdown right.
Left sidebar (240px, collapsible to 64px icons): 9 sections (Dashboard/Tasks/Colleges/Applications/Advisor/Financial/Career/Housing/Reports) with sub-items. Selected = primary bg pill. Collapsed = icons + tooltips.
Content area: max 1200px centered, xl padding. Keyboard: ⌘K search, ⌘N new, ⌘/ sidebar, Esc close.

---

## Screens

### D8. AI-GENERATED COLLEGE PAGE
- Same layout as College Profile (D2) with these additions:
- **"AI-Generated" banner** at very top of content area (above hero): full-width, SurfaceContainerHigh bg, md16 padding. Left: sparkle icon + "AI-Generated Profile" Manrope 14pt bold. Right: "This page was assembled by AI from public sources. Data may be inaccurate." Manrope 12pt, On Surface Variant. "Report Inaccuracy" text link (Error color) + "Request Official Page" outlined button (small, Primary border).
- Throughout the profile, any AI-sourced data point has a small "unverified" badge next to it: pill, SurfaceContainerHigh bg, Outline border, Manrope 10pt label, italic, with info-circle icon (8px). Hover on badge: tooltip explaining "This data was gathered by AI and has not been verified by the institution."
- Hero section: same gradient overlay, but with a subtle AI sparkle pattern (dotted grid at 5% opacity) overlaid.
- All other sections (stats, Quick Facts, Your Fit, etc.) identical to D2 in structure.
- Footer of page: card (SurfaceContainerLow bg, xl radius, md16 padding). "Know someone at this school? **Help us verify this page.**" Manrope 14pt. "Suggest Edit" PrimaryBtn.

### D9. WHAT-IF SIMULATOR
- Full-page layout. Content: two-column, lg24 gap.
- **Left column (45%):** SurfaceContainerLowest bg card, xl radius, ambient shadow, xl32 padding.
  - "What-If Simulator" — Noto Serif Headline Small (24pt). Sparkle icon beside title.
  - "Adjust your stats to see how your match scores change." Manrope 14pt, On Surface Variant, mt xs4.
  - Input controls (stacked, lg24 gap, mt lg24):
    - **GPA:** label (Manrope 14pt) + current value indicator (pill, SurfaceContainerHigh, Manrope 12pt — "Current: 3.6") + slider (range 0.0–4.0, Primary filled track, white thumb with Primary border, step 0.1, value label above thumb on drag) + number input (small, 60px, right of slider for direct entry).
    - **SAT:** same pattern (range 400–1600, step 10).
    - **ACT:** same pattern (range 1–36, step 1).
    - **AP Courses:** number stepper (minus/plus buttons, SurfaceContainerHigh circle, 32px, value between in Manrope 16pt). Current indicator.
    - **Activities:** number stepper (0–20).
    - **Service Hours:** number stepper (0–500, step 10).
  - "Reset to Current" — text button, On Surface Variant, mt lg24. Resets all sliders.
- **Right column (55%):** Scrollable.
  - "Projected Changes" Manrope 14pt title bold, On Surface Variant, mb md16.
  - College cards (stacked, md16 gap), live-updating as sliders change:
    - Each card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. College logo/initials (40px circle) + name (Manrope 14pt title bold) + location (Manrope 12pt, On Surface Variant).
    - Score area (right-aligned): Current % (Manrope 14pt, On Surface Variant) → Projected % (Manrope 16pt title bold, Primary color if improved, Error if decreased) + delta arrow (up green triangle / down red triangle) + delta value.
    - Badge: pill indicating change — "Now a Match!" (Primary bg, On Primary) / "Improved" (Accent Lime bg) / "Unchanged" (SurfaceContainerHigh) / "Decreased" (Error Container bg, Error text).
    - Subtle animation: score numbers count up/down when changed.
  - **AI Insight card** at bottom: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "AI Insight" label. "Improving your SAT by 60 points would move 3 schools from Reach to Match." Manrope 14pt. "Chat with Advisor" Primary link.

### D10. MY CHANCES CALCULATOR
- Full-page layout. Content area (max 1200px).
- **Top section:** 3 rings in a row, centered, lg24 gap:
  - **Reach ring** (100px diameter): Tertiary (#725232) stroke, count inside (Manrope 22pt bold), "Reach" label below (Manrope 12pt label, tracking +2.0).
  - **Match ring** (100px): Primary (#42603f) stroke, count, "Match" label.
  - **Safety ring** (100px): Accent Lime (#A1C621) stroke, count, "Safety" label.
- **Three columns below,** lg24 gap, mt xl32:
  - Each column: header (category name, matching color, Manrope 14pt title bold) + college cards stacked (md16 gap).
  - College card: SurfaceContainerLow bg, lg radius, ambient shadow, md16 padding. College name (Manrope 14pt bold) + location (Manrope 12pt, On Surface Variant). Probability bar: horizontal, 100% width within card, 8px height, lg radius. Fill color matches category (Tertiary/Primary/Accent Lime). Percentage label right (Manrope 12pt bold).
  - Expandable: click card to reveal factor breakdown (mini bars for GPA/SAT/ACT/Activities match, Manrope 12pt labels).
  - Hover: lift, border Outline Variant.
- **AI Summary card** (full width, mt xl32): SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "Your Profile Summary" Manrope 14pt title bold. Paragraph text — personalized analysis of chances. "Improve Your Odds →" Primary link to What-If Simulator.
- **Methodology note** (bottom): small text, Manrope 12pt, On Surface Variant. "Calculations based on historical admissions data and your profile. Actual results may vary." Info icon with tooltip for more detail.

### D11. WHY THIS SCHOOL ESSAY SEED
- Full-page layout. Content: two-column, lg24 gap.
- **Left column (40%):**
  - **College selector:** dropdown at top, SurfaceContainerLowest bg, Outline border, xl radius. Shows selected college logo + name. Change to switch context.
  - "Connection Points" Manrope 14pt title bold, mt lg24.
  - AI connection cards (stacked, md16 gap): 6 topic cards. Each: SurfaceContainerLow bg, lg radius, md16 padding. Topic icon (20px, Primary) + title (Manrope 14pt bold — e.g., "Research Opportunities" / "Campus Community" / "Specific Professor" / "Study Abroad" / "Career Services" / "Location & Culture") + brief description (Manrope 12pt, On Surface Variant, 2-line). "Use This" toggle switch right side (off: Outline Variant track; on: Primary track + check).
  - "Generate More" — text button, Primary, sparkle icon, mt md16.
- **Right column (60%):**
  - "Essay Outline" Manrope 14pt title bold. "Why [College Name]" Noto Serif Headline Small (24pt), mt xs4.
  - Outline workspace: SurfaceContainerLowest bg, xl radius, Outline border, xl32 padding.
    - 4 sections, each editable:
      - **Hook** — section label (Manrope 12pt label, tracking +2.0, Accent Lime) + text area (Manrope 14pt, placeholder "Your opening — connect personal story to the school...").
      - **What Excites You About [School]** — label + text area.
      - **What You'll Contribute** — label + text area.
      - **Conclusion** — label + text area.
    - Each section: SurfaceContainerLow bg when hovered (subtle), sm8 padding, lg radius. Auto-populated with seed text from selected connection points (italic, On Surface Variant).
  - Action buttons, mt lg24: "Copy Outline" outlined button (clipboard icon) + "Open in Essay Editor" AccentBtn (arrow-right icon).

### D12. DEADLINE HEATMAP
- Full-page layout. Content: two-column (70/30 split), lg24 gap.
- **Left — Calendar (70%):**
  - Month navigation: left/right arrows + month-year label (Noto Serif Headline Small 24pt) + "Today" text button.
  - Month grid: 7 columns (day headers Manrope 10pt label, tracking +2.0). Day cells (square, ~140px): day number top-left (Manrope 12pt). Background color intensity based on deadline count: 0 = transparent, 1 = Primary at 10%, 2 = Primary at 20%, 3+ = Primary at 35%. Deadline dots within cell: small colored circles (6px) — Primary for application deadlines, Error for financial aid, Tertiary for testing, Accent Lime for events. Max 4 dots visible, "+2 more" label if overflow. Today: Primary border (2px). Selected day: Primary bg, On Primary text.
  - Hover on cell: floating tooltip with deadline count + types.
  - Legend below calendar: dot + label pairs for each color.
- **Right — Sidebar (30%):** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding.
  - **Selected day deadlines:** date header (Manrope 14pt title bold). List of deadline items: colored dot + college name (Manrope 14pt) + deadline type (Manrope 12pt, On Surface Variant) + time remaining (pill, color-coded — red if <7 days, amber if <30, green otherwise). Click: navigate to application.
  - **Weekly urgency chart** (below, mt lg24): small horizontal bar chart (7 bars for days of week). Primary fill, Manrope 10pt day labels. Shows deadline density per day. "This Week" Manrope 12pt label above.

### D13. VISIT PLANNER
- Full-page layout. Content: two-column (55/45 split), lg24 gap.
- **Left — Map (55%):** Embedded map placeholder (SurfaceContainerHigh bg, xl radius, full height). College pins: circular markers with college initials (Primary bg, On Primary text, 32px). Route lines connecting pins (Primary color, 2px dashed). Drive time labels along route segments (pill, SurfaceContainerLowest bg, Manrope 10pt — "2h 15m"). Current location pin: Accent Lime. Map controls: zoom +/- buttons (bottom-right, SurfaceContainerLowest bg, floating shadow).
- **Right — Visit List (45%):** SurfaceContainerLowest bg, xl32 padding, scrollable.
  - "Your Visit Plan" Manrope 16pt title bold + "Add Visit" AccentBtn (small, + icon).
  - Visit cards (stacked, md16 gap), draggable to reorder (drag handle left, 6 dots icon, On Surface Variant):
    - Card: SurfaceContainerLow bg, lg radius, ambient shadow, md16 padding. Order number circle (24px, Primary bg, On Primary, Manrope 12pt bold). College name (Manrope 14pt title bold) + location (Manrope 12pt, On Surface Variant). Date picker: inline date field (SurfaceContainerLowest bg, Outline border, sm radius, Manrope 12pt). Status chip: pill — "Scheduled" (Primary bg) / "Visited" (Accent Lime bg) / "Not Scheduled" (SurfaceContainerHigh). Notes: small textarea (2 rows, Manrope 12pt, collapsed by default, expand on focus).
    - Hover: lift, drag cursor on handle.
  - **Trip summary card** at bottom: SurfaceContainerLow bg, lg radius, md16 padding. Total schools + total drive time + trip dates range. Manrope 14pt.
  - Action buttons: "Optimize Route" PrimaryBtn (sparkle icon — AI-powered) + "Export to Calendar" outlined button (calendar icon).

### D14. MY COLLEGE LIST
- Full-page layout. Content: two-column (65/35 split), lg24 gap.
- **Left column (65%):**
  - Top: "My College List" Noto Serif Headline Small (24pt) + count badge (pill, SurfaceContainerHigh). Sort bar: "Sort by" dropdown (Deadline / Match % / Name / Status) + search field (small, 200px).
  - College cards (stacked, md16 gap):
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Left: college logo/initials (48px circle) + name (Manrope 16pt title bold) + location (Manrope 12pt, On Surface Variant). Center: application status badge (pill — "Not Started" SurfaceContainerHigh / "In Progress" Primary bg / "Submitted" Accent Lime bg / "Accepted" Accent Lime bg bold / "Waitlisted" amber / "Denied" Error Container). Deadline countdown (Manrope 14pt — "23 days left" or "Due Dec 1" with calendar icon; urgent <7 days: Error color). Right: compare checkbox (custom, 20px, Primary when checked, Outline border default) + 3-dot menu (icon button, tooltip, click: dropdown with View / Edit / Remove / Move to...).
    - Hover: lift shadow, border Outline Variant.
    - Right-click: same context menu as 3-dot.
  - "Compare Selected" — AccentBtn, appears fixed bottom when 2+ checkboxes selected (floating bar, SurfaceContainerLowest bg, floating shadow, xl32 padding, centered).
- **Right column (35%):**
  - **Summary card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. "List Summary" Manrope 14pt title bold. Stats: total schools, by category (Reach/Match/Safety with colored dots + counts), applications started, submitted. Mini donut chart (80px, 3 segments Tertiary/Primary/Accent Lime).
  - **"List Health" AI card** (mt md16): SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "List Health" Manrope 14pt title bold. Health score (letter grade or percentage, large, Primary color). Feedback bullets: "Good balance of reach and safety schools." / "Consider adding 1 more safety option." / "All deadlines tracked." Manrope 14pt. "Get AI Recommendations" Primary link.

---

**Deliverable:** Design all 7 screens at 1440px width. Batch 4 of 12.
