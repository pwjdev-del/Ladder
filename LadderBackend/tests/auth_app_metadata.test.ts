// LadderBackend/tests/auth_app_metadata.test.ts
//
// Integration tests: verify that every sign-up path results in role + tenant_id
// being present in auth.users.raw_app_meta_data (the JWT app_metadata claims
// the iOS app reads via SupabaseAuthService.swift).
//
// TODO: integrate when test runner is configured.
//   Recommended runner: `deno test --allow-env --allow-net tests/` pointed at
//   a local Supabase instance (`supabase start`).
//   Set env vars: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_ANON_KEY.
//
// SECURITY INVARIANT VERIFIED BY THESE TESTS:
//   - No test writes role/tenant_id from the client side.
//   - role + tenant_id are ONLY set by:
//       a) The auth.set_default_app_metadata_role trigger (migration 0008), or
//       b) invite-redeem Edge Function using service_role key.

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? 'http://localhost:54321';
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const INVITE_REDEEM_URL = `${SUPABASE_URL}/functions/v1/invite-redeem`;

/** Service-role admin client — server-only. Never expose to browser/iOS. */
function adminClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
}

/** Anonymous client — simulates what the iOS app uses before sign-in. */
function anonClient(): SupabaseClient {
  return createClient(SUPABASE_URL, ANON_KEY);
}

/**
 * Fetch the raw_app_meta_data for a given user via the admin API.
 * Only service_role can read auth.users — this is intentionally server-side only.
 */
async function getAppMetadata(userId: string): Promise<Record<string, unknown>> {
  const admin = adminClient();
  const { data, error } = await admin.auth.admin.getUserById(userId);
  if (error || !data.user) throw new Error(`getAppMetadata failed: ${error?.message}`);
  return (data.user.app_metadata ?? {}) as Record<string, unknown>;
}

/** Delete a test user by ID to keep the local DB clean between test runs. */
async function deleteUser(userId: string): Promise<void> {
  const admin = adminClient();
  await admin.auth.admin.deleteUser(userId);
}

// ---------------------------------------------------------------------------
// Test 1: B2C direct-signup — trigger stamps role=student, tenant_id=null
// ---------------------------------------------------------------------------

Deno.test('B2C direct-signup: trigger stamps role=student and tenant_id=null', async () => {
  // TODO: integrate when test runner is configured.
  // This test exercises migration 0008 (auth.set_default_app_metadata_role trigger).

  const email = `test-b2c-${Date.now()}@ladder-test.invalid`;
  const password = 'TestPassword!2026';

  const anon = anonClient();
  const { data: signUpData, error: signUpErr } = await anon.auth.signUp({ email, password });
  if (signUpErr || !signUpData.user) {
    throw new Error(`signUp failed: ${signUpErr?.message}`);
  }

  const userId = signUpData.user.id;

  try {
    // The trigger fires synchronously AFTER INSERT on auth.users, so by the time
    // signUp returns, raw_app_meta_data should already be stamped.
    const meta = await getAppMetadata(userId);

    if (meta['role'] !== 'student') {
      throw new Error(`Expected role=student, got: ${JSON.stringify(meta['role'])}`);
    }
    if ('tenant_id' in meta && meta['tenant_id'] !== null) {
      throw new Error(`Expected tenant_id=null, got: ${JSON.stringify(meta['tenant_id'])}`);
    }

    console.log('PASS: B2C direct-signup app_metadata', meta);
  } finally {
    await deleteUser(userId);
  }
});

// ---------------------------------------------------------------------------
// Test 2: Invite-redeem — role + tenant_id come from the invite_codes row
// ---------------------------------------------------------------------------

