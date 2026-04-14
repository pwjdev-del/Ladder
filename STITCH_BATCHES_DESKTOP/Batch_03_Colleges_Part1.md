# Batch 3 of 12 — Colleges Part 1 (7 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 3 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

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

### D1. COLLEGE DISCOVERY
- Full-page layout with sidebar (Colleges selected). Content area full width (no max-width constraint — uses available space).
- **Top bar area:** "Discover Colleges" Noto Serif Headline Small (24pt) + result count badge (pill, SurfaceContainerHigh, Manrope 12pt, "1,247 colleges") + search field (360px, SurfaceContainerLowest bg, Outline border, lg radius, magnifying glass icon, "Search colleges... ⌘K" placeholder) + "Filters" button (icon + label, SurfaceContainerHigh bg, pill, Manrope 12pt; active: Primary bg, On Primary text, count badge).
- **Filter bar** below: horizontal row of active filter chips (pill, SurfaceContainerHigh, Manrope 12pt, X remove icon). Sort dropdown right-aligned (Manrope 12pt, "Sort: Match %" default). View toggle: two icon buttons (grid/list), SurfaceContainerHigh bg active state.
- **Grid view (default):** 4-column card grid, lg24 gap.
  - College card: SurfaceContainerLow bg, xl radius, ambient shadow. Hero image area (180px height, lg radius top, placeholder gradient if no image). Heart/save icon button (top-right of image, 32px circle, SurfaceContainerLowest bg, Outline icon; saved: Error fill for heart). Match % badge (bottom-left of image, pill, Primary bg, On Primary text, Manrope 12pt bold — e.g., "87% Match"). Below image: xl32 padding. College name (Manrope 14pt title bold, 2-line clamp). Location (Manrope 12pt, On Surface Variant, map-pin icon). Tags row: 2-3 chips (pill, SurfaceContainerHigh, Manrope 10pt — "Private" / "Medium" / "Urban"). Hover: lift shadow (floating), cursor pointer.
  - Right-click: context menu (View Profile / Add to List / Compare / Share).
- **List view:** sortable table. Columns: Name (with mini logo/initials) / Location / Type / Size / Match % / Acceptance Rate / Tuition. Header row: Manrope 12pt label, tracking +2.0, On Surface Variant, sortable (click to sort, arrow indicator). Data rows: Manrope 14pt, hover SurfaceContainerHigh bg. Match % cell: colored pill.
- **Detail drawer (480px, slides from right)** on card/row click: SurfaceContainerLowest bg, floating shadow. Close X button top-right. College hero (200px) + name + location + key stats grid (2x3) + "Open Full Profile" PrimaryBtn at bottom. Drawer overlay dims background slightly.

### D2. COLLEGE PROFILE
- Full-page layout. Content area: hero section + two-column below.
- **Hero section (full width, 300px height):** Gradient overlay (Primary at 70% opacity) on campus photo (or solid gradient Primary → Primary Container). Content overlaid:
  - Match % ring (64px, top-right, white stroke, percentage inside Manrope 16pt bold white).
  - College name: Noto Serif Display Small (36pt), On Primary, bottom-left.
  - Location + type tags: Manrope 14pt, On Primary 80%, below name. Chips: "Private" / "Research University" / "Medium" — semi-transparent white bg.
  - Action buttons (bottom-right): "Start Application" AccentBtn + "Add to List" outlined button (white border, white text) + "Compare" icon button (scales icon, white, tooltip).
