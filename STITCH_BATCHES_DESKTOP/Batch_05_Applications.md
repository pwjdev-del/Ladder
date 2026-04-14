# Batch 5 of 12 — Applications (8 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 5 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

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

### E1. APPLICATION TRACKER
- Full-page layout with sidebar (Applications selected). Content: master-detail split.
- **Left panel (40%):** SurfaceContainerLowest bg, xl32 padding, scrollable.
  - Top: "Applications" Noto Serif Headline Small (24pt) + count badge (pill, SurfaceContainerHigh) + "Add Application" AccentBtn (small, + icon).
  - Filter chips row: "All" / "In Progress" / "Submitted" / "Accepted" / "Waitlisted" — horizontal pills (SurfaceContainerHigh default, Primary bg when selected, Manrope 12pt label). Scrollable if overflow.
  - Application cards (stacked, md16 gap, mt md16):
    - Card: SurfaceContainerLow bg, lg radius, ambient shadow, md16 padding. College logo/initials (36px circle) + name (Manrope 14pt title bold) + deadline (Manrope 12pt, On Surface Variant, calendar icon). Status badge (pill, color-coded). Progress bar (thin 4px, Primary fill, SurfaceContainerHigh track, bottom of card). Hover: lift, border Outline Variant. Selected: Primary left border (3px), SurfaceContainer bg.
    - Right-click: context menu (View Detail / Edit / Mark Submitted / Remove).
- **Right panel (60%):** SurfaceContainerLow bg, xl32 padding.
  - Selected application detail: college name (Noto Serif Headline Small 24pt) + status badge + deadline countdown. Tabs: "Overview" / "Checklist" / "Documents" / "Notes". Content per tab (see E2 for full detail view).
  - **Empty state:** centered illustration (folder with magnifying glass, 120px), "Select an application" Manrope 14pt, On Surface Variant. Below: "or **add your first application**" Primary link.

### E2. APPLICATION DETAIL
- Full-page layout. Content: three-column layout, lg24 gap.
- **Left column (30%):** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding.
  - **Status card:** college logo/initials (56px circle, centered) + name (Manrope 16pt title bold, centered) + status badge (pill, centered, mt sm8). Large status icon above badge (check/clock/hourglass, 32px).
  - **Key dates timeline** (mt lg24): vertical timeline, Primary line (2px left). Date nodes: circle (12px, Primary fill for past, Outline for future) + label + date. Items: "Added to List" / "Application Started" / "Essay Draft" / "Submitted" / "Decision Expected". Manrope 12pt each.
  - **Quick actions** (mt lg24): stacked buttons, full width. "Edit Application" outlined button. "Contact Admissions" outlined button. "View College Profile" Primary link. "Remove Application" text button (Error color, mt md16).
- **Center column (45%):** SurfaceContainerLowest bg, xl32 padding.
  - **Progress bar** at top: horizontal steps (6 items: "Info" / "Essays" / "Recs" / "Scores" / "Review" / "Submit"). Connected by line. Each step: circle (24px) + label (Manrope 10pt). Complete: Primary fill + check. Current: Primary border, pulsing. Upcoming: Outline Variant fill.
  - **Checklist sections** below (stacked, lg24 gap, mt lg24): each section is a card (SurfaceContainerLow bg, lg radius, md16 padding).
    - Section title (Manrope 14pt title bold) + completion fraction (Manrope 12pt, On Surface Variant).
    - Checklist items: checkbox + item name (Manrope 14pt) + status indicator (icon — check green, clock amber, X red). Hover: SurfaceContainerHigh bg + edit pencil icon appears right.
    - Sections: Personal Information / Essays & Writing / Recommendations / Test Scores / Supplemental Materials.
- **Right column (25%):** SurfaceContainerLow bg, xl radius, xl32 padding.
  - **Application timeline** (recent activity): "Activity" Manrope 12pt label, tracking +2.0. List: timestamp (Manrope 10pt, On Surface Variant) + action description (Manrope 12pt). Most recent first. Max 10 items, "View All" link.
  - **Documents** (mt lg24): "Documents" Manrope 12pt label, tracking +2.0. File items: file icon (type-specific: PDF red, DOC blue, IMG green) + file name (Manrope 12pt, truncated) + status icon (uploaded check / pending clock / missing warning triangle). Hover: underline name. "Upload" small text button at bottom.
  - **Notes** (mt lg24): "Notes" Manrope 12pt label. Textarea (SurfaceContainerLowest bg, Outline border, lg radius, Manrope 12pt, 4 rows). Auto-saves.

