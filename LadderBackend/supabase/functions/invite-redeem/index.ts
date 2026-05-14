// Invite redemption: HMAC-SHA256(code, INVITE_HMAC_SECRET) compared to bytea code_hash via RPC. See migration 0021.

// LadderBackend/supabase/functions/invite-redeem/index.ts
// §6.1 B2B and §6.2 B2C parent invite code redemption.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

interface RedeemRequest {
  code: string;
  email?: string;
  intended_student_id?: string;
}

// Shape of the invite_codes row returned by find_invite_by_hash().
// Mirrors the table definition in migration 0004 / 0018.
interface InviteRow {
  id: string;
  tenant_id: string;
  kind: string;
  code_hash: string;
  code_prefix: string;
  created_by: string;
  intended_email: string | null;
  intended_student_id: string | null;
  allowed_email_domain: string | null;
  expected_grade_level: number | null;
  max_uses: number;
  uses: number;
  expires_at: string | null;
  revoked_at: string | null;
  created_at: string;
}

// HMAC-SHA256 with a per-deployment secret. Phase 8 Security Audit recommended
// this over plain SHA-256 so scraped invite_codes rows are not rainbow-tableable.
// The secret lives in Supabase Edge Function env (INVITE_HMAC_SECRET); it must
// also be configured in Postgres as:
//   ALTER DATABASE postgres SET app.invite_hmac_secret = '<same-value>';
// so that the app.invite_hmac() DB function and this edge function agree.
// Rotate annually alongside the tenant DEK.
async function hmacCode(input: string): Promise<string> {
  const secret = Deno.env.get('INVITE_HMAC_SECRET') ?? '';
  if (!secret) throw new Error('INVITE_HMAC_SECRET not configured');
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign'],
  );
  const sig = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(input));
  // B-02 fix: return bare hex string (no \x prefix) so app.find_invite_by_hash()
  // can call decode(p_hex, 'hex') directly. Avoids supabase-js Uint8Array →
  // JSON object serialisation when passed to .eq().
  return Array.from(new Uint8Array(sig))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

// Uniform failure response — do not disclose whether the code is unknown,
// expired, revoked, or over max-uses.
function uniformFailure(): Response {
  return new Response(JSON.stringify({ error: 'invite_invalid' }), {
    status: 400,
    headers: { 'content-type': 'application/json' },
  });
}

serve(async (req) => {
  if (req.method !== 'POST') return new Response('method not allowed', { status: 405 });

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) return new Response('missing auth', { status: 401 });
    const jwt = authHeader.slice(7);

    const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE);
    const { data: userRes } = await supa.auth.getUser(jwt);
    if (!userRes?.user) return new Response('invalid jwt', { status: 401 });
    const user = userRes.user;

    const body = (await req.json()) as RedeemRequest;

    // B-01 fix: hmacCode() returns hex; DB side now also stores HMAC-SHA256
    // (via app.invite_hmac()) since migration 0021. Previously the DB stored
    // plain digest(code, 'sha256') which never matched.
    const codeHex = await hmacCode(body.code);

    // B-02 fix: use app.find_invite_by_hash() RPC instead of .eq('code_hash', ...)
    // with a raw Uint8Array. supabase-js serialises Uint8Array to {"0":...,"1":...}
    // JSON which PostgREST cannot match to a bytea column. The RPC accepts a bare
    // hex string and calls decode(p_hex, 'hex') inside Postgres, which is reliable.
    // find_invite_by_hash lives in public schema, so no schema override needed.
    // Type-assert to InviteRow: supabase-js v2 rpc() is typed against generated
    // DB types which aren't present here; the function signature is stable.
    const { data: inviteRaw, error: rpcError } = await supa
      .rpc('find_invite_by_hash', { p_hex: codeHex })
      .single();
    const invite = inviteRaw as InviteRow | null;

    // All failure paths return the SAME error to deny the oracle. Audit details
    // go into the log (server-side) but never to the caller (§16).
    if (rpcError || invite === null) {
      await supa.from('audit_log').insert({
        actor_id: user.id,
        action: 'invite.redeem_failed',
        metadata: { reason: 'unknown_code_hash' },
      });
      return uniformFailure();
    }
    if (invite.revoked_at) {
      await supa.from('audit_log').insert({ tenant_id: invite.tenant_id, actor_id: user.id, action: 'invite.redeem_failed', metadata: { reason: 'revoked' } });
      return uniformFailure();
    }
    if (invite.expires_at && new Date(invite.expires_at) < new Date()) {
      await supa.from('audit_log').insert({ tenant_id: invite.tenant_id, actor_id: user.id, action: 'invite.redeem_failed', metadata: { reason: 'expired' } });
      return uniformFailure();
    }
    if (invite.uses >= invite.max_uses) {
      await supa.from('audit_log').insert({ tenant_id: invite.tenant_id, actor_id: user.id, action: 'invite.redeem_failed', metadata: { reason: 'max_uses' } });
      return uniformFailure();
    }
    if (invite.allowed_email_domain && body.email) {
      if (!body.email.toLowerCase().endsWith('@' + invite.allowed_email_domain.toLowerCase())) {
        await supa.from('audit_log').insert({ tenant_id: invite.tenant_id, actor_id: user.id, action: 'invite.redeem_failed', metadata: { reason: 'email_domain' } });
        return uniformFailure();
      }
    }

    // Derive the application role from invite kind.
    // The invite_codes table has no separate `role` column — kind is the source
    // of truth. b2c_parent → 'parent'; any B2B kind → 'student'.
    const resolvedRole: string = invite.kind === 'b2c_parent' ? 'parent' : 'student';

    // SECURITY: all three writes below use the service_role client (supa).
    // The caller's JWT is used only for identity verification (getUser above).
    // role + tenant_id are NEVER accepted from the request body — they come
    // exclusively from the invite_codes row fetched server-side.

    // 1. Stamp JWT app_metadata so the iOS app can read role + tenant_id from
    //    the claim without a round-trip to user_profiles.
    //    auth.admin.updateUserById requires service_role — never exposed to clients.
    const { error: metaErr } = await supa.auth.admin.updateUserById(user.id, {
      app_metadata: {
        role: resolvedRole,
        tenant_id: invite.tenant_id,
      },
    });
    if (metaErr) {
      console.error('invite-redeem: failed to stamp app_metadata', metaErr);
      // Hard fail — without the JWT claim the iOS app will throw missingRoleClaim.
      return new Response('internal error', { status: 500 });
    }

    // 2. Bind the caller's user_profile to this tenant (table-level RLS source).
    await supa
      .from('user_profiles')
      .upsert({
        id: user.id,
        tenant_id: invite.tenant_id,
        role: resolvedRole,
        email: user.email,
      });

    // 3. Increment invite use counter.
    await supa.from('invite_codes').update({ uses: invite.uses + 1 }).eq('id', invite.id);

    await supa.from('audit_log').insert({
      tenant_id: invite.tenant_id,
      actor_id: user.id,
      action: 'invite.redeemed',
      target_type: 'invite_code',
      target_id: invite.id,
      metadata: { kind: invite.kind },
    });

    return new Response(JSON.stringify({ ok: true, tenant_id: invite.tenant_id, role: resolvedRole }), {
      headers: { 'content-type': 'application/json' },
    });
  } catch (e) {
    console.error('invite-redeem error', e);
    return new Response('internal error', { status: 500 });
  }
});
