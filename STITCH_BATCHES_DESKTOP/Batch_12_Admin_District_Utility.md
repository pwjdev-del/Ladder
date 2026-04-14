You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 12 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

## Design System — "Evergreen Ascent"

**Colors (Light):** Primary #42603f, Primary Container #5a7956, On Primary #ffffff, Secondary (Lime) #516600, Secondary Fixed #caf24d, Accent Lime #A1C621, Tertiary #725232, Surface #fff8f2, Surface Container Lowest #ffffff, Surface Container Low #fbf2e8, Surface Container #f5ede2, Surface Container High #efe7dd, Surface Container Highest #eae1d7, On Surface #1f1b15, On Surface Variant #434840, Outline #737970, Outline Variant #c3c8be, Error #ba1a1a, Error Container #ffdad6, Inverse Surface #343029, Inverse Primary #a8d4a0

**Colors (Dark):** Primary #a8d4a0, Primary Container #304e2e, On Primary #1a3518, Secondary #b3d430, Surface #1f1b15, Surface Container Low #252119, Surface Container #2a2620, Surface Container High #353027, On Surface #eae1d7, Error #ffb4ab

**Typography:** Noto Serif for headlines (56/45/36/32/28/24pt). Manrope for body (22/16/14pt titles, 16/14/12pt body, 14/12/10pt labels). Editorial tracking -0.5 headlines, wide +2.0 labels.

**Spacing (8pt):** xxs2 xs4 sm8 md16 lg24 xl32 xxl48 xxxl64 xxxxl80. Radius: sm8 md12 lg16 xl24 xxl32 xxxl40 pill9999.

**Shadows:** Ambient rgba(31,28,20,.06) blur20 y4. Floating blur30 y10. Glow rgba(201,242,77,.30) blur15. PrimaryGlow rgba(66,96,63,.15) blur20 y4.

**Components:** PrimaryBtn gradient pill white hover:brightness+glow. AccentBtn lime dark glow. Cards SurfaceContainerLow XL ambient hover:lift. Chips SurfaceContainerHigh pill hover:outline. TextFields SurfaceContainerLowest outline focus:primary glow. TableRows hover:SurfaceContainerHigh. Links primary underline-on-hover. No dividers. Tooltips on icon buttons. Right-click context menus.

## Desktop Navigation
Top bar (64px): Logo+sidebar toggle | breadcrumbs | search(Cmd+K) + bell + theme + profile dropdown.
Left sidebar (240px, collapsible to 64px): 9 sections with sub-items. Selected=primary pill. Icons+tooltips when collapsed.
Content: max 1200px centered, xl padding. Keys: Cmd+K search, Cmd+N new, Cmd+/ sidebar, Esc close.

---

# Batch 12: Admin + District + Utility (16 screens)

## P1. ADMIN DASHBOARD
Row 1: 4 metric cards (SurfaceContainerLow, XL radius, ambient shadow): Total Students (with trend arrow), Active Counselors, Acceptance Rate, Avg Scholarships Per Student. Each card has icon, value (Headline Medium), label, and percentage change.

Row 2: Acceptance rate chart (60% width, grouped bar chart by year/school, Primary + Accent Lime bars) + Grade distribution donut chart (40% width, segments colored by grade level).

Row 3: At-risk students table (50% width, compact: Name | Grade | Risk Level badge | Last Active) + Top college destinations table (50% width: College | Accepted Count | Yield %). Both tables with hover rows and sortable headers.

Action buttons below: "View All Students" (PrimaryBtn), "Manage Counselors" (outlined), "Download Report" (outlined).

## P2. CLASS CATALOG
Left panel (55%): Course catalog table (sortable). Columns: Course Code | Name | Department | Credits | Level (Regular/Honors/AP/DE) | Prerequisites | Capacity. Sortable headers, hover rows, inline editing on click. "Add Course" AccentBtn at top. "Upload CSV" outlined button for bulk import.

