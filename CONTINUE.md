# CONTINUE — Ladder iOS App

**Generated:** 2026-05-12
**Repo state:** Active — 38 commits since 2026-04-25, last commit today
**PWJ artifacts found:** SPEC_v2.md | PLAN.md | AUDIT_REPORT.md | BUG_REPORT.md | LEGACY_TRIAGE.md | IDEAS_DIGEST.md | CLAUDE.md | REPO_MAP.md
**Current pipeline phase (estimated):** build (Phase 1 complete, Phase 2 partially done, Phase 3-4 not started)
**Launch target:** 15 days (2026-05-27)

---

## 1. Where You Left Off

- **Auth is now real.** The hardcoded `Ladder!v2-pilot` check was replaced with genuine Supabase auth in commit `1b2ec5f`. Role comes from the JWT claim, grade comes from the DB. The single biggest security blocker from AUDIT_REPORT is gone.

- **Five of the ten S1 bugs were fixed in one commit** (`0572ef0`, Apr 28). Forgot password, nav tabs, invite redemption via Edge Function, AI chat wiring in ExtracurricularsView, and signup error classification are all resolved.

- **SIA engine exists and has real structure.** `SiaEngine.swift` (468 lines), `MemoryExtractorService.swift`, `StudentContextBuilder.swift`, `NudgeRules.swift`, and a full `Context/` + `Prompts/` subfolder are in the active build. Memory extraction is wired through `AIGatewayClient`. The engine is not a stub — it has real logic for college evaluation, activity gap analysis, SAT progress, essay status, and timeline.

- **Five S1 bugs are still open.** Grades are still lost on navigation (S1-6), counselor queue buttons are stubs (S1-5), scheduling window is permanently disabled (S1-8), feature-flags save is a TODO (S1-10), and parent invite codes are fake local UUIDs (S1-9).

- **The Legacy un-quarantine (PLAN Phase 2) has not started.** The ~210 student-journey files remain excluded from the build. The SIA engine has the guts but no chat UI — `AdvisorChatView` is still in `Features/Legacy/`. The student-facing product is essentially headless.

---

## 2. What's Claimed Done vs Reality

| Item | Claimed / Spec | Verified in repo | Status |
|---|---|---|---|
| Real Supabase auth (all 3 logins) | PLAN Phase 1 #1 | Commit `1b2ec5f` — SupabaseAuthService.swift added, login files updated | VERIFIED |
| Delete hardcoded password + SwiftLint rule | PLAN Phase 1 #2 | Commit `1b2ec5f` — .swiftlint.yml updated, literal removed | VERIFIED |
| JWT role claim replaces email-prefix detection | PLAN Phase 1 #7 | Commit `9ce158c` | VERIFIED |
| Grade read from DB not email switch | PLAN Phase 1 #8 | Commit `c7b35d7` | VERIFIED |
| iPad target re-enabled | PLAN Phase 1 #6 | Commit `4ea2ff0` | VERIFIED |
| Founder data wall applied to all non-founder views | PLAN Phase 1 #3 | No commit found; `RequireNonFounderModifier` still has no callers (grep confirms) | CLAIMED BUT UNVERIFIED |
| AppConfig preflight crash | PLAN Phase 1 #4 | Partial: Supabase host/key hardcoded in commits `d98061a` + `bbe6f0e` but not as crash-on-missing | PARTIAL |
| TLS SPKI pins filled | PLAN Phase 1 #5 | No commit references TLS pins update | UNVERIFIED — likely still placeholder bytes |
| S1-1 Invite redemption via Edge Function | BUG_REPORT S1-1 | Commit `0572ef0` | VERIFIED |
| S1-2 Signup error classification | BUG_REPORT S1-2 | Commit `0572ef0` | VERIFIED |
| S1-3 Forgot password | BUG_REPORT S1-3 | Commit `0572ef0` | VERIFIED |
| S1-4 Nav tabs interactive | BUG_REPORT S1-4 | Commit `0572ef0` | VERIFIED |
| S1-5 Counselor queue buttons | BUG_REPORT S1-5 | `StudentQueueView.swift:71` still has `/* TODO */` | OPEN |
| S1-6 Grades lost on navigation | BUG_REPORT S1-6 | `GradesSelfEntryView.swift:16` still uses `@State var grades: [GradeEntry]` — no @Query, no SwiftData write | OPEN |
| S1-7 ExtracurricularsView AI chat | BUG_REPORT S1-7 | Commit `0572ef0` | VERIFIED |
| S1-8 Scheduling window perma-disabled | BUG_REPORT S1-8 | `SchedulingWindowView.swift:10` still `prereqsReady = false` with no .task | OPEN |
| S1-9 Parent invite fake codes | BUG_REPORT S1-9 | `ParentInviteView.swift:52` still has `// TODO: POST /rpc/generate_parent_invite` | OPEN |
| S1-10 Feature flags save | BUG_REPORT S1-10 | `FeatureFlagsView.swift:213` still has `// TODO: POST` | OPEN |
| Phase 2 Legacy un-quarantine | PLAN Phase 2 | Zero Phase-2 commits found | NOT STARTED |
| AdvisorChatView un-quarantined | SPEC_v2 §2.7 | Still in `Features/Legacy/AIAdvisor/Views/` | NOT STARTED |
| student_memory_summaries schema | SPEC_v2 §2.5 | Not found in migrations 0001-0009 | NOT IN DB |
| student_nudge_log schema | SPEC_v2 §2.5 | Not found in migrations 0001-0009 | NOT IN DB |
| transfer_requests table | SPEC_v2 §3.9 | Not found in migrations 0001-0009 | NOT IN DB |
| Career quiz scoring / career_profile_vector | SPEC_v2 §2.7 | `CareerQuizView.swift:51` still has `// TODO: POST` | OPEN |
| iPad parity (all dashboards) | PLAN Phase 3 | Phase 3 not started | NOT STARTED |
| CI activated | PLAN Phase 4 #3 | Commit `df43683` | VERIFIED |

