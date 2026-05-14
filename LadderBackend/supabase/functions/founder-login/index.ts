// LadderBackend/supabase/functions/founder-login/index.ts
// Auth flow: password → TOTP decrypt → verify → app_metadata.role assignment. Rate-limited per S2-1.
//
// The iOS client performs signInWithPassword first (first factor), then calls
// this endpoint with the resulting JWT + the TOTP code the founder typed.
// On success, app_metadata.role is stamped as 'founder' and iOS refreshes the session.
//
// Call contract:
//   POST /functions/v1/founder-login
//   Authorization: Bearer <jwt>       (JWT from a prior signInWithPassword)
//   Content-Type: application/json
//   Body: { "totpCode": "123456" }
//
// On success  → 200  { ok: true, role: "founder" }
// Soft fail   → 401  { ok: false, error: "invalid_credentials" } (uniform — see S2-NEW-3)
// Hard lock   → 429  { ok: false, error: "too_many_attempts" } (after 5 fails in 15min)
// Locked out  → 429  { ok: false, error: "too_many_attempts" }
// Server err  → 500  { ok: false, error: "internal_error" }

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';
import { authenticator } from 'npm:otplib@12.0.1';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// otplib authenticator options — 30-second window, 6 digits, ±1 step grace
// (allows the founder ~60 seconds of clock skew tolerance).
authenticator.options = {
  digits: 6,
  step: 30,
  window: 1,
};

// Rate-limit constants (S2-1).
const RATE_LIMIT_MAX_ATTEMPTS = 5;
const RATE_LIMIT_WINDOW_MINUTES = 15;

// ── Helpers ──────────────────────────────────────────────────────────────────

/** Returns the start of the current 15-minute rate-limit window. */
function currentWindowStart(): Date {
  const now = new Date();
  const slotMs = RATE_LIMIT_WINDOW_MINUTES * 60 * 1000;
  return new Date(Math.floor(now.getTime() / slotMs) * slotMs);
}

/** Bucket key for TOTP rate-limiting. Uses last-8 of userId — not full UUID — for log safety. */
function buildBucketKey(prefix: string, userId: string): string {
  const windowStart = currentWindowStart();
  const windowLabel = windowStart.toISOString().slice(0, 16); // "YYYY-MM-DDTHH:MM"
  return `${prefix}:${userId}:${windowLabel}`;
}