Deno.test('Invite-redeem: app_metadata role and tenant_id match the invite', async () => {
  // TODO: integrate when test runner is configured.
  // This test exercises the invite-redeem Edge Function (Option A fix).
  //
  // Prerequisites (set up via seed.sql or admin calls before this test runs):
  //   - A tenant row exists with a known id (TEST_TENANT_ID env var).
  //   - An invite_codes row exists with kind='b2b_student_single' for that tenant.
  //   - INVITE_TEST_CODE env var holds the plaintext invite code.

  const TEST_TENANT_ID = Deno.env.get('TEST_TENANT_ID');
  const INVITE_TEST_CODE = Deno.env.get('INVITE_TEST_CODE');

  if (!TEST_TENANT_ID || !INVITE_TEST_CODE) {
    console.warn('SKIP: TEST_TENANT_ID or INVITE_TEST_CODE not set — skipping invite-redeem test');
    return;
  }

  const email = `test-invite-${Date.now()}@ladder-test.invalid`;
  const password = 'TestPassword!2026';

  const anon = anonClient();
  const { data: signUpData, error: signUpErr } = await anon.auth.signUp({ email, password });
  if (signUpErr || !signUpData.user) {
    throw new Error(`signUp failed: ${signUpErr?.message}`);
  }
  const userId = signUpData.user.id;

  // Sign in to get a valid JWT for the Edge Function.
  const { data: sessionData, error: sessionErr } = await anon.auth.signInWithPassword({ email, password });
  if (sessionErr || !sessionData.session) {
    throw new Error(`signIn failed: ${sessionErr?.message}`);
  }
  const accessToken = sessionData.session.access_token;

  try {
    // Call the invite-redeem Edge Function as the signed-in user.
    const resp = await fetch(INVITE_REDEEM_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ code: INVITE_TEST_CODE, email }),
    });

    if (!resp.ok) {
      const body = await resp.text();
      throw new Error(`invite-redeem returned ${resp.status}: ${body}`);
    }

    const json = await resp.json() as { ok: boolean; role: string; tenant_id: string };
    if (!json.ok) throw new Error('invite-redeem response.ok was false');

    // Verify app_metadata was stamped on the JWT claims (admin read).
    const meta = await getAppMetadata(userId);

    if (meta['role'] !== 'student') {
      throw new Error(`Expected role=student (b2b_student_single), got: ${JSON.stringify(meta['role'])}`);
    }
    if (meta['tenant_id'] !== TEST_TENANT_ID) {
      throw new Error(`Expected tenant_id=${TEST_TENANT_ID}, got: ${JSON.stringify(meta['tenant_id'])}`);
    }

    console.log('PASS: Invite-redeem app_metadata', meta);
  } finally {
    await deleteUser(userId);
  }
});

// ---------------------------------------------------------------------------
// Test 3: Founder user — role=founder is set via the founder_login path
// ---------------------------------------------------------------------------

Deno.test('Founder user: role=founder in app_metadata (manual verification only)', async () => {
  // TODO: integrate when test runner is configured.
  //
  // Founder auth is currently stubbed — migration 0006 creates founder_users and
  // a founder_login() SQL function that returns {status: "not_implemented"}.
  // The stub comment says: "move credential verification to
  //   LadderBackend/supabase/functions/founder-login".
  //
  // Until founder-login Edge Function exists, this test can only verify that:
  //   a) A founder auth.users row (created manually / via admin) has role=founder
  //      in app_metadata, AND
  //   b) That row satisfies founder_users.auth_user_id FK.
  //
  // When founder-login is implemented, it MUST call:
  //   supabase.auth.admin.updateUserById(founderId, {
  //     app_metadata: { role: 'founder', tenant_id: null }
  //   })
  // using service_role ONLY — never from client code.

  const FOUNDER_USER_ID = Deno.env.get('TEST_FOUNDER_USER_ID');

  if (!FOUNDER_USER_ID) {
    console.warn('SKIP: TEST_FOUNDER_USER_ID not set — skipping founder test');
    return;
  }

  const meta = await getAppMetadata(FOUNDER_USER_ID);

  if (meta['role'] !== 'founder') {
    throw new Error(`Expected role=founder, got: ${JSON.stringify(meta['role'])}`);
  }
  if ('tenant_id' in meta && meta['tenant_id'] !== null) {
    throw new Error(`Expected tenant_id=null for founder, got: ${JSON.stringify(meta['tenant_id'])}`);
  }

  console.log('PASS: Founder app_metadata', meta);
});
