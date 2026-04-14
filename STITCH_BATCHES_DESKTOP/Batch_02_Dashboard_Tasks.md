# Batch 2 of 12 — Dashboard & Tasks (10 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 2 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

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

### B1. STUDENT DASHBOARD
- Full desktop layout with top bar + left sidebar (Dashboard selected).
- Content area (max 1200px centered, xl32 padding):
- **Row 1 — Welcome Banner (full width):** Card with gradient Primary (#42603f) → Primary Container (#5a7956), xxl radius, xl32 padding, ambient shadow. Three sections:
  - Left: "Good morning, [Name]!" Noto Serif Headline Medium (28pt), On Primary. Below: career interest tag (chip, lime bg) + "Grade 11" label (Manrope 14pt, On Primary 80%).
  - Center: Quick action buttons row — "Log Activity" / "Add College" / "Chat Advisor" — each a small card (SurfaceContainerLowest bg at 15% opacity, lg radius, sm8 padding, icon + label Manrope 12pt, On Primary). Hover: bg at 25% opacity.
  - Right: Avatar circle (56px, initials or photo) + streak fire icon with count badge (Accent Lime bg, On Surface text, 24px circle, Manrope 10pt bold).
- **Row 2 — Three columns, lg24 gap:**
  - **Checklist Progress card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Centered circular progress ring (120px diameter, Primary stroke, SurfaceContainerHigh track, 6px stroke width). Inside ring: fraction "12/20" Manrope 22pt title bold. Below ring: "Tasks Complete" Manrope 12pt label, On Surface Variant. "View All" — Primary link, Manrope 12pt, bottom of card.
  - **Next Up card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Task name Manrope 16pt title bold. Category chip (pill, SurfaceContainerHigh). Linear progress bar (Primary fill, 4px, lg radius). "Continue" — AccentBtn, sm size, mt md16.
  - **Urgent Deadline card:** Inverse Surface (#343029) bg, xl radius, Error border (2px left), xl32 padding. "Due Tomorrow" label (Error color, Manrope 10pt label uppercase, tracking +2.0). College/task name (Manrope 16pt title, On Surface dark-mode equivalent #eae1d7). Countdown: "23h 14m" Noto Serif Headline Small (24pt), Error color.
- **Row 3 — Two columns, lg24 gap:**
  - **Quick Stats card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. 2x2 inner grid (md16 gap). Each stat cell: label (Manrope 10pt label, On Surface Variant, tracking +2.0) + value (Manrope 22pt title bold, On Surface) + trend arrow (up green/down red) + delta (Manrope 10pt). Stats: GPA / SAT / Colleges Saved / Day Streak.
  - **Daily Tip card:** Gradient from Secondary Fixed (#caf24d) at 20% opacity to Surface, xl radius, ambient shadow, xl32 padding. Lightbulb icon (32px, Secondary #516600). "Tip of the Day" Manrope 10pt label, Secondary, tracking +2.0. Tip text Manrope 14pt, On Surface. "Learn More" Primary link.

### B2. WEEKLY 3 THINGS
- Modal or centered card overlay (500px width), SurfaceContainerLowest bg, xxl radius, floating shadow, xxxl64 padding.
- Sparkle icon (32px, Accent Lime) top-left.
- "This Week's Priorities" — Noto Serif Headline Small (24pt), On Surface.
- "AI-curated based on your deadlines and goals." Manrope 12pt, On Surface Variant, mt xs4.
- 3 task cards stacked, md16 gap, mt lg24:
  - Each card: SurfaceContainerLow bg, lg radius, md16 padding.
    - Top row: priority badge (pill, numbered "1"/"2"/"3", Primary bg On Primary text for #1, SurfaceContainerHigh for others) + category chip (pill, Manrope 10pt label).
    - Title: Manrope 16pt title bold, On Surface.
    - Bottom row: due date (Manrope 12pt, On Surface Variant, calendar icon) + "Do It" — small AccentBtn, right-aligned.
    - Hover: lift shadow, border Outline Variant.
- "Dismiss" text button, centered, mt lg24.

### B3. NOTIFICATIONS CENTER
- Full-page layout with sidebar. Content area: master-detail split.
- **Left panel (35%):** SurfaceContainerLow bg, full height.
  - Top: "Notifications" Manrope 16pt title bold, xl32 padding. Filter tabs below: "All" / "Unread" / "Deadlines" / "Advisor" — horizontal pills (SurfaceContainerHigh default, Primary bg when selected, Manrope 12pt label).
  - Notification list: scrollable. Each item: xl32 horizontal padding, md16 vertical padding. Hover: SurfaceContainerHigh bg. Unread: bold title + small Primary dot (8px) left edge. Icon (category-specific, 20px) + content area: title (Manrope 14pt, bold if unread) + preview text (Manrope 12pt, On Surface Variant, 1-line truncate) + timestamp (Manrope 10pt label, On Surface Variant).
  - Selected item: SurfaceContainer bg, Primary left border (3px).
- **Right panel (65%):** SurfaceContainerLowest bg, xl32 padding.
  - Expanded notification: icon (32px) + title (Manrope 16pt title bold) + timestamp + full message body (Manrope 14pt) + action buttons (PrimaryBtn + outlined secondary). Context-specific content below (e.g., deadline card, task link).
  - **Empty state:** centered illustration (mailbox, 120px), "Select a notification" Manrope 14pt, On Surface Variant.

### B4. STREAK & ACHIEVEMENTS
- Full-page layout. Content: two-column, lg24 gap.
- **Left column (50%):**
  - Streak header: fire icon (48px, gradient orange-red) + streak count (Noto Serif Display Medium 45pt, On Surface) + "Day Streak" (Manrope 14pt, On Surface Variant). Row layout, items baseline-aligned.
  - Streak calendar card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Month grid (7 columns, S-M-T-W-T-F-S headers Manrope 10pt label). Each day: 32px circle. Active day: Primary bg. Inactive: SurfaceContainerHigh. Today: Primary border. Missed: transparent. Hover: tooltip with activity count.
  - Longest streak card below: SurfaceContainerLow bg, lg radius, md16 padding. Trophy icon + "Longest Streak: 28 days" Manrope 14pt bold + date range.
- **Right column (50%):**
  - "Achievements" — Noto Serif Headline Small (24pt), mb lg24.
  - Achievement grid: 3 columns, md16 gap. Each achievement: SurfaceContainerLow bg, lg radius, xl32 padding, centered content. Icon/badge (48px, unique per achievement — star, rocket, book, etc.). Title (Manrope 14pt bold). Description (Manrope 12pt, On Surface Variant).
  - Unlocked: full color, ambient shadow.
  - Locked: grayed out (On Surface at 30% opacity), lock overlay icon (small, bottom-right).
  - Progress toward next: below grid, card with progress bar (Primary fill) + "3 more tasks to unlock 'Task Master'" Manrope 12pt.

### C1. TASKS VIEW
- Full-page layout. Content: three-panel layout.
- **Left panel — Filter Sidebar (240px):** SurfaceContainerLow bg, full height, xl32 padding.
  - Search field: small text field, magnifying glass icon, "Search tasks..." placeholder.
  - "Categories" label (Manrope 10pt label, tracking +2.0, On Surface Variant), mt lg24.
  - Category list: each item is a row — category name (Manrope 14pt) + count badge (SurfaceContainerHigh pill, Manrope 10pt). Selected: Primary text, bold. Hover: SurfaceContainerHigh bg. Categories: All / Academics / Testing / Activities / Essays / Applications / Financial.
  - Sort section: "Sort By" label + dropdown (Due Date / Priority / Category / Recently Added).
- **Center panel — Task List:** SurfaceContainerLowest bg, scrollable.
  - Task items: full-width rows, md16 vertical padding, xl32 horizontal padding. Checkbox (circle, 20px, Outline border; checked: Primary fill + white check) + title (Manrope 14pt; completed: strikethrough, On Surface Variant) + category chip (pill, small) + due date (Manrope 12pt, On Surface Variant; overdue: Error color). Hover: SurfaceContainerHigh bg + quick-action icons appear on right (edit pencil, delete trash, flag — icon buttons 28px with tooltips).
  - Selected task: SurfaceContainer bg, Primary left border (3px).
  - Completed section: collapsible, "Completed (8)" header with chevron toggle, Manrope 14pt, On Surface Variant.
- **Right panel — Task Detail (360px):** SurfaceContainerLow bg, xl32 padding.
  - Title: Manrope 16pt title bold.
  - Meta row: status badge (pill, Primary bg for active, SurfaceContainerHigh for pending) + category chip + priority chip (Error bg for high, amber for medium, SurfaceContainerHigh for low).
  - Due date with calendar icon, Manrope 14pt.
  - Description: Manrope 14pt body, On Surface, mt md16.
  - Subtasks section: "Subtasks" label + nested checkboxes (indented, same style as main checkboxes, Manrope 14pt).
  - Resources: "Resources" label + link cards (icon + title + URL, hover underline).
  - Notes: "Notes" label + textarea (SurfaceContainerLowest bg, Outline border, lg radius, Manrope 14pt, 4 rows). Placeholder "Add notes..."
  - "Mark Complete" — AccentBtn, full width, mt lg24.
  - **Empty state (no task selected):** centered, clipboard icon (48px, On Surface Variant at 40%), "Select a task to view details" Manrope 14pt, On Surface Variant.

### C2. TASK DETAIL (Full Page)
- Single-column layout (700px centered), xl32 padding.
- Back link: "← Tasks" Primary link, Manrope 14pt, mb lg24.
- Title: Noto Serif Headline Medium (28pt), On Surface.
- Meta row: status badge + category chip + priority chip + due date with icon. mt sm8, horizontal, sm8 gaps.
- Description section: Manrope 16pt body, On Surface, mt lg24. Multiple paragraphs supported.
- Subtasks card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding, mt lg24. "Subtasks" Manrope 14pt title bold. Checkbox items, md16 vertical gap.
- Resources card: same card style. "Resources" label. Link items: icon (external link/document) + title (Manrope 14pt, Primary color, hover underline) + URL (Manrope 12pt, On Surface Variant).
- Notes section: "Notes" Manrope 14pt title bold. Textarea (SurfaceContainerLowest bg, Outline border, lg radius, Manrope 14pt, 6 rows, full width).
- Action buttons row, mt xl32: "Mark Complete" AccentBtn + "Edit" outlined button + "Delete" text button (Error color, hover Error Container bg).

### C3. ROADMAP
- Full-page layout. Content: horizontal scrollable timeline.
- **Grade tabs** at top: "9th" / "10th" / "11th" / "12th" — tab bar with underline indicator (Primary, 3px, animated slide). Manrope 14pt title. Selected: On Surface bold, Primary underline. Unselected: On Surface Variant.
- Timeline area below: horizontal scroll container.
  - **Quarter columns** (4 per grade): "Q1 Fall" / "Q2 Winter" / "Q3 Spring" / "Q4 Summer" — column headers (Manrope 12pt label, tracking +2.0, On Surface Variant). Each column ~280px wide, SurfaceContainerLowest bg, lg radius, md16 padding.
  - Milestone cards within columns: SurfaceContainerLow bg, lg radius, md16 padding. Title (Manrope 14pt bold) + category chip + due month. Vertical connector lines (Outline Variant, 1px) between cards within same column.
  - Current quarter: Primary border (2px) on column, subtle PrimaryGlow.
  - Completed milestones: green check icon replacing bullet, title with strikethrough effect, On Surface Variant color.
- **Right collapsible sidebar (280px):** SurfaceContainerLow bg, xl32 padding. "Progress" Manrope 14pt title bold. Per-quarter mini progress bars (label + bar + fraction). Toggle: chevron button on sidebar edge.

### C4. ACTIVITY TRACKER
- Full-page layout. Content: master-detail split.
- **Left panel (40%):** SurfaceContainerLowest bg, xl32 padding, scrollable.
  - Top: "Activities" Manrope 16pt title bold + "Add Activity" AccentBtn (small, icon +).
  - Filter tabs: "All" / "Academic" / "Athletic" / "Arts" / "Service" / "Work" — horizontal scroll pills.
  - Activity cards stacked, md16 gap: SurfaceContainerLow bg, lg radius, md16 padding. Activity name (Manrope 14pt bold) + organization (Manrope 12pt, On Surface Variant) + role chip (pill, SurfaceContainerHigh) + years badge. Hover: lift + border Outline Variant. Selected: Primary left border (3px).
- **Right panel (60%):** SurfaceContainerLow bg, xl32 padding.
  - Activity name: Noto Serif Headline Small (24pt).
  - Meta row: organization (Manrope 14pt) + category chip + role chip + years (Manrope 14pt).
  - Hours chart: small bar chart (200px height) showing hours per month/semester. Primary bars, Outline Variant axis. Manrope 10pt labels.
  - Description: Manrope 14pt body, mt md16.
  - Skills tags: flow layout of chips (pill, SurfaceContainerHigh, Manrope 12pt).
  - Awards section: bullet list with trophy icons + award names.
  - Action buttons: "Edit" outlined button + "Delete" text button (Error color).

### C5. PRE-ADMISSION CHECKLIST
- Single-column layout (700px centered), xl32 padding.
- **College banner** at top: full-width card, gradient overlay on college photo bg (or solid Primary Container if no photo), xl radius, xl32 padding. College name (Noto Serif Headline Small 24pt, On Primary) + "Pre-Admission Checklist" Manrope 14pt, On Primary 80%.
- **Progress bar** below banner: full-width, 8px height, lg radius. Primary fill, SurfaceContainerHigh track. Percentage label right-aligned (Manrope 12pt, On Surface Variant). mt md16.
- **Categorized sections** (stacked, lg24 gap, mt lg24):
  - Section header: category name (Manrope 14pt title bold, On Surface) + item count (Manrope 12pt, On Surface Variant).
  - Checklist items: SurfaceContainerLow bg, lg radius, md16 padding. Each row: checkbox (circle, 20px) + item title (Manrope 14pt) + status badge (pill — "Not Started"/"In Progress"/"Complete", color-coded) + due date (Manrope 12pt, On Surface Variant, right-aligned). Hover: SurfaceContainerHigh bg.
  - Categories: Testing / Transcripts / Recommendations / Essays / Financial Aid / Supplementals.

### C6. POST-ADMISSION CHECKLIST
- Single-column layout (700px centered), xl32 padding.
- **Celebration header:** SurfaceContainerLow bg card, xl radius, xl32 padding. Confetti/party icon (48px) + "Congratulations!" Noto Serif Headline Small (24pt) + "You've been accepted to [College Name]" Manrope 14pt, On Surface Variant. Accent Lime subtle glow on card.
- **Sections** (stacked, lg24 gap, mt lg24): Each section is a card (SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding).
  - **Decision:** Accept/Decline buttons, deposit deadline, comparison link.
  - **Housing:** Housing application checklist items, preferences form link, deadline.
  - **Registration:** Orientation signup, course registration, advisor meeting.
  - **Financial:** Final aid package review, scholarship deadlines, payment plan.
  - **Preparation:** Roommate finder, campus map, move-in date.
  - Each section: title (Manrope 16pt title bold) + checklist items (checkbox + title + status + due date) + timeline bar showing window (start date → deadline, Primary fill for elapsed).

---

**Deliverable:** Design all 10 screens at 1440px width. Batch 2 of 12.