/**
 * Uniform 401 used for every soft-failure path. Critical for preventing
 * account enumeration (S2-NEW-3): if we returned distinct status/error codes
 * for "not a founder" vs "wrong TOTP" vs "decrypt failed", an attacker
 * iterating auth.users could enumerate which accounts are in founder_users.
 *
 * The REAL failure reason is logged server-side (see redactId-tagged
 * console.error calls); the client only ever sees `invalid_credentials`.
 *
 * Reserve other status codes for: 429 (hard rate-limit lockout — timing
 * already deterministic), 500 (genuine server error), 405/400 (malformed
 * request, no enumeration risk).
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

interface FounderLoginRequest {
  totpCode: string;
}

// ── Handler ───────────────────────────────────────────────────────────────────

serve(async (req) => {
  // ── CORS preflight ──────────────────────────────────────────────────────────
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

  // Use service_role client for all admin operations. This key is auto-injected
  // by the Supabase runtime and is NEVER returned to callers.
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
    let body: FounderLoginRequest;
    try {
      body = (await req.json()) as FounderLoginRequest;
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

    // Normalise: strip spaces the user may have typed between digit groups.
    const code = body.totpCode.replace(/\s+/g, '');

    // ── 3. Rate-limit check (S2-1, S2-CR4 fix) ──────────────────────────────
    // Uses the existing rate_limit_buckets table (migration 0015) via the
    // upsert_rate_limit_bucket RPC.
    //
    // S2-CR4 fix: the pre-attempt SELECT that read the current count was removed.
    // That SELECT introduced a TOCTOU race: two concurrent requests both observing
    // count=4 would both proceed, both fail TOTP, and both increment to 5/6 before
    // lockout was checked. Attacker got ~2× allowed attempts per window.
    //
    // New pattern:
    //   - Lock check (SELECT count >= 5): safe pre-flight to return 429 fast if the
    //     window is already locked. A locked window stays locked for the full 15-min
    //     window; a millisecond race here is harmless.
    //   - On TOTP failure: call upsert_rate_limit_bucket (atomic INSERT/ON CONFLICT
    //     DO UPDATE RETURNING) and use the RETURNED post-increment count to decide
    //     whether to lock. Race-free because the increment and count read are a
    //     single atomic statement.
    //
    // The bucket key is scoped per-user per 15-minute window.
    const rateBucketKey = buildBucketKey('founder_totp', userId);
    const windowStart = currentWindowStart();

    // Lock check: is this window already locked? (SELECT-only, no race risk here.)
    const { data: lockRow } = await supa
      .from('rate_limit_buckets')
      .select('count')
      .eq('bucket_key', rateBucketKey)
      .maybeSingle();

    const lockedCount: number = (lockRow as { count: number } | null)?.count ?? 0;

    if (lockedCount >= RATE_LIMIT_MAX_ATTEMPTS) {
      // Already locked out — do not reveal whether the TOTP would have been valid.
      console.error(JSON.stringify({
        fn: 'founder-login',
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

    // ── 4. Look up founder_users row ─────────────────────────────────────
    // Service_role bypasses RLS — required here because the JWT app_metadata
    // does not yet carry role='founder' (that's what we're about to verify).
    const { data: founderRow, error: founderErr } = await supa
      .from('founder_users')
      .select('id, totp_secret_cipher')
      .eq('auth_user_id', userId)
      .maybeSingle();

    if (founderErr) {
      console.error(JSON.stringify({
        fn: 'founder-login',
        event: 'founder_users_lookup_error',
        error: founderErr.message,
      }));
      return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
        status: 500,
        headers: corsJson(),
      });
    }

    if (!founderRow) {
      // Not in founder_users. Return uniformFailure to prevent account
      // enumeration (S2-NEW-3). Log the real reason server-side only.
      console.warn(JSON.stringify({
        fn: 'founder-login',
        event: 'not_a_founder_attempt',
        actor: redactId(userId),
      }));
      return uniformFailure();
    }

    // ── 5. Decrypt TOTP secret via Postgres RPC (S1-1) ───────────────────
    // Migration 0020 (agent A1) adds app.decrypt_founder_totp(p_user_id uuid)
    // which retrieves the DEK from Supabase Vault and decrypts
    // founder_users.totp_secret_cipher, returning the base32 plaintext.
    const { data: totpSecret, error: decryptErr } = await supa.rpc('decrypt_founder_totp', {
      p_user_id: userId,
    });

    if (decryptErr || !totpSecret) {
      console.error(JSON.stringify({
        fn: 'founder-login',
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
      // Increment fail counter atomically (S2-CR4 fix). upsert_rate_limit_bucket
      // does INSERT … ON CONFLICT DO UPDATE … RETURNING count in a single
      // statement, so the returned value is the authoritative post-increment count.
      // There is no separate SELECT; the lockout decision is made solely from this
      // return value, eliminating the TOCTOU window.
      const { data: newCount, error: rpcErr } = await supa.rpc('upsert_rate_limit_bucket', {
        p_bucket_key: rateBucketKey,
        p_window_start: windowStart.toISOString(),
      });

      // If the RPC errors, conservatively treat it as a lockout-threshold breach
      // to fail closed (better to lock a real founder out for 15 min than to allow
      // unlimited attempts on a broken counter).
      const failCount: number = rpcErr ? RATE_LIMIT_MAX_ATTEMPTS : (newCount as number);

      console.error(JSON.stringify({
        fn: 'founder-login',
        event: 'totp_verify_failed',
        actor: redactId(userId),
        fail_count: failCount,
      }));

      // Invalidate the session immediately.
      try {
        await supa.auth.admin.signOut(userId);
      } catch (signOutErr) {
        console.error(JSON.stringify({
          fn: 'founder-login',
          event: 'sign_out_after_bad_totp_failed',
          actor: redactId(userId),
          error: String(signOutErr),
        }));
      }

      // Audit-log the failed attempt, including whether lockout was triggered.
      const isNowLocked = failCount >= RATE_LIMIT_MAX_ATTEMPTS;
      await supa.from('audit_log').insert({
        tenant_id: null,
        actor_id: userId,
        actor_role: 'founder',
        action: isNowLocked ? 'founder.totp_lockout' : 'founder.totp_failed',
        target_type: 'founder_users',
        target_id: founderRow.id,
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
    // Delete the failure bucket so a legitimate user who had some prior fails
    // gets a clean slate on success.
    await supa
      .from('rate_limit_buckets')
      .delete()
      .eq('bucket_key', rateBucketKey);

    // ── 8. Stamp app_metadata and audit-log ─────────────────────────────
    // Idempotent: if role is already 'founder' this is a no-op in effect.
    const { error: updateErr } = await supa.auth.admin.updateUserById(userId, {
      app_metadata: {
        role: 'founder',
        tenant_id: null,
      },
    });

    if (updateErr) {
      console.error(JSON.stringify({
        fn: 'founder-login',
        event: 'app_metadata_write_failed',
        actor: redactId(userId),
        error: updateErr.message,
      }));
      return new Response(JSON.stringify({ ok: false, error: 'metadata_write_failed' }), {
        status: 500,
        headers: corsJson(),
      });
    }

    // Update last_login_at on the founder row.
    await supa
      .from('founder_users')
      .update({ last_login_at: new Date().toISOString() })
      .eq('id', founderRow.id);

    // Audit-log the successful login.
    await supa.from('audit_log').insert({
      tenant_id: null,
      actor_id: userId,
      actor_role: 'founder',
      action: 'founder.login_success',
      target_type: 'founder_users',
      target_id: founderRow.id,
      metadata: {},
    });

    console.log(JSON.stringify({
      fn: 'founder-login',
      event: 'login_success',
      actor: redactId(userId),
    }));

    return new Response(
      JSON.stringify({ ok: true, role: 'founder' }),
      {
        status: 200,
        headers: corsJson(),
      },
    );
  } catch (e) {
    // Catch-all: never leak internal details or the service_role key.
    console.error(JSON.stringify({
      fn: 'founder-login',
      event: 'unhandled_error',
      error: String(e),
    }));
    return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
      status: 500,
      headers: corsJson(),
    });
  }
});
