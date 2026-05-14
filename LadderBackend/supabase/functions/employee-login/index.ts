// LadderBackend/supabase/functions/employee-login/index.ts
// Auth flow: password → TOTP decrypt → verify → app_metadata.role assignment. Rate-limited per S2-1.
//
// Mirrors founder-login but targets the AppRole.employee path.
// The iOS client (EmployeeLoginView) calls this after signInWithPassword, passing the resulting JWT
// and the TOTP code from the employee's authenticator app.  On success, app_metadata.role is
// stamped as 'employee' server-side (moved from client-side EmployeeLoginView per S2-2 fix).
//
// Call contract:
//   POST /functions/v1/employee-login
//   Authorization: Bearer <jwt>       (JWT from a prior signInWithPassword)
//   Content-Type: application/json
//   Body: { "totpCode": "123456" }
//
// On success  → 200  { ok: true, role: "employee" }
// Soft fail   → 401  { ok: false, error: "invalid_credentials" } (uniform — see S2-NEW-3)
// Hard lock   → 429  { ok: false, error: "too_many_attempts" } (after 5 fails in 15min)
// Locked out  → 429  { ok: false, error: "too_many_attempts" }
// Server err  → 500  { ok: false, error: "internal_error" }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';
import { authenticator } from 'npm:otplib@12.0.1';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// otplib options — must match enrollment settings.
authenticator.options = {
  digits: 6,
  step: 30,
  window: 1,
};

// Rate-limit constants (S2-1 — same window/max as founder).
const RATE_LIMIT_MAX_ATTEMPTS = 5;
const RATE_LIMIT_WINDOW_MINUTES = 15;

// ── Helpers ────────────────────────────────────────────────────────────────

function currentWindowStart(): Date {
  const now = new Date();
  const slotMs = RATE_LIMIT_WINDOW_MINUTES * 60 * 1000;
  return new Date(Math.floor(now.getTime() / slotMs) * slotMs);
}

function buildBucketKey(prefix: string, userId: string): string {
  const windowStart = currentWindowStart();
  const windowLabel = windowStart.toISOString().slice(0, 16);
  return `${prefix}:${userId}:${windowLabel}`;
}

/**
 * Uniform 401 for every soft-failure path (S2-NEW-3 — prevent account
 * enumeration via 403/401 distinction). Real reason logged server-side only.
 */
function uniformFailure(): Response {
  return new Response(JSON.stringify({ ok: false, error: 'invalid_credentials' }), {
    status: 401,
    headers: corsJson(),
  });
}

