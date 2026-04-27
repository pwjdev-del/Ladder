#!/usr/bin/env bash
# scripts/seed-test-users.sh
#
# Creates five test users (one per Ladder role) in the live Supabase project.
# Safe to re-run — existing users are detected via the Admin API and skipped.
#
# Prerequisites:
#   - bash 4+ or zsh
#   - curl (ships with macOS)
#   - jq  (brew install jq)
#   - SUPABASE_SERVICE_ROLE_KEY filled in .env at the repo root
#
# Usage:
#   cd /path/to/LadderApp
#   bash scripts/seed-test-users.sh
#
# Docs: see docs/test-credentials.md for what each account unlocks.

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Locate repo root + load .env
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "ERROR: ${ENV_FILE} not found."
  echo "       Copy .env.example to .env and fill in SUPABASE_SERVICE_ROLE_KEY."
  exit 1
fi

# Source only the keys we need; shellcheck-safe because the file is local.
# shellcheck disable=SC1090
source "${ENV_FILE}"

SUPABASE_URL="${SUPABASE_URL:-}"
SUPABASE_SERVICE_ROLE_KEY="${SUPABASE_SERVICE_ROLE_KEY:-}"

if [[ -z "${SUPABASE_URL}" ]]; then
  echo "ERROR: SUPABASE_URL is empty in .env"
  exit 1
fi

if [[ -z "${SUPABASE_SERVICE_ROLE_KEY}" ]]; then
  echo "ERROR: SUPABASE_SERVICE_ROLE_KEY is empty in .env"
  echo "       Find it in your Supabase dashboard → Settings → API → service_role."
  exit 1
fi

# Reject accidental prod runs — the project ref must match the known test ref.
EXPECTED_REF="seicofzlgwjqkggscvao"
ACTUAL_REF="$(echo "${SUPABASE_URL}" | sed 's|https://||' | sed 's|\.supabase\.co.*||')"
if [[ "${ACTUAL_REF}" != "${EXPECTED_REF}" ]]; then
  echo "ERROR: SUPABASE_URL points to project '${ACTUAL_REF}', not the expected test"
  echo "       project '${EXPECTED_REF}'. Aborting to protect a non-test project."
  exit 1
fi

# Dependency check
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is not installed. Run: brew install jq"
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Shared constants
# ---------------------------------------------------------------------------

AUTH_ADMIN_URL="${SUPABASE_URL}/auth/v1/admin/users"
REST_URL="${SUPABASE_URL}/rest/v1"
PASSWORD="LadderTest123!"

# School tenant fixed ID — deterministic UUID so idempotent re-runs find it.
SCHOOL_TENANT_ID="10000000-0000-0000-0000-000000000001"
# B2C family tenant fixed ID
FAMILY_TENANT_ID="10000000-0000-0000-0000-000000000002"

# ---------------------------------------------------------------------------
# 2. Helper functions
# ---------------------------------------------------------------------------

# Print a separator line to stdout.
hr() { printf '%s\n' "------------------------------------------------------------"; }

# Curl wrapper that surfaces HTTP errors clearly.
# Usage: api_call METHOD URL BODY_JSON
# Returns the response body. Exits non-zero on curl failure.
api_call() {
  local method="$1" url="$2" body="$3"
  curl --silent --show-error --fail-with-body \
    --request "${method}" \
    --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "Content-Type: application/json" \
    --header "Prefer: return=representation" \
    --data "${body}" \
    "${url}"
}

# Look up an auth user by email via the Admin API list endpoint.
# Returns the user's UUID, or empty string if not found.
# Exits with a clear message if the key is invalid (HTTP 401/403).
find_user_by_email() {
  local email="$1"
  local response http_code

  # The Admin API lists up to 1000 users; for a seed script this is fine.
  response=$(curl --silent --write-out '\n__HTTP_STATUS__%{http_code}' \
    --request GET \
    --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    "${AUTH_ADMIN_URL}?page=1&per_page=1000") || {
    echo "ERROR: curl failed when listing auth users. Check your network."
    exit 1
  }

  http_code=$(echo "${response}" | tail -n1 | sed 's/__HTTP_STATUS__//')
  response=$(echo "${response}" | head -n -1)

  if [[ "${http_code}" == "401" || "${http_code}" == "403" ]]; then
    echo "ERROR: SUPABASE_SERVICE_ROLE_KEY is invalid or expired (HTTP ${http_code})."
    echo "       Regenerate it in Supabase dashboard → Settings → API → service_role."
    exit 1
  fi

  echo "${response}" | jq -r --arg email "${email}" \
    '.users[] | select(.email == $email) | .id' 2>/dev/null || true
}

