// LadderBackend/supabase/functions/founder-login/index.ts
// §14.1 Founder TOTP verification — server-side second factor for founder login.
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
// Not founder → 403  { ok: false, error: "not_a_founder" }
// Bad TOTP    → 401  { ok: false, error: "invalid_totp" }    + session invalidated
// Server err  → 500  { ok: false, error: "<safe message>" }

// ─────────────────────────────────────────────────────────────────────────────
// SCHEMA GAP WARNING
// ─────────────────────────────────────────────────────────────────────────────
// Migration 0006 created founder_users with column:
//   totp_secret_cipher  bytea
//
// This column stores the TOTP secret ENCRYPTED with the tenant DEK (or a
// founder-level DEK). The DEK retrieval mechanism has NOT been implemented yet.
//
// Until migration 0009 ships AND a plaintext/decryptable secret is available,
// this function uses a HARDCODED PLACEHOLDER secret:
//
//   PLACEHOLDER_TOTP_SECRET = 'JBSWY3DPEHPK3PXP'
//
// This is a well-known RFC 6238 test vector. Any TOTP app pointed at it will
// generate valid codes, so the end-to-end wiring can be verified before real
// secrets exist.
//
// REQUIRED before going to production:
//   1. Ship migration 0009_founder_totp_secret.sql to add plaintext or DEK-
//      encrypted secret storage with a clear decryption path.
//   2. Implement a Founder TOTP enrollment flow (Phase 4 task) so the founder
//      can scan a QR code into their authenticator app.
//   3. Replace EVERY reference to PLACEHOLDER_TOTP_SECRET below with actual
//      secret retrieval from the founder_users row.
// ─────────────────────────────────────────────────────────────────────────────

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';
import { authenticator } from 'npm:otplib@12.0.1';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// TODO: replace once 0009 ships + enrollment flow is live.
// This is a test-only secret. NEVER ship this value to a production founder row.
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
const PLACEHOLDER_TOTP_SECRET = 'JBSWY3DPEHPK3PXP';

// otplib authenticator options — 30-second window, 6 digits, ±1 step grace
// (allows the founder ~60 seconds of clock skew tolerance).
authenticator.options = {
  digits: 6,
  step: 30,
  window: 1,
};

interface FounderLoginRequest {
  totpCode: string;
}

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
      headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }

  // Use service_role client for all admin operations. This key is auto-injected
  // by the Supabase runtime and is NEVER returned to callers.
  const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    // ── 1. Verify caller identity via JWT ─────────────────────────────────
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(JSON.stringify({ ok: false, error: 'missing_authorization_header' }), {
        status: 401,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }
    const jwt = authHeader.slice(7);

    const { data: userRes, error: userErr } = await supa.auth.getUser(jwt);
    if (userErr || !userRes?.user) {
      return new Response(JSON.stringify({ ok: false, error: 'invalid_jwt' }), {
        status: 401,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    const user = userRes.user;
    const userId = user.id;

    // ── 2. Parse request body ─────────────────────────────────────────────
    let body: FounderLoginRequest;
    try {
      body = (await req.json()) as FounderLoginRequest;
    } catch {
      return new Response(JSON.stringify({ ok: false, error: 'invalid_json_body' }), {
        status: 400,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    if (!body?.totpCode || typeof body.totpCode !== 'string') {
      return new Response(JSON.stringify({ ok: false, error: 'totpCode_required' }), {
        status: 400,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    // ── 3. Look up founder_users row ──────────────────────────────────────
    // Service_role bypasses RLS — required here because the JWT app_metadata
    // does not yet carry role='founder' (that's what we're about to verify).
    const { data: founderRow, error: founderErr } = await supa
      .from('founder_users')
      .select('id, totp_secret_cipher')
      .eq('auth_user_id', userId)
      .maybeSingle();

    if (founderErr) {
      console.error('founder-login: founder_users lookup error', founderErr.message);
      return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
        status: 500,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    if (!founderRow) {
      // Not in founder_users — not a founder. Do NOT audit-log with user detail
      // to avoid confirming which accounts exist in founder_users.
      return new Response(JSON.stringify({ ok: false, error: 'not_a_founder' }), {
        status: 403,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    // ── 4. Resolve the TOTP secret ────────────────────────────────────────
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // TODO: replace once 0009 ships + enrollment flow is live.
    //
    // CURRENT (placeholder):
    //   Ignore totp_secret_cipher entirely and use the hardcoded test secret.
    //
    // FUTURE (production path):
    //   1. Fetch the founder-level DEK from Supabase Vault (or KMS).
    //   2. Decrypt founderRow.totp_secret_cipher with the DEK.
    //   3. Decode the resulting bytes as UTF-8 base32 → pass to authenticator.verify.
    //
    // Example (pseudocode, fill in once DEK API is known):
    //   const dek = await fetchFounderDEK(founderRow.id);
    //   const totpSecretBytes = decryptAES256GCM(founderRow.totp_secret_cipher, dek);
    //   const totpSecret = new TextDecoder().decode(totpSecretBytes);
    // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    const totpSecret = PLACEHOLDER_TOTP_SECRET; // TODO: replace once 0009 ships

    // ── 5. Verify the TOTP code ───────────────────────────────────────────
    const isValid = authenticator.verify({
      token: body.totpCode,
      secret: totpSecret,
    });

    if (!isValid) {
      // Invalidate the session immediately — the first factor is useless without
      // the second. This prevents replay attacks on the issued session JWT.
      try {
        await supa.auth.admin.signOut(userId);
      } catch (signOutErr) {
        console.error('founder-login: failed to sign out after bad TOTP', signOutErr);
        // Continue to 401 — the failed audit log is more important than sign-out succeeding.
      }

      // Audit-log the failed attempt.
      await supa.from('audit_log').insert({
        tenant_id: null,
        actor_id: userId,
        actor_role: 'founder',
        action: 'founder.totp_failed',
        target_type: 'founder_users',
        target_id: founderRow.id,
        metadata: { reason: 'invalid_totp_code' },
      });

      return new Response(JSON.stringify({ ok: false, error: 'invalid_totp' }), {
        status: 401,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    // ── 6. TOTP valid — stamp app_metadata and audit-log ─────────────────
    // Idempotent: if role is already 'founder' this is a no-op in effect.
    const { error: updateErr } = await supa.auth.admin.updateUserById(userId, {
      app_metadata: {
        role: 'founder',
        tenant_id: null,
      },
    });

    if (updateErr) {
      console.error('founder-login: failed to stamp app_metadata for', userId, updateErr.message);
      return new Response(JSON.stringify({ ok: false, error: 'metadata_write_failed' }), {
        status: 500,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
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

    return new Response(
      JSON.stringify({ ok: true, role: 'founder' }),
      {
        status: 200,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      },
    );
  } catch (e) {
    // Catch-all: never leak internal details or the service_role key.
    console.error('founder-login: unhandled error', e);
    return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
      status: 500,
      headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }
});