- **Two-column layout below hero, lg24 gap, mt lg24:**
  - **Left column (65%):**
    - Section tabs: "Overview" / "Deadlines" / "Personality" / "Actions" — tab bar, Manrope 14pt, underline indicator (Primary, 3px). mb lg24.
    - **Overview tab:** Stats grid (3-col, md16 gap): acceptance rate, avg GPA, avg SAT, enrollment, student-faculty ratio, graduation rate — each in a mini card (SurfaceContainerLow, lg radius, md16 padding, icon + value Manrope 22pt bold + label Manrope 10pt). Majors section: popular majors as chips. About section: paragraph text Manrope 14pt.
    - **Deadlines tab:** timeline list of deadlines (ED, EA, RD, Financial Aid) with dates, status, countdown.
    - **Personality tab:** campus culture radar chart or descriptive cards (e.g., "Collaborative", "Research-Focused").
    - **Actions tab:** checklist of things to do for this college (visit, apply, request info).
  - **Right column (35%):**
    - **Quick Facts card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Key-value pairs: Founded / Endowment / Setting / Calendar / Religious Affiliation. Manrope 12pt label + Manrope 14pt value.
    - **Your Fit card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding, mt md16. "Your Fit" Manrope 14pt title bold. Comparison bars (your stat vs. college avg — dual-colored horizontal bars, Primary for you, Outline Variant for avg). Categories: GPA, SAT, ACT. Overall badge (pill — "Strong Match" / "Match" / "Reach", color-coded).
    - **Financial card:** SurfaceContainerLow bg, xl radius. Tuition, avg aid, net price. "See Full Breakdown" link.
    - **Similar Colleges:** SurfaceContainerLow bg, xl radius. 3 mini cards (logo + name + match %, clickable).

### D3. COLLEGE COMPARISON
- Full-page layout. Content area (max 1200px).
- **Top: School selectors** — 2-3 columns. Each: dropdown/search selector (SurfaceContainerLowest bg, Outline border, xl radius, md16 padding). Selected: college logo/initials (40px circle) + name + location + "Change" link. Empty slot: dashed Outline border, "Add College" with + icon, click to open selector dropdown. "Add Column" button if < 3.
- **Comparison table** below, mt lg24: full width. SurfaceContainerLowest bg, xl radius, ambient shadow.
  - Row categories: Admissions / Academics / Cost / Campus Life / Outcomes. Each category: header row (SurfaceContainerHigh bg, Manrope 12pt label bold, tracking +2.0).
  - Data rows: metric label left (Manrope 14pt, 200px column) + values per school. Best value in each row: Primary text + bold + subtle Primary bg tint. Hover: SurfaceContainerHigh bg.
  - Metrics: Acceptance Rate, Avg GPA, Avg SAT, Avg ACT, Tuition, Room & Board, Avg Aid, Net Price, Student-Faculty Ratio, Graduation Rate, Retention Rate, Median Earnings, etc.
- **Photo row** below table: horizontal scroll of campus photos per school, md16 gap, lg radius, 120px height thumbnails.
- **AI Recommendation card** at bottom: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "AI Recommendation" Manrope 14pt title bold. Text: personalized recommendation comparing the schools. AccentBtn "Chat with Advisor about this".

### D4. MATCH SCORE DETAIL
- Full-page layout. Content: two-column, lg24 gap.
- **Left column (55%):**
  - Match score ring: large (160px diameter), Primary stroke, SurfaceContainerHigh track. Percentage inside (Noto Serif Display Small 36pt). College name below (Manrope 16pt title bold) + match label (pill — "Strong Match" Primary bg / "Match" Secondary bg / "Reach" Tertiary bg / "Safety" Accent Lime bg).
  - "Factor Breakdown" Manrope 14pt title bold, mt xl32.
  - Factor bars (stacked, md16 gap): each factor row: label (Manrope 14pt, 180px) + horizontal bar (200px, lg radius, 8px height, colored fill proportional to score) + score fraction (Manrope 12pt). Factors: GPA Match / Test Scores / Major Availability / Selectivity / Financial Fit / Location Preference / Size Preference / Campus Culture.
  - Each factor row: clickable/expandable — click reveals detail card below with explanation text (Manrope 14pt, On Surface Variant) + your value vs. college value comparison.
- **Right column (45%):**
  - **"How to Improve" AI card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "How to Improve Your Match" Manrope 14pt title bold. Bulleted list of actionable suggestions (Manrope 14pt, md16 gap between items, green bullet dots).
  - **Similar Colleges card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding, mt md16. "Similar Colleges You Might Like" Manrope 14pt title bold. 4 mini cards: logo/initials circle + name + match % pill + location. Hover: border Outline Variant.
  - **What-If link card:** SurfaceContainerLow bg, xl radius, ambient shadow, md16 padding, mt md16. Sliders icon + "What if you improved your scores?" Manrope 14pt. "Try the What-If Simulator →" Primary link.

