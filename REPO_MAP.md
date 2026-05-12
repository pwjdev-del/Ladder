# REPO_MAP — Ladder iOS App

**Stack class:** mobile (iOS + Supabase backend)  
**Size class:** medium (~819 active files, excl. Legacy)  
**Freshness:** active (38 commits since 2026-04-25, last 2026-05-12)  
**Existing PWJ artifacts:** SPEC_v2.md, PLAN.md, IDEAS_DIGEST.md, LEGACY_TRIAGE.md, AUDIT_REPORT.md, BUG_REPORT.md, CLAUDE.md, README.md

---

## Detected stack

| Layer | Technology | Status | Notes |
|---|---|---|---|
| Frontend | iOS SwiftUI + SwiftData | active | 819 Swift files, Xcode 16+ |
| Backend | Supabase Edge Functions (TypeScript) | active | 6 functions, bootstrap/auth/provisioning/ai-gateway |
| Database | Postgres (Supabase) | active | migrations, seed.sql, 18 TS files |
| AI | SiaEngine + legacy AdvisorChatViewModel | mixed | SiaEngine in Services/AI/, Legacy AIAdvisor quarantined |
| Auth | Placeholder hardcoded password | **FLAG** | `password == "Ladder!v2-pilot"` in B2CSignup — no real Supabase call |
| CI | GitHub Actions | active | .github/workflows enabled as of 2026-04-30 |

---

## Directory tree (depth 2, active paths)

```
LadderApp/
├── App/
│   ├── Navigation/ (MainTabView, CounselorTabView, AdminTabView, AppCoordinator)
│   ├── Routing/ (Route.swift — role-based)
│   ├── Data/ (SwiftDataContainer.swift)
│   └── SignedInRouter.swift
├── Features/
│   ├── Founder/ (Dashboard, FeatureFlags)
│   ├── Counselor/ (Dashboard, InviteCodes, Models)
│   ├── Student/ (AIAdvisor + Chat models, Extracurriculars)
│   ├── Parent/ (parent-digest, multi-child)
│   ├── Admin/ (admin role)
│   ├── Auth/ (B2CSignup — auth placeholder lives here)
│   ├── Backdoor/ (long-press logo → Founder/Employee split)
│   ├── Landing/ (landing page)
│   └── Legacy/ (~210 files, EXCLUDED from build, quarantined)
├── Services/
│   ├── AI/ (SiaEngine.swift — active AI counselor)
│   ├── MemoryExtractorService.swift
│   └── (other domain services)
├── DesignSystem/ (components, theme, tokens)
├── Models/ (SwiftData models, Routes, Engines)
├── Utilities/ (helpers)
└── Resources/ (assets, strings, fonts)

LadderBackend/
├── supabase/functions/ (6 Edge Functions)
│   ├── ai-gateway/ (SIA → OpenAI bridge)
│   ├── bootstrap-user/ (initial user provisioning)
│   ├── founder-login/ (founder auth)
│   ├── invite-redeem/ (invite token redemption)
│   ├── provision-tenant/ (school tenant setup)
│   └── varun-validate/ (validation utility)
├── supabase/migrations/ (schema)
├── db/ (database layer)
├── api/ (REST handlers)
├── domain/ (business logic)
├── crypto/ (envelope.ts — secret encryption)
├── ai-gateway/ (AI orchestration)
├── audit/ (compliance)
└── tests/

supabase/
├── migrations/ (schema version control)
├── functions/ (symlink to LadderBackend/supabase/functions)
├── seed.sql (test data)
└── .temp/ (Supabase CLI state)

tests/
├── LadderAppTests/ (unit tests, Models/, Engines/)
├── e2e/ (end-to-end)
├── scheduling/ (deadline calc tests)
├── crypto/ (encryption tests)
└── flags/ (feature flag tests)

docs/
├── design/ (Stitch design system deliverables)
├── decisions/ (ADR-008, technical decisions)
├── planning/ (roadmap, Q1-Q3 spec)
├── compliance/ (legal, FERPA)
└── runbooks/ (deployment, troubleshooting)

Config/
scripts/
```

---

## Files most likely to matter (ranked by coupling + recency)

| File | Purpose | Status |
|---|---|---|
| `LadderApp/App/Data/SwiftDataContainer.swift` | SwiftData persistence container, used by all features | active |
| `LadderApp/App/Routing/Route.swift` | Role-based routing (student, counselor, founder, employee, parent, admin) | active |
| `LadderApp/Features/Auth/B2CSignup/B2CSignupView.swift` | **PLACEHOLDER AUTH HARDCODED** — password == "Ladder!v2-pilot" | **HIGH PRIORITY FIX** |
| `LadderApp/Services/AI/SiaEngine.swift` | AI counselor brain + memory extraction | active, critical |
| `LadderApp/Features/Student/AIAdvisor/Models/ChatModels.swift` | Chat/conversation data structures | active |
| `LadderApp/Features/Counselor/Dashboard/CounselorDashboardView.swift` | Counselor role view (sees student essays + AI insights) | active |
| `LadderApp/Features/Founder/Dashboard/FounderDashboardView.swift` | Founder/school config + invite codes | active |
| `LadderApp/Features/Backdoor/` | Employee long-press split + backdoor role choice | active (2026-04-29) |
| `LadderBackend/supabase/functions/ai-gateway/` | SIA → OpenAI bridge + prompt engineering | active |
| `LadderBackend/supabase/functions/bootstrap-user/` | User provisioning on signup | active |
| `LadderBackend/supabase/migrations/` | Postgres schema (school, student, counselor, transfers, essays, invites) | active |
| `LadderApp/Features/Legacy/` | ~210 files, student-journey v1, **not in active build** | archived |