---

## 3. Open from AUDIT_REPORT.md (S0 / S1 findings only)

| Finding | File | Recommended Action |
|---|---|---|
| Founder data wall unenforced — `RequireNonFounderModifier` defined but zero callers | `TenantContext.swift` + ~30 dashboard files | Apply `.requireNonFounder()` modifier to every non-founder root view; 1-day sweep |
| TLS pinning placeholder bytes (0x00/0x01) | `TLSPinnedSession.swift:18-30` | Paste real Supabase SPKI SHA-256 hashes; add CI gate to reject placeholder bytes |
| AppConfig no preflight crash — misconfigured release boots silently | `AppConfiguration.swift` | Add `AppConfig.preflightOrCrash()` in `LadderApp.init()`; remove placeholder fallback URL |
| Legacy `.xcodeproj` still in repo | `Ladder.xcodeproj/` (2,142 lines) | Delete and add to `.gitignore`; document that `LadderApp.xcodeproj` is the active one |
| ai-gateway rate limiting is a TODO stub | `ai-gateway/index.ts` | Implement per-minute/per-user rate limit before any real-user traffic |
| `safeSerialize` regex strips wrong chars | `ai-gateway/index.ts` | Fix `/\s-/g` → `/[\x00-\x1f]/g`; add unit test |

---

## 4. SIA Counselor Overhaul Scope

The existing `SiaEngine.swift` is not a stub — it has real logic for 6 analysis functions. But it has three gaps against the user's stated requirements:

**Gap A — No per-student isolation enforcement.** `SiaEngine` and `StudentContextBuilder` operate on whichever `ModelContext` is passed in. There is no runtime check that the context belongs to the currently-authenticated student UUID. If a counselor impersonation view or a multi-student render accidentally passes the wrong context, SIA would answer with another student's data. The fix is a lightweight identity-assertion wrapper: every SiaEngine call must receive `studentId: String` (from the session JWT), and `StudentContextBuilder.build()` must verify the loaded `StudentModel.userId` matches before returning context.

**Gap B — No AdvisorChatView.** The chat UI is quarantined in `Features/Legacy/`. The engine runs but there is no screen for the student to talk to SIA. Un-quarantining `AdvisorChatView` (PROMOTE_WITH_REWRITES per LEGACY_TRIAGE.md) is the single highest-leverage UI move — it surfaces everything the engine already computes.

**Gap C — Memory is local-only.** `MemoryExtractorService` writes to `ConversationMemoryStore` (SwiftData), not to the `student_memory_summaries` Supabase table specified in SPEC_v2 §2.5. The schema doesn't exist yet (confirmed: migrations 0001-0009 have no `student_memory_summaries` or `student_nudge_log`). This means memory is lost on reinstall and doesn't sync across devices.

**Open design questions requiring founder input before build:**