Right panel (45%): Course edit form (SurfaceContainerLow, XL radius). Fields: code, name, department dropdown, description textarea, credits, level dropdown, prerequisites multi-select, capacity, teacher assignment. "Save" (PrimaryBtn) + "Delete" (Error text button). "Publish Catalog" PrimaryBtn at bottom of panel (publishes all changes).

## P3. SCHOOL PROFILE
Form layout (700px max-width, centered). School logo upload (circle, 96px) with "Change" link. Fields organized in sections: Basic Info (school name, address, city, state, zip, district), Administration (principal name, phone, email), Details (school type dropdown, total enrollment, student-counselor ratio, graduation rate). Programs section: tags input for available programs (AP, IB, DE, CTE). Clubs section: tags input. Academic calendar: start/end date pickers. "Save Profile" (PrimaryBtn) + "View Public Profile" (outlined, opens preview).

## P4. AMBASSADOR SIGNUP
Marketing page layout (700px max-width). Hero section: headline (Display Small, Noto Serif) "Become a Ladder Ambassador", subheading explaining the program. Benefits section: 3 cards in a row (icon + title + description): Earn Commission, Help Students, Grow Your Practice. Requirements list (checkmark icons): credentials, experience, commitment. Application form: name, email, school/organization, role, years of experience, specialties multi-select, why interested textarea. "Apply Now" PrimaryBtn.

## P5. DATA EXPORT
Centered container (600px max-width). Export type radio group: Student Data, Application Data, Scholarship Data, Analytics Summary, Full Report. Date range picker (start + end). Grade filter (multi-select chips). Format selector: CSV, XLSX, PDF. "Generate Export" PrimaryBtn. Processing state: spinner with progress text. Download history table below: Date | Type | Format | Size | "Download" link. Each export available for 30 days.

## P6. DPA MANAGEMENT
Left panel (55%): DPA (Data Processing Agreement) list. Each entry: vendor/partner name (Title Small), agreement type, status badge (Active green, Expiring Soon amber, Expired red), renewal date. Search and filter at top.

Right panel (45%): Selected DPA detail. Document viewer (embedded PDF/preview area). Key terms summary card. Signature status (both parties). Action buttons: "Renew Agreement" (PrimaryBtn), "Download PDF" (outlined). Audit trail at bottom (date + action + user).

## P7. ANNOUNCEMENT MANAGER
Same layout as O11 (Announcement Composer) with additional admin features. Scope selector includes: All Schools, Specific Schools multi-select, All Roles. Analytics section below past announcements: Sent count, Read count (with %), Click-through rate. Past announcements table: Date | Title | Audience | Sent | Read | CTR. Click to view/edit. "New Announcement" AccentBtn at top.

## Q1. DISTRICT DASHBOARD
Metrics row: 4 cards (Total Students across district, Schools, Avg Acceptance Rate, Total Scholarships). School comparison table below (full width, sortable): School Name | Students | Counselors | Avg GPA | Acceptance Rate | Scholarship Total | At-Risk %. Click row to drill down into school admin view. Equity summary cards (2-3 cards): demographic representation, first-gen stats, free/reduced lunch correlation. Bright Futures chart: district-wide eligibility trending by year (area chart, Primary fill). Action buttons: "Export District Report" (PrimaryBtn) + "Schedule Monthly Report" (outlined).

## Q2. SCHOOL COMPARISON
School selector at top: 2-3 school multi-select dropdowns. Comparison table below with rows for all key metrics: Enrollment, Counselor Ratio, Avg GPA, Avg SAT, Acceptance Rate, Scholarship Per Student, At-Risk %, Bright Futures Eligible %, College-Going Rate. Green highlight on best value per row, red on concerning values. Bar charts below table for visual comparison of key metrics (grouped bars, one color per school). "Export Comparison" outlined button.