---

## Recent git activity (2026-04-25 → 2026-05-12 / 17 days, 38 commits)

**High-activity paths:**
- `LadderApp/Features/Counselor/` — counselor role + dashboard
- `LadderApp/Features/Founder/` — founder dashboard, feature flags
- `LadderApp/Features/Backdoor/` — employee split (new)
- `LadderBackend/supabase/` — config hardcoding fixes
- `LadderApp/Features/Auth/` — signup UX fixes + legal text

**Recent themes (by commit message):**
1. Config hardcoding (Supabase host + publishable key) — 2 commits
2. UX fixes: forgot password, nav tabs, invite, AI chat, signup error — 1 mega-fix (8 files)
3. Legal text readability + validation feedback — 2 commits
4. Employee backdoor role split (13 files) — 2026-04-29
5. Feature flags, spec baking, seed users — 3 commits
6. CI activation (GitHub Actions workflow) — 1 commit

**Stale areas (not touched since ~2026-04-25):**
- `LadderApp/Features/Parent/` — parent digests (marked for ADR-008 but untouched)
- `LadderApp/Features/Admin/` — admin role (scaffolded)
- `docs/research/` — older research

---

## AI / Counselor / Chat topology

**Active AI paths:**
- `LadderApp/Services/AI/SiaEngine.swift` — main AI engine (memory, routing, counselor behavior)
- `LadderApp/Features/Student/AIAdvisor/Models/ChatModels.swift` — student-facing chat models
- `LadderApp/Features/Counselor/Dashboard/` — counselor sees student essays + AI summaries
- `LadderBackend/supabase/functions/ai-gateway/` — OpenAI bridge, prompt engineering

**Quarantined (Legacy):**
- `LadderApp/Features/Legacy/AIAdvisor/Views/` (AdvisorChatView, AdvisorHubView, EssayHubView)
- `LadderApp/Features/Legacy/AIAdvisor/ViewModels/AdvisorChatViewModel.swift`

---

## Auth / Signup status

**CRITICAL FLAG:** Auth is fully placeholder.

- **Hardcoded gate:** `LadderApp/Features/Auth/B2CSignup/B2CSignupView.swift` checks `password == "Ladder!v2-pilot"` only.
- **No Supabase call:** Real `supabase.auth.signUp()` never reached; gate is local.
- **Affected logins:** All 3 entry points (student, parent, school partner) use same hardcode.
- **Backend unprepared:** Supabase functions (`bootstrap-user`, `founder-login`) exist but unreachable in production.

**Must fix before:** any production use. Switch to real Supabase Auth SignUp + JWT flow.

---

## Legacy quarantine status

**Features/Legacy/** exists but is **NOT in active build** (per project memory, hard rule from 2026-04-14).

- **File count:** ~210 files
- **Contains:** student-journey v1, old AIAdvisor UI, old messaging
- **Reason:** Ideas-aligned prototype; superseded by current school-sandbox app
- **Fate:** Keep (don't delete); may be un-quarantined later per ADR decisions

**Build rule:** Xcode excludes `Features/Legacy/` from active target. No warnings; no build churn.

---

## Known issues & hotspots

| Issue | Last touched | Status |
|---|---|---|
| **Auth placeholder** | 2026-04-26 | BLOCKER — no real Supabase auth |
| **Font missing (.ladderTitle)** | 2026-04-29 | Fixed (swap to .system) |
| **Signup button grey on iOS 26** | 2026-04-29 | Fixed |
| **Forgot password broken** | 2026-05-01 | Fixed (top 5 UX bugs fix) |
| **Nav tabs non-functional** | 2026-05-01 | Fixed (routing + tab state) |
| **AI chat crashes** | 2026-05-01 | Fixed (SiaEngine integration) |
| **Legal text unreadable** | 2026-04-29 | Fixed (layout + scrolling) |
| **Supabase config not reaching backend** | 2026-05-12 | Fixed (hardcode host + publishable key) |

---

## Pipeline routing recommendation

**Mode:** Continue in-progress (bug fixes + feature enablement)  
**Specialists needed:**
1. **iOS SwiftUI engineer** — SPEC v2 UI parity (iPad + iPhone), Design System completion
2. **Backend/Supabase engineer** — Real auth implementation, AI gateway optimization
3. **Product/compliance** — FERPA audit, data ownership model enforcement

**Re-run mapper:** if >50 commits since 2026-05-12

---

Generated 2026-05-12 (refreshed from 2026-04-25 snapshot). Zero files read; structural data only.
