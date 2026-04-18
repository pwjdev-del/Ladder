// tests/crypto/envelope.test.ts
// CLAUDE.md §16.2 + ADR-004 — per-tenant DEK envelope tests.

import { assertEquals, assertRejects } from 'https://deno.land/std@0.224.0/assert/mod.ts';
import { encryptField, decryptField } from '../../LadderBackend/crypto/envelope.ts';

Deno.test('envelope roundtrip: encrypt then decrypt yields identity', async () => {
  const dek = crypto.getRandomValues(new Uint8Array(32));
  const plaintext = 'student-grade-A-subject-math';
  const cipher = await encryptField(dek, plaintext);
  const roundTripped = await decryptField(dek, cipher);
  assertEquals(roundTripped, plaintext);
});

Deno.test('different DEKs produce different ciphertexts for same plaintext', async () => {
  const dekA = crypto.getRandomValues(new Uint8Array(32));
  const dekB = crypto.getRandomValues(new Uint8Array(32));
  const plaintext = 'private';
  const a = await encryptField(dekA, plaintext);
  const b = await encryptField(dekB, plaintext);
  assertEquals(a.length, b.length);
  // Different nonce + different key → different bytes.
  assertEquals(a.join(',') === b.join(','), false);
});

Deno.test('wrong DEK fails to decrypt', async () => {
  const dekA = crypto.getRandomValues(new Uint8Array(32));
  const dekB = crypto.getRandomValues(new Uint8Array(32));
  const cipher = await encryptField(dekA, 'secret');
  await assertRejects(async () => {
    await decryptField(dekB, cipher);
  });
});

Deno.test('ciphertext too short rejected', async () => {
  const dek = crypto.getRandomValues(new Uint8Array(32));
  await assertRejects(async () => {
    await decryptField(dek, new Uint8Array(5));
  });
});
