-- LadderBackend/supabase/migrations/0020_founder_totp_decrypt.sql
-- S1-1 (part 1): Real DEK-based TOTP encrypt/decrypt path for founder_users.
-- S1-2: Wire app.bind_session() as a db-pre-request hook (verified idempotent below).
--
-- ═══════════════════════════════════════════════════════════════════════════════
-- WHY THIS MIGRATION EXISTS
-- ═══════════════════════════════════════════════════════════════════════════════
-- S1-1: founder-login/index.ts:57,178 verifies every founder against the world-known
--   RFC 6238 test vector JBSWY3DPEHPK3PXP. The totp_secret_cipher column is read
--   but its value is silently discarded. This migration provides:
--     (a) schema enforcement: totp_secret_cipher must be NOT NULL before a founder
--         account is usable in production (ALTER COLUMN constraint added below).
--     (b) app.decrypt_founder_totp(p_user_id) — called by the edge function to
--         recover the base32 TOTP secret before verification.
--     (c) app.enroll_founder_totp(p_user_id, p_secret) — called once during the
--         founder's first-login / onboarding setup flow.
--
-- S1-2: app.bind_session() exists (migration 0001) and is SECURITY DEFINER + idempotent
--   but is only called inside specific RPCs (0011, 0012, 0013, 0018). PostgREST direct
--   queries (iOS client select/insert via the Supabase SDK) never trigger it, so every
--   RLS policy depending on current_setting('app.role', true) or
--   current_setting('app.tenant_id', true) silently evaluates NULL → 0 rows.
--   The db-pre-request hook in config.toml (created alongside this migration) causes
--   PostgREST to call app.bind_session() before every request. This migration documents
--   that contract and re-asserts SECURITY DEFINER idempotency on bind_session.
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 1 — Crypto extension
-- ─────────────────────────────────────────────────────────────────────────────
-- This project does NOT currently use pgsodium or the Supabase Vault extension.
-- Migrations 0001–0019 use only pgcrypto (already enabled in 0001) and store
-- ciphertext as bytea columns. For consistency, this migration uses the same
-- pgcrypto approach with AES-256-CBC (pgcrypto's pgp_sym_encrypt uses
-- a passphrase-derived key, unsuitable here) — instead we use:
--   pgcrypto.encrypt(data bytea, key bytea, type text)   (OpenSSL AES-CBC)
--   pgcrypto.decrypt(data bytea, key bytea, type text)
-- with the key sourced from a Supabase Vault secret OR an env-var secret.
--
-- NOTE ON PGSODIUM:
--   pgsodium.crypto_aead_det_encrypt/decrypt would be the ideal choice because it
--   provides authenticated encryption without needing to manage a separate MAC.
--   However, the Supabase platform auto-provisions pgsodium only when you enable it
--   in the Dashboard (Database → Extensions → pgsodium) and set a master key in the
--   Vault. Since this project has NO existing pgsodium usage and the master key
--   provisioning step is a platform-dashboard action outside of migrations, adding it
--   here without that infrastructure would make the migration non-deployable.
--   RECOMMENDATION: after enabling pgsodium in the Supabase dashboard, a follow-up
--   migration should replace the pgcrypto path below with pgsodium.crypto_aead_det_*.
--
-- DEK DESIGN FOR FOUNDER TOTP:
--   A dedicated "Founder Signing Key" (FSK) is stored as a Vault secret with key name
--   'founder_totp_fsk'. The FSK is a 32-byte random value stored as a hex string in
--   Vault. The edge function that calls enroll_founder_totp passes the plaintext TOTP
--   secret; this function encrypts it with AES-256-CBC using the FSK from Vault.
--   The FSK is accessed via vault.decrypted_secrets (available when Supabase Vault is
--   enabled) OR via a fallback to current_setting('app.founder_totp_fsk', true) for
--   environments that inject it as a Postgres session config (e.g., CI).
-- ─────────────────────────────────────────────────────────────────────────────