# Create an auth user. Returns UUID on success.
# Caller passes: email, display_name, role, tenant_id_or_null
create_auth_user() {
  local email="$1" display_name="$2" role="$3" tenant_id="$4"

  local meta_obj
  if [[ "${tenant_id}" == "null" ]]; then
    meta_obj="{\"role\": \"${role}\"}"
  else
    meta_obj="{\"role\": \"${role}\", \"tenant_id\": \"${tenant_id}\"}"
  fi

  local body
  body=$(jq -n \
    --arg email "${email}" \
    --arg password "${PASSWORD}" \
    --arg display_name "${display_name}" \
    --argjson meta "${meta_obj}" \
    '{
      email: $email,
      password: $password,
      email_confirm: true,
      app_metadata: $meta,
      user_metadata: { display_name: $display_name }
    }')

  local response
  response=$(curl --silent --show-error \
    --request POST \
    --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "Content-Type: application/json" \
    "${AUTH_ADMIN_URL}" \
    --data "${body}") || {
    echo "ERROR: curl failed creating auth user ${email}"
    exit 1
  }

  # Check for error in response body
  local err_msg
  err_msg=$(echo "${response}" | jq -r '.msg // .message // ""' 2>/dev/null || true)
  if [[ -n "${err_msg}" && "${err_msg}" != "null" ]]; then
    echo "ERROR: Supabase returned an error for ${email}: ${err_msg}"
    exit 1
  fi

  echo "${response}" | jq -r '.id'
}

# Upsert a row via PostgREST. Uses Prefer: resolution=ignore-duplicates for idempotency.
upsert_row() {
  local table="$1" body="$2"
  curl --silent --show-error \
    --request POST \
    --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
    --header "Content-Type: application/json" \
    --header "Prefer: resolution=ignore-duplicates,return=minimal" \
    --data "${body}" \
    "${REST_URL}/${table}" >/dev/null || {
    echo "ERROR: upsert failed for table ${table}"
    exit 1
  }
}

# ---------------------------------------------------------------------------
# 3. Ensure tenants exist
# ---------------------------------------------------------------------------

hr
echo "Step 1 of 7: Ensuring school tenant exists..."

SCHOOL_BODY=$(jq -n \
  --arg id "${SCHOOL_TENANT_ID}" \
  '{
    id: $id,
    type: "school",
    slug: "test-springs-high",
    display_name: "Test Springs High School",
    primary_color_hex: "#1D4E89",
    plan: "pilot"
  }')

# Use ignore-duplicates so re-runs skip gracefully
curl --silent --show-error \
  --request POST \
  --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "Content-Type: application/json" \
  --header "Prefer: resolution=ignore-duplicates,return=minimal" \
  --data "${SCHOOL_BODY}" \
  "${REST_URL}/tenants" >/dev/null
echo "  School tenant: Test Springs High School (${SCHOOL_TENANT_ID})"

echo "Step 1b: Ensuring B2C family tenant exists..."
FAMILY_BODY=$(jq -n \
  --arg id "${FAMILY_TENANT_ID}" \
  '{
    id: $id,
    type: "family",
    slug: "test-family",
    display_name: "Test Family",
    plan: "free"
  }')

curl --silent --show-error \
  --request POST \
  --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "Content-Type: application/json" \
  --header "Prefer: resolution=ignore-duplicates,return=minimal" \
  --data "${FAMILY_BODY}" \
  "${REST_URL}/tenants" >/dev/null
echo "  B2C family tenant: Test Family (${FAMILY_TENANT_ID})"

# ---------------------------------------------------------------------------
# 4. Create / detect each auth user
# ---------------------------------------------------------------------------

hr
echo "Step 2 of 7: Creating auth users (skipping any that already exist)..."

# ---- student.test ----
STUDENT_EMAIL="student.test@ladder.dev"
STUDENT_ID=$(find_user_by_email "${STUDENT_EMAIL}")
if [[ -n "${STUDENT_ID}" ]]; then
  echo "  [SKIP] ${STUDENT_EMAIL} already exists (${STUDENT_ID})"
else
  STUDENT_ID=$(create_auth_user "${STUDENT_EMAIL}" "Student Test" "student" "${FAMILY_TENANT_ID}")
  echo "  [OK]   ${STUDENT_EMAIL} created (${STUDENT_ID})"
fi

