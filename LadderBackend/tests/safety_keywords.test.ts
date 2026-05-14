// LadderBackend/tests/safety_keywords.test.ts
//
// Unit tests for the word-boundary safety-keyword detection (S2 #3).
// Run with:
//   deno test --allow-env --allow-net LadderBackend/tests/safety_keywords.test.ts
//
// These tests do NOT require a running Supabase instance.

import { assertEquals } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { checkUserSafetySignals } from '../supabase/functions/ai-gateway/index.ts';

// ---------------------------------------------------------------------------
// False-positive cases — must NOT trigger a safety flag
// ---------------------------------------------------------------------------

Deno.test("false-positive: 'I want to die laughing' does NOT flag", () => {
  assertEquals(checkUserSafetySignals("I want to die laughing"), false);
});

Deno.test("false-positive: 'I'll kill myself if I see one more chem problem' does NOT flag", () => {
  assertEquals(checkUserSafetySignals("I'll kill myself if I see one more chem problem"), false);
});

// ---------------------------------------------------------------------------
// True-positive cases — must trigger a safety flag
// ---------------------------------------------------------------------------

Deno.test("true-positive: 'I want to die' flags", () => {
  assertEquals(checkUserSafetySignals("I want to die"), true);
});

Deno.test("true-positive: 'I want to kill myself' flags", () => {
  assertEquals(checkUserSafetySignals("I want to kill myself"), true);
});

// ---------------------------------------------------------------------------
// Additional boundary checks
// ---------------------------------------------------------------------------

Deno.test("case-insensitive: 'I Want To Die' flags", () => {
  assertEquals(checkUserSafetySignals("I Want To Die"), true);
});

Deno.test("phrase at end of sentence: 'things are bad, I want to die' flags", () => {
  assertEquals(checkUserSafetySignals("things are bad, I want to die"), true);
});

Deno.test("unrelated message does NOT flag", () => {
  assertEquals(checkUserSafetySignals("What AP classes should I take junior year?"), false);
});
