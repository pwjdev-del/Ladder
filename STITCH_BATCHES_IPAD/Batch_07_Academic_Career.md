You are designing iPad screens for Ladder, a college preparation app. This is batch 7 of 12. Use these exact design tokens.

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

# Batch 7: Academic Planning + Career — 12 Screens

---

## Screen G1: GPA Tracker

**Layout:** Two-panel split — Left 55%, Right 45%. Full sidebar navigation visible on left edge.

**Left Panel (55%) — Chart & Overview:**
- Header: "GPA Tracker" in Headline Large (Noto Serif, 32pt Bold, On Surface #1f1b15). Subtitle: "Track your academic progress" in Body Medium (Manrope, 14pt, On Surface Variant #434840).
- **Trend Line Chart:** Full-width chart area with 16pt padding. X-axis = semesters (Fall 9th, Spring 9th, Fall 10th, etc.). Y-axis = GPA scale 0.0–5.0 with 0.5 increments. Two lines: Unweighted (Primary #42603f, 3pt stroke) and Weighted (Secondary Lime #A1C621, 3pt stroke, dashed). Each data point = 8pt circle, tappable — on tap shows tooltip card (SurfaceContainerLowest bg, md radius, ambient shadow) with semester name, unweighted GPA, weighted GPA. Chart background = SurfaceContainerLow #fbf2e8. Grid lines = Outline Variant #c3c8be at 0.5pt.
- **Semester Pills:** Horizontal scroll row below chart. Each pill = Chip component (SurfaceContainerHigh pill, LabelSmall). Selected semester = Primary #42603f bg with On Primary #ffffff text. Tapping a pill updates the right panel.
- **Current GPA Display:** Card (SurfaceContainerLow, XL radius, ambient shadow). Two large numbers side by side: "Unweighted" with value in Display Small (36pt, Primary), "Weighted" with value in Display Small (36pt, Accent Lime). Label Medium beneath each.
- **Bright Futures Eligibility Card:** Card below with Accent Lime left border (4pt). Icon: star. "Bright Futures Status" Title Medium. Status badge: "Academic Scholar — Eligible" in green chip or "X.XX GPA needed" in amber chip. Body Small explanation text.

**Right Panel (45%) — Semester Detail:**
- Header: Selected semester name in Headline Small (24pt Medium). "Edit Courses" link text in Primary.
- **Course Table:** Full-width table with columns: Name (flex), Credits (60pt), Grade (60pt), Weight (80pt). Header row = SurfaceContainerHigh bg, Label Large text, wide tracking. Each row = SurfaceContainerLowest bg with sm vertical spacing.
  - Grade badges: color-coded rounded rectangles (md radius, 32pt height). A/A+ = Primary Container #5a7956 bg + white text. B/B+ = #3d6b99 blue bg + white. C/C+ = #b8860b amber bg + white. D = Error #ba1a1a bg + white. F = Error bg + white.
  - Weight column shows "Honors +0.5" or "AP +1.0" or "Standard" in Body Small.
- **"Add Course" Button:** Full-width outline button (Primary border, LG radius, 44pt height). Plus icon + "Add Course" in Title Small Primary.
- **Live GPA Calculation:** Card (SurfaceContainerLow, XL radius). Shows real-time semester GPA and cumulative GPA as they update. "Semester GPA: X.XX" and "Cumulative: X.XX" in Title Medium.
- **"Save" Button:** PrimaryBtn (gradient primary→primaryContainer, pill, white text, scale 0.95 on press). Full width, 48pt height.

---

## Screen G2: Transcript Upload

**Layout:** Two-panel split — Left 40%, Right 60%.

**Left Panel (40%) — Upload:**
- Header: "Upload Transcript" in Headline Large. Subtitle: "Import your grades automatically" Body Medium.
- **Upload Area:** Large dashed-border zone (Outline #737970 dashed 2pt, XL radius, 200pt height). Center content: cloud-upload icon (48pt, Primary), "Drag & drop your transcript" Title Small, "or" Body Small, two buttons side by side: "Take Photo" (camera icon, outline) and "Choose File" (folder icon, outline). Both 44pt height, LG radius.
- **Processing Animation:** When uploading, the dashed zone transforms: solid Primary border, pulsing green glow (Primary Glow shadow), centered spinner animation, "Analyzing transcript..." Body Medium, progress percentage.
- **Upload History:** Below upload area. "Previous Uploads" Label Large. List of past uploads: each row shows filename, date, status chip (Imported/Pending/Error), tap to re-view.

**Right Panel (60%) — Parsed Results:**
- **Semester Tabs:** Horizontal tab row at top. Each tab = pill chip. Selected = Primary bg + white text. Shows "Fall 9th", "Spring 9th", etc.
- **Course Table:** Columns: Name (flex), Grade (60pt), Credits (60pt), Weight (80pt), Status (50pt). Header = SurfaceContainerHigh bg. Rows alternate SurfaceContainerLowest and Surface.
  - Status column: ✓ green checkmark (verified), ⚠ amber warning (needs review), ✗ red X (error/mismatch). Each tappable for detail.
  - Flagged items: entire row gets amber background tint (Error Container #ffdad6 at 30% opacity) with ⚠ icon and explanation tooltip on tap.
- **GPA Summary:** Below table. Two cards side by side: "Semester GPA" and "Cumulative GPA" each with large number (Title Large) and trend arrow.
- **Action Buttons:** Three buttons at bottom:
  - "Confirm All" = AccentBtn (lime bg #A1C621, dark text, glow shadow). Full width.
  - "Edit" = Outline button (Primary border). Half width.
  - "Import to GPA Tracker" = PrimaryBtn (gradient pill). Half width.

---

## Screen G3: AP Course Suggestions

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — Recommendations:**
- Header: "Recommended APs" in Headline Large with sparkles icon (✨) animated subtle pulse. Below: context chips showing career path (e.g., "Pre-Med"), current GPA, and grade level as Chips.
- **Course Cards:** Vertical scroll list. Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Course name in Title Medium (bold). Difficulty rating: 1–5 filled circles (Primary = filled, Outline Variant = empty).
  - "Why this AP?" — AI explanation in Body Medium, italic, 3 lines max with "Read more" link.
  - Prerequisites: Body Small, Outline color. E.g., "Requires: Honors Biology".
  - School average grade: "School avg: B+" in Label Small chip.
  - Bright Futures badge: if applicable, small lime chip "Bright Futures ✓".
  - "Add to Schedule" button: PrimaryBtn small variant (pill, 36pt height).
  - Cards spaced 16pt apart.

**Right Column (45%) — Current Status:**
- **Current APs Card:** Card listing enrolled AP courses with grade badges.
- **AP Exam Scores Card:** Table — Exam | Score (1–5) | College Credit. Score badges: 5/4 = green, 3 = amber, 1–2 = red.
- **College Credit Map:** Expandable accordion per target college. Shows which AP scores grant credit and for which courses.
- **Load Balance Assessment Card:** Card with amber/green/red indicator. "Course Load: Moderate" with bar visualization. AI note: "Adding AP Chemistry would increase your load to Heavy. Consider dropping one elective." Body Small.

---

## Screen G4: Dual Enrollment Guide

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — Guide & Courses:**
- **"What is DE?" Explainer Card:** Featured card (SurfaceContainerLow, XL radius, Primary left border 4pt). Icon: graduation cap. "Dual Enrollment" Headline Small. 3–4 line explanation Body Medium. "Learn More" link.
- **Available Courses:** Below explainer. Filter bar: search field + filter chips (Subject, College, Schedule, Cost). Course list — each card:
  - Course name (Title Medium), college name (Body Small, On Surface Variant).
  - Two-column detail: "HS Credits: 1.0" | "College Credits: 3". Cost: "$0" or "$XX" in lime or amber. Transferability: "Transfers to: FSU, UCF, UF" Body Small.
  - Schedule: "Mon/Wed 10:00–11:15" Body Small.
  - "Enroll" outline button.

**Right Column (45%) — Your Status:**
- **Your DE Courses Card:** List of enrolled DE courses with progress indicators (in progress / completed / grade).
- **Credits Tracker:** Visual split bar — HS credits (Primary) vs College credits (Accent Lime). Numbers below each. "Total: X HS / X College credits earned."
- **Cost Savings Calculator Card:** Card (SurfaceContainerLow, XL radius). Inputs: number of DE courses, avg college credit cost. Output: "You've saved approximately $X,XXX" in Display Small lime. Comparison: "vs. taking these at [University]".
- **Transfer Guide Card:** Accordion by state university. Shows which DE credits transfer and as what course.

---

## Screen G5: AI Class Scheduler

**Layout:** Main area 70% + Sidebar 30%.

**Main Area (70%) — Schedule Grid:**
- Header: "Class Schedule" Headline Large. Semester selector dropdown. "AI Suggestions" toggle switch.
- **Weekly Grid:** Table layout. Columns: Period label (left, 60pt) × Mon–Fri (equal width). Rows: Period 1 through Period 7 (plus Lunch row grayed out).
  - Filled cells: Rounded rectangle (LG radius, 80pt min height). Background color-coded by department: STEM = light blue tint, Humanities = light amber tint, Arts = light purple tint, Electives = light green tint. Content: Course name (Label Large, bold), Teacher name (Body Small), Room number (Body Small, Outline color).
  - AI-recommended cells: Same style but with green dashed border (Primary #42603f, 2pt dashed) and small sparkles icon in top-right corner.
  - Empty cells: Light dotted border (Outline Variant), centered "+" button (32pt, Primary).
  - Tap on a filled cell: Bottom drawer slides up (280pt height, SurfaceContainerLow, xxxl top radius). Shows current course + 2–3 alternative options as horizontal cards. Each alternative card shows course name, teacher, rating, and "Swap" button.

**Sidebar (30%) — Analysis:**
- **Career Alignment Score:** Ring chart (120pt diameter). Percentage in center (Title Large). Primary color fill. "Career Alignment" Label Medium below.
- **Bright Futures Progress Bar:** Horizontal bar (Primary fill on Outline Variant track). "X of Y required credits" Body Small.
- **Total Credits:** "Credits: XX" Title Medium.
- **Difficulty Rating:** 1–5 scale with filled/empty circles. Label: "Overall Difficulty" Label Medium.
- **AI Suggestions Card:** Card (SurfaceContainerLow, XL radius). Sparkles icon. 2–3 bullet suggestions: "Consider swapping Study Hall for AP Statistics to strengthen your STEM profile." Body Small.
- **"Submit to Counselor" Button:** PrimaryBtn full width. 48pt height. "Submit for Approval" text.

---

## Screen G6: Research & Internship Tracker

**Layout:** Two-panel — Left 45%, Right 55%.

**Left Panel (45%) — List:**
- Header: "Research & Internships" Headline Large. "Add New" AccentBtn (lime bg, dark text, plus icon) aligned right of header.
- **Filter Tabs:** Horizontal pills — All | Research | Internships | Competitions. Selected = Primary bg + white text.
- **Entry Cards:** Vertical scroll. Each card (SurfaceContainerLow, XL radius, ambient shadow, 16pt padding):
  - Title in Title Medium. Organization in Body Small (On Surface Variant).
  - Type badge: chip — "Research" = blue tint, "Internship" = green tint, "Competition" = purple tint.
  - Date range: "Jun 2025 – Aug 2025" Body Small.
  - Status chip: "Active" green, "Completed" Primary, "Planned" amber.
  - Hours: "120 hrs" Label Medium.
  - Selected card gets Primary left border (4pt).

**Right Panel (55%) — Detail View:**
- **Title** in Headline Medium. Organization in Title Small (On Surface Variant). Supervisor: Body Medium.
- **Description:** Body Large, 4–6 lines.
- **Skills Tags:** Horizontal wrap of chips (SurfaceContainerHigh, pill, LabelSmall). E.g., "Python", "Data Analysis", "Lab Techniques".
- **Outcomes Section:** Bullet list — publications, presentations, awards. Body Medium.
- **Hours Chart:** Small bar chart showing hours logged per month. Primary bars.
- **Documents Section:** Attached files list — letter of rec, certificate, paper. Each row: file icon + name + date + download icon.
- **Action Buttons:** "Edit" outline button + "Delete" red outline button. Both 44pt height.

---

## Screen G7: Supplemental Essay Tracker

**Layout:** Master-detail — Left 35%, Right 65%.

**Left Panel (35%) — College List:**
- Header: "Essay Tracker" Headline Large.
- **College Cards:** Vertical scroll. Each card (SurfaceContainerLow, XL radius, 12pt padding):
  - College name in Title Small (bold).
  - Completion badge: "2/4 Complete" in Label Medium. Color: green if all done, amber if in progress, Outline if not started.
  - Progress bar: thin horizontal bar (4pt height, LG radius). Fill = Primary (proportional to completion). Track = Outline Variant.
  - Status chip: "In Progress" amber, "Complete" green, "Not Started" Outline.
  - Selected college card: Primary left border 4pt + slightly elevated shadow.

**Right Panel (65%) — Selected College Essays:**
- College name in Headline Medium at top. Logo if available.
- **Essay Cards:** Vertical stack. Each essay card (SurfaceContainerLowest, LG radius, 16pt padding, 12pt spacing between cards):
  - Prompt text in Body Large, italic, up to 3 lines with expand.
  - Status badge: "Draft" amber chip, "Review" blue chip, "Final" green chip, "Not Started" outline chip.
  - Word count: "247 / 350 words" Label Medium. Color changes: green if within range, amber if close to limit, red if over.
  - Progress bar: thin bar showing word count proportion.
  - "Open in Editor" PrimaryBtn small variant (pill, 36pt height). Arrow-right icon.
  - "Last edited: 2 days ago" Body Small, Outline color.
- **"Start All Essays" Button:** At bottom if essays not started. AccentBtn full width (lime bg, glow). "Start All Essays" with sparkles icon.

---

## Screen G8: Career Activity Suggestions

**Layout:** Two-column — Left 55%, Right 45%.

**Left Column (55%) — Suggestions:**
- Header: "Suggested for You" Headline Large with sparkles icon (✨). Career badge chip below: e.g., "Pre-Med" in Primary Container bg + white text, pill shape.
- **Grouped Sections:** Three collapsible sections:
  - **"High Impact"** — Title Medium, green left border. AI activity cards:
    - Activity name (Title Small bold), category chip (Leadership/Service/Academic/Creative/Athletic), "Why this matters" in Body Small italic (AI-generated explanation), commitment level ("5 hrs/week, 9 months" Body Small), impact rating (1–5 stars), "Add to Activities" outline button.
  - **"Medium Impact"** — Title Medium, amber left border. Same card format.
  - **"Quick Wins"** — Title Medium, blue left border. Same card format but shorter commitment.

**Right Column (45%) — Current Status:**
- **Current Activities List:** Card with list of current activities. Each: name, category chip, hours/week, years. Compact rows.
- **Coverage Radar Chart:** 5-axis radar (Leadership / Service / Academic / Creative / Athletic). Primary fill with 20% opacity. Outline = Primary. Ideal profile = dashed Accent Lime line. 160pt diameter.
- **"Gaps to Fill" AI Card:** Card (SurfaceContainerLow, XL radius, amber left border 4pt). Sparkles icon. "Based on your career path, you're missing: clinical volunteer experience and a leadership role in a STEM club." Body Medium. "View Suggestions" link.
- **Typical Admitted Student Comparison:** Small horizontal bar chart comparing student's profile to typical admitted students at target schools. Categories: Leadership, Service, Academic, Creative, Athletic. Student bar = Primary, Target bar = Outline Variant dashed.

---

## Screen H1: Career Quiz (3-Stage)

**Layout:** Centered single column (600pt max width). No sidebar visible during quiz.

- **Progress Bar:** Top of content area. Three stage indicators connected by line: Stage 1 (Interests), Stage 2 (Strengths), Stage 3 (Aspirations). Completed = Primary fill. Current = Primary outline + pulse. Upcoming = Outline Variant. Below stages: question progress "Question 3 of 15" Label Medium.

- **Stage 1 (15 Questions) — Interest Discovery:**
  - Question text in Headline Small (24pt Medium), centered. E.g., "Which environment appeals to you most?"
  - **2x2 Answer Grid:** Four answer cards (140pt × 140pt each, 16pt gap). Each card: SurfaceContainerLow, XL radius, ambient shadow. Center content: icon (40pt), label (Label Large, bold), short description (Body Small, 2 lines). On select: Primary border (3pt), Primary background tint (10% opacity), checkmark in top-right corner. Unselected: Outline Variant border (1pt).
  - Min 44pt touch target per card.

- **Stage 2 (10 Branching Questions) — Strengths:**
  - Same visual pattern but questions branch based on Stage 1 answers. May include Likert scales (5-point horizontal row of circles, selected = Primary fill) and ranking (drag-to-reorder list).

- **Stage 3 (5 Open-Ended Questions) — Aspirations:**
  - Question in Headline Small. Text area below (SurfaceContainerLowest, Outline border, LG radius, Primary focus border). Placeholder text in Outline color. Character count in bottom-right. 120pt min height.

- **Navigation:** "Back" outline button (left) + "Next" PrimaryBtn (right). Both pill, 48pt height. On last question: "Next" becomes "See Results" AccentBtn with sparkles.

---

## Screen H2: Career Quiz Results

**Layout:** Centered rich card (700pt max width). Celebratory feel.

- **Top Section:** Sparkles icon (animated subtle shimmer). Archetype title in Display Small (Noto Serif, 36pt): e.g., "The Ambitious Healer". RIASEC code below: "ISA" in Label Large with wide tracking. Description paragraph in Body Large (3–4 lines).

- **Three Detail Cards** (horizontal row, equal width, 16pt gap):
  - **Traits Card:** SurfaceContainerLow, XL radius. "Your Traits" Title Small header. Horizontal wrap of trait chips: "Analytical", "Empathetic", "Detail-Oriented", "Persistent". Chip style = SurfaceContainerHigh pill.
  - **Career Paths Card:** Same card style. "Career Paths" Title Small. Vertical list: "Physician", "Biomedical Researcher", "Public Health Director", "Genetic Counselor". Each with arrow-right icon. Tappable.
  - **Recommended Classes Card:** Same card style. "Take These Classes" Title Small. Checklist: "AP Biology ☐", "AP Chemistry ☐", "Anatomy & Physiology ☐", "AP Statistics ☐". Checkboxes = Primary when checked.

- **RIASEC Hexagon Radar:** 6-axis radar chart (Realistic, Investigative, Artistic, Social, Enterprising, Conventional). Primary fill (20% opacity), Primary stroke. 180pt diameter. Centered below cards.

- **Action Buttons:** Three buttons in a row:
  - "Save to Profile" PrimaryBtn (gradient pill). Primary action.
  - "Retake Quiz" outline button (Primary border, pill).
  - "Explore Careers" AccentBtn (lime bg, glow, pill).
  All 48pt height.

---

## Screen H3: Career Explorer

**Layout:** Dashboard — Top selector + two-column below (50/50).

**Top Section — Career Selector:**
- Horizontal scroll of career cards (160pt wide × 100pt tall each, 12pt gap). Each card: SurfaceContainerLow, XL radius. Center: icon (32pt) + career name (Label Large). Selected card: Primary border (3pt) + Primary tint bg. E.g., Medicine icon, Engineering icon, Law icon, Education icon, Business icon, Arts icon, Tech icon.

**Left Column (50%) — Career Detail:**
- Career title in Headline Large. Brief description in Body Large (4–5 lines).
- **Education Timeline:** Vertical timeline visualization. Nodes: High School → Bachelor's (4yr) → Graduate/Professional (variable). Each node = circle (Primary fill) + label + duration. Connector lines = Primary at 1pt.
- **Salary Bars:** Three horizontal bars (Entry Level, Mid-Career, Senior). Bar = Primary fill proportional to salary. Labels: "$XX,XXX" on right of each bar. Title Small header: "Salary Range".
- **Growth Rate:** Large number "15%" in Display Small (Accent Lime) with up-arrow icon. "Projected 10-Year Growth" Body Small.

**Right Column (50%) — Related & Exploration:**
- **Related Jobs Grid:** 2-column grid of cards (SurfaceContainerLow, LG radius, 12pt padding). Each card: Title (Title Small bold), salary (Body Small, lime), growth % (Body Small + arrow), education level (Body Small), tags as mini chips. 6–8 cards.
- **Related Majors:** Horizontal wrap of chips. "Biology", "Biochemistry", "Public Health", "Neuroscience". Chip = SurfaceContainerHigh pill LabelSmall.
- **"Set as Career Path" Button:** AccentBtn full width at bottom. "Set as My Career Path" with check icon. 48pt height.

---

## Screen H4: Post-Graduation Mode

**Layout:** Dashboard — full width with sections.

- **Header:** "Life After College" in Headline Large (Noto Serif). Subtitle: "Your transition guide" Body Medium.
- **Mode Switcher:** Segmented control (two segments, pill shape, Primary bg on selected). "Pre-Graduation" | "Post-Graduation". Toggles content below.

- **Checklists (2x2 Grid):**
  - **Housing Section Card:** SurfaceContainerLow, XL radius. House icon + "Housing" Title Medium. Checklist items: "Research apartment options ☐", "Set housing budget ☐", "Sign lease ☐", "Set up utilities ☐", "Renter's insurance ☐". Checkbox = Primary fill when checked.
  - **Career Section Card:** Briefcase icon + "Career" Title Medium. "Update resume ☐", "Apply to jobs ☐", "Prepare for interviews ☐", "Negotiate offer ☐", "Professional wardrobe ☐".
  - **Financial Section Card:** Dollar icon + "Financial" Title Medium. "Create post-grad budget ☐", "Set up bank account ☐", "Understand loan repayment ☐", "Emergency fund ☐", "Health insurance ☐".
  - **Life Section Card:** Heart icon + "Life Skills" Title Medium. "Learn to cook basics ☐", "Set up healthcare ☐", "Build professional network ☐", "Self-care routine ☐".

- **Month-by-Month Timeline:** Horizontal scrollable timeline (May → June → July → August → September). Each month = card (SurfaceContainerLow, LG radius, 140pt wide). Key tasks listed per month. Current month = Primary border.

- **Resources Section:** Bottom row of resource cards (2-column). "Budgeting Tools", "Interview Prep", "Apartment Hunting Guide", "Loan Repayment Calculator". Each: icon + title + "Open" link.

---

**Deliverable:** Design all 12 screens. Batch 7 of 12.
