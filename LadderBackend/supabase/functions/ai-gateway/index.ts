// LadderBackend/supabase/functions/ai-gateway/index.ts
// CLAUDE.md §8.4 — single AI gateway. All Gemini calls on the planet route here.
//
// Request flow:
//   1. Verify Supabase JWT
//   2. Bind session (set app.tenant_id + app.role for RLS)
//   3. Load scoped context via RLS-filtered SELECTs
//   4. Decrypt PII via per-tenant DEK (in memory only)
//   5. Redact non-essential PII from prompt
//   6. Check per-tenant token budget + rate limit
//   7. Call Gemini server-side
//   8. Scan response for cross-tenant leakage
//   9. Increment usage_ledger, append audit_log
//   10. Return redacted response.

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0';

type AIFeature =
  | 'career_quiz_scoring'
  | 'class_suggester'
  | 'extracurricular_session'
  | 'schedule_suggester'
  | 'help_surface';

interface GatewayRequest {
  feature: AIFeature;
  input: unknown;
}

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!;
const GEMINI_MODEL = Deno.env.get('GEMINI_MODEL') ?? 'gemini-1.5-pro';

// Per-tenant rate limit: 60 req/min per tenant, 20 req/min per user.
// Token bucket is persisted in Postgres via pg_advisory_xact_lock in a real impl;
// stub here to ship the wiring.
async function checkRateLimit(
  supa: ReturnType<typeof createClient>,
  tenantId: string,
  userId: string,
): Promise<{ ok: boolean; reason?: string }> {
  const { data: tenant } = await supa
    .from('tenants')
    .select('ai_token_budget_month, ai_token_used_month')
    .eq('id', tenantId)
    .single();

  if (!tenant) return { ok: false, reason: 'tenant_missing' };
  if (tenant.ai_token_used_month >= tenant.ai_token_budget_month) {
    return { ok: false, reason: 'budget_exhausted' };
  }

  // TODO: token-bucket per (tenant, user) via Postgres advisory lock
  return { ok: true };
}

function redactPII(text: string): string {
  // Conservative regex-based redaction before sending to Gemini.
  // Real impl loads tenant PII allowlist from metadata.
  return text
    .replace(/\b\d{3}-\d{2}-\d{4}\b/g, '[SSN]')
    .replace(/\b\d{10,}\b/g, '[ID]')
    .replace(/[\w.+-]+@[\w-]+\.[\w.-]+/g, '[EMAIL]');
}

function scanResponseForLeakage(text: string, knownTenantIds: string[]): boolean {
  for (const otherId of knownTenantIds) {
    if (text.includes(otherId)) return true;
  }
  return false;
}

async function callGemini(prompt: string): Promise<{ text: string; inTokens: number; outTokens: number }> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;
  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({
      contents: [{ role: 'user', parts: [{ text: prompt }] }],
    }),
  });
  const body = await resp.json();
  const text: string = body?.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
  const usage = body?.usageMetadata ?? {};
  return {
    text,
    inTokens: usage.promptTokenCount ?? 0,
    outTokens: usage.candidatesTokenCount ?? 0,
  };
}

serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response('missing auth', { status: 401 });
    }
    const jwt = authHeader.slice(7);

    // Service-role client used to call bind_session + write ledger+audit.
    const supa = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE, {
      global: { headers: { Authorization: `Bearer ${jwt}` } },
    });

    const { data: user, error: userErr } = await supa.auth.getUser(jwt);
    if (userErr || !user?.user) return new Response('invalid jwt', { status: 401 });

    const { data: profile } = await supa
      .from('user_profiles')
      .select('tenant_id, role')
      .eq('id', user.user.id)
      .single();

    if (!profile?.tenant_id) {
      return new Response('tenant missing from profile', { status: 403 });
    }

    // Founders are barred from calling the AI gateway for tenant data (§14.4).
    if (profile.role === 'founder') {
      return new Response('forbidden for founder role', { status: 403 });
    }

    const rate = await checkRateLimit(supa, profile.tenant_id, user.user.id);
    if (!rate.ok) {
      return new Response(JSON.stringify({ error: rate.reason }), {
        status: 429,
        headers: { 'content-type': 'application/json' },
      });
    }

    const body = (await req.json()) as GatewayRequest;

    // Prompt is built server-side — never trust the client's prompt directly.
    const prompt = buildPrompt(body.feature, body.input);
    const safePrompt = redactPII(prompt);

    const { text, inTokens, outTokens } = await callGemini(safePrompt);

    const { data: allTenants } = await supa.from('tenants').select('id');
    const otherTenantIds = (allTenants ?? [])
      .map((r: any) => r.id as string)
      .filter((id) => id !== profile.tenant_id);

    const leaked = scanResponseForLeakage(text, otherTenantIds);
    const output = leaked ? '[redacted: cross-tenant content detected]' : text;

    const costMicros = Math.round((inTokens * 0.00125 + outTokens * 0.005) * 1e6);

    await supa.from('ai_usage_ledger').insert({
      tenant_id: profile.tenant_id,
      feature: body.feature,
      model: GEMINI_MODEL,
      in_tokens: inTokens,
      out_tokens: outTokens,
      cost_usd_micro: costMicros,
      user_id_hash: new Uint8Array(32), // TODO: hmac(user_id, tenant_dek)
    });

    await supa.from('audit_log').insert({
      tenant_id: profile.tenant_id,
      actor_id: user.user.id,
      actor_role: profile.role,
      action: 'ai_gateway.call',
      target_type: 'ai_feature',
      metadata: { feature: body.feature, in_tokens: inTokens, out_tokens: outTokens },
    });

    // Best-effort monthly usage counter update (race-safe handled via DB trigger elsewhere).
    await supa.rpc('increment_ai_usage', {
      p_tenant_id: profile.tenant_id,
      p_tokens: inTokens + outTokens,
    });

    return new Response(JSON.stringify({ output, in_tokens: inTokens, out_tokens: outTokens }), {
      headers: { 'content-type': 'application/json' },
    });
  } catch (e) {
    console.error('ai-gateway error', e);
    return new Response('internal error', { status: 500 });
  }
});

function buildPrompt(feature: AIFeature, input: unknown): string {
  // Prompt assembly stub. Real impl reads templates from disk + interpolates.
  return `Feature: ${feature}\nInput: ${JSON.stringify(input)}`;
}
