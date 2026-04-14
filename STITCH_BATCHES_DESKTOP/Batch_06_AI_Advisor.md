# Batch 6 of 12 — AI Advisor (8 Screens)

You are designing Desktop (Mac + Web) screens for Ladder, a college preparation app. This is batch 6 of 12. The Mac app and web app share identical designs. Optimized for mouse/keyboard with hover states. Use these exact tokens.

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

### F1. ADVISOR HUB
- Full-page layout with sidebar (Advisor selected). Content area (max 800px centered), xxxl64 vertical padding.
- "AI Advisor" Noto Serif Headline Medium (28pt), On Surface, centered. Sparkle icon (24px, Accent Lime) beside title.
- "Your personal college prep assistant." Manrope 14pt, On Surface Variant, centered, mt xs4.
- **2x2 card grid,** lg24 gap, mt xl32:
  - **Chat:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Chat bubble icon (40px, Primary). "Chat with Advisor" Manrope 16pt title bold. "Ask anything about college admissions, essays, or planning." Manrope 14pt, On Surface Variant. "Start Chat" AccentBtn, mt md16. Hover: lift, border Outline Variant.
  - **Essay Hub:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Pen/document icon (40px, Primary). "Essay Hub" Manrope 16pt title bold. "Write, review, and polish your college essays." Manrope 14pt, On Surface Variant. "Open Essays" PrimaryBtn, mt md16. Hover: lift.
  - **Score Improvement:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Chart-up icon (40px, Primary). "Score Improvement" Manrope 16pt title bold. "Personalized SAT/ACT study plan and tracking." Manrope 14pt, On Surface Variant. "View Plan" PrimaryBtn, mt md16. Hover: lift.
  - **Interview Prep:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Microphone icon (40px, Primary). "Interview Prep" Manrope 16pt title bold. "Practice with AI mock interviews." Manrope 14pt, On Surface Variant. "Practice Now" PrimaryBtn, mt md16. Hover: lift.
- **Recent conversations preview** (mt xl32): "Recent" Manrope 12pt label, tracking +2.0, On Surface Variant. Horizontal row of 3 conversation preview cards (SurfaceContainerLow bg, lg radius, md16 padding, 200px width each): title (Manrope 14pt, 1-line truncate) + date (Manrope 10pt, On Surface Variant) + preview text (Manrope 12pt, 2-line truncate, On Surface Variant). Hover: border Outline Variant. Click: opens that conversation.

### F2. AI CHAT
- Full-page layout. Content: two-panel.
- **Left sidebar panel (240px):** SurfaceContainerLow bg, full height, xl32 padding.
  - "New Chat" AccentBtn, full width, + icon. mb lg24.
  - "Conversations" Manrope 10pt label, tracking +2.0, On Surface Variant. Conversation history list (scrollable): each item: title (Manrope 14pt, 1-line truncate) + date (Manrope 10pt, On Surface Variant). Hover: SurfaceContainerHigh bg. Selected: Primary bg at 10%, Primary left border (3px), bold title.
  - Quick Tools section (bottom, mt auto): "Quick Tools" Manrope 10pt label, tracking +2.0. Links: "Essay Review" / "Score Plan" / "Interview Prep" / "Why This School" — each Manrope 12pt, Primary color, hover underline. Stacked, sm8 gap.
