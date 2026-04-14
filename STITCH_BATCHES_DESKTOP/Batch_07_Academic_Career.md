You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 7 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

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

# Batch 7: Academic + Career (12 screens)

## G1. GPA TRACKER
Left panel (55%): Trend chart showing semesters on x-axis and GPA on y-axis with two lines (unweighted in Primary, weighted in Accent Lime). Hover tooltips on data points showing exact GPA values. Below the chart: semester pill selectors (SurfaceContainerHigh, pill radius, selected = Primary fill with white text). Current GPA displayed as Display Small in Primary. Bright Futures eligibility card (SurfaceContainerLow, XL radius, ambient shadow) showing qualification status with progress bar.

Right panel (45%): Semester course table with columns: Name | Credits | Grade | Weight (dropdown for Honors/AP/DE/Standard). Each row is editable inline with TextFields. TableRows hover state (SurfaceContainerHigh). "Add Course" text button (Primary, underline-on-hover) below table. Live GPA calculation updates as grades change, displayed in a small card above the table. "Save" PrimaryBtn (gradient, pill, white text, hover:brightness+glow) at bottom right.

## G2. TRANSCRIPT UPLOAD
Left panel (40%): Drag-and-drop zone (SurfaceContainerLowest, dashed Outline border, XL radius). Icon centered with "Drop transcript here" Body Large text. "Browse Files" AccentBtn below. Camera/scan option as text link. Processing state: spinner with "Analyzing transcript..." text. Upload history list below showing previous uploads with date, filename, and status badge.

Right panel (60%): Parsed results area. Semester tabs (pill chips, horizontally scrollable). Course table per semester: Name | Grade | Credits | Weight | Status (checkmark green for confirmed, warning amber for needs review, X red for error). Each status has tooltip explaining the issue. GPA calculation summary card at bottom. Two action buttons: "Confirm All" (AccentBtn) and "Import to GPA Tracker" (PrimaryBtn).

## G3. AP SUGGESTIONS
Left panel (55%): Header "Recommended APs" with sparkles icon in Secondary. AI-generated recommendation cards (SurfaceContainerLow, XL radius, ambient shadow, hover:lift). Each card contains: AP course name (Title Medium), difficulty rating (1-5 dots, filled in Primary), AI reasoning paragraph (Body Small, On Surface Variant), prerequisites list, school average score, Bright Futures badge if applicable (Secondary Fixed chip). "Add to Schedule" AccentBtn per card.

Right panel (45%): Current APs section listing enrolled AP courses with status. Exam scores table (Subject | Score | College Credit). College credit equivalency map showing which colleges accept which scores. Course load balance visualization (bar chart showing difficulty distribution across semesters).

## G4. DUAL ENROLLMENT
Left panel (55%): Explainer card (SurfaceContainerLow) with overview of dual enrollment benefits. Course list below with cards: course name (Title Medium), partner college, credits earned, cost per credit, transfer acceptance rate, schedule compatibility. Filter chips at top (Subject, College, Schedule, Cost). Sortable by relevance, cost, or credits.

Right panel (45%): "Your DE Courses" section listing enrolled courses. Credits tracker (progress ring showing earned vs. target). Cost savings calculator card showing tuition saved vs. traditional college credits. Transfer guide accordion sections per target college showing which credits transfer.

## G5. AI CLASS SCHEDULER
Main area (70%): Weekly schedule grid with Period 1-7 rows and Mon-Fri columns. Color-coded cells by subject category. AI-recommended courses shown with green dashed border. Click any cell to open alternatives dropdown (floating card with course options, each showing teacher, room, time). Drag-and-drop to rearrange. Conflict indicators (Error red highlight) on overlapping periods.

Sidebar (30%): Career alignment ring chart (how well schedule matches career path). Bright Futures progress bar (credits toward qualification). Total credits counter. Difficulty score meter. AI suggestions list (numbered, with reasoning). "Submit to Counselor" PrimaryBtn at bottom.

## G6. RESEARCH & INTERNSHIP TRACKER
Left panel (40%): Filter tabs (All | Research | Internships | Volunteering). Entry cards (SurfaceContainerLow, XL radius): title (Title Medium), organization, type chip, date range, status badge (Active green, Completed Primary, Planned Outline), hours logged. Hover:lift on cards. "Add New" AccentBtn at top.

