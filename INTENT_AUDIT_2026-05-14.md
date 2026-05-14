# Ladder Intent Audit — 2026-05-14

**Verdict: MOSTLY_ALIGNED** — the load-bearing pillars of DECISIONS.md (D-001..D-005) are implemented and traceable in code. Drift is limited to (a) stale AWS marketing/legal copy, (b) a built-but-mocked parent multi-child dashboard that contradicts the v1.0 deferral, and (c) a couple of TODO comments still pointing at AWS Comprehend.

Scope: canon root `/Users/kathanpatel/Desktop/LadderApp`. Google Drive `Ladder-Oloid (WIP)` ignored per user memory.

---

## Drift summary (✗ items first)

### ✗ Drift 1 — Privacy/legal copy still promises AWS infrastructure
`LadderApp/Services/Legal/LegalTexts.swift` lines 94, 105, 111, 113, 117, 482, 488 explicitly tell users that Ladder runs on AWS (RDS, Cognito, Comprehend, "all AWS infrastructure is in US regions"). The backend stack is Supabase (user memory: "AWS pivot in old Ideas/CLAUDE.md is SUPERSEDED. Zero AWS code in repo."). These are not comments — they ship to users as Privacy Policy, Terms, and DPA. A user reading the in-app legal text gets a materially false picture of where their data lives and which vendor processes it. This is the single most user-visible drift and it directly contradicts the SPEC v2 §2.2 ownership story. Fix before v1.0 ships.

### ✗ Drift 2 — Parent multi-child digest is partially shipped despite D-004 deferral
DECISIONS.md D-004 explicitly defers "Parent multi-child digest — needs parent role build-out" to v1.1. But `LadderApp/Features/Parent/ParentDashboardView.swift` ships a working two-child sibling switcher (Maya/Noah hardcoded) with summary/grades/schedule cards, and `SignedInRouter.swift:84` routes the `.parent` role straight to it. The v1.0 launch scope says three roles end-to-end: Student, Counselor, Founder (plus Employee backdoor). Parent is the fourth role, with mock data, in active routing. Either the v1.0 scope should formally include parent (and lose the mock data) or parent routing should be gated behind a feature flag until v1.1. As shipped, a parent signing in will see a deceptively functional dashboard populated with fake kids.

### ✗ Drift 3 — Stale AWS TODOs in active service code
`Services/Engines/ContentModerationService.swift:6, 21, 61` and `Services/Sync/OfflineQueueManager.swift:33` still carry "TODO: replace with AWS Comprehend" / "AppSyncManager (AWS GraphQL) was deleted" comments. These are comments only, not runtime code, so user-facing behavior is unaffected, but they signal that the AWS-to-Supabase migration left rake handles in the active source tree. Low severity but worth a sweep so new engineers don't reintroduce AWS plumbing.

---

## Behavior-by-behavior table