### E3. DEADLINES CALENDAR
- Full-page layout. Content: two-column (75/25 split), lg24 gap.
- **Main — Calendar (75%):**
  - Top bar: month navigation (left/right arrow icon buttons + "November 2026" Noto Serif Headline Small 24pt) + view toggles right ("Month" / "Week" / "List" — pills, SurfaceContainerHigh default, Primary bg selected, Manrope 12pt).
  - Month grid: 7 columns (Sun-Sat headers, Manrope 10pt label, tracking +2.0). Day cells (~160px wide, ~120px tall, SurfaceContainerLowest bg, sm8 radius, xs4 gap). Day number top-left (Manrope 12pt). Deadline dots within cell: small colored pills (college initials + type icon, truncated if >3, "+2" overflow label). Color-coding: Primary for regular deadline, Error for urgent (<7 days), Accent Lime for completed/submitted. Today: Primary border (2px). Selected day: Primary bg at 10%, border Primary.
  - Hover on cell: subtle lift.
  - Click on deadline dot: popover with full details (college name, deadline type, date, status, "Go to Application" link).
- **Sidebar (25%):** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding.
  - **Selected date deadlines:** date header (Manrope 14pt title bold, formatted "Monday, Nov 15"). Deadline items (stacked, md16 gap): colored left border (3px) + college name (Manrope 14pt bold) + type (Manrope 12pt, On Surface Variant — "Early Decision" / "Regular" / "Financial Aid") + time remaining (Manrope 12pt, color-coded). Click: navigate to application.
  - **Upcoming** (mt lg24): "Upcoming Deadlines" Manrope 12pt label, tracking +2.0. Next 5 deadlines, compact list: date + college + type.
  - **Overdue** (mt lg24): "Overdue" Manrope 12pt label, Error color. Items with Error left border + Error text.

### E4. APPLICATION SEASON DASHBOARD
- Full-page layout. Content area full width.
- **Top strip:** SurfaceContainerLow bg, xl radius, xl32 padding. Three items in a row:
  - Countdown: "45 days until Regular Decision" — Noto Serif Headline Small (24pt), On Surface + clock icon.
  - Stats: 4 inline stat pills (Applications Started / Submitted / Decisions Received / Accepted — each: value Manrope 16pt bold + label Manrope 10pt, SurfaceContainerHigh bg pill).
  - "Chat with Advisor" AccentBtn (small, sparkle icon).
- **Kanban board** below (mt lg24): 4 columns, horizontal scroll if needed, lg24 gap.
  - Column headers: "Preparing" / "In Progress" / "Submitted" / "Decided" — Manrope 14pt title bold + count badge (pill). Each column: SurfaceContainerLowest bg, xl radius, md16 padding, min 280px width.
  - Cards within columns: SurfaceContainerLow bg, lg radius, md16 padding, mb sm8. College name (Manrope 14pt bold) + deadline (Manrope 12pt, On Surface Variant) + progress bar (thin 3px). Drag handle (6 dots, On Surface Variant, left edge). Draggable between columns (drag: floating shadow, slight rotation, origin column dimmed placeholder). Hover: lift, border Outline Variant.
  - Click card: detail drawer slides from right (same as E1 right panel).
- **Bottom action items strip** (mt lg24): SurfaceContainerLow bg, xl radius, xl32 padding. "Action Items" Manrope 14pt title bold. Horizontal scroll of mini task cards: icon + title + due date. Hover: border Primary.

### E5. SUBMISSION TRACKER
- Single-column layout (700px centered), xl32 padding.
- **Horizontal stepper** at top: 6 steps in a row, connected by lines. Each step: circle (32px) + label below (Manrope 10pt label, tracking +2.0). States: completed = Primary fill + white check icon (checkmark), current = Primary border + pulsing dot center + Primary text label, upcoming = Outline Variant fill + Outline Variant text. Steps: "Personal Info" / "Essays" / "Recommendations" / "Test Scores" / "Review" / "Submit".
- **Current step detail card** below (mt xl32): SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding.
  - Step title (Noto Serif Headline Small 24pt) + completion status (Manrope 14pt, On Surface Variant — "3 of 5 items complete").
  - Checklist of items for current step: checkbox + item name + status badge. mt md16.
  - Warning banners if applicable: amber bg card, warning icon, "Your SAT scores haven't been sent to this school yet." Manrope 14pt. "Send Scores" Primary link.
- **"Review & Submit" section** (visible on step 5/6): SurfaceContainerLow bg, xl radius, xl32 padding, mt lg24. Summary of all sections with green checks or warning icons. "Submit Application" AccentBtn (large, full width, glow). Confirmation checkbox: "I confirm all information is accurate."
- **Post-submit confirmation** (replaces entire page content): centered, xxxl64 padding. Large green check circle (80px, Primary bg, white check, PrimaryGlow) + "Application Submitted!" Noto Serif Display Small (36pt) + college name + submission timestamp. Confetti animation (subtle, lime + primary colored dots falling). "View Confirmation" outlined button + "Back to Applications" PrimaryBtn.

