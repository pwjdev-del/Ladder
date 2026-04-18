# Test fixtures

The `LadderFixtures` swift package + `scripts/seed-users.ts` share one seed
universe across iOS tests and backend tests:

- **LWRPA** — school tenant, one admin, one counselor, three students (Alice, Bob, Carol), one teacher.
- **Beta School** — isolated school for cross-tenant tests.
- **Family Smith** — B2C family with one parent + two linked kids.
- **Family Jones** — B2C family used for cross-family isolation tests.

Every test that references a fixture uses the named IDs so isolation tests can
spoof `tenant_id` claims to produce clean cross-tenant attack cases.