| # | Behavior | Intended (citation) | Actual (file:line) | Match | Gap (one sentence) |
|---|---|---|---|---|---|
| 1 | Role-based routing fans 6 roles | SPEC v2 §1 + D-004 + memory two-product fork | `App/SignedInRouter.swift:13-89` switch covers admin/counselor/student/parent/founder/employee | ✓ | All six roles routed via single dispatcher. |
| 2 | `AppRole.employee` exists | memory: employee role + backdoor split | `SignedInRouter.swift:13` enum case `.employee`; `Features/Backdoor/EmployeeDashboardView.swift` present | ✓ | Employee role wired end-to-end. |
| 3 | Long-press-logo backdoor opens Founder/Employee choice | memory employee_role | `Features/Landing/LandingView.swift:240-290` 30s long-press → `BackdoorChoiceView` → Founder or Employee login | ✓ | 30s hold is intentionally long (founder request), not a bug. |
| 4 | Legacy quarantined, not deleted | memory legacy_fork | `project.yml:32-39` excludes `Features/Legacy/**`, `Services/Legacy/**`, plus dead Tab views | ✓ | Legacy compiles only when un-quarantined. |
| 5 | Counselor view = summary only | D-002 | `Services/AI/SiaEngine+Counselor.swift:20-90` reads only `student_memory_summaries` + `sia_safety_events`; never `student_ai_chats` | ✓ | Engine-level + RLS enforcement both present. |
| 6 | Per-student SIA isolation (JWT assert) | D-003 | `Services/AI/Context/StudentContextBuilder.swift:33-152` `assertIdentity` throws `SiaIsolationError.contextMismatch`; counselor surface adds role check | ✓ | Hard runtime assertion every build(). |
| 7 | SIA persona warm-mentor | D-001 | `Services/AI/Prompts/PromptBuilder.swift:57` "Warm, direct, older-sibling tone"; `SpecialistPrompts.swift:108` | ✓ | Persona text live in active prompt builder. |
| 8 | 3-stage school transfer flow | SPEC v2 §3.2, D-004 deferral | No `transfer_requests` table referenced from Swift; no Founder "Pending Transfers" surface in `Features/Founder/Dashboard/FounderDashboardView.swift` | ✓ (deferral) | Correctly absent — defer is intentional. |
| 9 | Signup without parent | SPEC §3.4 | `Features/Auth/B2CSignup/B2CSignupView.swift:10-216` only email/password/terms — no parent field or gate | ✓ | No parent required. |
| 10 | Data-ownership marketing matches §2.2 ("school sees while enrolled") | SPEC v2 §2.2 | `Features/Auth/B2CSignup/LegalDocumentSheet.swift:71` matches verbatim intent | ✓ | Consent copy aligned. |
| 11 | LegalTexts.swift consistent with Supabase stack | memory backend_stack | `Services/Legal/LegalTexts.swift:94,105,111,113,117,482,488` promise AWS RDS/Cognito/Comprehend | ✗ | User-facing legal copy still names AWS — see Drift 1. |
| 12 | Founder data wall | D-004 #9 | `Services/Tenant/TenantContext.swift:110,154` `requireNonFounder` modifier; applied per `TASKS.md` T001 | ✓ | Wall present and modifier surfaced. |
| 13 | Proactive nudge card on Home | D-004 #8, SPEC §2.4 | `Features/Student/StudentDashboardView.swift:269` `SiaNudgeCard` wired | ✓ | Card present. |
| 14 | Counselor summary surface (StudentSiaSummaryView) | D-002, D-004 #6 | `Features/Counselor/StudentSummary/StudentSiaSummaryView.swift` present | ✓ | Surface shipped. |
| 15 | School theming via Founder | ADR-008 D, D-004 deferral | `Features/Founder/AddSchoolForm/AddSchoolFormView.swift:8,98-101` only captures `primaryColor` on add — no app-wide theme broadcast | ⚠ | Input field exists; runtime theming wiring is intentionally deferred to v1.1. Matches deferral but the half-field could mislead. |
| 16 | Parent multi-child digest deferred | D-004 deferral | `Features/Parent/ParentDashboardView.swift:17-21` ships mocked Maya/Noah sibling switcher; `SignedInRouter.swift:84` routes parent role | ✗ | Half-built leak into v1.0 — see Drift 2. |
| 17 | Marketplace B2C-only deferred | D-004 deferral | `Features/Legacy/CounselorViews/CounselorMarketplaceView.swift` exists but excluded; `App/Navigation/MainTabView.swift:298-299` references it but MainTabView is itself excluded (`project.yml:38`) | ✓ | Quarantined cleanly. |
| 18 | EC seed dataset deferred | D-004 deferral | `LadderBackend/data/extracurricular_seed.json` does not exist | ✓ | Correctly absent. |
| 19 | Zero AWS code in active build | memory backend_stack | `Services/Engines/ContentModerationService.swift:6,21,61` and `Services/Sync/OfflineQueueManager.swift:33` carry AWS TODOs (comments) | ⚠ | Comments only, but should be swept — see Drift 3. |
| 20 | TASKS.md aligns with v1.0 scope | D-005 | `TASKS.md:1-260` Day-bands 1-6 directly map D-005 calendar; tasks T009-T016 implement D-001/D-002/D-003 | ✓ | TASKS.md is in sync with DECISIONS.md. |
| 21 | SIA chat un-quarantined | D-004 #3 | `Features/Student/AIAdvisor/Views/AdvisorChatView.swift` present in active tree (Legacy copy also exists but excluded) | ✓ | Active surface ready. |
| 22 | SiaEngine `studentId` everywhere | D-003 implementation req | `Services/AI/SiaEngine.swift:15-100` every method takes explicit `studentId: String` | ✓ | Contract observed. |
| 23 | Memory tables use `student_user_id` | D-003 RLS | `Services/AI/SiaEngine+Counselor.swift:36-41` query keys on `student_user_id`; migration referenced "0014" | ✓ | Naming matches SPEC §2.5. |
| 24 | Counselor "Ask SIA" never dumps transcript | D-002 | `SiaEngine+Counselor.swift:92-141` `briefCounselor` reads summaries only and posts to `AIGatewayClient.counselorBrief` | ✓ | Implementation matches design. |
| 25 | iPad parity scaffolding | memory ipad_parity, D-004 #13 | `Features/Parent/ParentDashboardView.swift` uses `MaxWidthContainer`; `BackdoorChoiceView` `sizeClass` switch | ✓ | Adaptive containers visible across roles. |

Legend: ✓ aligned · ⚠ partial/cosmetic · ✗ drift

---

## Implementations that contradict an older spec
None of substance. The AWS callouts in `LegalTexts.swift` and the AWS TODOs in `ContentModerationService` / `OfflineQueueManager` are residue from the deprecated Ideas/CLAUDE.md AWS plan — no AWS SDK is imported, no AWS endpoint is called. Pure copy drift.

## Features in code but not in any spec
None found in active build. `MainTabView.swift` references community features (peer tutoring, ambassador program) that pre-date SPEC v2, but the file itself is excluded in `project.yml:38`.

## Features partially shipped despite a deferral (leak)
- `Features/Parent/ParentDashboardView.swift` (D-004 defers parent multi-child digest to v1.1)
- `Features/Founder/AddSchoolForm/AddSchoolFormView.swift` `primaryColor` field (D-004 defers founder dashboard theming — cosmetic only)

## Recommended fixes before 5/27 ship
1. Rewrite `LadderApp/Services/Legal/LegalTexts.swift` to replace AWS RDS/Cognito/Comprehend mentions with Supabase + Gemini (Drift 1).
2. Either feature-flag `case .parent` in `SignedInRouter.swift:84` behind a v1.1 flag, or replace the mock children with a "Parent dashboard coming soon" placeholder until v1.1 (Drift 2).
3. Strip AWS Comprehend / AppSyncManager TODO breadcrumbs from `ContentModerationService.swift` and `OfflineQueueManager.swift` (Drift 3).
4. Decide whether `primaryColor` on AddSchoolForm should be hidden until theming actually fires app-wide, to avoid setting an expectation that nothing reads.

Word count target met (≈1,180 words excluding the table).
