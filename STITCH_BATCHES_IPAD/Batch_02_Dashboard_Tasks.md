You are designing iPad screens for Ladder, a college preparation app. This is batch 2 of 12 (screens listed below). Use these exact design tokens for all screens.

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

### B1. STUDENT DASHBOARD
Two-column grid. Left (60%): Welcome Header Card (gradient green, greeting + career badge + grade badge + avatar with streak fire), Next Up Card (task title + category + progress bar + "Continue"), Daily Tip Card (gradient lime, lightbulb icon, tip text). Right (40%): Checklist Progress Card (100px circular progress with glow + count + "View All Tasks"), Urgent Deadline Card (dark card, red left border, deadline title + college + days remaining), Quick Stats Grid (2x2: GPA, SAT, Colleges Saved, Streak Days with icons + numbers + trend arrows).

### B2. WEEKLY "3 THINGS TO DO"
Card component. "This Week's Priorities" header. 3 prioritized task cards: priority number badge (1/2/3), task title, category chip + due date, "Do It" accent button. "See All Tasks" link. AI-generated.

### B3. NOTIFICATIONS CENTER
Master-detail split. Left (40%): "Notifications" header + badge, filter tabs (All/Deadlines/Tasks/Scholarships/Messages), notification list (unread bold + icon + title + preview + time ago, swipe to dismiss). Right (60%): Expanded detail with action buttons per type (View Application, Complete Task, etc.).

### B4. STREAK & ACHIEVEMENTS
Two-column. Left (55%): Current streak fire icon + count (Display Medium), streak calendar (month grid, lime days), longest streak, motivational text. Right (45%): Achievements badge grid (3 columns, locked = grayed silhouettes).

### C1. TASKS VIEW
Two-panel split. Left (40%): Contained header card (gradient green), circular progress 56pt + count, search bar, filter chips (All/Academic/Extracurricular/Application/Financial/Housing/Test Prep), TO DO task rows (checkbox + category icon + title + desc + chip + due date + priority dot), COMPLETED section (collapsible). Right (60%): Selected task detail (title + category + priority + due date + description + subtasks + resources + notes + "Mark Complete"). Empty state if none selected.

### C2. TASK DETAIL (Full Screen)
Single column (700pt). Back button toolbar. Title (Headline Large), status badge, category + priority + due date, full description, subtasks checklist, resources link cards, notes textarea. "Mark Complete" primary, "Edit" secondary, "Delete" tertiary red.

### C3. ROADMAP (4-Year Timeline)
Full-width horizontal timeline. Grade picker: 4 large tab buttons (9-12 with labels). Horizontal scroll: quarter columns (Fall/Winter/Spring/Summer, 240pt each). Milestone cards per quarter: category chip + title + description + checkbox. Vertical connector within column, horizontal between. Current quarter highlighted. Completed = green check + strikethrough.

### C4. ACTIVITY TRACKER
Two-panel. Left (45%): "My Activities" + count + "Add Activity", activity cards (name + category chip + role + hours + years + impact badge). Right (55%): Selected detail (name + org + category + role + years + hours chart + description + awards + Edit/Delete). Empty state.

### C5. PRE-ADMISSION CHECKLIST
Single column (700pt). "Before You're Accepted" header + college name banner. Categories: Application Materials (Common App, essays, recs, transcripts, scores), Financial (FAFSA, CSS, scholarships), Preparation (visit, interview, interest). Items: checkbox + title + desc + due date + status. Progress bar top.

### C6. POST-ADMISSION CHECKLIST
Single column (700pt). "After You're Accepted" + college name + celebration header. Categories: Decision (accept/decline, deposit), Housing (app, roommate, meal plan), Registration (orientation, placement, courses), Financial (aid, loans, scholarships), Preparation (health forms, immunizations). Items with checkboxes + due dates. Timeline showing open/close windows.

---

Design all 10 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 2 of 12.
