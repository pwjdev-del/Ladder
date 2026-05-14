// LadderBackend/tests/rls/safety_events.test.ts
//
// RLS isolation tests for migration 0019 (T015 — sia_safety_events).
//
// Runner: deno test --allow-env --allow-net tests/rls/safety_events.test.ts
// Prerequisites: a running local Supabase instance (`supabase start`).
// Required env vars:
//   SUPABASE_URL              — default http://localhost:54321
//   SUPABASE_SERVICE_ROLE_KEY — admin operations (create users, seed data)
//   SUPABASE_ANON_KEY         — base client (sign-in to obtain user JWTs)
//
// Test matrix (D-002 + D-003):
//   T1. Student JWT cannot SELECT their own safety events.
//   T2. Counselor JWT (same tenant) CAN SELECT events in their tenant.
//   T3. Counselor JWT (different tenant) cannot SELECT events from another tenant.
//   T4. Anonymous (no JWT) cannot SELECT any safety events.
//
// SECURITY INVARIANTS:
//   - Zero student SELECT policy: student JWT always returns 0 rows.
//   - Counselor access is tenant-scoped: cross-tenant counselor returns 0 rows.
//   - Unauthenticated requests return 0 rows (RLS denies by default).
//   - Edge Function service-role INSERT is not tested here (it bypasses RLS by design).

import { createClient, SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

// ---------------------------------------------------------------------------
// Config
// ---------------------------------------------------------------------------

const SUPABASE_URL     = Deno.env.get('SUPABASE_URL')              ?? 'http://localhost:54321';
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
const ANON_KEY         = Deno.env.get('SUPABASE_ANON_KEY')         ?? '';

// ---------------------------------------------------------------------------
// Client helpers
// ---------------------------------------------------------------------------

function adminClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
}

function anonClient(): SupabaseClient {
  return createClient(SUPABASE_URL, ANON_KEY);
}

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
// Seed helpers
// ---------------------------------------------------------------------------

interface TestUser {
  userId: string;
  email: string;
  password: string;
}

async function seedTenant(label: string): Promise<string> {
  const admin = adminClient();
  const { data, error } = await admin
    .from('tenants')
    .insert({
      type: 'school',
      slug: `rls-se-${label}-${Date.now()}`,
      display_name: `Safety Events RLS Test ${label}`,
    })
    .select('id')
    .single();
  if (error || !data) throw new Error(`seedTenant(${label}) failed: ${error?.message}`);
  return data.id as string;
}

async function deleteTenant(id: string): Promise<void> {
  await adminClient().from('tenants').delete().eq('id', id);
}

async function createTestUser(
  tenantId: string,
  role: 'student' | 'counselor',
  suffix: string,
): Promise<TestUser> {
  const admin    = adminClient();
  const email    = `rls-se-${role}-${suffix}-${Date.now()}@ladder-test.invalid`;
  const password = 'TestRls!2026';

  const { data, error } = await admin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    app_metadata: { role, tenant_id: tenantId },
  });
  if (error || !data.user) throw new Error(`createUser(${email}) failed: ${error?.message}`);

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

/**
 * Seed a sia_safety_events row via service-role (bypasses RLS — mirrors the
 * Edge Function's service-role insert path).
 *
 * Uses the EXACT column names from the ai-gateway/index.ts insert:
 *   tenant_id, student_id, flag_type, triggered_by
 * Do NOT use student_user_id or source here; they are not in the table schema.
 */
async function seedSafetyEvent(tenantId: string, studentUserId: string): Promise<string> {
  const admin = adminClient();
  const { data, error } = await admin
    .from('sia_safety_events')
    .insert({
      tenant_id:    tenantId,
      student_id:   studentUserId,
      flag_type:    'crisis_resource_mentioned',
      triggered_by: 'response_scan',
    })
    .select('id')
    .single();
  if (error || !data) throw new Error(`seedSafetyEvent failed: ${error?.message}`);
  return data.id as string;
}

async function deleteSafetyEvent(id: string): Promise<void> {
  await adminClient().from('sia_safety_events').delete().eq('id', id);
}

