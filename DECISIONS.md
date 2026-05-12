# Founder Decisions — Locked

Decisions made by the founder during /pwj continue-mode orientation. These are **binding inputs** to all downstream agents (tech-lead, specialists, code-reviewer, autonomous-ui-tester, etc.). If a decision conflicts with anything earlier in SPEC_v2.md, this file wins.

Date locked: 2026-05-12
Launch target: 2026-05-27 (T+15 days)

---

## D-001 — SIA "raw box" starter persona

**Decision:** Warm mentor + professional counselor — blended, not toggled.

**What this means concretely:**
- SIA speaks like an empathetic older sibling (warm-mentor delivery: curiosity-first, no jargon, validates feelings before advising)
- AND has the actual competence of a trained school counselor (motivational interviewing, age-appropriate scaffolding for ages 13-18, college-prep substance, ethics/safety boundaries)
- It is NOT just a friendly chatbot. It is NOT a stiff coach. It is the school counselor every student wishes they had.
- Adapts per student over time (see D-003) but the starter tone is always warm-mentor.

**Reference research:** `SIA_PERSONA_RESEARCH.md` (being written by research subagent — Rogerian + motivational interviewing + adolescent development literature).

**Affects:** SiaEngine system prompt, first-conversation flow, AdvisorChatView opening message, NudgeRules tone, counselor-summary phrasing.

---

## D-002 — Counselor's view of SIA conversations

**Decision:** Summary + safety-flag only. **No raw chat access.**

**What this means concretely:**
- A staff counselor's dashboard for a student shows: SIA-generated topic summary ("currently working through: college essays, AP Calc anxiety, family stress") + active safety flags + last-active timestamp
- Counselor can NOT scroll the student's chat history
- Counselor CAN ask SIA via a button ("Ask SIA: what does this student need from me this week?") — SIA decides what to surface from the student's data, never dumps raw transcript
- This is the literal implementation of the user's framing: "the counselor has access to all the chats but not access to all the chats"

**Affects:** new counselor-side surface in the Counselor tab, new SiaEngine API surface (`SiaEngine.summarize(studentId:)` and `SiaEngine.briefCounselor(studentId:, question:)`), Supabase RLS policies (counselor role can read `student_memory_summaries`, NOT `student_chat_messages`).

---

## D-003 — Per-student SIA isolation

**Decision (from user's prompt, not an option — this is a HARD requirement):**
- Each student starts from the same "raw box" persona baseline
- SIA adapts that baseline per-student over time
- Zero cross-student data leakage. Student A's content NEVER influences SIA's behavior with Student B.
- Counselor-summary surface (D-002) is the ONLY legitimate read of one student's SIA data by a non-student role.

**Implementation requirements (for tech-lead):**
- Runtime assertion in SiaEngine: every context-load and every prompt-build must include the active `studentId` and assert it matches the authenticated user (or the counselor's authorized lookup).
- Supabase RLS: `student_memory_summaries`, `student_chat_messages`, `student_nudge_log`, and any future SIA tables must enforce `auth.uid() = student_id` for students, and a separate counselor policy for read-summary-only.
- No shared embedding cache keyed by anything other than `studentId`.
- Test: write a deliberate negative test that confirms Student B's context cannot be loaded into Student A's session.

---

## D-004 — v1.0 launch scope

**Decision:** Ship the focused core. Defer the rest to v1.1.

### Ships in v1.0 (locked):
1. Real Supabase auth (already landed)
2. Three roles working end-to-end: Student, Counselor, Founder (Employee role for backdoor)
3. SIA chat UI (un-quarantine AdvisorChatView from Legacy)
4. SIA memory sync to Supabase (migration 0010 + sync code)
5. SIA persona implementation (per D-001)
6. Counselor's summary view of SIA (per D-002)
7. Per-student isolation hardening (per D-003)
8. Proactive nudge card on Home tab
9. Founder data wall (`RequireNonFounderModifier` applied app-wide)
10. TLS pins + AppConfig preflight
11. All open S1 bugs from BUG_REPORT.md
12. S2 bug batch (career quiz, class suggester, counselor mock KPIs)
13. iPad parity for all shipping screens (mandatory per project rule)
14. Autonomous UI tests passing + human QA pass + TestFlight build

### Deferred to v1.1 (post-launch):
- School transfer flow (3-stage approval) — needs email Edge Function
- Parent multi-child digest — needs parent role build-out
- Marketplace (B2C) — separate product surface
- Extracurricular seed dataset — needs 3-5 days human research curation
- Founder dashboard school theming (basic founder dashboard ships; theming defers)

### NOT a v1.0 cut (still mandatory):
- iPad parity (this is a project-level hard rule, never negotiable)
- Per-student isolation (privacy floor)
- Real auth (already done)

---

## D-005 — Launch calendar (target: 2026-05-27)

| Days | Focus | Owner pattern |
|---|---|---|
| 1-3 (5/12 - 5/14) | Hard blockers: founder data wall, TLS pins, 5 remaining S1 bugs | swift-ios-specialist × 3 parallel + supabase-specialist |
| 4-7 (5/15 - 5/18) | SIA visible: chat UI un-quarantine, migration 0010, isolation runtime check, nudge card on Home | swift-ios-specialist + supabase-specialist + claude-api-specialist |
| 8-9 (5/19 - 5/20) | SIA persona (per D-001), counselor summary surface (per D-002), S2 bug batch | claude-api-specialist + swift-ios-specialist |
| 10-11 (5/21 - 5/22) | iPad parity sweep (skill: `ladder-ipad-parity`) | swift-ios-specialist |
| 12-13 (5/23 - 5/24) | Autonomous UI tests, human QA, fix-loop | autonomous-ui-tester + tester-guide + debugger |
| 14-15 (5/25 - 5/27) | Founder-CEO ship review, TestFlight, App Store submission | founder-ceo + deployment-coach |

---

## Update protocol
Append new decisions at the bottom as D-006, D-007, etc. Never edit old decisions in-place — supersede with a new D-NNN that references the prior.
