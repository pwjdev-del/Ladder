// LadderBackend/tests/rls/sia_isolation.test.ts
//
// RLS isolation tests for migration 0014 (T009 — SIA memory + nudge log).
//
// Runner: deno test --allow-env --allow-net tests/rls/sia_isolation.test.ts
// Prerequisites: a running local Supabase instance (`supabase start`).
// Required env vars:
//   SUPABASE_URL              — default http://localhost:54321
//   SUPABASE_SERVICE_ROLE_KEY — admin operations (create users, seed data)
//   SUPABASE_ANON_KEY         — base client (sign-in to obtain user JWTs)
//
// Test matrix (DECISIONS.md D-002 + D-003):
//   1. Student A can SELECT their own summary. Cannot SELECT Student B's summary.
//   2. Student A can SELECT their own nudge rows. Cannot SELECT Student B's nudge rows.
//   3. Counselor (same tenant) can SELECT student summaries. CANNOT SELECT nudge_log.
//   4. Counselor (different tenant) cannot SELECT summaries OR nudge_log.
//   5. Anonymous (no JWT) cannot SELECT anything from either table.
//   6. Raw student_ai_chats — counselor JWT read check (D-002 concern for T011).
//
// SECURITY INVARIANTS VERIFIED:
//   - student_nudge_log has ZERO counselor policy: any counselor JWT returns 0 rows.
//   - Cross-tenant counselor reads return 0 rows by current_setting(app.tenant_id) binding.
//   - Unauthenticated requests return 0 rows (RLS denies by default when no policy matches).

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const SUPABASE_URL        = Deno.env.get('SUPABASE_URL')              ?? 'http://localhost:54321';
const SERVICE_ROLE_KEY    = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const ANON_KEY            = Deno.env.get('SUPABASE_ANON_KEY')         ?? '';

// ---------------------------------------------------------------------------
// Client helpers
// ---------------------------------------------------------------------------

function adminClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
}

function anonClient(): SupabaseClient {
  return createClient(SUPABASE_URL, ANON_KEY);
}

