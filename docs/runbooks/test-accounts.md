# Ladder — test accounts for the LWRPA pilot

**Shared password for every account:** `Ladder!v2-pilot`
(14 chars, passes the 12-char gate, trivial to type.)

> These only work against the local in-memory auth gate used in the
> simulator today. Once `SupabaseAuthService` ships, the same emails +
> password become real Supabase Auth rows via `scripts/seed-users.ts`.

---

## Quick-reference cheatsheet

| Screen on the app | What to tap / type |
|---|---|
| Landing → **Log in with your ID** (B2C) | `parent.smith@ladder.test` · `Ladder!v2-pilot` → Parent dashboard |
| Landing → **Sign in through your school** → LWRPA → Sign in | `admin.lwrpa@ladder.test` · `Ladder!v2-pilot` → Admin dashboard |
| Same as above | `counselor.lwrpa@ladder.test` · `Ladder!v2-pilot` → Counselor dashboard |
| Same as above | `alice.lwrpa@ladder.test` · `Ladder!v2-pilot` → Student dashboard |
| Same screen → **Join with invite code** | `LDR-TEST-0001` · `new@lrpa.edu` → Student dashboard |
| Landing → press-and-hold logo 30 seconds | `FND-0001` · `Ladder!v2-pilot` · TOTP `123456` → Founder backdoor |
| Landing → **New to Ladder? Create an account** | any DOB, 12+ char password, both toggles on → B2C signup submit |
| Landing → **A school representative? Get in touch** | fills the B2B inquiry form. No login — founders review in the backdoor. |

---

## Every B2B school tenant

### LWRPA — Lakewood Ranch Preparatory Academy
Tenant slug: `lwrpa` · id `00000000-0000-0000-0000-000000000001`

| Role | Email | Dashboard you'll land on |
|---|---|---|
| Admin | `admin.lwrpa@ladder.test` | Admin home (banner, KPIs, quick actions, Teacher data / Classes / Scheduling sections) |
| Counselor | `counselor.lwrpa@ladder.test` | Counselor home (queue card, KPIs, quick actions, activity feed) |
| Student · grade 3 · under-13 | `alice.lwrpa@ladder.test` | Student home (checklist, Career quiz next-up, Daily tip) |
| Student · grade 6 | `bob.lwrpa@ladder.test` | Student home |
| Student · grade 8 | `carol.lwrpa@ladder.test` | Student home |

### Beta Test Academy (for cross-tenant isolation tests)
Tenant slug: `beta-school` · id `00000000-0000-0000-0000-000000000002`

| Role | Email |
|---|---|
| Admin | `admin.beta@ladder.test` |
| Counselor | `counselor.beta@ladder.test` |
| Student · grade 5 | `zed.beta@ladder.test` |

---

## Every B2C family tenant

### Smith family
Tenant slug: `family-smith` · id `00000000-0000-0000-0000-000000000010`

| Role | Email | Dashboard |
|---|---|---|
| Parent | `parent.smith@ladder.test` | Parent home with sibling switcher (Maya + Noah) |
| Student Maya · grade 4 · under-13 | `maya.smith@ladder.test` | Student home |
| Student Noah · grade 7 | `noah.smith@ladder.test` | Student home |

### Jones family
Tenant slug: `family-jones` · id `00000000-0000-0000-0000-000000000011`

| Role | Email |
|---|---|
| Parent | `parent.jones@ladder.test` |
| Student Kai · grade 5 | `kai.jones@ladder.test` |

---

## Invite codes (redeem from School login → Join with invite code)

| Code | Kind | Window | Email-domain restriction |
|---|---|---|---|
| `LDR-TEST-0001` | single-use | +30 days | none |
| `LDR-TEST-BULK-A` | bulk (max 20 uses) | +14 days | `@lrpa.edu` only |
| `LDR-TEST-G5` | class-level (grade 5, max 30) | +7 days | none |

Any of those codes paired with any `@*.edu` or `@lakewood.edu` email will redeem successfully in the sim and push a Student dashboard.

Parent-invite code already generated for the Smith family (student → "Add a grown-up"): `LDR-PARENT-SMITH-1`.

---

## Founders (hidden — 30-second logo hold)

| Founder ID | Password | TOTP (dev only) |
|---|---|---|
| `FND-0001` | `Ladder!v2-pilot` | `123456` |
| `FND-0002` | `Ladder!v2-pilot` | `123456` |

After founder login you get the backdoor overview with the **Schools** · **Solo** · **System** tabs and a grid of tappable school cards (LWRPA · Beta · St. Jude · Evergreen). Tap any card to drill into the school detail with aggregates, contracts, audit trail. Every surface refuses student data per §14.4.

In production, TOTP `123456` is replaced by a real platform authenticator; passwords are argon2id-hashed; and the RLS + KMS layers deny founders every tenant-data table regardless of auth.

---

## B2C signup (Landing → "Create an account")

Pick any email + pick any DOB. Requirements:
- Password **12+ characters** (the strength bar turns Strong at 12).
- Toggle **Terms** on.
- Toggle **Privacy** on.
- If the DOB makes the user under 13 the COPPA card appears — signup still succeeds but quiz/grades writes are blocked server-side until a parent co-signs (batch 2 `parental_co_sign_sheet`).

---

## School partner inquiry (Landing → "Get in touch")

Nobody signs up as a school here. This form just records the inquiry; founders review it in the backdoor and provision the tenant from **Schools → + Add a new school**. Fill any fields to submit.

---

## How to load these fixtures in the real backend

```sh
make seed              # runs LadderBackend/supabase/seed.sql + scripts/seed-users.ts
```

`scripts/seed-users.ts` (wired in the next PR) signs every account up via the Supabase Auth admin API with these exact emails + passwords and patches `user_profiles.tenant_id` + `user_profiles.role`. Until then, the sim uses the in-memory accept-list.

## Security reminder

This list lives on a dev branch. The seed script hard-codes a URL allowlist that refuses to run against prod. Any attempt to provision these accounts on prod fails loudly and pages the on-call founder.