1. **SIA "raw box" baseline persona.** What is SIA's starting archetype when a new student opens the app for the first time? Options: (a) warm-mentor ("Hey, I'm Sia — let's figure out your next step together"), (b) neutral-listener ("Tell me about yourself"), (c) structured-coach ("Let's start with your grade and career interest"). This affects `SpecialistPrompts.swift` and the opening context injection.

2. **Counselor-to-SIA access level.** SPEC_v2 §2.2 says counselors get read access to `student_ai_chats`. The user wants something more nuanced: options are (a) summary-only — SIA generates a weekly digest visible to the counselor ("Student is working through college list anxiety, mentions essays 3x per week"), (b) keyword-tagged view — counselor sees flagged topics, not raw text, (c) query-on-demand — counselor's own SIA instance can ask "what has this student been discussing" and get a curated answer. This is a product decision that changes both the DB schema and the ai-gateway logic.

3. **15-day scope cuts.** The full SIA overhaul (AdvisorChatView + isolation + memory sync + counselor access + nudge cards) is 8-12 days of work. See Section 7 for what this document recommends deferring.

**Concrete SIA deliverables for this sprint (recommended):**

| Deliverable | What it is | Effort |
|---|---|---|
| Student isolation assertion | Wrap `StudentContextBuilder.build()` with JWT-UUID check; add unit test | S |
| AdvisorChatView un-quarantine | Promote + rewrite (swap `AIService` → `AIGatewayClient`, `AuthManager` → `SupabaseAuthService`) | M |
| Migration: `student_memory_summaries` + `student_nudge_log` | New migration 0010 with RLS (student-owned, no school read) | S |
| Memory sync to Supabase | Update `MemoryExtractorService` to also upsert to `student_memory_summaries` after local save | S |
| Proactive nudge card on Home tab | Wire `NudgeRules.evaluate()` output to a ranked card in the existing Dashboard urgency section | M |
| SIA opening persona (raw box baseline) | Update `SpecialistPrompts.swift` once founder picks archetype | S (after decision) |
| Counselor summary surface | Implement chosen access model once founder picks option | M (after decision) |

---

## 5. Ranked Next Moves

### A. Hard Launch Blockers (must ship before any real user)

**Move 1 — Founder data wall enforcement**
- Why first: This is an open S1 audit finding. The founder can currently read every tenant's student data. This is a security promise the product makes but doesn't keep.
- Touches: `TenantContext.swift` modifier, ~30 dashboard root views under `Features/{Student,Counselor,Admin,Parent}/`
- Agent: `pwj:swift-ios-specialist`
- Complexity: S (mechanical — apply one modifier to ~30 files)

**Move 2 — TLS pins + AppConfig preflight crash**
- Why: A release build today either refuses all connections (wrong SPKI bytes) or silently boots with a non-functional backend. Either failure mode is user-invisible.
- Touches: `TLSPinnedSession.swift`, `AppConfiguration.swift`, `LadderApp.swift`, CI gate
- Agent: `pwj:swift-ios-specialist` + `pwj:security-auditor`
- Complexity: S

**Move 3 — Fix remaining 5 open S1 bugs from BUG_REPORT**
- S1-5: Wire counselor queue Approve/Send-back/Modify buttons to PATCH schedules endpoint
- S1-6: Replace `@State var grades` in `GradesSelfEntryView` with `@Query` + SwiftData insert
- S1-8: Add `.task` to `SchedulingWindowView` to fetch real precondition states from DB
- S1-9: Replace client-generated parent invite code with `POST /rpc/generate_parent_invite`
- S1-10: Wire feature flags Save to POST feature_flags endpoint
- Agent: `pwj:swift-ios-specialist` + `pwj:supabase-specialist`
- Complexity: M (5 bugs, each independent)

### B. SIA Personalization Work

**Move 4 — Student isolation assertion in SiaEngine**
- Why: The user's requirement #1b. A counselor surface or future multi-student render must not leak data across students. One assertion in `StudentContextBuilder.build()` closes the gap.
- Touches: `StudentContextBuilder.swift`, `SiaEngine.swift`
- Agent: `pwj:swift-ios-specialist`
- Complexity: S

**Move 5 — AdvisorChatView un-quarantine (the most important UI move)**
- Why: SIA has a real engine but no student-facing chat UI. The student product is essentially headless without this. This is the central feature the user listed as requirement #1.
- Touches: `Features/Legacy/AIAdvisor/Views/AdvisorChatView.swift` (promote + rewrite), `AdvisorChatViewModel.swift` (AIService → AIGatewayClient), wire to `StudentDashboardView` Advisor tab
- Agent: `pwj:swift-ios-specialist`
- Complexity: M

