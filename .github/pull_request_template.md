# Summary

<!-- 1–3 bullets, why + what. -->

## CLAUDE.md sections touched

<!-- Cite sections, e.g., §4, §8.4, §11.3 -->

## Pre-merge checklist (per §19, §21)

- [ ] Read the existing prototype before changing it
- [ ] Tests cover new/changed behavior (isolation/scheduling/flags/crypto/e2e)
- [ ] Audit events emitted where relevant
- [ ] AI gateway calls are properly scoped + budgeted (§8.4)
- [ ] No direct Gemini calls from iOS
- [ ] No new student-PII field without Lawyer-agent sign-off (§17)
- [ ] Isolation suite green in CI (§4.2 P0)
- [ ] Per-tenant DEK / RLS / role policy unchanged or explicitly versioned
- [ ] Docs updated (README, ADR, compliance note) as appropriate
- [ ] No behavioral ads, 3rd-party analytics on student pages, or data-sale integrations (§16.4)

## Human founder review

- [ ] Diff summary reviewed by Kathan or Jet
