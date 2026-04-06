# What to Build Next — Prioritized Roadmap
_Based on all research. This is the recommended order of implementation after Phase 1 foundation._

---

## Immediate Priorities (Phase 2)

These are the features that make Ladder a real product instead of a demo.

### Priority 1: Career Quiz (Full Implementation)
**Why first:** Everything downstream depends on this. Class recommendations, activity suggestions, college filtering — none of it works without the student's career path.

**Build scope:**
- 15–20 questions across 3 sections (hobbies, career interests, lifestyle)
- Scoring algorithm → assigns primary + secondary bucket
- Output screen: archetype name, description, major dropdown
- Override flow: student can manually select a different bucket
- Annual retake prompt (triggered each September)
- Store result in `StudentProfileModel.careerPath`

### Priority 2: College Database (Seed + Images)
**Why second:** `CollegeDiscoveryView` and `CollegeProfileView` exist but show empty data.

**Build scope:**
- Supabase Edge Function to seed from College Scorecard API (6,500+ colleges)
- Add `heroImageURL` and `primaryColor` fields to `CollegeModel`
- Wikipedia API integration for campus images (top 500 colleges)
- Fallback: gradient + initials for colleges without images
- SwiftData local cache of college data (bulk download on first launch)

### Priority 3: Transcript Upload Flow
**Why third:** The transcript is the foundation of the class recommendation engine and AI personalization.

**Build scope:**
- Upload screen: tap → photo capture OR PDF import from Files
- Supabase Storage upload
- Gemini Vision call to extract: subjects, grades, GPA, difficulty level
- Store extracted data in `StudentProfileModel`
- Show parsed transcript summary screen for student to verify

### Priority 4: Activities System (Full Implementation)
**Why fourth:** The `TasksView` and `RoadmapView` are the heart of the app's ongoing value.

**Build scope:**
- Activities log: add/edit/delete entries for each of the 4 general + 6 specific categories
- Progress tracking per category
- Volunteer hours counter with Bright Futures warning (below 120 hrs)
- AI suggestions based on career path bucket
- Dashboard widget showing activities completion percentage

---

## Phase 3 Priorities

### AI Class Recommendation Engine
- Input: transcript grades + career path + school's class catalog
- Output: suggested class list for next year (Easy / Moderate / Hard tiers)
- Counselor submission flow (student sends preferences → counselor approves)

### Post-Acceptance Checklist System
- Trigger: application status changed to "Accepted"
- Show Phase 2 checklist (deposit, housing, immunization, etc.)
- School-specific customization (crowdsourced over time)

### Wheel of Career Visualization
- Radar/spider chart showing student status across 6 dimensions
- Animated fill on progress updates

### SAT Fee Waiver Checker
- Simple eligibility question in onboarding
- Step-by-step guidance + College Board link

---

## Phase 4 Priorities

- Alternative path flows (community college, trade, military)
- School/Counselor portal (requires district partnership)
- AI-generated college pages (for unlisted colleges)
- Scholarship action plans
- NCAA athlete track

---

## What NOT to Build Yet

- Post-college career features — too far out, not validated with users yet
- Parent portal — adds complexity without clear MVP need
- Resume builder — useful but secondary to getting students to college first
- Messaging between student and counselor — requires counselor portal first

---

## The One Thing That Makes the App Click

If there is one thing that would make a 9th grader open Ladder every day, it is this:

> **A personalized, grade-aware, always-updating checklist of exactly what they should do THIS WEEK to improve their college chances.**

Not a generic list. Not a roadmap with 50 items. A short, specific, "here are your 3 things this week" view — powered by their transcript, their career path, their current grade level, and their saved colleges' requirements.

That is the Duolingo lesson. That is the thing that drives daily active use. Everything else in the app supports getting to that one screen being genuinely useful.
