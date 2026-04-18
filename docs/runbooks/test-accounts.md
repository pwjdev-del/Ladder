# Ladder — test accounts for the LWRPA pilot

Seeded fixtures for every role. Use these for manual QA on the simulator, against a local `supabase start` instance, or against a shared dev deployment. **Never use these in production** — the passwords are intentionally guessable, and the fixture data is seeded from `LadderBackend/supabase/seed.sql`.

Passwords are all the same for convenience: `Ladder!v2-pilot`. Long enough to pass the 12-char gate, trivial to type.

## LWRPA (B2B school tenant)

Tenant slug: `lwrpa` · Tenant ID: `00000000-0000-0000-0000-000000000001`

| Role | Email | Password | Notes |
|---|---|---|---|
| Seed admin | `admin.lwrpa@ladder.test` | `Ladder!v2-pilot` | Mandatory-metrics banner fires 3 months after first login. |
| Counselor | `counselor.lwrpa@ladder.test` | `Ladder!v2-pilot` | Owns the student queue + invite codes. |
| Student — Alice (grade 3) | `alice.lwrpa@ladder.test` | `Ladder!v2-pilot` | Under-13 — requires parent co-sign before quiz / grades. |
| Student — Bob (grade 6) | `bob.lwrpa@ladder.test` | `Ladder!v2-pilot` | Eligible for 6–8 quiz band without co-sign. |
| Student — Carol (grade 8) | `carol.lwrpa@ladder.test` | `Ladder!v2-pilot` | Has quiz + grades populated for class-suggester demo. |

Invite codes for testing redemption:

| Code (plaintext) | Kind | Expires | Intended email | Status |
|---|---|---|---|---|
| `LDR-TEST-0001` | single | +30d | `new-student@lrpa.edu` | unredeemed |
| `LDR-TEST-BULK-A` | bulk (max 20 uses) | +14d | any `@lrpa.edu` | 3 used |
| `LDR-TEST-G5` | class-level (grade 5, max 30) | +7d | any | unused |

## Beta Test School (second B2B tenant — for cross-tenant isolation tests)

Tenant slug: `beta-school` · Tenant ID: `00000000-0000-0000-0000-000000000002`

| Role | Email | Password |
|---|---|---|
| Admin | `admin.beta@ladder.test` | `Ladder!v2-pilot` |
| Counselor | `counselor.beta@ladder.test` | `Ladder!v2-pilot` |
| Student — Zed | `zed.beta@ladder.test` | `Ladder!v2-pilot` |

## Family Smith (B2C tenant)

Tenant slug: `family-smith` · Tenant ID: `00000000-0000-0000-0000-000000000010`

| Role | Email | Password | Notes |
|---|---|---|---|
| Parent | `parent.smith@ladder.test` | `Ladder!v2-pilot` | Linked to Maya + Noah. |
| Student — Maya (grade 4) | `maya.smith@ladder.test` | `Ladder!v2-pilot` | Under-13 — parent must co-sign first. |
| Student — Noah (grade 7) | `noah.smith@ladder.test` | `Ladder!v2-pilot` | |

Parent-invite code (generated at Maya's signup, shown once):
- `LDR-PARENT-SMITH-1` — tied to `parent.smith@ladder.test`.

## Family Jones (B2C tenant — for family-isolation tests)

Tenant slug: `family-jones` · Tenant ID: `00000000-0000-0000-0000-000000000011`

| Role | Email | Password |
|---|---|---|
| Parent | `parent.jones@ladder.test` | `Ladder!v2-pilot` |
| Student — Kai | `kai.jones@ladder.test` | `Ladder!v2-pilot` |

## Founders (no tenant)

Founders are not tenant-scoped. They reach login via the 30-second press-and-hold on the Landing logo.

| Role | Founder ID | Password | TOTP | Notes |
|---|---|---|---|---|
| Founder — Kathan | `FND-0001` | `Ladder!v2-pilot` | `123456` (dev only) | Active account. TOTP is fixed in dev; rotates to a real authenticator in prod. |
| Founder — Jet | `FND-0002` | `Ladder!v2-pilot` | `123456` | Active account. |

**Production passkey:** founders use platform authenticators in production. The dev TOTP `123456` is a backdoor ONLY for local Supabase. Per `ADR-004`, founders are denied every tenant-data table at the RLS + IAM + UI layer regardless of how they signed in.

## How to load these fixtures

```sh
make seed              # runs LadderBackend/supabase/seed.sql + scripts/seed-users.ts
```

`scripts/seed-users.ts` (TODO — tracked in the next PR) signs every test account up via the Supabase Auth admin API with these exact emails + passwords, then patches `user_profiles.tenant_id` + `user_profiles.role` to match the table above.

Until the seed script lands, create accounts manually in the Supabase dashboard Auth → Users pane, then run `LadderBackend/supabase/seed.sql` to populate the tenant rows + profile bindings.

## What each account lets you test

- **Founder login → dashboard** — press and hold the Landing logo for 30 seconds, then use `FND-0001` + `Ladder!v2-pilot` + `123456`.
- **B2B invite redemption flow** — landing → "Sign in through your school" → pick LWRPA → "First time? Join with invite code" → paste `LDR-TEST-0001` → email `new-student@lrpa.edu`.
- **COPPA gate** — sign up as `alice.lwrpa@ladder.test` (grade 3). The app should block her from quiz + grades until the parent co-signs.
- **Parent sibling switcher** — sign in as `parent.smith@ladder.test`; Maya + Noah should appear in the switcher at the top.
- **Counselor approval queue** — sign in as `counselor.lwrpa@ladder.test`; Carol's submitted schedule should be at the top of the queue.
- **Admin mandatory metrics popup** — sign in as `admin.lwrpa@ladder.test`; the amber banner should prompt an update.
- **Cross-tenant isolation check (dev only)** — sign in as `admin.lwrpa@ladder.test`, then manually craft a request targeting `beta-school`; the API must return 403 / empty rows. `tests/isolation/` automates this.

## Security reminder

These credentials are in the repo on a dev branch. The seed script MUST refuse to run against a production database (hard-coded URL allowlist). Any attempt to provision these accounts on prod should fail loudly and page the on-call founder.
