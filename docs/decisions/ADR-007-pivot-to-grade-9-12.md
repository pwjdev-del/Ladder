# ADR-007 — Pivot from K-8 to Grades 9–12 (High-School College Guidance)

**Status:** Accepted
**Date:** 2026-04-18
**Deciders:** Kathan Patel (Director of Technical Foundations), Jet (Director of Marketing and Sales)

## Context

The original `CLAUDE.md` v2 spec (ADR-000) describes Ladder as a K-8 school-adoption platform with LWRPA as the first pilot. Founders have clarified that the authoritative product vision — documented in the ideas folder at `/Users/kathanpatel/Documents/Ladder/Ladder-Oloid (WIP)/Ideas/Ladder_CLAUDE.md` and `Ladder_GapAnalysis.html` — is a **grade 9–12 high-school college-guidance app**, not a K-8 school platform.

## Decision

- **Audience:** students in grades 9, 10, 11, 12 and their parents.
- **Tenants:** schools remain B2B (for school-licensed access) + B2C families, but every student is a high-schooler.
- **Core features reinstated from the original ideas backlog:**
  1. **5-step onboarding** — name, grade (9–12), GPA, SAT/ACT, AP list, dream colleges, career interests.
  2. **Career quiz** (RIASEC-style) — STEM / Medical / Business / Humanities / Sports, retakeable yearly. Drives `StudentProfileModel.careerPath`.
  3. **Activity suggestion engine** — 4 general + 6 career-specific activities rated 1–10 + mandatory research paper.
  4. **Class planner** — AI suggests next-year's classes by career + transcript, with easy/moderate/hard difficulty.
  5. **College discovery** — 6,500 colleges, search + filters, Match/Reach/Safety calculator (GPA + SAT vs acceptance rate), College Personality archetype.
  6. **Application tracker** — status machine: planning → inProgress → submitted → accepted / rejected / waitlisted → committed; auto-generated per-college pre-apply checklist; post-acceptance checklist (9 items).
  7. **Essay hub** — per-college essay tracker with AI "Why [field]?" talking points + mock interview (backlogged).
  8. **Deadlines calendar** — saved colleges' deadlines + custom reminders.
  9. **College Connect** — messaging with current college students (chat + request).
  10. **AI Academic Advisor** — chat surface powered by Gemini via the AI gateway (§8.4).

## Consequences

- `CLAUDE.md` §2.1 ("first pilot: Lakewood Ranch Preparatory Academy, K–8") is superseded — LWRPA remains the pilot school but serves its high-school students. Any copy referencing K-8 ranges is replaced with grade 9–12.
- Career quiz K-2 picture variant + 3-5 simple variant are OBSOLETE — single quiz variant for the 9–12 band (RIASEC).
- Class suggester + scheduling engine still live in-spec, but the inputs are AP transcripts + career profile, not K-8 class catalogs.
- Teacher data / teacher reviews remain admin-exclusive (§5, §20).
- Founder backdoor hard rules (§14.4) + RLS + DEK architecture (§4, §16.2) are unchanged — this is a copy + model update, not a security-model change.
- Student dashboard test accounts `alice.lwrpa@ladder.test` / `bob.lwrpa@ladder.test` / `carol.lwrpa@ladder.test` now map to grades **10, 11, 12** (was 3, 6, 8). `maya.smith@ladder.test` → grade 9. `noah.smith@ladder.test` → grade 11.

## Supersedes

- `CLAUDE.md` §2.1 K-8 framing.
- Stitch batch-11 `quiz_grade_band_picker` + `k_2_picture_quiz` screens (skipped).

## Does NOT supersede

- `ADR-000` ship-full-spec decision.
- `ADR-001` through `ADR-006` architecture ADRs.
- `§20` hard stops.

## Related

- Ideas folder: `/Users/kathanpatel/Documents/Ladder/Ladder-Oloid (WIP)/Ideas/`
- Original canon: `Ladder_CLAUDE.md`, `Ladder_GapAnalysis.html`, `Ladder_WireUp.md`.
