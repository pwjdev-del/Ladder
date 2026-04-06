# Laser Research — Executive Summary
_Compiled from all brainstorm video transcripts (20+ sessions), branding files, research JSONs, and the Stitch screen designs. April 2026._

---

## What Ladder Is (True Vision)

Ladder is not just a college app. It is a **guided life-planning companion for high school students, starting in 9th grade**, that navigates them all the way from "I don't know what I want to do" to "I'm enrolled and ready for what's next." The north star is: **increase the number of kids — especially first-generation, public school students — who make it to college.**

The co-founders' analogy: the counselor ratio at schools like Marine River (3–5 counselors for 5,000–7,000 kids) means most students get zero personalized guidance. Ladder replaces that gap with an always-available, always-updating AI counselor who knows the student's full history.

---

## What's Built vs. What Was Imagined

### Built (Phase 1 — Foundation)
- Design system (colors, typography, spacing, components)
- Navigation (5 tabs, 49 routes)
- Auth (Sign in with Apple, Google, email)
- 5-step onboarding
- Dashboard
- Stub views for all 49 routes

### What Was Imagined (Missing from the Build)
See `01_MISSING_FEATURES.md` for the full list. The biggest gaps:

1. **Career / Life Quiz** — the entry point for everything; defines the student's path
2. **Annual Transcript Upload + Class Recommendation Engine** — the core academic loop
3. **Activities System (4 General + 6 Specific)** — structured extracurricular portfolio
4. **Wheel of Career / Wheel of Life visualization** — holistic student status dashboard
5. **School Profile System** — schools and counselors have their own side of the app
6. **Full College Database** (6,500+ schools, not 6) with images
7. **AI-Generated College Pages** — if a college page doesn't exist, AI creates it
8. **Post-Acceptance Checklist System** — what to do AFTER getting accepted
9. **Alternative Path Flows** — military, trade school, community college branches
10. **Scholarship Deep Integration** — not just search, but action plans per scholarship
11. **SAT Fee Waiver Checker** — for free-meal eligible students
12. **Post-College Career Section** — internships, resume builder, job matching

---

## Key Product Principles (Straight from the Transcripts)

1. **Suggest, never force.** Every recommendation is phrased as a suggestion. "These are not final decisions — just things we think would fit you." Students can always override the AI.
2. **Specificity over vagueness.** "Go bug your counselor by X date to get your transcript submitted" beats generic advice.
3. **Duolingo-style engagement.** Streaks, levels, daily actions. Clarity is the engagement mechanic.
4. **Annual re-quiz.** The career quiz is retaken every year because student interests change.
5. **Both student AND counselor.** The app is a tool for the counselor too — reducing their paperwork, giving them a dashboard of their students' class preferences and progress.
6. **4W + H principle.** What to learn, How to learn, When to learn, Where to learn. The app answers all four.

---

## Document Index

| File | Contents |
|------|----------|
| `01_MISSING_FEATURES.md` | Complete prioritized feature list |
| `02_CAREER_QUIZ_DESIGN.md` | Career quiz architecture and questions |
| `03_COLLEGE_DATABASE_STRATEGY.md` | Data sources, images, AI page generation |
| `04_STUDENT_JOURNEY_MAP.md` | 9th grade → college, year by year |
| `05_ACTIVITIES_SYSTEM.md` | The 4 general + 6 specific framework |
| `06_SCHOOL_COUNSELOR_PORTAL.md` | Dual-user design (student + counselor) |
| `07_MONETIZATION_AND_PARTNERSHIPS.md` | Business model, SAT partners, scholarships |
| `08_DATA_PRIVACY_AND_COMPLIANCE.md` | FERPA, transcripts, school APIs |
