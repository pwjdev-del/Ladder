# ADR-002 — Repo Layout Follows CLAUDE.md §18

**Status:** Accepted
**Date:** 2026-04-18

## Decision
Repo layout migrates to the structure in `CLAUDE.md` §18:

```
/
├── CLAUDE.md
├── Ladder.xcworkspace
├── LadderApp/                  ← iOS app target
│   ├── App/
│   ├── Features/
│   │   ├── Landing/ Auth/ Student/ Parent/ Counselor/ Admin/ Founder/
│   ├── Services/
│   │   ├── Auth/ Tenant/ Crypto/ AI/ Flags/ Audit/ Networking/
│   ├── Models/
│   └── Resources/
├── LadderBackend/               ← Supabase project
│   ├── api/ domain/ ai-gateway/ crypto/ db/ audit/ varun/
├── tests/
│   ├── isolation/ scheduling/ flags/ crypto/ e2e/
└── docs/
    ├── decisions/ research/ runbooks/ compliance/
```

Existing `Ladder/Core/*` and `Ladder/Features/*` contents are moved into `LadderApp/Services/*` and `LadderApp/Features/*` respectively. College-app surfaces that do not map to the new spec (`CollegeIntelligence/`, `CollegeMatchCalculator`, `StateRequirementsEngine`, `DeadlineCalculator`) are retained under `LadderApp/Features/Legacy/` pending triage in ADR-006.

## Why
- Every phase of the CEO pipeline flagged structure drift as a blocker — Claude re-corrects the layout every session otherwise.
- Spec §18 is the single source of truth. Either the code matches or the spec is updated; we chose to match the code to the spec.

## Consequences
- One large mechanical migration commit. XcodeGen `project.yml` updated to reflect new paths.
- `tests/` moves from untracked to a committed directory with populated subdirs.
