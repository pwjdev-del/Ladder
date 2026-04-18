# ADR-000 — Ship the Full CLAUDE.md Spec (Founder Override of CEO Scope Cuts)

**Status:** Accepted
**Date:** 2026-04-18
**Deciders:** Kathan Patel (Director of Technical Foundations), Jet (Director of Marketing and Sales)
**Context window:** CEO pipeline run on branch `feat/ladder-v2-spec-upgrade`

## Context

The gstack CEO pipeline (Phases 1–5) ran against the new 605-line `CLAUDE.md` and unanimously recommended deep scope cuts for an 8-week LWRPA pilot: defer scheduling, extracurriculars, parent-invite, B2C signup, teacher data, per-tenant DEK rotation, WebAuthn, cert pinning; and kill founder backdoor, Varun, Lawyer AI, 30s logo hold, sector-adaptive quiz, deep-research pipeline, teacher reviews, AI upload parsers.

Founders have explicitly overruled the scope-cut recommendation. Full spec ships.

## Decision

Build and ship the full `CLAUDE.md` spec simultaneously:

- Scheduling engine (deterministic core + AI suggester + approval state machine) — §11
- Extracurricular engine (iterative AI session) — §10
- Parent-invite flow — §6.2
- B2C signup flow — §6, §3.3
- Teacher profiles / schedules / assignments / reviews — §12, §13
- Founder backdoor with 30s logo hold + MFA + Schools grid + Solo People + Feature Flags + Varun — §14, §15
- Lawyer AI watchdog — §17
- Per-tenant DEK + KMS envelope encryption + rotation — §16.2
- Certificate pinning, jailbreak detection, screenshot blocking — §16.3
- WebAuthn/passkey MFA — §16.1
- Sector-adaptive career quiz + Gemini scoring + career profile vector — §8.3
- Deep-research class suggester — §9
- AI parsers for CSV/XLSX/PDF/pasted text class-list upload — §12
- All tenant isolation, RLS, audit, Varun tests — §4.2, §18

## User model

Primary users: **students, counselors, school administration**. Parents are secondary viewers via the invite flow (§6.2), NOT reframed as primary. Office-hours / CEO recommendation to make parents primary is rejected.

## Consequences

- Scope is multiples of the 8-week window implied by the pilot. Founders accept the risk.
- CI must be green across isolation/scheduling/flags/crypto/e2e before ship. No shortcuts.
- Spec hard-stops (§20) remain in force. No weakening of tenant isolation, no founder data access, no teachers-as-users, no grades-for-non-student, no Lawyer AI bypass on student-data PRs.

## Supersedes

None — this is the first ADR.

## Related artifacts

- Full CEO pipeline planning outputs archived at `docs/planning/` on this branch.
- Engineering architecture plan (Supabase-native, AWS KMS, deterministic scheduling core, 10-milestone build order) is adopted as-is from Phase 3.
- Design fixes (Dynamic Type, K-8 variant, missing components) adopted from Phase 4.
- DevEx fixes (Makefile, CI, secrets flow, ADR culture) adopted from Phase 5.