### E6. DECISION PORTAL
- Full-page layout. Content: two-column (55/45 split), lg24 gap.
- **Left column (55%):** "Decisions" Noto Serif Headline Small (24pt), mb lg24.
  - Decision cards (stacked, md16 gap):
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Left color bar (4px, full height — Accent Lime for accepted, Primary for pending, amber for waitlisted, Error for denied).
    - College logo/initials (48px) + name (Manrope 16pt title bold) + decision badge (large pill — "Accepted!" Accent Lime bg bold / "Waitlisted" amber bg / "Denied" Error Container bg / "Pending" SurfaceContainerHigh).
    - Aid summary (if accepted): "Offered: $32,000/yr" Manrope 14pt, Primary color. Net cost: "$18,500/yr" Manrope 12pt, On Surface Variant.
    - Countdown (if pending): "Decision expected in 14 days" Manrope 12pt, On Surface Variant, clock icon.
    - Action buttons (bottom of card): accepted → "Accept Offer" AccentBtn + "Decline" outlined button + "Compare" text link. Waitlisted → "Write LOCI" PrimaryBtn + "View Strategy" text link. Pending → "Track" disabled chip.
    - Hover: lift shadow.
- **Right column (45%):**
  - **Summary card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. "Decision Summary" Manrope 14pt title bold. Donut chart (120px, centered): 4 segments (Accent Lime accepted, Primary pending, amber waitlisted, Error denied). Legend below chart with counts.
  - **"Compare Accepted" button:** AccentBtn, full width, mt md16. (Enabled only if 2+ accepted.)
  - **"Need Help Deciding?" card** (mt md16): SurfaceContainerLow bg, xl radius, xl32 padding. Sparkle icon + "Talk to Your Advisor" Manrope 14pt. "Get personalized help choosing the right school." Manrope 12pt, On Surface Variant. "Chat with Advisor" PrimaryBtn, mt sm8.

### E7. WAITLIST TRACKER
- Full-page layout. Content: two-column (55/45 split), lg24 gap.
- **Left column (55%):** "Waitlisted Schools" Noto Serif Headline Small (24pt), mb lg24.
  - School cards (stacked, md16 gap):
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Amber left border (4px).
    - College name (Manrope 16pt title bold) + "Waitlisted" amber badge.
    - LOCI (Letter of Continued Interest) status: progress indicator — "Not Started" / "Drafted" / "Sent" with corresponding icon (circle-outline / pencil / check-circle) and color (On Surface Variant / amber / Primary).
    - Additional materials checklist: compact list of items (updated transcript, additional rec, etc.) with check/pending icons.
    - "Write LOCI" AccentBtn (if not started/drafted) or "View LOCI" outlined button (if sent). mt md16.
    - Hover: lift shadow.
- **Right column (45%):**
  - **AI Strategy card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Sparkle icon + "Waitlist Strategy" Manrope 14pt title bold. Personalized advice bullets (Manrope 14pt, md16 gap): "Send your LOCI to [School] within 2 weeks." / "Update your transcript showing improved GPA." / "Have your counselor call admissions." "Chat with Advisor" Primary link.
  - **LOCI Preview card** (mt md16): SurfaceContainerLow bg, xl radius, xl32 padding. "LOCI Preview" Manrope 14pt title bold. Preview text area: SurfaceContainerLowest bg, lg radius, md16 padding, Manrope 14pt, 8 rows, read-only preview of latest draft. "Edit in Essay Editor" Primary link below.

### E8. SERVICE HOURS LOG
- Full-page layout. Content: master-detail split.
- **Left panel (40%):** SurfaceContainerLowest bg, xl32 padding, scrollable.
  - Top: "Service Hours" Manrope 16pt title bold + total hours badge (pill, Primary bg, On Primary, Manrope 14pt bold — "127 hours") + "Log Hours" AccentBtn (small, + icon).
  - Filter tabs: "All" / "Verified" / "Pending" — pills.
  - Entry cards (stacked, md16 gap, mt md16):
    - Card: SurfaceContainerLow bg, lg radius, md16 padding. Organization name (Manrope 14pt bold) + date (Manrope 12pt, On Surface Variant) + hours (Manrope 14pt bold, Primary) + status badge (pill — "Verified" Accent Lime / "Pending" amber / "Rejected" Error Container). Category chip (pill, SurfaceContainerHigh, Manrope 10pt — "Tutoring" / "Community" / "Environmental" etc.).
    - Hover: lift, border Outline Variant. Selected: Primary left border (3px).
- **Right panel (60%):** SurfaceContainerLow bg, xl32 padding.
  - **Entry form / detail view** (toggles based on context):
    - Form: "Log Service Hours" Manrope 16pt title bold. Fields: Organization (text, autocomplete) + Date (date picker) + Hours (number input, stepper) + Category (dropdown) + Description (textarea, 4 rows) + Supervisor name + Supervisor email (for verification). "Save" AccentBtn + "Cancel" outlined button.
    - Detail view: all fields displayed read-only with labels. Status badge + verification info. "Edit" / "Delete" buttons.
  - **Monthly chart** (mt lg24): bar chart (200px height), months on x-axis, hours on y-axis. Primary bars. Manrope 10pt labels. Current month highlighted (Accent Lime bar).
  - **Category breakdown** (mt lg24): horizontal stacked bar or small donut (80px) showing hours by category. Legend: colored dots + category name + hours. Manrope 12pt.

---

**Deliverable:** Design all 8 screens at 1440px width. Batch 5 of 12.