Right panel (60%): Selected entry detail view. Title (Headline Small), organization, supervisor name and contact. Description paragraph. Skills tags (chips, SurfaceContainerHigh). Outcomes/achievements list. Hours chart (bar chart by week/month). Documents section (attached files list). "Edit" and "Delete" (Error text) buttons at bottom.

## G7. SUPPLEMENTAL ESSAY TRACKER
Left panel (30%): College list, each row showing: college name (Title Small), completion count "X/Y complete", progress bar (Primary fill). Selected college highlighted with Primary background. Scrollable list.

Right panel (70%): Essay table for selected college. Columns: Prompt (truncated, hover for full text) | Status badge (Not Started=Outline, Drafting=Secondary, Review=Tertiary, Complete=Primary) | Word Count / Limit | Progress bar | "Open Editor" link (Primary, underline-on-hover). TableRows with hover state. Bulk actions at top for status updates.

## G8. CAREER ACTIVITY SUGGESTIONS
Left panel (55%): AI-generated suggestion cards grouped by priority: High Impact (Primary border), Medium Impact (Secondary border), Quick Wins (Accent Lime border). Each card: activity name (Title Medium), category chip, AI reasoning (Body Small), time commitment, impact score (1-5 stars), "Add to Profile" AccentBtn. Sparkles icon on AI-generated content.

Right panel (45%): Current activities list with categories. Coverage radar chart (6 axes: Leadership, Service, Academic, Creative, Athletic, Work). Gaps identification card (SurfaceContainerLow, amber left border) listing underrepresented areas. "Typical Admitted Student" comparison overlay on radar chart (dashed line).

## H1. CAREER QUIZ
Centered container (640px max-width). Progress bar at top (Primary fill, pill radius). Question number and total (Label Medium). Question text (Headline Small, Noto Serif). 2x2 option grid below: each option is a card (SurfaceContainerLow, XL radius) with hover:border (Outline). Selected state: Primary border with checkmark icon in top-right corner. Stage indicators: Stage 1 (15 general questions), Stage 2 (10 branching questions), Stage 3 (5 open text responses with TextFields). Navigation: "Previous" (outlined button) left, "Next" (PrimaryBtn) right. Keyboard hint at bottom: "Press 1-4 to select" (Label Small, On Surface Variant).

## H2. CAREER QUIZ RESULTS
Centered container (800px max-width). Sparkles animation at top. Archetype title (Display Small, Noto Serif, Primary). RIASEC code displayed as colored letter chips. Description paragraph (Body Large). Three result cards in a row: Traits card (chips list of personality traits), Career Paths card (ordered list with icons), Recommended Classes card (checklist with toggles). RIASEC hexagon radar chart below (Primary fill with 30% opacity, Primary stroke). Action buttons: "Save to Profile" (PrimaryBtn), "Retake Quiz" (outlined), "Explore Careers" (AccentBtn).

## H3. CAREER EXPLORER
Top section: Career selector with horizontal scrollable cards or searchable dropdown. Each career card shows icon, title, and match percentage.

Left panel (50%): Selected career detail. Title (Headline Medium). Description (Body Large). Education timeline (vertical stepper: High School, College, Graduate/Professional). Salary range bars (entry, mid, senior levels in Accent Lime). Growth percentage with trend arrow. Related certifications list.

Right panel (50%): Related jobs in 2-column grid. Each card: job title, salary range, growth %, education level required, skill tags (chips). Related majors list below with match scores. "Set as Career Path" PrimaryBtn at bottom (updates profile).

## H4. POST-GRADUATION MODE
Dashboard layout. Mode switcher at top (toggle between "College Prep" and "Post-Graduation" modes, pill selector). Four checklist sections as expandable cards: Housing (apartment search, utilities, furniture), Career (job applications, resume, interviews), Financial (budget, bank accounts, insurance), Life Skills (cooking, laundry, time management). Each item has checkbox, description, and resource link.

Month-by-month timeline (May through September) as horizontal scrollable timeline with milestone nodes. Each month expands to show tasks. Resources section at bottom: curated links and guides in card grid.

---

**Deliverable:** Design all 12 screens at 1440px. Batch 7 of 12.
