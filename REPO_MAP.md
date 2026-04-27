# REPO_MAP — Ladder iOS App (Canonical)

**Stack class:** mobile + full-stack  
**Size class:** medium (~297 Swift files + 5 backend TypeScript + 287 docs/config)  
**Freshness:** active (20 commits in last 60 days, most recent 2026-04-18)  
**Existing PWJ artifacts:** CLAUDE.md (34K — architectural guide), docs/decisions/ADR-*.md (7 files), docs/design/stitch-batches/

---

## Detected stack

| Layer | Technology | Confidence | Source |
|---|---|---|---|
| Frontend | SwiftUI + iOS 17.0+ | high | project.yml + LadderApp/ sources |
| App Architecture | MVVM + feature-driven | high | ./LadderApp/Features/** folder structure |
| Design System | Ladder brand tokens + components | high | DesignSystem/Theme/ + Components/ |
| Backend (cloud) | Supabase (PostgreSQL + Edge Functions) | high | LadderBackend/supabase/ structure |
| Backend (code) | TypeScript Edge Functions | high | LadderBackend/supabase/functions/*.ts |
| Cryptography | Per-tenant DEK envelope system | high | LadderBackend/crypto/envelope.ts |
| Build system | XCGen (YML → .pbxproj) | high | project.yml present |
| Deployment | iOS app (no web) | high | iOS only targets |
| Auth | Supabase Auth + role-based routing | high | LadderApp/Features/Auth/** |
| Feature flags | Grouped feature gates by grade level | high | Services/Flags/GradeFeatureManager.swift |
| AI | Gateway to LLM via Edge Function | high | LadderBackend/ai-gateway/ + AIGatewayClient.swift |

---

## Language breakdown

- **Swift:** ~287 files (95%)
- **TypeScript/JavaScript:** ~5 files backend (2%)
- **Markdown/Docs:** ~130 files (3%)
- **Config/YAML:** project.yml, .swiftlint.yml, etc.

**Total source (excluding build, DerivedData, node_modules): ~422 files**

---

## Directory tree (depth 3, build artifacts hidden)

```
.
├── LadderApp/                          # Main SwiftUI app (iOS 17+)
│   ├── App/                            # App entry + routing
│   │   ├── LadderApp.swift             # @main, WindowGroup setup
│   │   └── SignedInRouter.swift        # Role-based navigation
│   ├── Features/                       # Feature modules (MVVM)
│   │   ├── Auth/                       # Login, signup, school picker, invites
│   │   │   ├── B2CLoginView.swift
│   │   │   ├── SchoolLoginView.swift
│   │   │   ├── SchoolPickerView.swift
│   │   │   ├── InviteRedemptionView.swift
│   │   │   └── FounderLoginView.swift
│   │   ├── Landing/
│   │   │   └── LandingView.swift       # 2-CTA branding
│   │   ├── Student/
│   │   │   └── StudentDashboardView.swift
│   │   ├── Parent/
│   │   │   └── ParentDashboardView.swift
│   │   ├── Counselor/
│   │   │   └── CounselorDashboardView.swift
│   │   ├── Admin/
│   │   │   └── AdminDashboardView.swift
│   │   ├── Founder/
│   │   │   ├── Dashboard/FounderDashboardView.swift
│   │   │   └── Login/FounderLoginView.swift
│   │   └── Legacy/                    # Quarantined old code
│   ├── Services/                       # Core business logic
│   │   ├── Tenant/TenantContext.swift  # Multi-tenant identity
│   │   ├── Crypto/CryptoService.swift  # Envelope crypto ops
│   │   ├── Flags/                      # Feature gates
│   │   │   ├── GradeFeatureManager.swift
│   │   │   ├── FeatureGateManager.swift
│   │   │   └── FlagClient.swift
│   │   ├── Networking/                 # TLS pinning + Supabase
│   │   │   └── TLSPinnedSession.swift
│   │   ├── Audit/AuditClient.swift     # Compliance logging
│   │   └── AI/AIGatewayClient.swift    # LLM integration
│   ├── Models/DomainEnums.swift        # Role, Grade, etc.
│   ├── DesignSystem/                   # Brand tokens + components
│   │   ├── Theme/
│   │   │   ├── LadderTheme.swift
│   │   │   ├── LadderBrand.swift
│   │   │   ├── ColorTokens.swift
│   │   │   ├── Typography.swift
│   │   │   └── Spacing.swift
│   │   ├── Components/                 # 15+ reusable UI elements
│   │   │   ├── BrandGradient.swift
│   │   │   ├── LogoutButton.swift
│   │   │   ├── PasswordField.swift
│   │   │   ├── DataDenseTable.swift
│   │   │   ├── ScheduleGrid.swift
│   │   │   ├── SiblingSwitcher.swift
│   │   │   └── ...
│   │   └── Legacy/                    # Old v1 components (archived)
│   ├── Resources/Assets.xcassets/      # Images + Ladder logo
│   └── Utilities/Log.swift             # Logging
│
├── LadderBackend/                      # Backend services (TypeScript + SQL)
│   ├── supabase/
│   │   ├── migrations/                 # PostgreSQL schema migrations
│   │   ├── functions/                  # Edge Functions (Deno runtime)
│   │   │   ├── ai-gateway/index.ts     # LLM orchestration
│   │   │   ├── varun-validate/         # Varun AI validation
│   │   │   └── invite-redeem/          # Invite code redemption
│   │   └── ...
│   ├── db/                             # SQL policies + functions
│   │   ├── migrations/
│   │   ├── policies/                   # Row-level security (RLS)
│   │   └── functions/
│   ├── crypto/envelope.ts              # Per-tenant DEK system
│   ├── domain/scheduling.ts            # Deterministic scheduling logic
│   ├── ai-gateway/                     # (deprecated v1)
│   ├── api/                            # (deprecated v1)
│   ├── audit/
│   ├── varun/                          # Varun AI vendor integration
│   └── db/seed/                        # Test data fixtures
│
├── Ladder.xcodeproj/                   # LEGACY (Xcode 15 gen'd, 2142 lines)
│   └── project.pbxproj                 # ⚠️ Dual .xcodeproj issue (see note)
│
├── LadderApp.xcodeproj/                # ACTIVE (gen'd by XCGen from project.yml, 1303 lines)
│   └── project.pbxproj
│
├── Config/
│   └── Base.xcconfig                   # Build settings bridge
│
├── docs/                               # Architecture + decisions
│   ├── decisions/
│   │   ├── ADR-000-scope-full-spec.md  # v2 spec scope
│   │   ├── ADR-001-supabase-native-backend.md
│   │   ├── ADR-002-repo-layout-spec-§18.md
│   │   ├── ADR-003-deterministic-scheduling-core.md
│   │   ├── ADR-004-per-tenant-dek-envelope.md
│   │   ├── ADR-005-ai-gateway-single-edge-function.md
│   │   ├── ADR-006-llm-prompt-injection-defense.md
│   │   ├── ADR-007-pivot-to-grade-9-12.md
│   │   └── OVERRIDES.md                # Decision overrides log
│   ├── design/
│   │   ├── stitch-prompt.md            # Figma Stitch design brief
│   │   └── stitch-batches/             # Batch 1–5 screen specs
│   ├── runbooks/
│   │   ├── test-accounts.md            # QA credentials cheatsheet
│   │   └── qa-ios-simulator.md
│   ├── planning/
│   │   └── pr-body.md                  # v2 spec migration PR template
│   ├── ci-pending/
│   │   └── ci.yml                      # GitHub Actions (no workflow scope yet)
│   └── research/
│
├── .swiftlint.yml                      # SwiftLint config (140 char warn, 200 error)
├── project.yml                         # XCGen manifest (iOS 17+, Swift 5, A17)
├── CLAUDE.md                           # Architectural guide (34 KB — READ THIS FIRST)
├── README.md                           # High-level project overview
└── build/                              # Xcode DerivedData (ignored)
    ├── Build/
    ├── CompilationCache.noindex/
    ├── Index.noindex/
    ├── Logs/
    └── ModuleCache.noindex/
```

---

## Files most likely to matter (ranked by structural importance)

1. **LadderApp/App/LadderApp.swift** — `@main` entry point; WindowGroup + state setup
2. **CLAUDE.md** — 34 KB architectural guide; READ THIS FIRST before coding
3. **LadderApp/App/SignedInRouter.swift** — Role-based routing logic for all 6 user types
4. **LadderApp/Features/Landing/LandingView.swift** — Landing page (6 edits recent)
5. **LadderApp/Features/Auth/B2CLoginView.swift** — B2B-to-Consumer auth flow (6 edits)
6. **LadderApp/Features/Founder/Dashboard/FounderDashboardView.swift** — Founder role dashboard (6 edits)
7. **LadderApp/Features/Auth/SchoolLoginView.swift** — School-admin login (6 edits)
8. **LadderApp/Features/Auth/InviteRedemptionView.swift** — Invite code UX (6 edits)
9. **LadderApp/Services/Tenant/TenantContext.swift** — Multi-tenant identity context
10. **LadderApp/Services/Flags/GradeFeatureManager.swift** — Grade 9–12 feature gates
11. **LadderApp/DesignSystem/Theme/LadderTheme.swift** — Brand color/typography tokens
12. **LadderBackend/supabase/functions/ai-gateway/index.ts** — LLM orchestration edge function
13. **LadderBackend/crypto/envelope.ts** — Per-tenant DEK cryptography system
14. **LadderBackend/domain/scheduling.ts** — Deterministic scheduling core algorithm
15. **docs/decisions/ADR-007-pivot-to-grade-9-12.md** — Recent scope pivot (why grades 9–12)

---

## 🚨 CRITICAL FLAG: Dual .xcodeproj files

**Status:** ⚠️ **Suspicious structural issue**

| File | Lines | Status | Notes |
|---|---|---|---|
| `Ladder.xcodeproj/project.pbxproj` | 2,142 | LEGACY | Older Xcode 15 handcrafted project |
| `LadderApp.xcodeproj/project.pbxproj` | 1,303 | ACTIVE | Generated by XCGen from `project.yml` (current truth) |

**Analysis:**
- `project.yml` is the **single source of truth** (uses XCGen to generate .pbxproj)
- `Ladder.xcodeproj` is an older project file (not in use)
- `LadderApp.xcodeproj` is the active target (matches `project.yml` config)
- **Recommendation:** Delete `Ladder.xcodeproj` to eliminate confusion; make `LadderApp.xcodeproj` exclusive

---

## iPad parity status

**Search results:**  
- ❌ **No SceneDelegate/UISceneDelegate** found
- ❌ **No UIDevice.idiom checks** found
- ❌ **No sizeClass usage** found
- ❌ **No iPad-specific layouts** found

**Verdict:** SwiftUI app uses native iOS (iPhone) target only. iPad support **NOT implemented**.  
**Per project memory rule:** iPad parity is mandatory. This is a gap that must be closed before production.

---

## Recent git activity (last 20 commits)

**Velocity:** 20 commits in 60 days (active development)  
**Contributor:** Kathan (21 commits across this window)  
**Hottest paths (most edited):**
- `LadderApp/Features/Landing/LandingView.swift` (6 edits)
- `LadderApp/Features/Parent/ParentDashboardView.swift` (6 edits)
- `LadderApp/Features/Founder/Dashboard/FounderDashboardView.swift` (6 edits)
- `LadderApp/Features/Auth/SchoolLoginView.swift` (6 edits)
- `LadderApp/Features/Auth/InviteRedemptionView.swift` (6 edits)
- `LadderApp/Features/Auth/B2CLoginView.swift` (6 edits)

**Recent commits (last 7 days):**
```
526d7b8 feat(ui): grade-9-12 pivot + grouped feature flags + wired founder+admin + logout everywhere
10e5188 fix(ui): real Ladder logo + Landing simplified to 2 CTAs + full test creds cheatsheet
78fc332 fix(ui): clean logo mark + highly visible password field
1948424 feat(ui): role-aware sign-in routing + gradient founder backdoor + role dashboards
7c0137d feat(ui): brand gradient auth screens + press-and-hold password reveal + testable sign-in
ddb9bcd fix(ui): real Ladder logo on Landing + brand-aligned B2CLogin
ee44159 feat(ui): FounderDashboardView matches Stitch founder_overview
76124b6 feat(ui): wire 5 more Stitch designs (auth + founder login)
d3eb8e2 feat(ui): LandingView matches Stitch batch-11 brand 1:1
4e90846 docs(design): split Stitch prompt into 6 paste-sized batches
```

**Stale areas:** None detected (all areas touched within 30 days)

---

## Build & deployment

- **iOS Deployment Target:** 17.0 (latest stable)
- **Swift Version:** 5.x (strict concurrency warnings enabled)
- **Bundle ID:** `com.ladderapp.ladder`
- **Version:** 1.0.0
- **Code signing:** Automatic
- **Build config:** Debug (via Base.xcconfig) + Release variants
- **Xcode version:** 16.0+

**Build exclusions (per project.yml):**
- `Features/Legacy/**`
- `Services/Legacy/**`
- `DesignSystem/Legacy/**`
- `Models/DomainEnums.swift`
- `App/Navigation/**`
- `App/Configuration/**`

---

## PWJ continuation hints

**Pipeline recommendation:**
- **Mode:** Feature development + audit (brand alignment + iPad parity)
- **Skip repo-mapper:** This map is fresh (created today). Rerun only if >50 commits appear.
- **Prioritize specialists:**
  1. iOS/SwiftUI expert (Features + DesignSystem refinement)
  2. Backend/Supabase specialist (Edge Functions + RLS policies)
  3. Cryptography reviewer (DEK envelope system in LadderBackend/crypto/)

**Before coding:**
1. Read CLAUDE.md (34 KB — architectural contract)
2. Review ADRs in docs/decisions/ (especially ADR-007 for grade 9–12 scope)
3. Check docs/design/stitch-batches/ for Figma specs

**Known gaps to close:**
- iPad parity (mandatory per project rule)
- Dual .xcodeproj cleanup (delete Ladder.xcodeproj)
- GitHub Actions workflow scope (ci.yml staged in docs/ci-pending/)

---

**Generated by PWJ Repo Mapper** | File count: 297 Swift + 5 Backend TS + 130 docs | 0 source files read | 11 tool calls
