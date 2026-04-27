-- 0008 — Default app_metadata stamp for B2C direct-signup users.
--
-- PROBLEM: The iOS app reads role + tenant_id from JWT app_metadata claims.
-- Without a stamp in raw_app_meta_data, every Release build sign-in throws
-- LadderAuthError.missingRoleClaim for users who did NOT redeem an invite.
--
-- SOLUTION (B2C path): A trigger on auth.users AFTER INSERT writes
--   raw_app_meta_data = { "role": "student", "tenant_id": null }
-- ONLY when raw_app_meta_data is missing a role key.
--
-- The invite-redeem Edge Function (Option A) overwrites this with the correct
-- role + tenant_id after a successful invite redemption — see
-- supabase/functions/invite-redeem/index.ts.
--
-- SECURITY CONTRACT:
-- - This trigger runs as SECURITY DEFINER with a superuser extension context
--   (auth schema). No client can invoke it directly.
-- - The trigger sets only "student" as the default — no privilege escalation
--   path exists here. Role upgrades require invite redemption via Edge Function
--   with service_role key, which is server-only.
-- - This deliberately does NOT set tenant_id to anything other than null for
--   B2C users, consistent with the check constraint in user_profiles:
--       (role = 'founder' AND tenant_id IS NULL)
--       OR (role <> 'founder' AND tenant_id IS NOT NULL)
--   NOTE: B2C students have tenant_id = NULL in app_metadata but MUST have a
--   tenant_id row in user_profiles before any data operations can proceed.
--   The iOS app treats tenant_id=null in the JWT as the "B2C, no school" signal.

-- The trigger function lives in the auth schema and uses the Supabase admin
-- extension function `auth.uid()` / direct auth.users writes. Running it as
-- SECURITY DEFINER with a GRANT limited to the auth schema extension owner
-- ensures no regular role can call it.

create or replace function auth.set_default_app_metadata_role()
returns trigger
language plpgsql
security definer
set search_path = auth, public
as $$
begin
    -- Only stamp if role claim is absent. Preserves invite-set values on
    -- accounts created via OAuth or Magic Link where the metadata was pre-set
    -- by the invite-redeem Edge Function before the auth.users row was fully
    -- committed (race-safe: trigger fires AFTER INSERT so the row exists).
    if (NEW.raw_app_meta_data ->> 'role') is null then
        update auth.users
        set raw_app_meta_data =
            coalesce(NEW.raw_app_meta_data, '{}'::jsonb)
            || jsonb_build_object(
                'role',      'student',
                'tenant_id', null
            )
        where id = NEW.id;
    end if;
    return NEW;
end;
$$;

comment on function auth.set_default_app_metadata_role is
  'Stamps role=student, tenant_id=null into raw_app_meta_data for B2C direct-signup '
  'users who have not redeemed an invite code. Server-only — SECURITY DEFINER. '
  'The invite-redeem Edge Function overwrites this with the correct role+tenant. '
  'See ADR-008 and LadderAuthError.missingRoleClaim in SupabaseAuthService.swift.';

-- Drop and recreate so the migration is idempotent on re-run / CI.
drop trigger if exists on_auth_user_created_set_default_role on auth.users;

create trigger on_auth_user_created_set_default_role
    after insert on auth.users
    for each row
    execute function auth.set_default_app_metadata_role();

-- No RLS change needed — auth.users is not an application table and is
-- managed exclusively by Supabase Auth + service_role writes.