# ---- parent.test ----
PARENT_EMAIL="parent.test@ladder.dev"
PARENT_ID=$(find_user_by_email "${PARENT_EMAIL}")
if [[ -n "${PARENT_ID}" ]]; then
  echo "  [SKIP] ${PARENT_EMAIL} already exists (${PARENT_ID})"
else
  PARENT_ID=$(create_auth_user "${PARENT_EMAIL}" "Parent Test" "parent" "${FAMILY_TENANT_ID}")
  echo "  [OK]   ${PARENT_EMAIL} created (${PARENT_ID})"
fi

# ---- counselor.test ----
COUNSELOR_EMAIL="counselor.test@ladder.dev"
COUNSELOR_ID=$(find_user_by_email "${COUNSELOR_EMAIL}")
if [[ -n "${COUNSELOR_ID}" ]]; then
  echo "  [SKIP] ${COUNSELOR_EMAIL} already exists (${COUNSELOR_ID})"
else
  COUNSELOR_ID=$(create_auth_user "${COUNSELOR_EMAIL}" "Counselor Test" "counselor" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${COUNSELOR_EMAIL} created (${COUNSELOR_ID})"
fi

# ---- admin.test ----
ADMIN_EMAIL="admin.test@ladder.dev"
ADMIN_ID=$(find_user_by_email "${ADMIN_EMAIL}")
if [[ -n "${ADMIN_ID}" ]]; then
  echo "  [SKIP] ${ADMIN_EMAIL} already exists (${ADMIN_ID})"
else
  ADMIN_ID=$(create_auth_user "${ADMIN_EMAIL}" "Admin Test" "admin" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${ADMIN_EMAIL} created (${ADMIN_ID})"
fi

# ---- founder.test ----
# The FounderLoginView converts "Founder ID" to {id.lowercased()}@ladder.internal
# so this user's email must use the @ladder.internal domain.
FOUNDER_EMAIL="founder.test@ladder.internal"
FOUNDER_ID=$(find_user_by_email "${FOUNDER_EMAIL}")
if [[ -n "${FOUNDER_ID}" ]]; then
  echo "  [SKIP] ${FOUNDER_EMAIL} already exists (${FOUNDER_ID})"
else
  FOUNDER_ID=$(create_auth_user "${FOUNDER_EMAIL}" "Founder Test" "founder" "null")
  echo "  [OK]   ${FOUNDER_EMAIL} created (${FOUNDER_ID})"
fi

# ---------------------------------------------------------------------------
# 5. user_profiles rows
# ---------------------------------------------------------------------------

hr
echo "Step 3 of 7: Upserting user_profiles rows..."

upsert_row "user_profiles" "$(jq -n \
  --arg id "${STUDENT_ID}" \
  --arg tid "${FAMILY_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "student", display_name: "Student Test", email: "student.test@ladder.dev" }')"
echo "  [OK] user_profiles: student"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${PARENT_ID}" \
  --arg tid "${FAMILY_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "parent", display_name: "Parent Test", email: "parent.test@ladder.dev" }')"
echo "  [OK] user_profiles: parent"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${COUNSELOR_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "counselor", display_name: "Counselor Test", email: "counselor.test@ladder.dev" }')"
echo "  [OK] user_profiles: counselor"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${ADMIN_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "admin", display_name: "Admin Test", email: "admin.test@ladder.dev" }')"
echo "  [OK] user_profiles: admin"

# Founders have tenant_id = null (enforced by DB constraint founder_has_no_tenant)
upsert_row "user_profiles" "$(jq -n \
  --arg id "${FOUNDER_ID}" \
  '{ id: $id, role: "founder", display_name: "Founder Test", email: "founder.test@ladder.internal" }')"
echo "  [OK] user_profiles: founder"

# ---------------------------------------------------------------------------
# 6. students row for student.test
# ---------------------------------------------------------------------------

hr
echo "Step 4 of 7: Upserting students row for student.test (grade 11)..."

# Fixed deterministic student-row ID for idempotency
STUDENT_ROW_ID="20000000-0000-0000-0000-000000000001"

upsert_row "students" "$(jq -n \
  --arg id "${STUDENT_ROW_ID}" \
  --arg uid "${STUDENT_ID}" \
  --arg tid "${FAMILY_TENANT_ID}" \
  '{ id: $id, user_id: $uid, tenant_id: $tid, grade_level: 11 }')"
echo "  [OK] students row: grade_level=11, id=${STUDENT_ROW_ID}"

# ---------------------------------------------------------------------------
# 7. parent_links row
# ---------------------------------------------------------------------------

hr
echo "Step 5 of 7: Upserting parent_links row (parent.test -> student.test)..."

upsert_row "parent_links" "$(jq -n \
  --arg puid "${PARENT_ID}" \
  --arg sid "${STUDENT_ROW_ID}" \
  --arg tid "${FAMILY_TENANT_ID}" \
  '{ parent_user_id: $puid, student_id: $sid, tenant_id: $tid, relationship: "parent", status: "active" }')"
echo "  [OK] parent_links: parent.test -> student.test (active)"

# ---------------------------------------------------------------------------
# 8. counselor_assignments row (migration 0009 schema)
# ---------------------------------------------------------------------------

hr
echo "Step 6 of 7: Upserting counselor_assignments row (counselor.test -> student.test)..."

# counselor_assignments.student_id is an FK to students.id (not auth.users.id)
# student.test is a B2C user and counselor.test is school-tenant, so this is a
# cross-tenant assignment. In production this would not occur; for test coverage
# it verifies the counselor RLS path. A school student row would be needed for
# a fully realistic assignment — this uses the B2C student row as a placeholder
# since the DB FK only requires the row to exist in `students`.
#
# NOTE: if the DB rejects this due to a tenant_id mismatch FK, create a school
# student row first and update SCHOOL_STUDENT_ROW_ID below.
upsert_row "counselor_assignments" "$(jq -n \
  --arg tid "${SCHOOL_TENANT_ID}" \
  --arg cuid "${COUNSELOR_ID}" \
  --arg sid "${STUDENT_ROW_ID}" \
  '{ tenant_id: $tid, counselor_user_id: $cuid, student_id: $sid }')"
echo "  [OK] counselor_assignments: counselor.test -> student.test"

# ---------------------------------------------------------------------------
# 9. founder_users row + TOTP secret
# ---------------------------------------------------------------------------

hr
echo "Step 7 of 7: Upserting founder_users row for founder.test..."

# TOTP secret JBSWY3DPEHPK3PXP stored as plain text in totp_secret_cipher.
# In production this field holds a KMS-wrapped ciphertext. In the test environment
# the founder-login Edge Function accepts this placeholder directly
# (commit a78b00d schema gap — the Edge Function checks the raw value).
# The secret encodes "Hello!" in Base32, which Google Authenticator / Authy
# will accept. Use it with the seed TOTP in docs/test-credentials.md.

upsert_row "founder_users" "$(jq -n \
  --arg auid "${FOUNDER_ID}" \
  '{ auth_user_id: $auid, display_name: "Founder Test", totp_secret_cipher: "JBSWY3DPEHPK3PXP" }')"
echo "  [OK] founder_users: founder.test, totp_secret_cipher=JBSWY3DPEHPK3PXP"

# ---------------------------------------------------------------------------
# 10. Summary table
# ---------------------------------------------------------------------------

hr
echo ""
echo "Seed complete. Test credentials summary:"
echo ""
printf "%-12s  %-38s  %-20s  %-30s\n" "ROLE" "EMAIL" "PASSWORD" "LOGIN SCREEN"
printf "%-12s  %-38s  %-20s  %-30s\n" "----" "-----" "--------" "------------"
printf "%-12s  %-38s  %-20s  %-30s\n" \
  "student"   "student.test@ladder.dev"         "${PASSWORD}" "B2C login  (Landing → Log in)"
printf "%-12s  %-38s  %-20s  %-30s\n" \
  "parent"    "parent.test@ladder.dev"           "${PASSWORD}" "B2C login  (Landing → Log in)"
printf "%-12s  %-38s  %-20s  %-30s\n" \
  "counselor" "counselor.test@ladder.dev"        "${PASSWORD}" "School login (Test Springs High School)"
printf "%-12s  %-38s  %-20s  %-30s\n" \
  "admin"     "admin.test@ladder.dev"            "${PASSWORD}" "School login (Test Springs High School)"
printf "%-12s  %-38s  %-20s  %-30s\n" \
  "founder"   "founder.test  [ID for login UI]"  "${PASSWORD}" "Founder backdoor (30-sec logo hold)"
echo ""
echo "Founder login ID: founder.test"
echo "Founder TOTP:     JBSWY3DPEHPK3PXP (add to Google Authenticator / Authy)"
echo "                  In DEBUG builds the app may bypass TOTP — see docs/test-credentials.md"
echo ""
echo "Full credential details + what to verify after each login:"
echo "  docs/test-credentials.md"
hr