**Move 6 — SIA memory persistence to Supabase + migration 0010**
- Why: Memory is currently local SwiftData only. Reinstall or new device = blank SIA. Requirement #1c ("starts from raw box, adapts per user") requires durable per-student memory.
- Touches: New migration (`student_memory_summaries`, `student_nudge_log`), `MemoryExtractorService.swift` upsert, RLS policies
- Agent: `pwj:supabase-specialist` + `pwj:swift-ios-specialist`
- Complexity: M

**Move 7 — Proactive nudge card on Home tab**
- Why: Requirement #1a — the counselor "reacts to everything." `NudgeRules.evaluate()` already generates nudges. They need to surface. This is the "feel alive" moment for SIA.
- Touches: `StudentDashboardView.swift` urgency section, `NudgeRules.swift`, `student_nudge_log` (schema from Move 6)
- Agent: `pwj:swift-ios-specialist`
- Complexity: M

**Move 8 — SIA opening persona + counselor summary surface**
- Why: Requirement #1a (human-brain adaptive) and #1d (counselor access). Depends on founder picking archetype and access model (see Section 4 open questions).
- Touches: `SpecialistPrompts.swift`, `ai-gateway/index.ts`, new counselor-summary view
- Agent: `pwj:supabase-specialist` + `pwj:swift-ios-specialist`
- Complexity: M (after founder decisions)

### C. Bug Batch from BUG_REPORT (S2 — friction bugs)