## Q3. EQUITY METRICS
Cards row: key equity metrics (First-Gen Rate, Free/Reduced Lunch %, Demographic Diversity Index, Achievement Gap Score). Demographic charts section: acceptance rates by ethnicity (grouped bar), scholarship distribution by income (stacked bar), AP enrollment by demographic (100% stacked bar). Year-over-year trends: line charts showing progress on equity goals. AI action plan card (SurfaceContainerLow, sparkles, Primary left border): recommended interventions based on data patterns. "Export Equity Report" PrimaryBtn.

## Q4. REPORT GENERATOR
Wizard layout (700px max-width). Step 1: Report type selector (cards: Student Outcomes, Financial Summary, Equity Analysis, Custom). Step 2: Section checkboxes (which data to include). Step 3: Date range picker + school selector (multi-select for district). Step 4: Format (PDF, XLSX, Slides). "Generate Report" PrimaryBtn. Processing state: progress bar with estimated time. Download when complete. Recent reports list below with "Regenerate" option.

## R1. FIRST 100 DAYS
Left panel (55%): Vertical timeline from May through August. Each month is a section with milestone nodes (circles on a vertical line, completed = Primary fill, upcoming = Primary border). Milestones: Graduation, Housing Deposit, Orientation Registration, Roommate Selection, Course Registration, Financial Aid Acceptance, Packing, Move-In. Each node expands to show task details and links.

Right panel (45%): Countdown ring (large, centered, showing days until move-in). Current tasks card: active to-do items with checkboxes. Packing checklist (collapsible, categorized: Bedding, Electronics, School Supplies, Personal, Documents). "Share with Parent" outlined button at bottom.

## R2. GLOBAL SEARCH / COMMAND PALETTE
Modal overlay (600px max-width, centered vertically in upper third). Large search TextField with magnifying glass icon (auto-focused). Results grouped by category with section headers: Pages (navigation links), Students (for counselors), Colleges, Scholarships, Documents. Each result: icon + title + breadcrumb path + keyboard hint. Recent searches section when input is empty. Keyboard navigation: arrow keys to move, Enter to select, Esc to close. Trigger: Cmd+K from anywhere in the app.

## R3. OFFLINE / SYNC STATUS
Amber banner across top of content area (below top bar): "You are currently offline. Changes will sync when reconnected." Click banner to expand detail card: Last Synced timestamp, Pending Changes list (count + types: edits, new entries, uploads), "Sync Now" PrimaryBtn (active when connection restored), Conflicts section (if any: item name + local vs. server version + resolve options). Collapse back to banner.

## R4. CONTENT MODERATION
Queue layout. Left panel (40%): report queue list. Each entry: content type icon (essay, message, profile), reporter name, reported user, timestamp, severity badge (Low blue, Medium amber, High red). Filter chips at top: All, Pending, Reviewed.

Right panel (60%): selected report detail. Full content display (SurfaceContainerLowest, lg radius). AI assessment card (SurfaceContainerLow, sparkles): automated analysis of content with confidence score and category (spam, inappropriate, harassment, other). Action buttons: "Approve Content" (outlined, green), "Remove Content" (PrimaryBtn, Error-tinted), "Warn User" (outlined, amber), "Suspend User" (Error outlined). Audit trail below: previous moderation actions on this user/content.

## R5. DATA DELETION
Centered container (500px max-width). Warning icon (Error red, 48px) at top. Title (Headline Medium): "Delete Your Account". Description explaining what happens. Two sections: "Will Be Permanently Deleted" list (red X icons: profile, essays, activities, messages) and "Will NOT Be Deleted" list (checkmark icons: counselor records, aggregate analytics). Confirmation: "Type DELETE to confirm" TextField. "Delete My Account" button (Error fill, white text, disabled until DELETE typed). "Cancel" outlined button. "Download My Data First" link (Primary, underline-on-hover) above the delete button.

---

**Deliverable:** Design all 16 screens at 1440px. Batch 12 of 12.
