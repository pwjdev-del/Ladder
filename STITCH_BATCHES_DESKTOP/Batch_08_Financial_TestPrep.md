You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 8 of 12. Mac app and web app share identical designs. Mouse/keyboard optimized with hover states. Use these exact tokens.

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

# Batch 8: Financial + Test Prep (10 screens)

## I1. SCHOLARSHIP SEARCH
Table layout with detail drawer. Top bar: search TextField (SurfaceContainerLowest, outline, focus:primary glow, Cmd+K hint), filter chips (Amount Range, Deadline, Category, Match %), sort dropdown. Results table columns: Name | Provider | Amount | Deadline | Match % (colored bar) | Status (badge). Sortable column headers with arrow indicators. Hover state on rows (SurfaceContainerHigh). Bookmark star icon per row (toggle, filled = Secondary). Click any row to open detail drawer (480px, slides in from right, floating shadow): full scholarship info, eligibility checklist (checkmark green, warning amber, X red), essay requirements, past recipients stats. Drawer action buttons: "Apply Now" (PrimaryBtn) + "Save" (outlined). Pagination at bottom.

## I2. SCHOLARSHIP DETAIL
Single column layout (700px max-width, centered). Provider logo at top (64px). Scholarship name (Headline Medium, Noto Serif). Amount displayed as Display Small in Accent Lime. Deadline with countdown timer (days:hours:minutes). "About" section (Body Large). Eligibility requirements list with status icons (checkmark/warning/X per item). Application process steps (numbered vertical stepper). Required materials checklist with upload status. Action buttons: "Apply Now" (PrimaryBtn, full width), "Save to List" (outlined), "Share" (icon button with tooltip).

## I3. SCHOLARSHIP MATCH SCORE
Left panel (45%): Total potential aid card (Display Small, Accent Lime, SurfaceContainerLow card with glow shadow). Below: ranked scholarship list sorted by match percentage. Each row: scholarship name, match % with colored progress bar (green >80%, amber 50-80%, red <50%), amount, deadline. Click to select.

Right panel (55%): Selected scholarship match breakdown. Criteria list with status: checkmark green for met, warning amber for partially met, X red for not met. Each criterion shows requirement and your profile value side by side. Profile tags showing relevant qualifications (chips). AI suggestions card (SurfaceContainerLow, Primary left border): specific steps to improve match score. "Apply" PrimaryBtn.

## I4. SCHOLARSHIP ACTION PLAN
Timeline layout. AI-prioritized scholarship plan sorted by ROI (amount / effort). Monthly plan sections (collapsible). Each month shows task cards: scholarship name, task description, deadline, priority badge (High/Medium/Low), estimated time. Total potential amount counter at top (Display Small, Accent Lime). Progress tracker showing completed vs. pending applications. "Add Custom Task" text button.

## I5. FINANCIAL AID COMPARISON
Side-by-side comparison for 2-3 schools. School selector at top (dropdown or search). Comparison table rows: Tuition, Room & Board, Fees, Total Cost of Attendance, Grants & Scholarships, Federal Aid, State Aid, Institutional Aid, Net Cost, Loan Amount, Monthly Payment After Graduation. Green highlight on best value per row. AI recommendation card at bottom (SurfaceContainerLow, sparkles icon): summarizing best financial choice with reasoning. "Export as PDF" outlined button.

## I6. FAFSA READINESS
Left panel (55%): Readiness score ring (large, centered, Primary fill for completed percentage). Checklist below: FSA ID Created, Tax Returns Ready, W-2 Forms Collected, Bank Statements, CSS Profile (if needed), State Deadline Noted, Federal Deadline Noted. Each item: checkbox, label, status badge, help icon with tooltip. Progress updates live as items are checked.

Right panel (45%): Net cost calculator card (SurfaceContainerLow, XL radius). Input fields: household income slider, assets field, family size stepper, number in college stepper. College selector dropdown. Output: estimated cost of attendance, estimated aid, estimated net cost (Display Small). Disclaimer text at bottom (Label Small, On Surface Variant): "Estimates only. Actual aid may vary."

## J1. TEST PREP RESOURCES
2-column card grid. Each card (SurfaceContainerLow, XL radius, ambient shadow, hover:lift): resource logo (48px), title (Title Medium), description (Body Small), "Open" link (Primary, underline-on-hover), cost badge chip (Free = green, Paid = Tertiary). Resources: Khan Academy (SAT prep), College Board Official Practice, ACT Academy, Fee Waiver Information, Local Prep Programs, Ladder Study Plan. Search/filter at top.

## J2. SAT/PSAT REGISTRATION
12-month timeline view. Each test date shown as a card on the timeline: test name (SAT/PSAT/ACT), date (Title Medium), registration deadline with countdown (days remaining, amber if <14 days, red if <7), "Register" link (Primary, opens external), fee info and waiver eligibility badge, "Set Reminder" bell icon button with tooltip. Registration deadline banner at top if any deadline is within 14 days (amber SurfaceContainerLow card with warning icon). Calendar export option.

## J3. PRACTICE TEST LOG
Left panel (55%): Trend chart (line graph, scores over time). Composite score line (Primary) with target score horizontal line (dashed, Accent Lime). Section mini charts below (Reading, Writing, Math) as small sparklines. Hover tooltips showing exact scores and dates.

Right panel (45%): Score entries list (reverse chronological). Each entry: date, test type, composite score, section scores, notes. "Log New Score" form at top: date picker, test type dropdown, score fields (composite auto-calculates from sections), notes TextField. "Save" PrimaryBtn.

## J4. STUDY SCHEDULE
Left panel (60%): Monthly calendar view. Lime-highlighted study days. AI-recommended study blocks shown as colored cells. Click a day to view/edit sessions. Navigation arrows for month switching.

Right panel (40%): Selected day detail. Study sessions list: subject chip, focus topic (Body Medium), duration, linked resource, "Completed" checkbox. Add session button. Weekly stats card below: total hours, sessions completed, streak count, subject distribution pie chart.

---

**Deliverable:** Design all 10 screens at 1440px. Batch 8 of 12.
