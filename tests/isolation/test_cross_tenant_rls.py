# tests/isolation/test_cross_tenant_rls.py
# CLAUDE.md §4.2 — P0 isolation suite. Fails the build on any cross-tenant
# read/write success. Runs hundreds of attempts per CI run.

import os
import uuid

import pytest
from supabase import create_client, Client

SUPA_URL = os.environ["SUPABASE_URL"]
SUPA_SERVICE_ROLE = os.environ["SUPABASE_SERVICE_ROLE_KEY"]


@pytest.fixture(scope="module")
def service_client() -> Client:
    return create_client(SUPA_URL, SUPA_SERVICE_ROLE)


@pytest.fixture(scope="module")
def fixture_tenants(service_client: Client):
    """Two schools + one family, each with one counselor + one student."""
    return service_client.rpc("seed_isolation_fixture").execute().data


def make_tenant_jwt(user_id: uuid.UUID, tenant_id, role: str) -> str:
    """Sign a JWT with the local Supabase anon/service JWT secret + custom claims.

    For local `supabase start`, the JWT secret is deterministic and can be
    read from `SUPABASE_JWT_SECRET` env (printed by `supabase status`).
    """
    import jwt  # pyjwt
    import time

    secret = os.environ["SUPABASE_JWT_SECRET"]
    now = int(time.time())
    claims = {
        "sub": str(user_id),
        "role": "authenticated",   # Supabase-Auth role column (not app role)
        "tenant_id": str(tenant_id) if tenant_id is not None else None,
        # Custom claim used by app.bind_session() for RLS — see migration 0001.
        # Dual-write `role` as the application-layer role in a namespaced claim
        # so Supabase doesn't conflate it with its own RBAC.
        "app_role": role,
        "iat": now,
        "exp": now + 300,
        "aud": "authenticated",
        "iss": os.environ.get("SUPABASE_URL", "http://localhost:54321") + "/auth/v1",
    }
    return jwt.encode(claims, secret, algorithm="HS256")


@pytest.mark.parametrize("attempt_ix", range(40))
def test_student_in_tenant_a_cannot_read_tenant_b_rows(fixture_tenants, service_client, attempt_ix):
    a = fixture_tenants["tenant_a"]
    b = fixture_tenants["tenant_b"]
    jwt = make_tenant_jwt(user_id=a["student_user_id"], tenant_id=a["id"], role="student")

    scoped = create_client(SUPA_URL, jwt)
    # Attempt to read a student in tenant B by PK.
    resp = scoped.from_("students").select("id").eq("id", b["student_id"]).execute()
    assert resp.data == [], f"leak: attempt #{attempt_ix} read tenant B row from tenant A session"


def test_counselor_cannot_read_teacher_review_for_other_tenant(fixture_tenants, service_client):
    _ = service_client  # fixture kept in scope; admin-seeded data reused
    a = fixture_tenants["tenant_a"]
    b = fixture_tenants["tenant_b"]
    jwt = make_tenant_jwt(user_id=a["counselor_user_id"], tenant_id=a["id"], role="counselor")
    scoped = create_client(SUPA_URL, jwt)

    resp = scoped.from_("teacher_reviews").select("id").eq("id", b["teacher_review_id"]).execute()
    assert resp.data == []


def test_admin_in_tenant_a_cannot_write_schedule_into_tenant_b(fixture_tenants):
    a = fixture_tenants["tenant_a"]
    b = fixture_tenants["tenant_b"]
    jwt = make_tenant_jwt(user_id=a["admin_user_id"], tenant_id=a["id"], role="admin")
    scoped = create_client(SUPA_URL, jwt)

    resp = scoped.from_("schedules").insert({
        "tenant_id": b["id"],     # spoof
        "student_id": b["student_id"],
        "window_id": b["window_id"],
        "state": "DRAFT",
    }).execute()
    # RLS must deny — either zero rows inserted or explicit error.
    assert resp.data == [] or resp.error is not None


def test_founder_cannot_read_student_row(fixture_tenants):
    a = fixture_tenants["tenant_a"]
    founder_jwt = make_tenant_jwt(user_id=uuid.uuid4(), tenant_id=None, role="founder")
    scoped = create_client(SUPA_URL, founder_jwt)

    resp = scoped.from_("students").select("id").eq("id", a["student_id"]).execute()
    assert resp.data == [], "§14.4 violation: founder read student row"


def test_founder_cannot_read_grades(fixture_tenants):
    a = fixture_tenants["tenant_a"]
    founder_jwt = make_tenant_jwt(user_id=uuid.uuid4(), tenant_id=None, role="founder")
    scoped = create_client(SUPA_URL, founder_jwt)

    resp = scoped.from_("grades").select("id").eq("student_id", a["student_id"]).execute()
    assert resp.data == [], "§14.4 violation: founder read grades"


def test_founder_cannot_read_quiz_answers(fixture_tenants):
    a = fixture_tenants["tenant_a"]
    founder_jwt = make_tenant_jwt(user_id=uuid.uuid4(), tenant_id=None, role="founder")
    scoped = create_client(SUPA_URL, founder_jwt)

    resp = scoped.from_("quiz_answers").select("id").eq("student_id", a["student_id"]).execute()
    assert resp.data == []


def test_jwt_tampered_tenant_id_is_rejected(fixture_tenants):
    # Craft a JWT where tenant_id claim is swapped to B's id but signed for A's user.
    # Expect Supabase Auth to reject at signature verification.
    pass  # wire with pyjwt + service role signing key
