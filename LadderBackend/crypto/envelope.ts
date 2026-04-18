// LadderBackend/crypto/envelope.ts
// CLAUDE.md §16.2, ADR-004 — per-tenant DEK envelope encryption via AWS KMS.
//
// DEK lifecycle:
//   - Create: kms.GenerateDataKey on tenant provisioning. Store ciphertext in
//     tenants.dek_ciphertext. Plaintext returned once for initial row inserts.
//   - Cache: 5-minute LRU in Edge Function memory keyed by tenant_id. Never
//     persisted beyond memory.
//   - Rotate: annual cron. Generates DEK_v2, re-encrypts rows, flips
//     tenants.active_dek_version, keeps DEK_v1 for 90 days.
//   - Destroy: scheduled KMS key deletion on hard-delete (+30d waiting period).

import { KMSClient, DecryptCommand, GenerateDataKeyCommand } from 'npm:@aws-sdk/client-kms@3';

const KMS_KEY_ID = Deno.env.get('LADDER_KMS_CMK_ID')!;
const KMS_REGION = Deno.env.get('AWS_REGION') ?? 'us-east-1';
const DEK_CACHE_TTL_MS = 5 * 60 * 1000;

const kms = new KMSClient({ region: KMS_REGION });

interface DekCacheEntry {
  plaintext: Uint8Array;
  expiresAt: number;
}

const cache = new Map<string, DekCacheEntry>();

export interface TenantDek {
  plaintext: Uint8Array;
  ciphertext: Uint8Array;
}

export async function provisionTenantDEK(): Promise<TenantDek> {
  const resp = await kms.send(
    new GenerateDataKeyCommand({
      KeyId: KMS_KEY_ID,
      KeySpec: 'AES_256',
    }),
  );
  if (!resp.Plaintext || !resp.CiphertextBlob) throw new Error('KMS GenerateDataKey failed');
  return { plaintext: new Uint8Array(resp.Plaintext), ciphertext: new Uint8Array(resp.CiphertextBlob) };
}

export async function loadTenantDEK(tenantId: string, ciphertext: Uint8Array): Promise<Uint8Array> {
  const cached = cache.get(tenantId);
  if (cached && cached.expiresAt > Date.now()) return cached.plaintext;

  // Founder-session enforcement: the Edge Function runtime must assume the
  // ladder-app role (not ladder-founder) before calling this. KMS denies the
  // decrypt if the caller principal is tagged role=founder. See ADR-004.
  const resp = await kms.send(
    new DecryptCommand({
      KeyId: KMS_KEY_ID,
      CiphertextBlob: ciphertext,
    }),
  );
  if (!resp.Plaintext) throw new Error('KMS Decrypt returned empty plaintext');
  const plaintext = new Uint8Array(resp.Plaintext);
  cache.set(tenantId, { plaintext, expiresAt: Date.now() + DEK_CACHE_TTL_MS });
  return plaintext;
}

export function purgeDEKCache(): void {
  cache.clear();
}

// AES-GCM helpers. Nonce is 12 random bytes prefix; auth tag embedded.
export async function encryptField(dek: Uint8Array, plaintext: string): Promise<Uint8Array> {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const key = await crypto.subtle.importKey('raw', dek, { name: 'AES-GCM' }, false, ['encrypt']);
  const cipherBuf = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, new TextEncoder().encode(plaintext));
  const cipher = new Uint8Array(cipherBuf);
  const out = new Uint8Array(iv.length + cipher.length);
  out.set(iv, 0);
  out.set(cipher, iv.length);
  return out;
}

export async function decryptField(dek: Uint8Array, blob: Uint8Array): Promise<string> {
  if (blob.length < 13) throw new Error('ciphertext too short');
  const iv = blob.slice(0, 12);
  const cipher = blob.slice(12);
  const key = await crypto.subtle.importKey('raw', dek, { name: 'AES-GCM' }, false, ['decrypt']);
  const plainBuf = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, key, cipher);
  return new TextDecoder().decode(plainBuf);
}
