You are designing iPad screens for Ladder, a college preparation app. This is batch 6 of 12 (screens listed below). Use these exact design tokens for all screens.

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

### F1. ADVISOR HUB
Dashboard grid. "Your AI Advisor" + sparkles. 2x2 tool cards: Chat (sparkles, "Ask Anything"), Essay Hub (pencil, "Essay Assistant"), Score Improvement (chart, "SAT/ACT Prep"), Interview Prep (person, "Mock Interviews"). Each with icon + title + desc + button. Recent conversation preview. "View All Conversations" link.

### F2. AI CHAT
Sidebar + chat. Left (280pt): "AI Advisor" + sparkles, conversation history list (title, date, preview), "New Conversation", divider, Quick Tools links. Right: Empty state = sparkles icon + greeting + 2x2 prompt cards. Messages: user (right, primary bg, white), advisor (left, surface bg, "Advisor" label + sparkles). Input bar (multi-line 1-6 lines, attach paperclip, send arrow lime/disabled).

### F3. CHAT HISTORY
Full list (700pt). "Conversation History" + search. Cards: title, date, preview, message count, swipe delete. Tap loads conversation.

### F4. ESSAY HUB
Two-column. Left (50%): Header card (sparkles + title + desc), "Start New Essay" accent, Common App Prompts (7 cards: number badge, title, desc, arrow), Supplemental Prompts (by college). Right (50%): My Essays list (title, type badge, college, status chip, word count, progress, "Open"). Empty state.

### F5. ESSAY EDITOR
Full-width workspace. Top toolbar: back, title (editable), college+prompt ref (collapsible), word count, "Get AI Review" accent, auto-save. Main (700pt centered): large text editor, minimal formatting (bold/italic/paragraph). Right margin (280pt collapsible): AI Suggestions, Outline (draggable), Version History.

### F6. ESSAY AI REVIEW
Two-column overlay. Left (55%): Essay text with inline highlights (green=strong, amber=improve, red=attention). Click highlight → right panel feedback. Right (45%): Score ring (0-100), Strengths card, Areas to Improve card, Structure Analysis (Opening/Body/Conclusion ratings), Tone Assessment, Action Items list, "Apply Suggestions" + "Rewrite Section".

### F7. SCORE IMPROVEMENT PLAN
Dashboard + sidebar. Left (65%): SAT Journey card (two score circles current/target + arrow + gap subtitle). Recommended Plan: 4 phase cards (Weeks 1-2, 3-6, 7-8, Test Day) with icons + tasks + hours. Right (35%): Free Resources (Khan Academy, College Board, Fee Waiver), Practice Test Log (scores + trend), Study Calendar (mini month, lime days), Test Dates.

### F8. INTERVIEW PREP / MOCK
Prep landing: "Interview Preparation" header, 10 common question cards (question + difficulty + tip + "Practice"), "Start Full Mock" accent, tips section. Mock mode: chat-like (AI question left, response area, timer, progress, Next/Skip). Results: score ring, per-question feedback (Strong/Adequate/Needs Work), "Retake".

---

Design all 8 screens above as high-fidelity iPad mockups in landscape orientation. This is Batch 6 of 12.
