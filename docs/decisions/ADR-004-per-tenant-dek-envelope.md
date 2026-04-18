# ADR-004 — Per-tenant DEK + AWS KMS Envelope Encryption

**Status:** Accepted
**Date:** 2026-04-18

## Decision
Per spec §16.2, every tenant has its own Data Encryption Key (DEK). DEKs are wrapped by a single Customer Master Key (CMK) in AWS KMS named `ladder-tenant-master` in `us-east-1`. Ciphertext DEKs are stored in `tenants.dek_ciphertext`. Plaintext DEKs are cached in Edge Function memory for 5 minutes with an LRU policy, never persisted.

Annual rotation per §16.2: generate DEK_v2, re-encrypt rows in a background job, flip `tenants.active_dek_version`, keep DEK_v1 for 90 days for rollback, then revoke.

## Founder can't load tenant DEK — infrastructure enforcement (§14.4)
- Two IAM principals: `ladder-app` (can `kms:Decrypt` on the CMK), `ladder-founder` (cannot).
- Edge Functions AssumeRole based on the caller's JWT `role` claim. KMS key policy denies `Decrypt` when `aws:PrincipalTag/role = 'founder'`.
- KMS grants are per-call and scoped to `tenant_id`, valid for 5 minutes.
- CloudTrail alarm on any Decrypt where the assumed role is founder (should be zero forever).

## Field classification
| Field | Protection |
|---|---|
| Student name, DOB, guardian contact, grades, quiz answers, profile vector, schedules, AI logs, teacher profiles and reviews | DEK + RLS |
| Invite code hash, feature flags, tenant metadata, audit metadata, billing, token usage counts | RLS only (no DEK needed) |

## Why
§14.4 requires that "per-tenant DEKs are never loaded into founder sessions." Application-layer checks are insufficient; this must be enforced at the IAM + KMS layer so that even if the app is compromised the infrastructure refuses to hand founders plaintext.