// ---------------------------------------------------------------------------
// Assertion helper
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
// T1 — Student JWT cannot SELECT their own safety events
// ---------------------------------------------------------------------------

Deno.test('T1: Student JWT cannot SELECT sia_safety_events (no student policy)', async () => {
  const tenantId = await seedTenant('se-t1');
  const student  = await createTestUser(tenantId, 'student', 'se-t1');
  const eventId  = await seedSafetyEvent(tenantId, student.userId);

  try {
    const studentClient = await signInClient(student.email, student.password);

    // Students have ZERO SELECT policy on sia_safety_events.
    // RLS denies by default → 0 rows, not an error.
    const { data, error } = await studentClient
      .from('sia_safety_events')
      .select('id')
      .eq('id', eventId);
    assertCount('Student cannot read own safety event', data, error, 0);

    console.log('PASS T1: student JWT blocked from sia_safety_events');
  } finally {
    await deleteSafetyEvent(eventId);
    await deleteTestUser(student.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// T2 — Counselor JWT (same tenant) CAN SELECT events in their tenant
// ---------------------------------------------------------------------------

Deno.test('T2: Counselor JWT (same tenant) can SELECT sia_safety_events', async () => {
  const tenantId = await seedTenant('se-t2');
  const student  = await createTestUser(tenantId, 'student',   'se-t2-stu');
  const counselor = await createTestUser(tenantId, 'counselor', 'se-t2-cou');
  const eventId  = await seedSafetyEvent(tenantId, student.userId);

  try {
    const counselorClient = await signInClient(counselor.email, counselor.password);

    const { data, error } = await counselorClient
      .from('sia_safety_events')
      .select('id')
      .eq('id', eventId);
    assertCount('Same-tenant counselor reads safety event', data, error, 1);

    console.log('PASS T2: same-tenant counselor can SELECT sia_safety_events');
  } finally {
    await deleteSafetyEvent(eventId);
    await deleteTestUser(student.userId);
    await deleteTestUser(counselor.userId);
    await deleteTenant(tenantId);
  }
});

// ---------------------------------------------------------------------------
// T3 — Counselor JWT (different tenant) cannot SELECT events from another tenant
// ---------------------------------------------------------------------------

Deno.test('T3: Counselor JWT (different tenant) cannot SELECT sia_safety_events', async () => {
  const tenantA   = await seedTenant('se-t3a');
  const tenantB   = await seedTenant('se-t3b');
  const student   = await createTestUser(tenantA, 'student',   'se-t3-stu');
  const counselor = await createTestUser(tenantB, 'counselor', 'se-t3-cou');
  const eventId   = await seedSafetyEvent(tenantA, student.userId);

  try {
    // Counselor session has app.tenant_id = tenantB; the event has tenant_id = tenantA.
    const counselorClient = await signInClient(counselor.email, counselor.password);

    const { data, error } = await counselorClient
      .from('sia_safety_events')
      .select('id')
      .eq('id', eventId);
    assertCount('Cross-tenant counselor cannot read safety event', data, error, 0);

    console.log('PASS T3: cross-tenant counselor blocked from sia_safety_events');
  } finally {
    await deleteSafetyEvent(eventId);
    await deleteTestUser(student.userId);
    await deleteTestUser(counselor.userId);
    await deleteTenant(tenantA);
    await deleteTenant(tenantB);
  }
});

// ---------------------------------------------------------------------------
// T4 — Anonymous (no JWT) cannot SELECT any safety events
// ---------------------------------------------------------------------------

Deno.test('T4: Anonymous client cannot SELECT sia_safety_events', async () => {
  const tenantId = await seedTenant('se-t4');
  const student  = await createTestUser(tenantId, 'student', 'se-t4-stu');
  const eventId  = await seedSafetyEvent(tenantId, student.userId);

  try {
    const anon = anonClient();

    const { data, error } = await anon
      .from('sia_safety_events')
      .select('id')
      .eq('id', eventId);
    assertCount('Anonymous client cannot read safety events', data, error, 0);

    console.log('PASS T4: anonymous access blocked from sia_safety_events');
  } finally {
    await deleteSafetyEvent(eventId);
    await deleteTestUser(student.userId);
    await deleteTenant(tenantId);
  }
});