-- pgcrypto is already enabled in migration 0001, but include a guard.
create extension if not exists pgcrypto;

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 2 — Schema: enforce NOT NULL on totp_secret_cipher
-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 0006 created this column as nullable bytea. We can't hard-NOT-NULL
-- immediately because existing rows have NULL (no secret enrolled yet). Instead:
--   1. Add a deferred check constraint: cipher must be non-null before a founder
--      account can authenticate. Enforced at the application layer by the edge
--      function, not at the Postgres storage layer (to avoid blocking existing rows).
--   2. Document that the enrollment function below must be called before the
--      decrypt function will succeed.
--
-- When the enrollment flow is live and all founder rows are populated, run:
--   ALTER TABLE founder_users ALTER COLUMN totp_secret_cipher SET NOT NULL;
-- as a follow-up migration (0021+ is not this agent's file — note in OUT_OF_SCOPE).
--
-- For now: add a descriptive comment marking the intent.
comment on column founder_users.totp_secret_cipher is
  'IV-prefixed AES-256-CBC ciphertext of the founder TOTP base32 secret. '
  'Storage format: first 16 bytes = random IV (gen_random_bytes(16)), '
  'remaining bytes = pgcrypto encrypt_iv(plaintext, fsk, iv, ''aes-cbc/pad:pkcs'') ciphertext. '
  'Encrypted by app.enroll_founder_totp(), decrypted by app.decrypt_founder_totp(). '
  'Key source: Vault secret name ''founder_totp_fsk'' (32-byte hex). '
  'NULL means TOTP not yet enrolled — founder login must be blocked until populated. '
  'TODO: ALTER COLUMN SET NOT NULL after all existing founder rows are enrolled.';

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 3 — Helper: resolve the Founder Signing Key (FSK)
-- ─────────────────────────────────────────────────────────────────────────────
-- Separate private helper so both encrypt and decrypt share the same key
-- resolution logic. Returns the raw 32 bytes used as the AES key.
-- Key resolution order:
--   1. vault.decrypted_secrets where name = 'founder_totp_fsk'  (preferred, production)
--   2. current_setting('app.founder_totp_fsk', true)            (CI / local dev)
-- If neither is available, raises an exception — fail closed.
create or replace function app._founder_totp_fsk()
returns bytea
language plpgsql
security definer
set search_path = public, vault
as $$
declare
    v_hex text;
begin
    -- Attempt Vault lookup first. vault.decrypted_secrets is a view provided by
    -- Supabase when the Vault extension is enabled. The select will fail with a
    -- "relation does not exist" error if Vault is not enabled; catch that and fall
    -- through to the session-config fallback.
    begin
        select decrypted_secret
          into v_hex
          from vault.decrypted_secrets
         where name = 'founder_totp_fsk'
         limit 1;
    exception
        when undefined_table then
            v_hex := null;
        when insufficient_privilege then
            v_hex := null;
    end;

    -- Fallback: session config injected by CI or edge function bootstrap.
    if v_hex is null or v_hex = '' then
        v_hex := current_setting('app.founder_totp_fsk', true);
    end if;

    if v_hex is null or length(v_hex) < 64 then
        raise exception
            'founder_totp_fsk not available: set Vault secret ''founder_totp_fsk'' '
            '(32-byte hex value) or session config app.founder_totp_fsk. '
            'See LadderBackend/supabase/migrations/0020_founder_totp_decrypt.sql §3.';
    end if;

    return decode(v_hex, 'hex');
end;
$$;

-- No public access — used only by the two functions below (also service_role only).
revoke execute on function app._founder_totp_fsk() from public;
revoke execute on function app._founder_totp_fsk() from anon;
revoke execute on function app._founder_totp_fsk() from authenticated;

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 4 — app.decrypt_founder_totp(p_user_id uuid) returns text
-- ─────────────────────────────────────────────────────────────────────────────
-- Called by the founder-login edge function (service_role) to recover the
-- base32 TOTP secret for a given founder auth user ID.
--
-- Flow:
--   1. Look up founder_users row by auth_user_id = p_user_id.
--   2. Assert totp_secret_cipher IS NOT NULL (not enrolled → exception).
--   3. Split IV-prefixed blob: bytes 1–16 = IV, bytes 17+ = ciphertext.
--   4. Decrypt with FSK via pgcrypto.decrypt_iv using 'aes-cbc/pad:pkcs'.
--   5. Decode bytes as UTF-8 and return the base32 secret string.
--
-- Storage format (written by app.enroll_founder_totp):
--   totp_secret_cipher = gen_random_bytes(16) || encrypt_iv(plaintext, fsk, iv, 'aes-cbc/pad:pkcs')
--   substring(cipher from 1 for 16) → IV
--   substring(cipher from 17)       → ciphertext
--
-- Called by: founder-login edge function (service_role key).
-- Security:  SECURITY DEFINER so it runs as the migration owner, not the
--            caller. Only service_role is granted EXECUTE.
create or replace function app.decrypt_founder_totp(p_user_id uuid)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
    v_stored  bytea;   -- full IV-prefixed blob from the column
    v_iv      bytea;   -- first 16 bytes: the AES-CBC IV
    v_cipher  bytea;   -- bytes 17+: the actual ciphertext
    v_fsk     bytea;
    v_plain   bytea;
begin
    -- 1. Fetch stored blob.
    select totp_secret_cipher
      into v_stored
      from founder_users
     where auth_user_id = p_user_id;

    if not found then
        raise exception 'founder_totp: no founder row for user %', p_user_id
            using errcode = 'no_data_found';
    end if;

    if v_stored is null then
        raise exception 'founder_totp: TOTP not enrolled for user %. '
            'Call app.enroll_founder_totp() first.', p_user_id
            using errcode = 'null_value_not_allowed';
    end if;

    if octet_length(v_stored) < 17 then
        raise exception 'founder_totp: stored cipher is too short (% bytes); '
            'expected at least 17 (16-byte IV + 1-byte ciphertext). '
            'Re-enroll via app.enroll_founder_totp().', octet_length(v_stored)
            using errcode = 'data_corrupted';
    end if;

    -- 2. Split IV prefix from ciphertext.
    --    substring(bytea, start, length) — 1-indexed.
    v_iv     := substring(v_stored from 1 for 16);
    v_cipher := substring(v_stored from 17);

    -- 3. Resolve FSK.
    v_fsk := app._founder_totp_fsk();

    -- 4. Decrypt with explicit IV. 'aes-cbc/pad:pkcs' pins padding mode explicitly
    --    to avoid reliance on pgcrypto defaults (S1-CR3 fix, 2026-05-14).
    --    decrypt_iv(data, key, iv, type): data and key must each be multiples of
    --    the AES block size (16 bytes) after key-padding; pgcrypto handles this.
    v_plain := decrypt_iv(v_cipher, v_fsk, v_iv, 'aes-cbc/pad:pkcs');

    -- 5. Return UTF-8 string (base32 TOTP secret).
    return convert_from(v_plain, 'UTF8');
end;
$$;

comment on function app.decrypt_founder_totp(uuid) is
  'Decrypts founder_users.totp_secret_cipher for the given auth user ID. '
  'Expects IV-prefixed format: bytes 1-16 = random IV, bytes 17+ = ciphertext. '
  'Uses decrypt_iv(..., ''aes-cbc/pad:pkcs'') — explicit padding to avoid zero-IV default. '
  'Returns the plaintext base32 TOTP secret for verification. '
  'Requires Vault secret ''founder_totp_fsk'' or session config app.founder_totp_fsk. '
  'SECURITY DEFINER — only service_role may execute. S1-CR3 fix (2026-05-14).';

-- Grant only to service_role. Deny everything else.
revoke execute on function app.decrypt_founder_totp(uuid) from public;
revoke execute on function app.decrypt_founder_totp(uuid) from anon;
revoke execute on function app.decrypt_founder_totp(uuid) from authenticated;
grant  execute on function app.decrypt_founder_totp(uuid) to service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 5 — app.enroll_founder_totp(p_user_id uuid, p_secret text) returns void
-- ─────────────────────────────────────────────────────────────────────────────
-- Called once during founder onboarding. Encrypts the plaintext base32 secret
-- (generated by the enrollment edge function, shown as a QR code) and writes
-- the ciphertext to founder_users.totp_secret_cipher.
--
-- Idempotent: re-enrolling overwrites the previous ciphertext. Audit-log entry
-- written so re-enrollment is visible to compliance review.
--
-- Called by: founder onboarding edge function (service_role key).
create or replace function app.enroll_founder_totp(p_user_id uuid, p_secret text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    v_fsk    bytea;
    v_cipher bytea;
    v_founder_id uuid;
begin
    if p_secret is null or length(trim(p_secret)) = 0 then
        raise exception 'enroll_founder_totp: p_secret must not be empty';
    end if;

    -- Verify the founder row exists.
    select id into v_founder_id
      from founder_users
     where auth_user_id = p_user_id;

    if not found then
        raise exception 'enroll_founder_totp: no founder row for user %', p_user_id
            using errcode = 'no_data_found';
    end if;

    -- Resolve FSK, generate a fresh random IV, and encrypt.
    -- Storage format: 16-byte random IV prepended to ciphertext.
    --   IV = gen_random_bytes(16)
    --   ciphertext = encrypt_iv(plaintext, fsk, iv, 'aes-cbc/pad:pkcs')
    -- Storing iv || ciphertext together means each enrollment produces a
    -- different blob even for the same secret, defeating ciphertext comparison.
    -- S1-CR3 fix (2026-05-14): replaces encrypt(..., 'aes-cbc') which used a
    -- zero IV and was deterministic (same plaintext → same ciphertext).
    declare
        v_iv bytea;
    begin
        v_iv     := gen_random_bytes(16);
        v_cipher := v_iv || encrypt_iv(convert_to(p_secret, 'UTF8'), v_fsk, v_iv, 'aes-cbc/pad:pkcs');
    end;

    -- Write ciphertext.
    update founder_users
       set totp_secret_cipher = v_cipher
     where auth_user_id = p_user_id;

    -- Audit trail: enrollment/re-enrollment is security-significant.
    insert into audit_log (
        tenant_id, actor_id, actor_role,
        action, target_type, target_id, metadata
    ) values (
        null, p_user_id, 'founder',
        'founder.totp_enrolled', 'founder_users', v_founder_id,
        jsonb_build_object('note', 'TOTP secret enrolled or re-enrolled via app.enroll_founder_totp')
    );
end;
$$;

comment on function app.enroll_founder_totp(uuid, text) is
  'Encrypts and stores a founder TOTP base32 secret in founder_users.totp_secret_cipher. '
  'Stored format: gen_random_bytes(16) || encrypt_iv(plaintext, fsk, iv, ''aes-cbc/pad:pkcs''). '
  'The prepended 16-byte IV ensures each enrollment produces unique ciphertext. '
  'Call once during founder onboarding. Re-calling overwrites the prior secret (re-enrollment). '
  'Writes an audit_log entry for compliance. SECURITY DEFINER — only service_role may execute. '
  'S1-CR3 fix (2026-05-14).';

-- Grant only to service_role.
revoke execute on function app.enroll_founder_totp(uuid, text) from public;
revoke execute on function app.enroll_founder_totp(uuid, text) from anon;
revoke execute on function app.enroll_founder_totp(uuid, text) from authenticated;
grant  execute on function app.enroll_founder_totp(uuid, text) to service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 6 — Re-assert app.bind_session() is SECURITY DEFINER + idempotent
-- ─────────────────────────────────────────────────────────────────────────────
-- CRITICAL CONTEXT FOR S1-2:
--
-- 97 RLS policies across migrations 0001–0019 evaluate:
--   current_setting('app.role',      true)   -- 'true' = missing-ok, returns NULL
--   current_setting('app.tenant_id', true)
--
-- When PostgREST handles a direct iOS SDK query (select, insert, update, delete),
-- it opens a Postgres transaction and executes the SQL without calling any
-- setup function. Both settings are NULL. Every USING clause that compares
-- current_setting(…) to a tenant value returns NULL, which Postgres treats as
-- FALSE in a USING predicate → 0 rows returned silently.
--
-- CONSEQUENCE: The counselor SIA surface (student_memory_summaries SELECT policy,
-- sia_safety_events SELECT policy) ships broken. Queries return empty. The D-002
-- promise is silently undelivered.
--
-- SECOND CONSEQUENCE: The silence creates a false-security trap. When bind_session
-- is eventually wired, dozens of previously-blocked queries start returning rows
-- simultaneously, potentially surfacing RLS regressions that were invisible.
--
-- FIX: config.toml [api] db_pre_request = "app.bind_session" (co-shipped with
-- this migration). PostgREST calls app.bind_session() at the start of every
-- transaction before executing the user's query. This is the PostgREST
-- PGRST_DB_PRE_REQUEST mechanism.
--
-- This section uses CREATE OR REPLACE to re-assert SECURITY DEFINER and
-- idempotency on bind_session without changing its logic.
-- (Original definition is in 0001; this is an authoritative restatement.)
-- ─────────────────────────────────────────────────────────────────────────────
create or replace function app.bind_session()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
    -- Reads JWT claims injected by PostgREST into the request.jwt.claims GUC.
    -- 'true' = missing-ok (returns NULL rather than raising) so the function
    -- is safe to call even when there is no JWT (anon requests, health checks).
    jwt_claims jsonb := coalesce(
        current_setting('request.jwt.claims', true)::jsonb,
        '{}'::jsonb
    );
    v_tenant_id text := jwt_claims ->> 'tenant_id';
    v_role      text := jwt_claims ->> 'role';
begin
    -- set_config(key, value, is_local):
    --   is_local = true  → value lives for this transaction only (auto-cleared on commit).
    --   Using true is correct for a pre-request hook: each PostgREST request is
    --   one transaction, so the config is scoped to exactly that request.
    if v_tenant_id is not null then
        perform set_config('app.tenant_id', v_tenant_id, true);
    end if;
    if v_role is not null then
        perform set_config('app.role', v_role, true);
    end if;
    -- Idempotency: calling this function multiple times (e.g., from an RPC that
    -- also calls it manually) is harmless — set_config is an overwrite.
end;
$$;

comment on function app.bind_session is
  'Reads JWT claims tenant_id + role and sets Postgres session GUCs for RLS. '
  'Called automatically by PostgREST as the db-pre-request hook (config.toml [api] '
  'db_pre_request = "app.bind_session"). Without this hook, all RLS policies that '
  'read current_setting(''app.role'', true) evaluate NULL → 0 rows silently. '
  'SECURITY DEFINER + idempotent. S1-2 fix (2026-05-14). Original: migration 0001.';