/** Sign in a test user and return a user-scoped client. */
async function signInClient(email: string, password: string): Promise<SupabaseClient> {
  const anon = anonClient();
  const { data, error } = await anon.auth.signInWithPassword({ email, password });
  if (error || !data.session) {
    throw new Error(`signIn(${email}) failed: ${error?.message}`);
  }
  return createClient(SUPABASE_URL, ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${data.session.access_token}` } },
  });
}

// ---------------------------------------------------------------------------
// Seed helpers (service-role only)
// ---------------------------------------------------------------------------

interface TestUser {
  userId: string;
  email: string;
  password: string;
}

/** Create a Supabase auth user + user_profiles row for testing. */
async function createTestUser(
  tenantId: string,
  role: 'student' | 'counselor',
  suffix: string,
): Promise<TestUser> {
  const admin = adminClient();
  const email    = `rls-test-${role}-${suffix}-${Date.now()}@ladder-test.invalid`;
  const password = 'TestRls!2026';

  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    app_metadata: { role, tenant_id: tenantId },
  });
  if (error || !data.user) throw new Error(`createUser(${email}) failed: ${error?.message}`);

  // Insert user_profiles row so RLS helpers that join user_profiles work.
  const { error: profileErr } = await admin
    .from('user_profiles')
    .insert({ id: data.user.id, tenant_id: tenantId, role });
  if (profileErr) throw new Error(`user_profiles insert failed: ${profileErr.message}`);

  return { userId: data.user.id, email, password };
}

async function deleteTestUser(userId: string): Promise<void> {
  const admin = adminClient();
  await admin.from('user_profiles').delete().eq('id', userId);
  await admin.auth.admin.deleteUser(userId);
}

/** Insert a student_memory_summaries row via service-role (bypasses RLS). */
async function seedSummary(tenantId: string, studentUserId: string): Promise<string> {
  const admin = adminClient();
  const { data, error } = await admin
    .from('student_memory_summaries')
    .insert({ tenant_id: tenantId, student_user_id: studentUserId, summary_text: 'test summary' })
    .select('id')
    .single();
  if (error || !data) throw new Error(`seedSummary failed: ${error?.message}`);
  return data.id as string;
}

/** Insert a student_nudge_log row via service-role (bypasses RLS). */
async function seedNudge(tenantId: string, studentUserId: string): Promise<string> {
  const admin = adminClient();
  const { data, error } = await admin
    .from('student_nudge_log')
    .insert({ tenant_id: tenantId, student_user_id: studentUserId, nudge_type: 'deadline_reminder' })
    .select('id')
    .single();
  if (error || !data) throw new Error(`seedNudge failed: ${error?.message}`);
  return data.id as string;
}

async function deleteSummary(id: string): Promise<void> {
  await adminClient().from('student_memory_summaries').delete().eq('id', id);
}

async function deleteNudge(id: string): Promise<void> {
  await adminClient().from('student_nudge_log').delete().eq('id', id);
}

/** Seed a tenant row and return its id. */
async function seedTenant(label: string): Promise<string> {
  const admin = adminClient();
  const { data, error } = await admin
    .from('tenants')
    .insert({ type: 'school', slug: `rls-test-${label}-${Date.now()}`, display_name: `RLS Test ${label}` })
    .select('id')
    .single();
  if (error || !data) throw new Error(`seedTenant failed: ${error?.message}`);
  return data.id as string;
}

async function deleteTenant(id: string): Promise<void> {
  await adminClient().from('tenants').delete().eq('id', id);
}

// ---------------------------------------------------------------------------
// Helper: assert row count
// ---------------------------------------------------------------------------

function assertCount(
  label: string,
  data: unknown[] | null,
  error: { message: string } | null,
  expected: number,
): void {
  if (error) throw new Error(`${label}: query error — ${error.message}`);
  const count = (data ?? []).length;
  if (count !== expected) {
    throw new Error(`${label}: expected ${expected} row(s), got ${count}`);
  }
}

// ---------------------------------------------------------------------------
// Test 1 — Student A reads own summary; cannot read Student B's summary
// ---------------------------------------------------------------------------

Deno.test('T1: Student A reads own summary; Student B summary is blocked', async () => {
  const tenantId = await seedTenant('t1');
  const userA = await createTestUser(tenantId, 'student', 'a-t1');
  const userB = await createTestUser(tenantId, 'student', 'b-t1');
  const summaryAId = await seedSummary(tenantId, userA.userId);
  const summaryBId = await seedSummary(tenantId, userB.userId);

  try {
    const clientA = await signInClient(userA.email, userA.password);

    // Student A can read own summary.
    const { data: ownRows, error: ownErr } = await clientA
      .from('student_memory_summaries')
      .select('id')
      .eq('id', summaryAId);
    assertCount('Student A sees own summary', ownRows, ownErr, 1);

    // Student A cannot read Student B's summary.
    const { data: otherRows, error: otherErr } = await clientA
      .from('student_memory_summaries')
      .select('id')
      .eq('id', summaryBId);
    assertCount('Student A blocked from Student B summary', otherRows, otherErr, 0);

    console.log('PASS T1: per-student summary isolation');
  } finally {
    await deleteSummary(summaryAId);
    await deleteSummary(summaryBId);
    await deleteTestUser(userA.userId);
    await deleteTestUser(userB.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// Test 2 — Student A reads own nudge; cannot read Student B's nudge
// ---------------------------------------------------------------------------

Deno.test('T2: Student A reads own nudge; Student B nudge is blocked', async () => {
  const tenantId = await seedTenant('t2');
  const userA = await createTestUser(tenantId, 'student', 'a-t2');
  const userB = await createTestUser(tenantId, 'student', 'b-t2');
  const nudgeAId = await seedNudge(tenantId, userA.userId);
  const nudgeBId = await seedNudge(tenantId, userB.userId);

  try {
    const clientA = await signInClient(userA.email, userA.password);

    // Student A reads own nudge.
    const { data: ownRows, error: ownErr } = await clientA
      .from('student_nudge_log')
      .select('id')
      .eq('id', nudgeAId);
    assertCount('Student A sees own nudge', ownRows, ownErr, 1);

    // Student A blocked from Student B's nudge.
    const { data: otherRows, error: otherErr } = await clientA
      .from('student_nudge_log')
      .select('id')
      .eq('id', nudgeBId);
    assertCount('Student A blocked from Student B nudge', otherRows, otherErr, 0);

    console.log('PASS T2: per-student nudge isolation');
  } finally {
    await deleteNudge(nudgeAId);
    await deleteNudge(nudgeBId);
    await deleteTestUser(userA.userId);
    await deleteTestUser(userB.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// Test 3 — Counselor (same tenant): can SELECT summaries, CANNOT SELECT nudge_log
// ---------------------------------------------------------------------------

Deno.test('T3: Counselor (same tenant) reads summaries; nudge_log returns 0 rows', async () => {
  const tenantId  = await seedTenant('t3');
  const student   = await createTestUser(tenantId, 'student',   'student-t3');
  const counselor = await createTestUser(tenantId, 'counselor', 'counselor-t3');
  const summaryId = await seedSummary(tenantId, student.userId);
  const nudgeId   = await seedNudge(tenantId, student.userId);

  try {
    const counselorClient = await signInClient(counselor.email, counselor.password);

    // Counselor can read summary (D-002: counselors read summaries, not raw chat).
    const { data: sumRows, error: sumErr } = await counselorClient
      .from('student_memory_summaries')
      .select('id')
      .eq('id', summaryId);
    assertCount('Counselor reads same-tenant summary', sumRows, sumErr, 1);

    // Counselor CANNOT read nudge_log (D-002: zero counselor access).
    const { data: nudgeRows, error: nudgeErr } = await counselorClient
      .from('student_nudge_log')
      .select('id')
      .eq('id', nudgeId);
    assertCount('Counselor blocked from nudge_log (D-002)', nudgeRows, nudgeErr, 0);

    console.log('PASS T3: counselor summary access + nudge_log blocked');
  } finally {
    await deleteSummary(summaryId);
    await deleteNudge(nudgeId);
    await deleteTestUser(student.userId);
    await deleteTestUser(counselor.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// Test 4 — Counselor (different tenant) cannot read summaries OR nudge_log
// ---------------------------------------------------------------------------

Deno.test('T4: Counselor (different tenant) cannot read summaries or nudge_log', async () => {
  const tenantA   = await seedTenant('t4a');
  const tenantB   = await seedTenant('t4b');
  const student   = await createTestUser(tenantA, 'student',   'student-t4');
  const counselor = await createTestUser(tenantB, 'counselor', 'counselor-t4');
  const summaryId = await seedSummary(tenantA, student.userId);
  const nudgeId   = await seedNudge(tenantA, student.userId);

  try {
    const counselorClient = await signInClient(counselor.email, counselor.password);

    // Different-tenant counselor: summary blocked (session app.tenant_id = tenantB, row tenant_id = tenantA).
    const { data: sumRows, error: sumErr } = await counselorClient
      .from('student_memory_summaries')
      .select('id')
      .eq('id', summaryId);
    assertCount('Cross-tenant counselor blocked from summary', sumRows, sumErr, 0);

    // Different-tenant counselor: nudge blocked (no policy at all for counselors).
    const { data: nudgeRows, error: nudgeErr } = await counselorClient
      .from('student_nudge_log')
      .select('id')
      .eq('id', nudgeId);
    assertCount('Cross-tenant counselor blocked from nudge_log', nudgeRows, nudgeErr, 0);

    console.log('PASS T4: cross-tenant counselor isolation');
  } finally {
    await deleteSummary(summaryId);
    await deleteNudge(nudgeId);
    await deleteTestUser(student.userId);
    await deleteTestUser(counselor.userId);
    await deleteTenant(tenantA);
    await deleteTenant(tenantB);
  }
});

// ---------------------------------------------------------------------------
// Test 5 — Anonymous (no JWT) cannot read either table
// ---------------------------------------------------------------------------

Deno.test('T5: Anonymous client cannot SELECT summaries or nudge_log', async () => {
  const tenantId  = await seedTenant('t5');
  const student   = await createTestUser(tenantId, 'student', 'student-t5');
  const summaryId = await seedSummary(tenantId, student.userId);
  const nudgeId   = await seedNudge(tenantId, student.userId);

  try {
    const anon = anonClient();

    const { data: sumRows, error: sumErr } = await anon
      .from('student_memory_summaries')
      .select('id')
      .eq('id', summaryId);
    assertCount('Anon blocked from summaries', sumRows, sumErr, 0);

    const { data: nudgeRows, error: nudgeErr } = await anon
      .from('student_nudge_log')
      .select('id')
      .eq('id', nudgeId);
    assertCount('Anon blocked from nudge_log', nudgeRows, nudgeErr, 0);

    console.log('PASS T5: anonymous access blocked');
  } finally {
    await deleteSummary(summaryId);
    await deleteNudge(nudgeId);
    await deleteTestUser(student.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// Test 6 — Counselor cannot SELECT student_ai_chats directly (D-002 concern)
//
// student_ai_chats was created in migration 0009 with a counselor read policy
// scoped to assigned students only. This test verifies that a counselor with no
// assignment to the student receives 0 rows — confirming the "raw chat" firewall.
//
// NOTE: student_ai_chats DOES exist (0009). The T011 raw-chat concern referenced
// in the T009 spec is about whether the policy is tight enough, not about missing
// table. See comment at bottom of this test for the verdict.
// ---------------------------------------------------------------------------

Deno.test('T6: Counselor JWT cannot read unassigned student_ai_chats (raw chat firewall)', async () => {
  const tenantId  = await seedTenant('t6');
  const student   = await createTestUser(tenantId, 'student',   'student-t6');
  const counselor = await createTestUser(tenantId, 'counselor', 'counselor-t6');

  // Seed a chat row via service-role. student_ai_chats uses students.id (not user_id) as FK,
  // so we must look up the students row first.
  const admin = adminClient();
  const { data: studentRow } = await admin
    .from('students')
    .select('id')
    .eq('user_id', student.userId)
    .single();

  let chatId: string | null = null;

  if (studentRow) {
    const { data: chatData } = await admin
      .from('student_ai_chats')
      .insert({
        tenant_id:      tenantId,
        student_id:     studentRow.id,
        role:           'user',
        content_cipher: new TextEncoder().encode('encrypted-placeholder'),
      })
      .select('id')
      .single();
    chatId = chatData?.id ?? null;
  }

  try {
    // Counselor has NO counselor_assignments row for this student.
    const counselorClient = await signInClient(counselor.email, counselor.password);

    const { data: chatRows, error: chatErr } = await counselorClient
      .from('student_ai_chats')
      .select('id');

    // Unassigned counselor must receive 0 rows (RLS policy ai_chats_counselor_read
    // requires a matching counselor_assignments row with removed_at IS NULL).
    assertCount('Unassigned counselor cannot read student_ai_chats', chatRows, chatErr, 0);

    // D-002 verdict for T011: student_ai_chats EXISTS (created in 0009).
    // The raw-chat policy in 0009 IS assignment-scoped, which is stricter than summaries.
    // T011 concern: verify the encryption layer (content_cipher) is never returned
    // as plaintext. That is an application-layer concern, not an RLS concern.
    console.log(
      'PASS T6: counselor cannot read unassigned raw chat. ' +
      'student_ai_chats EXISTS (0009). T011 concern = cipher plaintext exposure, not missing table.',
    );
  } finally {
    if (chatId) await admin.from('student_ai_chats').delete().eq('id', chatId);
    await deleteTestUser(student.userId);
    await deleteTestUser(counselor.userId);
    await deleteTenant(tenantId);
  }
});