function corsJson(): Record<string, string> {
  return {
    'content-type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
}

/** Redact UUID to last-8 chars for structured log fields. */
function redactId(id: string): string {
  return `...${id.slice(-8)}`;
}

interface EmployeeLoginRequest {
  totpCode: string;
}

// ── Handler ──────────────────────────────────────────────────────────────────

serve(async (req) => {
  // ── CORS preflight ────────────────────────────────────────────────────────
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Authorization, Content-Type',
      },
    });
  }

  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ ok: false, error: 'method_not_allowed' }), {
      status: 405,
      headers: corsJson(),
    });
  }

  const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    // ── 1. Verify caller identity via JWT ──────────────────────────────────
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ ok: false, error: 'missing_authorization_header' }), {
        status: 401,
        headers: corsJson(),
      });
    }
    const jwt = authHeader.slice(7);

    const { data: userRes, error: userErr } = await supa.auth.getUser(jwt);
    if (userErr || !userRes?.user) {
      return new Response(JSON.stringify({ ok: false, error: 'invalid_jwt' }), {
        status: 401,
        headers: corsJson(),
      });
    }

    const user = userRes.user;
    const userId = user.id;

    // ── 2. Parse request body ────────────────────────────────────────────
    let body: EmployeeLoginRequest;
    try {
      body = (await req.json()) as EmployeeLoginRequest;
    } catch {
      return new Response(JSON.stringify({ ok: false, error: 'invalid_json_body' }), {
        status: 400,
        headers: corsJson(),
      });
    }

    if (!body?.totpCode || typeof body.totpCode !== 'string') {
      return new Response(JSON.stringify({ ok: false, error: 'totpCode_required' }), {
        status: 400,
        headers: corsJson(),
      });
    }

    const code = body.totpCode.replace(/\s+/g, '');

    // ── 3. Rate-limit check (S2-1, S2-CR4 fix) ──────────────────────────────
    // S2-CR4 fix: removed pre-attempt SELECT that caused TOCTOU race. See
    // founder-login/index.ts §3 comment for full explanation. Same pattern applied.
    const rateBucketKey = buildBucketKey('employee_totp', userId);
    const windowStart = currentWindowStart();

    // Lock check: is this window already locked? (SELECT-only, no race risk.)
    const { data: lockRow } = await supa
      .from('rate_limit_buckets')
      .select('count')
      .eq('bucket_key', rateBucketKey)
      .maybeSingle();

    const lockedCount: number = (lockRow as { count: number } | null)?.count ?? 0;

    if (lockedCount >= RATE_LIMIT_MAX_ATTEMPTS) {
      console.error(JSON.stringify({
        fn: 'employee-login',
        event: 'totp_rate_limit_blocked',
        actor: redactId(userId),
        bucket: rateBucketKey,
        count: lockedCount,
      }));
      return new Response(JSON.stringify({ ok: false, error: 'too_many_attempts' }), {
        status: 429,
        headers: { ...corsJson(), 'Retry-After': String(RATE_LIMIT_WINDOW_MINUTES * 60) },
      });
    }

    // ── 4. Look up employee_users row ────────────────────────────────────
    // employee_users mirrors the shape of founder_users for the AppRole.employee
    // path introduced in the employee-role feature.
    const { data: employeeRow, error: employeeErr } = await supa
      .from('employee_users')
      .select('id, totp_secret_cipher')
      .eq('auth_user_id', userId)
      .maybeSingle();

    if (employeeErr) {
      console.error(JSON.stringify({
        fn: 'employee-login',
        event: 'employee_users_lookup_error',
        error: employeeErr.message,
      }));
      return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
        status: 500,
        headers: corsJson(),
      });
    }

    if (!employeeRow) {
      // Not in employee_users. Return uniformFailure to prevent account
      // enumeration (S2-NEW-3). Log the real reason server-side only.
      console.warn(JSON.stringify({
        fn: 'employee-login',
        event: 'not_an_employee_attempt',
        actor: redactId(userId),
      }));
      return uniformFailure();
    }

    // ── 5. Decrypt TOTP secret ───────────────────────────────────────────
    // TODO: employee TOTP decrypt — currently shares founder DEK path until
    // separate enrollment lands. Agent A1 must provide a dedicated
    // decrypt_employee_totp(p_user_id uuid) RPC that uses the employee DEK.
    // Until that migration ships, we call decrypt_founder_totp as a shim —
    // this WILL return an error for employees without a founder row, which
    // means employee TOTP login is intentionally gated until A1's migration
    // (or a follow-on 0021_employee_totp_decrypt.sql) ships.
    //
    // When A1's migration is ready, replace the RPC name below with:
    //   supa.rpc('decrypt_employee_totp', { p_user_id: userId })
    const { data: totpSecret, error: decryptErr } = await supa.rpc('decrypt_founder_totp', {
      p_user_id: userId,
    });

    if (decryptErr || !totpSecret) {
      console.error(JSON.stringify({
        fn: 'employee-login',
        event: 'totp_decrypt_failed',
        actor: redactId(userId),
        error: decryptErr?.message ?? 'null_secret',
      }));
      return uniformFailure();
    }

    // ── 6. Verify the TOTP code ──────────────────────────────────────────
    const isValid = authenticator.verify({
      token: code,
      secret: totpSecret as string,
    });

    if (!isValid) {
      // Atomic increment — returned count is authoritative (S2-CR4 fix).
      // Fail closed on RPC error: treat as threshold breach.
      const { data: newCount, error: rpcErr } = await supa.rpc('upsert_rate_limit_bucket', {
        p_bucket_key: rateBucketKey,
        p_window_start: windowStart.toISOString(),
      });

      const failCount: number = rpcErr ? RATE_LIMIT_MAX_ATTEMPTS : (newCount as number);

      console.error(JSON.stringify({
        fn: 'employee-login',
        event: 'totp_verify_failed',
        actor: redactId(userId),
        fail_count: failCount,
      }));

      try {
        await supa.auth.admin.signOut(userId);
      } catch (signOutErr) {
        console.error(JSON.stringify({
          fn: 'employee-login',
          event: 'sign_out_after_bad_totp_failed',
          actor: redactId(userId),
          error: String(signOutErr),
        }));
      }

      const isNowLocked = failCount >= RATE_LIMIT_MAX_ATTEMPTS;
      await supa.from('audit_log').insert({
        tenant_id: null,
        actor_id: userId,
        actor_role: 'employee',
        action: isNowLocked ? 'employee.totp_lockout' : 'employee.totp_failed',
        target_type: 'employee_users',
        target_id: employeeRow.id,
        metadata: { reason: 'invalid_totp_code', fail_count: failCount, locked: isNowLocked },
      });

      if (isNowLocked) {
        return new Response(JSON.stringify({ ok: false, error: 'too_many_attempts' }), {
          status: 429,
          headers: { ...corsJson(), 'Retry-After': String(RATE_LIMIT_WINDOW_MINUTES * 60) },
        });
      }

      return uniformFailure();
    }

    // ── 7. TOTP valid — clear rate-limit counter ─────────────────────────
    await supa
      .from('rate_limit_buckets')
      .delete()
      .eq('bucket_key', rateBucketKey);

    // ── 8. Stamp app_metadata server-side (S2-2) ─────────────────────────
    // Moved from client-side EmployeeLoginView.swift per S2-2: employee role
    // must only be granted after server-vetted TOTP, with full audit trail.
    const { error: updateErr } = await supa.auth.admin.updateUserById(userId, {
      app_metadata: {
        role: 'employee',
        // Employees are not tenant-scoped — they handle cross-tenant transfer
        // approvals but cannot read tenant row data directly.
        tenant_id: null,
      },
    });

    if (updateErr) {
      console.error(JSON.stringify({
        fn: 'employee-login',
        event: 'app_metadata_write_failed',
        actor: redactId(userId),
        error: updateErr.message,
      }));
      return new Response(JSON.stringify({ ok: false, error: 'metadata_write_failed' }), {
        status: 500,
        headers: corsJson(),
      });
    }

    // Update last_login_at on the employee row.
    await supa
      .from('employee_users')
      .update({ last_login_at: new Date().toISOString() })
      .eq('id', employeeRow.id);

    // Audit-log the successful login.
    await supa.from('audit_log').insert({
      tenant_id: null,
      actor_id: userId,
      actor_role: 'employee',
      action: 'employee.login_success',
      target_type: 'employee_users',
      target_id: employeeRow.id,
      metadata: {},
    });

    console.log(JSON.stringify({
      fn: 'employee-login',
      event: 'login_success',
      actor: redactId(userId),
    }));

    return new Response(
      JSON.stringify({ ok: true, role: 'employee' }),
      {
        status: 200,
        headers: corsJson(),
      },
    );
  } catch (e) {
    console.error(JSON.stringify({
      fn: 'employee-login',
      event: 'unhandled_error',
      error: String(e),
    }));
    return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
      status: 500,
      headers: corsJson(),
    });
  }
});