- **Main chat area:** SurfaceContainerLowest bg, flex-grow.
  - **Empty state (no messages):** centered content, xxxl64 padding. Sparkle icon (48px, Accent Lime, subtle glow animation). "How can I help today?" Noto Serif Headline Small (24pt), On Surface, mt md16. 2x2 prompt suggestion grid (md16 gap, mt xl32): each suggestion card (SurfaceContainerLow bg, lg radius, md16 padding, 280px width) — suggestion text (Manrope 14pt), click to send as message. Hover: border Primary, lift.
    - Suggestions: "Help me write a 'Why This School' essay" / "Review my Common App essay" / "Create a study plan for SAT" / "What are my chances at [school]?"
  - **Messages area** (when conversation active): max 720px centered, vertical scroll, xl32 padding bottom.
    - **User message:** right-aligned. Primary Container (#5a7956) bg, xl radius (top-left, bottom-left, bottom-right rounded; top-right sharp sm8), md16 padding. On Primary (#ffffff) text, Manrope 14pt. Timestamp below: Manrope 10pt, On Surface Variant, right-aligned.
    - **Advisor message:** left-aligned. SurfaceContainerLow bg, xl radius (top-right, bottom-left, bottom-right rounded; top-left sharp sm8), md16 padding. "Advisor" label top (Manrope 10pt label, Primary, tracking +2.0) + sparkle icon (12px). Message text: Manrope 14pt, On Surface. Supports markdown formatting (bold, lists, links in Primary). Timestamp below left.
    - Typing indicator: 3 dots pulsing in SurfaceContainerLow bubble.
  - **Input area** (bottom, sticky): SurfaceContainerLowest bg, top border Outline Variant (1px). xl32 horizontal padding, md16 vertical padding. Text field: SurfaceContainerLowest bg, Outline border, xl radius, Manrope 14pt, auto-expand (max 6 rows). Placeholder "Ask anything...". Left of send: attach icon button (paperclip, tooltip "Attach file"). Right: send icon button (arrow-up circle, Primary bg, On Primary icon; disabled: Outline Variant bg). Helper text below field: "Enter to send, Shift+Enter for new line" Manrope 10pt, On Surface Variant.

### F3. CHAT HISTORY
- Single-column layout (700px centered), xl32 padding.
- "Chat History" Noto Serif Headline Small (24pt), mb lg24.
- Search field: full width, SurfaceContainerLowest bg, Outline border, lg radius, magnifying glass icon. "Search conversations..." placeholder. mb lg24.
- Conversation cards (stacked, md16 gap):
  - Card: SurfaceContainerLow bg, lg radius, ambient shadow, md16 padding. Title (Manrope 14pt title bold) + date (Manrope 12pt, On Surface Variant, right-aligned) + preview text (Manrope 14pt, On Surface Variant, 2-line truncate, mt xs4) + message count badge (pill, SurfaceContainerHigh, Manrope 10pt — "12 messages").
  - Hover: lift, border Outline Variant + delete icon button appears (trash, 20px, Error color on hover, tooltip "Delete conversation") right side.
  - Click: navigates to that conversation in F2.
- **Empty state:** centered, xxxl64 padding. Chat bubble icon (48px, On Surface Variant at 40%). "No conversations yet." Manrope 14pt, On Surface Variant. "Start a Chat" AccentBtn.

### F4. ESSAY HUB
- Full-page layout. Content: three-column layout.
- **Left panel (240px):** SurfaceContainerLow bg, full height, xl32 padding.
  - "Start New Essay" AccentBtn, full width, + icon. mb lg24.
  - "My Essays" Manrope 10pt label, tracking +2.0, On Surface Variant. Essay list (scrollable): each item: title (Manrope 14pt, 1-line truncate) + word count (Manrope 10pt, On Surface Variant) + status icon (draft pencil / reviewed check / submitted send). Hover: SurfaceContainerHigh bg. Selected: Primary bg at 10%, Primary left border (3px), bold.
- **Center panel:** SurfaceContainerLowest bg, flex-grow.
  - **When essay selected:** essay workspace (see F5 for full editor).
  - **When no essay selected (prompt selection):** centered grid, xl32 padding. "Choose a Prompt" Noto Serif Headline Small (24pt), mb lg24. Prompt cards in a 2-column grid (md16 gap):
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Prompt number (pill, Primary bg, On Primary, Manrope 12pt — "#1") + prompt text (Manrope 14pt, On Surface). "Start Writing" text link (Primary, hover underline) bottom-right. Hover: lift, border Outline Variant.
    - Prompts: Common App prompts + college-specific supplemental prompts.
- **Right panel (320px):** SurfaceContainerLow bg, xl32 padding.
  - **AI Feedback panel** (when essay selected): "AI Feedback" Manrope 14pt title bold + sparkle icon. Score summary (if reviewed) + key points. "Get Full Review" PrimaryBtn.
  - **Common App Prompts** (collapsible section): "Common App Prompts" Manrope 12pt label + chevron toggle. Collapsed: shows just the header. Expanded: numbered list of all 7 prompts (Manrope 12pt, md16 gap). Click prompt: starts new essay with that prompt.
  - **When no essay selected:** tips card. "Essay Tips" Manrope 14pt title bold. Bulleted tips (Manrope 12pt, On Surface Variant).

### F5. ESSAY EDITOR
- Full-page layout (editor takes full content width).
- **Top toolbar:** SurfaceContainerLow bg, 56px height, xl32 horizontal padding. Left: back arrow icon button (tooltip "Back to Essays") + essay title (editable inline, Manrope 16pt title bold, click to edit, underline on focus) + prompt reference chip (pill, SurfaceContainerHigh, Manrope 10pt — "Common App #1", click to view full prompt in popover). Right: word count (Manrope 12pt, On Surface Variant — "347 / 650 words", turns Error if over limit) + "Get AI Review" AccentBtn (sparkle icon) + auto-save indicator (Manrope 10pt, On Surface Variant — "Saved" with check or "Saving..." with spinner).
- **Center — Text editor (700px centered),** mt lg24: SurfaceContainerLowest bg, xl radius, Outline border, xl32 padding. Rich text area: Manrope 16pt body, On Surface, line-height 1.6. Standard text editing (no formatting toolbar — plain text essay). Placeholder: "Start writing your essay..." On Surface Variant. Cursor: primary colored blinking line. Comfortable vertical space (min 500px height).
- **Right margin panel (280px, collapsible):** SurfaceContainerLow bg, xl32 padding. Toggle: chevron button on left edge of panel.
  - **AI Suggestions** (when available): "Suggestions" Manrope 12pt label, tracking +2.0. Suggestion cards (stacked, sm8 gap): SurfaceContainerHigh bg, sm8 radius, sm8 padding. Manrope 12pt text. Type indicator (pill, tiny — "Clarity" / "Detail" / "Flow"). Click: highlights relevant section in editor.
  - **Outline** section: "Outline" Manrope 12pt label. Detected paragraph topics (Manrope 12pt, numbered). Click: scrolls editor to that paragraph.
  - **Version History** section: "Versions" Manrope 12pt label. List of saved versions: timestamp + word count. Click: loads that version (with confirmation).

### F6. ESSAY AI REVIEW
- Full-page layout. Content: two-column (55/45 split), lg24 gap.
- **Left column (55%):** "Essay Review" Noto Serif Headline Small (24pt) + essay title (Manrope 14pt, On Surface Variant). mb lg24.
  - Essay text display: SurfaceContainerLowest bg, xl radius, Outline border, xl32 padding. Full essay text (Manrope 16pt, line-height 1.6). Inline highlights on specific passages:
    - Green highlight (Primary at 15% bg): strength — strong writing.
    - Amber highlight (Secondary at 15% bg): suggestion — could improve.
    - Red highlight (Error at 15% bg): issue — needs attention.
    - Hover on highlight: tooltip with brief feedback. Click: scrolls right panel to corresponding detail.
- **Right column (45%):** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Scrollable.
  - **Score ring** at top: 80px diameter, Primary stroke (score out of 100, Manrope 22pt bold inside). Score label below (pill — "Strong" Primary / "Good" Accent Lime / "Needs Work" amber / "Weak" Error).
  - **Strengths** (mt lg24): "Strengths" Manrope 14pt title bold, green dot. Bullet items (Manrope 14pt, md16 gap) with green left border.
  - **Areas to Improve** (mt lg24): "Areas to Improve" Manrope 14pt title bold, amber dot. Bullet items with amber left border.
  - **Structure** (mt lg24): "Structure" Manrope 14pt title bold. Visual: mini bar chart or outline showing paragraph balance. Feedback text (Manrope 14pt).
  - **Tone** (mt lg24): "Tone" Manrope 14pt title bold. Tone tags (pills — "Authentic" / "Reflective" / "Passionate", Accent Lime bg). Brief analysis (Manrope 14pt).
  - **Action Items** (mt lg24): "Action Items" Manrope 14pt title bold. Numbered checklist of specific improvements (checkbox + Manrope 14pt, md16 gap).
  - Action buttons (mt xl32): "Apply Suggestions" AccentBtn (sparkle icon — AI applies edits) + "Rewrite Section" outlined button (select section dropdown).

### F7. SCORE IMPROVEMENT
- Full-page layout. Content: two-column (70/30 split), lg24 gap.
- **Main column (70%):**
  - **SAT Journey card:** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. "Your SAT Journey" Noto Serif Headline Small (24pt). Two score circles side by side (80px each): "Current" (Manrope 22pt bold, On Surface) + "Target" (Manrope 22pt bold, Primary). Arrow between them. Delta badge (pill, Accent Lime bg — "+120 to go"). Below: progress bar (Primary fill toward target, SurfaceContainerHigh track, lg radius, 8px).
  - **Phase cards** (mt xl32, stacked, md16 gap): 4 horizontal cards, each expandable.
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Left: phase number circle (40px, Primary bg, On Primary, Manrope 14pt bold — "1"/"2"/"3"/"4") + phase title (Manrope 16pt title bold — "Foundation" / "Practice" / "Strategy" / "Final Prep") + duration (Manrope 12pt, On Surface Variant — "Weeks 1-3"). Right: task count (Manrope 12pt — "8 tasks") + hours (Manrope 12pt — "12 hours") + completion progress ring (32px, Primary stroke).
    - Expandable: click/chevron reveals task list below (checkbox items, md16 gap, Manrope 14pt, indented). Each task: checkbox + name + estimated time + resource link.
    - Current phase: Primary border (2px), slight PrimaryGlow.
    - Completed phase: green check replacing number, strikethrough on title.
    - Hover: lift shadow.
- **Sidebar (30%):** SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding.
  - **Resources:** "Resources" Manrope 12pt label, tracking +2.0. Link cards (stacked, sm8 gap): icon (book/video/link) + title (Manrope 14pt, Primary, hover underline) + type label (Manrope 10pt, On Surface Variant).
  - **Practice Log** (mt lg24): "Practice Scores" Manrope 12pt label. Trend line chart (160px height): x-axis dates, y-axis scores. Primary line, dots on data points. Manrope 10pt labels. "Log Score" small AccentBtn below chart.
  - **Study Calendar** (mt lg24): "Study Schedule" Manrope 12pt label. Mini month calendar (compact, 200px): days with study sessions highlighted (Primary bg at 20%). Today: Primary border.
  - **Upcoming Test Dates** (mt lg24): "Test Dates" Manrope 12pt label. List: date (Manrope 14pt bold) + test name + registration deadline (Manrope 12pt, On Surface Variant). Urgent: Error color on deadline.

### F8. INTERVIEW PREP
- Full-page layout. Content area (max 1000px centered).
- **Three states/views:**

- **State 1 — Prep (default):**
  - "Interview Prep" Noto Serif Headline Small (24pt) + "Practice makes perfect." Manrope 14pt, On Surface Variant.
  - Question cards (stacked, md16 gap, mt xl32): 10 cards.
    - Card: SurfaceContainerLow bg, xl radius, ambient shadow, xl32 padding. Question number (Manrope 12pt label, On Surface Variant — "Q1") + question text (Manrope 16pt title bold). Bottom row: difficulty chip (pill — "Easy" Accent Lime / "Medium" amber / "Hard" Error bg) + tips toggle ("Show Tips" text button, Primary). Tips area (expandable, mt sm8): SurfaceContainerHigh bg, lg radius, md16 padding, Manrope 14pt. "Practice This" PrimaryBtn (right-aligned).
    - Hover: lift, border Outline Variant.
  - "Start Full Mock Interview" AccentBtn (large, centered, mt xl32, glow).

- **State 2 — Mock Interview (active):**
  - Chat-like layout (700px centered). SurfaceContainerLowest bg.
  - Top bar: "Mock Interview" Manrope 14pt title bold + progress indicator (Manrope 12pt — "Question 3 of 10") + linear progress bar (Primary fill) + timer (Manrope 14pt, On Surface Variant, clock icon — counting up).
  - Messages area:
    - AI question: left-aligned bubble (SurfaceContainerLow bg, xl radius, md16 padding). "Interviewer" label (Manrope 10pt, Primary). Question text (Manrope 16pt).
    - User response area: SurfaceContainerLowest bg, Outline border, xl radius, xl32 padding, min-height 120px. Manrope 14pt, placeholder "Type your response...". Timer badge top-right (pill, SurfaceContainerHigh, Manrope 10pt — recommended time "~2 min").
    - "Submit Response" PrimaryBtn + "Skip" text button (On Surface Variant).
  - Previous Q&A pairs visible above (scrollable), collapsed (question truncated, click to expand).

- **State 3 — Results:**
  - "Interview Results" Noto Serif Headline Small (24pt), centered.
  - **Overall score ring** (120px, centered, Primary stroke): score (Manrope 28pt bold) + grade label (pill below — "Excellent" / "Good" / "Needs Practice").
  - **Per-question feedback** (mt xl32, stacked, md16 gap):
    - Card: SurfaceContainerLow bg, lg radius, md16 padding. Question (Manrope 14pt bold) + your response (Manrope 14pt, On Surface Variant, collapsible/truncated). Score: mini ring (32px) + score. Feedback text (Manrope 14pt, mt sm8): strengths (green text) + improvements (amber text). "Sample Answer" expandable section (SurfaceContainerHigh bg, lg radius, md16 padding, Manrope 14pt italic).
  - "Retake Interview" AccentBtn (centered, mt xl32) + "Back to Prep" outlined button.

---

**Deliverable:** Design all 8 screens at 1440px width. Batch 6 of 12.
