# ADR-001 — Supabase-native Backend

**Status:** Accepted
**Date:** 2026-04-18

## Decision
Backend is Supabase-native: Postgres with RLS, Supabase Auth, Supabase Storage, Supabase Edge Functions (Deno/TypeScript) for the AI gateway, Varun validator, and audit service. AWS KMS provides the master key for per-tenant DEK envelope encryption (not Supabase Vault) for provider independence and CloudTrail logging on every Decrypt.

## Why
1. RLS enforcement of `current_setting('app.tenant_id')` (§4.2) is native to Postgres; Supabase exposes it via `auth.jwt()` claims.
2. Auth, Postgres, Storage, Realtime, Edge Functions in one vendor = fastest path for solo dev + AI partner in the available window.
3. Supabase Pro fits one K-8 tenant at the pilot scale.
4. Swift-on-server (Vapor) and Node-on-Fly both introduce a second deploy surface without a corresponding feature gain.

## Consequences
- Supabase lock-in accepted. Mitigated by: business logic in plain Postgres functions + TS Edge Functions we own; Supabase Auth JWTs are portable; KMS in AWS, not Supabase Vault.
- iOS client uses `supabase-swift` SDK for auth + REST; all AI calls are routed through `supabase/functions/ai-gateway` Edge Function.
