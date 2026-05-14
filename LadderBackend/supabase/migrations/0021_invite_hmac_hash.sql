-- 0021 — Fix B-01: align invite_codes.code_hash to HMAC-SHA256 to match
--         the Edge Function (invite-redeem). Prior migrations 0010, 0013, 0018
--         stored digest(code, 'sha256') (plain SHA-256); the edge function has
--         always computed HMAC-SHA256(code, INVITE_HMAC_SECRET). They never
--         matched, so every invite redemption silently failed ("invite_invalid").
--
--         Fix B-02 companion: adds app.find_invite_by_hash() so the edge function
--         can pass a hex string and let Postgres decode + compare bytea — avoiding
--         the supabase-js Uint8Array → JSON object serialisation bug.
--
-- pgcrypto (hmac function) — already enabled in migration 0001.
--
-- ============================================================================
-- IMPORTANT: deploying this migration INVALIDATES all outstanding un-redeemed
-- invite codes. The stored hash will no longer match any newly-computed
-- HMAC-SHA256, so codes issued before this migration cannot be redeemed.
-- Admins / counselors / students must re-issue invites after deployment.
-- NOTE: this migration invalidates outstanding invites; re-issue required
-- ============================================================================
--
-- Secret configuration (two supported methods — choose one):
--   1. Supabase Edge Function env: set INVITE_HMAC_SECRET in
--      Dashboard → Edge Functions → invite-redeem → Secrets.
--      Then run once (e.g. via a migration hook or admin SQL):
--        ALTER DATABASE postgres SET app.invite_hmac_secret = '<your-secret>';
--   2. Direct ALTER DATABASE (simpler for a single-project deployment):
--        ALTER DATABASE postgres SET app.invite_hmac_secret = '<your-secret>';
--      Both sides must use the SAME secret value.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1. HMAC helper: app.invite_hmac(p_code text) -> bytea
--    Reads the secret from the app.invite_hmac_secret Postgres GUC so the
--    secret is never embedded in SQL source. Requires pgcrypto (loaded 0001).
-- ---------------------------------------------------------------------------
create or replace function app.invite_hmac(p_code text)
returns bytea
language sql
security definer
stable
set search_path = public, app
as $$
    select hmac(
        p_code,
        current_setting('app.invite_hmac_secret'),
        'sha256'
    )
$$;

comment on function app.invite_hmac(text) is
  'HMAC-SHA256(p_code, app.invite_hmac_secret). Used by all invite-code RPCs '
  'and the invite-redeem edge function. Secret must be configured via '
  'ALTER DATABASE postgres SET app.invite_hmac_secret = ''<secret>'' before use.';

-- ---------------------------------------------------------------------------
-- 2. Lookup RPC: public.find_invite_by_hash(p_hex text) -> setof invite_codes
--    Placed in the public schema so supabase-js .rpc('find_invite_by_hash', ...)
--    can call it without a schema override (PostgREST exposes public by default).
--    Accepts the hex-encoded HMAC (no \x prefix), decodes to bytea, and
--    returns the matching invite_codes row (or empty set).
--    Called by invite-redeem edge function to avoid supabase-js Uint8Array →
--    JSON serialisation bug (B-02 fix).
-- ---------------------------------------------------------------------------
create or replace function public.find_invite_by_hash(p_hex text)
returns setof invite_codes
language sql
security definer
stable
set search_path = public, app
as $$
    select *
    from invite_codes
    where code_hash = decode(p_hex, 'hex')
    limit 1
$$;

comment on function public.find_invite_by_hash(text) is
  'Lookup invite_codes by hex-encoded HMAC-SHA256 hash. Used by invite-redeem '
  'edge function. Accepts bare hex (no \\x prefix); returns zero or one row. '
  'In public schema so PostgREST / supabase-js .rpc() can reach it without a '
  'schema override.';

-- Grant to service_role so the edge function (which runs as service_role) can
-- call this RPC. authenticated is NOT granted — callers must go via the edge fn.
grant execute on function app.invite_hmac(text) to service_role;
grant execute on function public.find_invite_by_hash(text) to service_role;

-- ---------------------------------------------------------------------------
-- 3. Invalidate existing un-redeemed rows.
--    We do not have the original plaintext codes, so we cannot re-hash them.
--    Mark all un-redeemed, un-revoked rows as revoked so they fail gracefully
--    with "invite_invalid" rather than silently passing a wrong-hash lookup.
-- ---------------------------------------------------------------------------
update invite_codes
set    revoked_at = now()
where  revoked_at is null
  and  uses < max_uses;

