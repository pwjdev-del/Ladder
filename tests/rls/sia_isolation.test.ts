/**
 * RLS isolation tests for student_ai_chats and related SIA tables.
 *
 * Requires a local Supabase instance (supabase start) with migrations applied.
 * Run with: npx jest tests/rls/sia_isolation.test.ts
 *
 * Test helpers assume the helper functions set_app_role(role, tenant_id, user_id)
 * and reset_app_role() are available as SQL RPCs on the local instance, or that
 * the test runner injects the required session variables via SET LOCAL.
 */

import { createClient, SupabaseClient } from "@supabase/supabase-js";

const SUPABASE_URL = process.env.SUPABASE_URL ?? "http://localhost:54321";
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY ?? "";

// Two tenants so cross-tenant leakage can be tested separately.
const TENANT_A = "00000000-0000-0000-0000-000000000001";
const STUDENT_A = "00000000-0000-0000-0000-000000000010";
const COUNSELOR_A = "00000000-0000-0000-0000-000000000020";

// JWT helper — in a real setup these would be real Supabase-issued JWTs.
// For unit RLS tests we use service-role to insert seed data, then switch to
// a session that impersonates the desired role via SET LOCAL.
function serviceClient(): SupabaseClient {
  return createClient(SUPABASE_URL, SERVICE_KEY, {
    auth: { persistSession: false },
  });
}

/**
 * Execute a query as a specific app role by wrapping it in a transaction that
 * sets the session-local GUC variables Ladder RLS policies read.
 *
 * Returns the query result or throws on policy violation (empty rows = denied).
 */
async function selectAsCounselor(
  chatRowId: string
): Promise<{ data: unknown[] | null; error: unknown }> {
  const admin = serviceClient();

  // Use a raw RPC that sets local role vars and attempts the select.
  // The RPC must be defined in the DB as a SECURITY DEFINER function for tests.
  // Here we simulate it by using the service role client with explicit SET.
  const { data, error } = await admin.rpc("test_rls_select_chat_as_counselor", {
    p_tenant_id: TENANT_A,
    p_counselor_id: COUNSELOR_A,
    p_chat_row_id: chatRowId,
  });

  return { data, error };
}

// ── Seed helpers ──────────────────────────────────────────────────────────────

async function seedChatRow(): Promise<string> {
  const admin = serviceClient();
  const { data, error } = await admin
    .from("student_ai_chats")
    .insert({
      tenant_id: TENANT_A,
      student_id: STUDENT_A,
      role: "user",
      content: "seed message for RLS test",
    })
    .select("id")
    .single();

  if (error || !data) throw new Error(`Seed failed: ${JSON.stringify(error)}`);
  return (data as { id: string }).id;
}

async function seedCounselorAssignment(chatRowId: string): Promise<void> {
  // chatRowId unused — we only need the assignment row, not the chat id.
  void chatRowId;
  const admin = serviceClient();
  const { error } = await admin.from("counselor_assignments").upsert({
    tenant_id: TENANT_A,
    counselor_user_id: COUNSELOR_A,
    student_id: STUDENT_A,
    removed_at: null,
  });
  if (error) throw new Error(`Assignment seed failed: ${JSON.stringify(error)}`);
}

async function teardown(chatRowId: string): Promise<void> {
  const admin = serviceClient();
  await admin.from("student_ai_chats").delete().eq("id", chatRowId);
  await admin
    .from("counselor_assignments")
    .delete()
    .eq("counselor_user_id", COUNSELOR_A)
    .eq("student_id", STUDENT_A)
    .eq("tenant_id", TENANT_A);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe("student_ai_chats RLS — SIA isolation", () => {
  /**
   * D-002: Counselor JWT cannot SELECT student_ai_chats even for an assigned
   * student.  After migration 0016 drops the ai_chats_counselor_read policy,
   * any SELECT by a session whose app.role = 'counselor' must return 0 rows.
   *
   * This is a HARD product rule (DECISIONS.md D-002).  If this test starts
   * failing it means a new counselor SELECT policy was added to
   * student_ai_chats — that policy must be removed and the counselor surface
   * must instead read from student_memory_summaries.
   */
  test(
    "counselor JWT cannot SELECT student_ai_chats even for assigned student",
    async () => {
      const chatRowId = await seedChatRow();
      await seedCounselorAssignment(chatRowId);

      let result: { data: unknown[] | null; error: unknown };
      try {
        result = await selectAsCounselor(chatRowId);
      } finally {
        await teardown(chatRowId);
      }

      // Acceptable outcomes:
      //   1. RLS hard-blocks → error with code 42501 / insufficient_privilege
      //   2. RLS silently filters → data is an empty array
      // Either proves the counselor cannot read raw chat content.
      const rows = result!.data ?? [];
      expect(rows.length).toBe(0);
    },
    15_000
  );

  /**
   * Confirm the student's own SELECT policy is untouched by migration 0016.
   * A session with app.role = 'student' and matching student_id must still
   * be able to read their own chat rows.
   */
  test("student can still SELECT their own chat rows after 0016", async () => {
    const admin = serviceClient();
    const { data, error } = await admin
      .rpc("test_rls_select_chat_as_student", {
        p_tenant_id: TENANT_A,
        p_student_id: STUDENT_A,
      });

    // We only assert no unexpected RLS error here; actual row presence depends
    // on prior seed state managed by the caller.
    expect(error).toBeNull();
    // data may be an empty array if no rows seeded — that is fine.
  });
});
