// LadderBackend/supabase/functions/bootstrap-user/index.ts
// §B2C direct signup bootstrap — sets app_metadata.role = 'student' for new users.
//
// Migration 0008 was a no-op because Supabase forbids DDL against the auth schema
// from tenant migrations ("permission denied for schema auth"). This Edge Function
// takes its place.
//
// Call contract:
//   POST /functions/v1/bootstrap-user
//   Authorization: Bearer <jwt>          (the freshly-issued JWT after signUp)
//   No request body required.
//
// After this function returns { ok: true }, the iOS client MUST call
// supabase.auth.refreshSession() to receive a new JWT carrying the role claim.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

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

    // Use service_role client for all admin operations. The service_role key is
    // auto-injected by the Supabase runtime — it is never returned to callers.
    const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { data: userRes, error: userErr } = await supa.auth.getUser(jwt);
    if (userErr || !userRes?.user) {
      return new Response(JSON.stringify({ ok: false, error: 'invalid_jwt' }), {
        status: 401,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    const user = userRes.user;
    const userId = user.id;

    // ── 2. Idempotency guard — skip if already bootstrapped ───────────────
    // app_metadata is server-controlled; clients cannot write it directly.
    const existingRole = user.app_metadata?.role;
    if (existingRole) {
      return new Response(
        JSON.stringify({ ok: true, alreadyBootstrapped: true }),
        {
          status: 200,
          headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
        },
      );
    }

    // ── 3. Stamp role = 'student' onto app_metadata ───────────────────────
    // This is the authoritative write. tenant_id is null until the user
    // redeems an invite code via the invite-redeem function (§6.1, §6.2).
    const { error: updateErr } = await supa.auth.admin.updateUserById(userId, {
      app_metadata: {
        role: 'student',
        tenant_id: null,
      },
    });

    if (updateErr) {
      // Log server-side; never return the raw error to the caller.
      console.error('bootstrap-user: failed to stamp app_metadata for', userId, updateErr.message);
      return new Response(JSON.stringify({ ok: false, error: 'metadata_write_failed' }), {
        status: 500,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    return new Response(
      JSON.stringify({ ok: true, role: 'student', tenant_id: null }),
      {
        status: 200,
        headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      },
    );
  } catch (e) {
    // Catch-all: never leak internal details.
    console.error('bootstrap-user: unhandled error', e);
    return new Response(JSON.stringify({ ok: false, error: 'internal_error' }), {
      status: 500,
      headers: { 'content-type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }
});