comment on table invite_codes is
  'Migration 0021 revoked all pre-existing un-redeemed codes (hash algorithm '
  'changed from plain SHA-256 to HMAC-SHA256). Re-issue required after deploy.';

-- ---------------------------------------------------------------------------
-- 4. Re-define generate_parent_invite to use app.invite_hmac().
--    Same signature as 0010; re-creating with CREATE OR REPLACE is safe.
-- ---------------------------------------------------------------------------
create or replace function public.generate_parent_invite(
    p_parent_email text,
    p_relationship text default 'parent'
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_code     text;
    v_tenant   uuid;
    v_expires  timestamptz := now() + interval '14 days';
begin
    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    if p_parent_email is null or length(trim(p_parent_email)) = 0 then
        raise exception 'parent_email_required';
    end if;

    -- 12-char code: LDR- + 8 hex chars
    v_code := 'LDR-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id, kind, code_hash, code_prefix,
        created_by, intended_email, expires_at
    ) values (
        v_tenant, 'b2c_parent',
        app.invite_hmac(v_code),   -- HMAC-SHA256; was digest(v_code, 'sha256')
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_parent_email)),
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

grant execute on function public.generate_parent_invite(text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- 5. Re-define generate_student_invite to use app.invite_hmac().
--    Same signature as 0013.
-- ---------------------------------------------------------------------------
create or replace function public.generate_student_invite(
    p_email text,
    p_grade int default null
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_code     text;
    v_tenant   uuid;
    v_role     text;
    v_expires  timestamptz := now() + interval '30 days';
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    v_role   := current_setting('app.role', true);
    if v_tenant is null then raise exception 'tenant_required'; end if;
    if v_role not in ('admin', 'counselor') then raise exception 'forbidden'; end if;
    if p_email is null or length(trim(p_email)) = 0 then
        raise exception 'email_required';
    end if;

    v_code := 'LDR-' || upper(substr(encode(gen_random_bytes(6), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id, kind, code_hash, code_prefix,
        created_by, intended_email, expected_grade_level, expires_at
    ) values (
        v_tenant, 'b2b_student_single',
        app.invite_hmac(v_code),   -- HMAC-SHA256; was digest(v_code, 'sha256')
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_email)),
        p_grade,
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

grant execute on function public.generate_student_invite(text, int) to authenticated;

-- ---------------------------------------------------------------------------
-- 6. Re-define counselor_issue_invite to use app.invite_hmac().
--    Same signature as 0018. Enum value b2c_counselor already exists (0018).
-- ---------------------------------------------------------------------------
create or replace function public.counselor_issue_invite(
    p_intended_email text default null
)
returns table(code text, expires_at timestamptz)
language plpgsql
security definer
set search_path = public, app
as $$
declare
    v_code    text;
    v_tenant  uuid;
    v_role    text;
    v_expires timestamptz := now() + interval '14 days';
begin
    perform app.bind_session();

    v_tenant := nullif(current_setting('app.tenant_id', true), '')::uuid;
    v_role   := current_setting('app.role', true);

    if v_tenant is null then
        raise exception 'tenant_required';
    end if;

    if v_role not in ('counselor', 'admin') then
        raise exception 'forbidden';
    end if;

    v_code := 'CSL-' || upper(substr(encode(gen_random_bytes(4), 'hex'), 1, 8));

    insert into invite_codes(
        tenant_id,
        kind,
        code_hash,
        code_prefix,
        created_by,
        intended_email,
        expires_at
    ) values (
        v_tenant,
        'b2c_counselor',
        app.invite_hmac(v_code),   -- HMAC-SHA256; was digest(v_code, 'sha256')
        substr(v_code, 1, 4),
        auth.uid(),
        lower(trim(p_intended_email)),
        v_expires
    );

    return query select v_code, v_expires;
end;
$$;

grant execute on function public.counselor_issue_invite(text) to authenticated;

-- ---------------------------------------------------------------------------
-- 7. Index on code_hash for fast lookup (unique constraint in 0004 already
--    creates a unique index; this adds a non-unique fallback for partial scans
--    on un-redeemed rows if the planner prefers it).
-- ---------------------------------------------------------------------------
create index if not exists idx_invite_codes_code_hash
    on invite_codes(code_hash);
