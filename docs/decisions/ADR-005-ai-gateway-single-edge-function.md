# ADR-005 — AI Gateway as a Single Supabase Edge Function

**Status:** Accepted
**Date:** 2026-04-18

## Decision
All Gemini calls go through a single Supabase Edge Function at `LadderBackend/ai-gateway/index.ts`. The iOS client NEVER calls Gemini directly. Direct-from-device Gemini calls are banned by lint rule and code review.

## Request flow
1. iOS sends request with Supabase Auth JWT.
2. Edge Function runs `app.bind_session(jwt)` — sets `app.tenant_id` and `app.role` for RLS.
3. Loads scoped context via RLS-filtered `SELECT`s only.
4. Decrypts PII with per-tenant DEK in memory.
5. Redacts non-essential PII from the prompt.
6. Checks per-tenant token budget (`ai_usage_ledger`).
7. Checks rate limit (token bucket, per-tenant + per-user).
8. Calls Gemini with server-side API key.
9. Scans response for cross-tenant leakage via regex.
10. Increments `ai_usage_ledger` (tenant_id, feature, in+out tokens, cost_usd).
11. Appends to `audit_log` (who, when, feature, token count; NO payload).
12. Returns redacted response.

## Career profile vector (§8.3)
Stored in `student_career_profiles(student_id, tenant_id, vector_ciphertext, scored_at)`. Encrypted with tenant DEK. Postgres `bytea` (with `pgvector` enabled for future ANN). No shared vector DB — cross-tenant contamination risk.

## Why
§8.4 is explicit: "All Gemini calls go through a Ladder-owned AI gateway service." A single Edge Function is the minimum-complexity implementation that satisfies session auth, tenant scoping, prompt construction from verified data, PII strip, token budget, logging, and response redaction in one place.