**Move 9 — S2 bug batch (career quiz scoring, class suggester, counselor KPIs)**
- S2-3: Wire career quiz `finish()` to ai-gateway for scoring + write `career_profile_vector_cipher`
- S2-2: Wire `ClassSuggesterView.load()` to `AIGatewayClient` (replace 500ms sleep + empty list)
- S2-12: Replace hardcoded mock KPIs in `CounselorDashboardView` with real DB fetch
- S2-10: Wire `CounselorInviteCodesView` to `/rpc/counselor_issue_invite` (fixes root cause of S1-1's sibling)
- Agent: `pwj:swift-ios-specialist` + `pwj:supabase-specialist`
- Complexity: M

### D. iPad Parity Gaps

**Move 10 — iPad parity sweep (PLAN Phase 3)**
- Why: Standing hard rule. iPad target is re-enabled (`4ea2ff0`) but zero `horizontalSizeClass` checks exist in any active view. Every dashboard clips on iPad.
- Touches: All dashboards under `Features/{Admin,Counselor,Founder,Parent,Student,Auth,Landing}/`, `AdaptiveContainer.swift` (new shared layout component)
- Agent: `pwj:swift-ios-specialist` using `ladder-ipad-parity` skill
- Complexity: L

### E. Nice-to-Haves (post-bug-fix)

**Move 11 — Legacy un-quarantine: Engines + Career + College Intelligence**
- Why: `ActivitySuggestionEngine`, `CollegeMatchCalculator`, `RIASECEngine`, `ConnectionEngine`, `StateRequirementsEngine` are classified PROMOTE in LEGACY_TRIAGE. They complete the AI context injection package (SPEC §2.3). All pure-logic with no auth deps.
- Touches: 8 engine files from `Services/Legacy/Engines/` → `Services/Engines/`; unit tests per engine
- Agent: `pwj:refactorer` + `pwj:swift-ios-specialist`
- Complexity: M

**Move 12 — ai-gateway hardening: rate limiting + safeSerialize fix**
- Why: S2 audit items. Rate limit is a `// TODO` stub — any real user could exhaust the AI quota. safeSerialize regex bug could pass control characters to the model.
- Touches: `ai-gateway/index.ts`, backend tests
- Agent: `pwj:supabase-specialist`
- Complexity: S

---

## 6. Recommended Path to Launch in 15 Days

**Days 1-3 — Unblock and secure**
- Move 1: Founder data wall enforcement (S — can be done in a few hours)
- Move 2: TLS pins + AppConfig preflight crash
- Move 3: Remaining 5 S1 bugs (5 independent fixes, run in parallel)
- Target: App is secure, all S1 bugs resolved, real-user test can begin

**Days 4-7 — SIA core (the headline feature)**
- Move 4: Student isolation assertion (S — Day 4 morning)
- Move 5: AdvisorChatView un-quarantine + wire to Advisor tab (M — Days 4-6)
- Move 6: Migration 0010 + memory persistence to Supabase (M — Days 4-6, parallel with Move 5)
- Move 7: Proactive nudge card on Home tab (M — Day 7)
- Founder input needed by Day 4: SIA persona archetype + counselor access model
- Target: Student can open app, chat with SIA, SIA remembers them across sessions, Home tab shows live nudges

**Days 8-11 — Polish and parity**
- Move 8: SIA opening persona + counselor summary (M — depends on Days 4 founder decisions)
- Move 9: S2 bug batch — career quiz, class suggester, counselor KPIs (M)
- Move 10: iPad parity sweep — begin with Student main tabs + Auth flows (L — split across Days 8-11)
- Move 12: ai-gateway rate limiting + safeSerialize fix (S, parallel)
- Target: Full SIA loop working, S2 friction gone, iPad usable for pilot schools

**Days 12-15 — Launch prep**
- Move 10 continued: Remaining iPad dashboards (Counselor, Admin, Founder)
- Move 11: Engine promotion if time permits (nice-to-have, accelerates AI context quality)
- TestFlight build + smoke test against Deku Drench Prep seed users
- Legal URL fix (S2-11 — swap `purewavejosh.com` domain to real domain)
- Clean up: delete `Ladder.xcodeproj/`, move Ideas/CLAUDE.md to `docs/historical/`
- Target: TestFlight build ready; real counselor can log in, see students, SIA is live

---

## 7. Defer to v1.1 (Post-Launch)

These are confirmed in-scope per SPEC_v2 but cannot fit in 15 days without risking the launch:

| Item | Why defer | Spec ref |
|---|---|---|
| School transfer flow (3-stage approval) | Requires `transfer_requests` schema, new Founder "Pending Transfers" surface, Admin "Incoming Transfers" panel, AND email Edge Function (not yet built) — at minimum 5 days | SPEC_v2 §3 |
| Email delivery Edge Function (Resend) | Prerequisite for transfer flow; no Resend integration exists anywhere in repo | SPEC_v2 §5 |
| Extracurricular seed dataset (300-600 entries) | Requires 3-5 days of human research curation; cannot parallelize to completion in 15 days | SPEC_v2 §4.3 |
| School-to-private conversion flow | Depends on transfer schema and email infra | SPEC_v2 §3.3 |
| Parent multi-child digest | ADR-008 §2.10; `Features/Parent/` untouched since April | ADR-008 |
| Counselor Marketplace | B2C-only, confirmed post-v1 in PLAN.md out-of-scope | PLAN.md |
| Mock interview / resume builder | Quarantined, no un-quarantine ticket | LEGACY_TRIAGE |
| Streak / points / levels | Not built anywhere | AUDIT_REPORT |
| AI streaming via AsyncThrowingStream | Backend supports SSE; iOS client doesn't — add after SIA chat is shipped | AUDIT_REPORT |
| Offline queue fix (S2-7 mutations lost) | `OfflineQueueManager` always returns `false`; lower priority for pilot | BUG_REPORT S2-7 |

---

## Open Questions (Founder must answer before Day 4)

1. **SIA persona archetype.** Which opening style: warm-mentor, neutral-listener, or structured-coach? This sets `SpecialistPrompts.swift` for every new student's first session.
2. **Counselor-to-SIA access model.** Pick one: (a) weekly summary digest, (b) keyword-tagged topic view, (c) query-on-demand via counselor's SIA. Affects both DB schema and ai-gateway routing.
3. **Extracurricular seed dataset.** Founder co-curates 50 entries per cluster (300 total) before launch, or defer the seeded engine to v1.1 and ship with the existing generic engine? (Generic engine already promoted and active — it works, just not named-activity specific.)
4. **Legal domain.** What domain replaces `purewavejosh.com` in `SchoolDetailView`? Needed before TestFlight.

---

## What NOT to Do Right Now

- Do not start the school transfer flow. It needs an email Edge Function that doesn't exist, and the 3-stage schema. Starting it burns 5+ days that should go to SIA.
- Do not do a full Legacy un-quarantine sweep before AdvisorChatView is working. The engines are nice; the chat UI is the product. Prove the UI first.
- Do not run a new spec phase. SPEC_v2.md is current and complete. Building is the constraint, not spec.