### D5. ADVANCED FILTERS
- Right-side drawer (480px width), slides in from right. SurfaceContainerLowest bg, floating shadow. Dark overlay behind.
- **Header:** "Filters" Manrope 16pt title bold + close X icon button + "Reset All" text link (Error color) right-aligned. xl32 padding, bottom border Outline Variant.
- **Scrollable content area,** xl32 padding:
  - **Location:** State multi-select dropdown + Region checkboxes (Northeast/Southeast/Midwest/West/International) + Distance slider (0-500 miles, Primary thumb, SurfaceContainerHigh track, current value label).
  - **Admissions:** Acceptance rate range slider (dual thumb, 0-100%) + GPA range slider + SAT range slider + ACT range slider. Each: label + slider + min/max value labels.
  - **Academics:** Major search autocomplete + Program type chips (Bachelors/Masters/Doctoral toggles) + Student-faculty ratio slider.
  - **Cost & Aid:** Tuition range slider + "Show only schools with merit aid" toggle + "Show only need-blind" toggle.
  - **Campus:** Size chips (Small <2k / Medium 2-10k / Large 10k+) + Setting chips (Urban/Suburban/Rural) + Religious affiliation dropdown + "Has Greek Life" toggle.
  - Each category: section label (Manrope 12pt label, tracking +2.0, On Surface Variant, uppercase) + controls below.
  - Sliders: Primary filled track, SurfaceContainerHigh empty track, white thumb with Primary border, tooltip showing value on drag.
  - Toggles: same styling as onboarding (Primary when on).
- **Footer (sticky):** "Apply Filters" AccentBtn (includes count "Apply Filters (23)") + "Reset All" outlined button. xl32 padding, top border Outline Variant.

### D6. CAMPUS PHOTO GALLERY
- Full-page layout. Content area (max 1200px).
- **Top:** "Campus Gallery" Noto Serif Headline Small (24pt) + college name (Manrope 14pt, On Surface Variant).
- **Category tabs:** "All" / "Campus" / "Dorms" / "Dining" / "Athletics" / "Student Life" — horizontal pills (SurfaceContainerHigh default, Primary bg when selected). mb lg24.
- **Masonry grid:** 3 columns, sm8 gap. Photo cards: lg radius, ambient shadow, overflow hidden. Varying heights based on aspect ratio. Hover: dark overlay (On Surface at 30%) + zoom icon centered + caption text (Manrope 12pt, white) at bottom.
- **Lightbox viewer (on click):** full-screen dark overlay (Inverse Surface at 90%). Centered photo (max 90vw x 80vh, xxl radius). Left/right arrow navigation (circle buttons, 48px, SurfaceContainerLowest bg, floating shadow). Close X top-right. Caption below photo (Manrope 14pt, white). Keyboard: left/right arrows to navigate, Esc to close. Thumbnail strip at bottom (60px height, horizontal scroll, selected has Primary border).

### D7. BEST FOR YOUR MAJOR
- Full-page layout. Content area (max 1200px).
- **Top:** "Best Colleges for Your Major" Noto Serif Headline Small (24pt) + career badge (pill, Accent Lime bg, On Surface text, Manrope 12pt — e.g., "Computer Science").
- Major selector dropdown: SurfaceContainerLowest bg, Outline border, lg radius, Manrope 14pt. Change to explore other majors.
- **Filter bar:** Region chips + Size chips + "Has Research Opportunities" toggle. mt md16.
- **Ranked list,** mt lg24, stacked cards, md16 gap:
  - Each college card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Layout:
    - Left: Rank number (Noto Serif Headline Medium 28pt, Primary color, 60px width) + college logo/initials circle (48px).
    - Center: College name (Manrope 16pt title bold) + location (Manrope 12pt, On Surface Variant) + program details (Manrope 14pt — "Top 15 CS Program" / "200+ CS graduates/year" / "Research opportunities available"). mt sm8: explanation text (Manrope 14pt, On Surface Variant, italic — AI-generated reason why this school is good for the major).
    - Right: Match % ring (48px, Primary) + tags (pills — "Research" / "Co-op" / "Small Classes").
    - Hover: lift shadow, border Outline Variant.
    - Right-click: context menu (View Profile / Add to List / Compare).

---

**Deliverable:** Design all 7 screens at 1440px width. Batch 3 of 12.
