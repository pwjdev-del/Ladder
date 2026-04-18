// LadderBackend/supabase/functions/invite-redeem/index.ts
// §6.1 B2B and §6.2 B2C parent invite code redemption.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';
import { crypto as stdCrypto } from 'https://deno.land/std@0.224.0/crypto/mod.ts';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

interface RedeemRequest {
  code: string;
  email?: string;
  intended_student_id?: string;
}

async function sha256(input: string): Promise<Uint8Array> {
  const data = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest('SHA-256', data);
  return new Uint8Array(digest);
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
    const codeHash = await sha256(body.code);

    const { data: invite } = await supa
      .from('invite_codes')
      .select('*')
      .eq('code_hash', codeHash)
      .single();

    if (!invite) {
      await supa.from('audit_log').insert({
        actor_id: user.id,
        action: 'invite.redeem_failed',
        metadata: { reason: 'unknown_code_hash' },
      });
      return new Response(JSON.stringify({ error: 'invite_invalid' }), { status: 404 });
    }

    if (invite.revoked_at) return new Response(JSON.stringify({ error: 'revoked' }), { status: 410 });
    if (invite.expires_at && new Date(invite.expires_at) < new Date()) {
      return new Response(JSON.stringify({ error: 'expired' }), { status: 410 });
    }
    if (invite.uses >= invite.max_uses) {
      return new Response(JSON.stringify({ error: 'max_uses_reached' }), { status: 410 });
    }
    if (invite.allowed_email_domain && body.email) {
      if (!body.email.toLowerCase().endsWith('@' + invite.allowed_email_domain.toLowerCase())) {
        return new Response(JSON.stringify({ error: 'email_domain_mismatch' }), { status: 403 });
      }
    }

    // Bind the caller's user_profile to this tenant.
    await supa
      .from('user_profiles')
      .upsert({
        id: user.id,
        tenant_id: invite.tenant_id,
        role: invite.kind === 'b2c_parent' ? 'parent' : 'student',
        email: user.email,
      });

    await supa.from('invite_codes').update({ uses: invite.uses + 1 }).eq('id', invite.id);

    await supa.from('audit_log').insert({
      tenant_id: invite.tenant_id,
      actor_id: user.id,
      action: 'invite.redeemed',
      target_type: 'invite_code',
      target_id: invite.id,
      metadata: { kind: invite.kind },
    });

    return new Response(JSON.stringify({ ok: true, tenant_id: invite.tenant_id, role: invite.kind === 'b2c_parent' ? 'parent' : 'student' }), {
      headers: { 'content-type': 'application/json' },
    });
  } catch (e) {
    console.error('invite-redeem error', e);
    return new Response('internal error', { status: 500 });
  }
});
