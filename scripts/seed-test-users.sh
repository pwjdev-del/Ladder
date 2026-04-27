#!/usr/bin/env bash
# scripts/seed-test-users.sh
#
# Creates a full test matrix:
#   - School tenant "Deku Drench Prep" with admin, counselor, 4 graded students, parent
#   - One B2C private-pay student (no tenant)
#   - One founder account with TOTP
#
# Safe to re-run — existing users are detected via the Admin API and skipped.
# All DB rows use Prefer: resolution=ignore-duplicates.
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
  echo "       Set SUPABASE_SERVICE_ROLE_KEY in .env first — grab from https://supabase.com/dashboard/project/seicofzlgwjqkggscvao/settings/api"
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

# Deku Drench Prep school tenant — deterministic UUID for idempotent re-runs.
SCHOOL_TENANT_ID="10000000-0000-0000-0000-000000000001"

# Deterministic student-row UUIDs (students table, not auth.users)
STUDENT_G9_ROW_ID="20000000-0000-0000-0000-000000000009"
STUDENT_G10_ROW_ID="20000000-0000-0000-0000-000000000010"
STUDENT_G11_ROW_ID="20000000-0000-0000-0000-000000000011"
STUDENT_G12_ROW_ID="20000000-0000-0000-0000-000000000012"
# B2C private-pay student row
B2C_STUDENT_ROW_ID="20000000-0000-0000-0000-000000000099"

# ---------------------------------------------------------------------------
# 2. Helper functions
# ---------------------------------------------------------------------------

hr() { printf '%s\n' "------------------------------------------------------------"; }

# find_user_by_email EMAIL
# Returns the auth UUID if found, empty string if not found.
# Exits with a clear message if the key is invalid (HTTP 401/403).
find_user_by_email() {
  local email="$1"
  local response http_code

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
    echo "       Set SUPABASE_SERVICE_ROLE_KEY in .env first — grab from https://supabase.com/dashboard/project/seicofzlgwjqkggscvao/settings/api"
    exit 1
  fi

  echo "${response}" | jq -r --arg email "${email}" \
    '.users[] | select(.email == $email) | .id' 2>/dev/null || true
}

# create_auth_user EMAIL DISPLAY_NAME ROLE TENANT_ID_OR_NULL
# Returns the new UUID. Exits on error.
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

  local err_msg
  err_msg=$(echo "${response}" | jq -r '.msg // .message // ""' 2>/dev/null || true)
  if [[ -n "${err_msg}" && "${err_msg}" != "null" ]]; then
    echo "ERROR: Supabase returned an error for ${email}: ${err_msg}"
    exit 1
  fi

  echo "${response}" | jq -r '.id'
}

# upsert_row TABLE BODY_JSON
# Inserts or silently skips on conflict (ignore-duplicates).
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
# Step 1 — Ensure "Deku Drench Prep" school tenant exists
# ---------------------------------------------------------------------------

hr
echo "Step 1 of 7: Ensuring school tenant 'Deku Drench Prep' exists..."

# theme_primary_color / theme_accent_color / enabled_features are migration-0009 columns.
# Sending them as null lets the DB default to Ladder branding. If the columns do not
# yet exist PostgREST will ignore unknown keys — no harm done.
SCHOOL_BODY=$(jq -n \
  --arg id "${SCHOOL_TENANT_ID}" \
  '{
    id: $id,
    type: "school",
    slug: "deku-drench-prep",
    display_name: "Deku Drench Prep",
    primary_color_hex: null,
    plan: "pilot",
    theme_primary_color: null,
    theme_accent_color: null,
    enabled_features: null
  }')

curl --silent --show-error \
  --request POST \
  --header "Authorization: Bearer ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "apikey: ${SUPABASE_SERVICE_ROLE_KEY}" \
  --header "Content-Type: application/json" \
  --header "Prefer: resolution=ignore-duplicates,return=minimal" \
  --data "${SCHOOL_BODY}" \
  "${REST_URL}/tenants" >/dev/null
echo "  [OK] tenant: Deku Drench Prep (${SCHOOL_TENANT_ID})"

# ---------------------------------------------------------------------------
# Step 2 — Create / detect all auth users
# ---------------------------------------------------------------------------

hr
echo "Step 2 of 7: Creating auth users (skipping any that already exist)..."

# --- admin ---
ADMIN_EMAIL="admin@dekudrenchprep.test"
ADMIN_ID=$(find_user_by_email "${ADMIN_EMAIL}")
if [[ -n "${ADMIN_ID}" ]]; then
  echo "  [SKIP] ${ADMIN_EMAIL} already exists (${ADMIN_ID})"
else
  ADMIN_ID=$(create_auth_user "${ADMIN_EMAIL}" "DDP Admin" "admin" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${ADMIN_EMAIL} created (${ADMIN_ID})"
fi

# --- counselor ---
COUNSELOR_EMAIL="counselor@dekudrenchprep.test"
COUNSELOR_ID=$(find_user_by_email "${COUNSELOR_EMAIL}")
if [[ -n "${COUNSELOR_ID}" ]]; then
  echo "  [SKIP] ${COUNSELOR_EMAIL} already exists (${COUNSELOR_ID})"
else
  COUNSELOR_ID=$(create_auth_user "${COUNSELOR_EMAIL}" "DDP Counselor" "counselor" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${COUNSELOR_EMAIL} created (${COUNSELOR_ID})"
fi

# --- student grade 9 ---
STU_G9_EMAIL="student.g9@dekudrenchprep.test"
STU_G9_ID=$(find_user_by_email "${STU_G9_EMAIL}")
if [[ -n "${STU_G9_ID}" ]]; then
  echo "  [SKIP] ${STU_G9_EMAIL} already exists (${STU_G9_ID})"
else
  STU_G9_ID=$(create_auth_user "${STU_G9_EMAIL}" "DDP Student G9" "student" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${STU_G9_EMAIL} created (${STU_G9_ID})"
fi

# --- student grade 10 ---
STU_G10_EMAIL="student.g10@dekudrenchprep.test"
STU_G10_ID=$(find_user_by_email "${STU_G10_EMAIL}")
if [[ -n "${STU_G10_ID}" ]]; then
  echo "  [SKIP] ${STU_G10_EMAIL} already exists (${STU_G10_ID})"
else
  STU_G10_ID=$(create_auth_user "${STU_G10_EMAIL}" "DDP Student G10" "student" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${STU_G10_EMAIL} created (${STU_G10_ID})"
fi

# --- student grade 11 ---
STU_G11_EMAIL="student.g11@dekudrenchprep.test"
STU_G11_ID=$(find_user_by_email "${STU_G11_EMAIL}")
if [[ -n "${STU_G11_ID}" ]]; then
  echo "  [SKIP] ${STU_G11_EMAIL} already exists (${STU_G11_ID})"
else
  STU_G11_ID=$(create_auth_user "${STU_G11_EMAIL}" "DDP Student G11" "student" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${STU_G11_EMAIL} created (${STU_G11_ID})"
fi

# --- student grade 12 ---
STU_G12_EMAIL="student.g12@dekudrenchprep.test"
STU_G12_ID=$(find_user_by_email "${STU_G12_EMAIL}")
if [[ -n "${STU_G12_ID}" ]]; then
  echo "  [SKIP] ${STU_G12_EMAIL} already exists (${STU_G12_ID})"
else
  STU_G12_ID=$(create_auth_user "${STU_G12_EMAIL}" "DDP Student G12" "student" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${STU_G12_EMAIL} created (${STU_G12_ID})"
fi

# --- parent (linked to all 4 school students) ---
PARENT_EMAIL="parent@dekudrenchprep.test"
PARENT_ID=$(find_user_by_email "${PARENT_EMAIL}")
if [[ -n "${PARENT_ID}" ]]; then
  echo "  [SKIP] ${PARENT_EMAIL} already exists (${PARENT_ID})"
else
  PARENT_ID=$(create_auth_user "${PARENT_EMAIL}" "DDP Parent" "parent" "${SCHOOL_TENANT_ID}")
  echo "  [OK]   ${PARENT_EMAIL} created (${PARENT_ID})"
fi

# --- B2C private-pay student (no tenant) ---
B2C_EMAIL="private.user@ladder.test"
B2C_ID=$(find_user_by_email "${B2C_EMAIL}")
if [[ -n "${B2C_ID}" ]]; then
  echo "  [SKIP] ${B2C_EMAIL} already exists (${B2C_ID})"
else
  B2C_ID=$(create_auth_user "${B2C_EMAIL}" "Private User" "student" "null")
  echo "  [OK]   ${B2C_EMAIL} created (${B2C_ID})"
fi

# --- founder (keep; FounderLoginView converts Founder ID → {id}@ladder.internal) ---
FOUNDER_EMAIL="founder.test@ladder.internal"
FOUNDER_ID=$(find_user_by_email "${FOUNDER_EMAIL}")
if [[ -n "${FOUNDER_ID}" ]]; then
  echo "  [SKIP] ${FOUNDER_EMAIL} already exists (${FOUNDER_ID})"
else
  FOUNDER_ID=$(create_auth_user "${FOUNDER_EMAIL}" "Founder Test" "founder" "null")
  echo "  [OK]   ${FOUNDER_EMAIL} created (${FOUNDER_ID})"
fi

# ---------------------------------------------------------------------------
# Step 3 — user_profiles rows
# ---------------------------------------------------------------------------

hr
echo "Step 3 of 7: Upserting user_profiles rows..."

upsert_row "user_profiles" "$(jq -n \
  --arg id "${ADMIN_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "admin",
     display_name: "DDP Admin", email: "admin@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: admin"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${COUNSELOR_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "counselor",
     display_name: "DDP Counselor", email: "counselor@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: counselor"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${STU_G9_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "student",
     display_name: "DDP Student G9", email: "student.g9@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: student.g9"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${STU_G10_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "student",
     display_name: "DDP Student G10", email: "student.g10@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: student.g10"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${STU_G11_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "student",
     display_name: "DDP Student G11", email: "student.g11@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: student.g11"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${STU_G12_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "student",
     display_name: "DDP Student G12", email: "student.g12@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: student.g12"

upsert_row "user_profiles" "$(jq -n \
  --arg id "${PARENT_ID}" --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, tenant_id: $tid, role: "parent",
     display_name: "DDP Parent", email: "parent@dekudrenchprep.test" }')"
echo "  [OK] user_profiles: parent"

# B2C student: tenant_id intentionally omitted (NULL)
upsert_row "user_profiles" "$(jq -n \
  --arg id "${B2C_ID}" \
  '{ id: $id, role: "student",
     display_name: "Private User", email: "private.user@ladder.test" }')"
echo "  [OK] user_profiles: private.user (tenant_id=NULL)"

# Founder: no tenant per founder_has_no_tenant constraint
upsert_row "user_profiles" "$(jq -n \
  --arg id "${FOUNDER_ID}" \
  '{ id: $id, role: "founder",
     display_name: "Founder Test", email: "founder.test@ladder.internal" }')"
echo "  [OK] user_profiles: founder"

# ---------------------------------------------------------------------------
# Step 4 — students rows (one per student, grade_level + tenant_id)
# ---------------------------------------------------------------------------

hr
echo "Step 4 of 7: Upserting students rows..."

upsert_row "students" "$(jq -n \
  --arg id "${STUDENT_G9_ROW_ID}" \
  --arg uid "${STU_G9_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, user_id: $uid, tenant_id: $tid, grade_level: 9 }')"
echo "  [OK] students: student.g9  grade=9  row=${STUDENT_G9_ROW_ID}"

upsert_row "students" "$(jq -n \
  --arg id "${STUDENT_G10_ROW_ID}" \
  --arg uid "${STU_G10_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, user_id: $uid, tenant_id: $tid, grade_level: 10 }')"
echo "  [OK] students: student.g10 grade=10 row=${STUDENT_G10_ROW_ID}"

upsert_row "students" "$(jq -n \
  --arg id "${STUDENT_G11_ROW_ID}" \
  --arg uid "${STU_G11_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, user_id: $uid, tenant_id: $tid, grade_level: 11 }')"
echo "  [OK] students: student.g11 grade=11 row=${STUDENT_G11_ROW_ID}"

upsert_row "students" "$(jq -n \
  --arg id "${STUDENT_G12_ROW_ID}" \
  --arg uid "${STU_G12_ID}" \
  --arg tid "${SCHOOL_TENANT_ID}" \
  '{ id: $id, user_id: $uid, tenant_id: $tid, grade_level: 12 }')"
echo "  [OK] students: student.g12 grade=12 row=${STUDENT_G12_ROW_ID}"

# B2C private-pay student: tenant_id NULL, no school assignment
upsert_row "students" "$(jq -n \
  --arg id "${B2C_STUDENT_ROW_ID}" \
  --arg uid "${B2C_ID}" \
  '{ id: $id, user_id: $uid, grade_level: 11 }')"
echo "  [OK] students: private.user  grade=11 tenant_id=NULL row=${B2C_STUDENT_ROW_ID}"

# ---------------------------------------------------------------------------
# Step 5 — parent_links: parent@dekudrenchprep.test -> all 4 school students
# ---------------------------------------------------------------------------

hr
echo "Step 5 of 7: Upserting parent_links (parent -> 4 school students, status=active)..."

for row_id_var in STUDENT_G9_ROW_ID STUDENT_G10_ROW_ID STUDENT_G11_ROW_ID STUDENT_G12_ROW_ID; do
  # Resolve the variable name to its value
  row_id="${!row_id_var}"
  upsert_row "parent_links" "$(jq -n \
    --arg puid "${PARENT_ID}" \
    --arg sid  "${row_id}" \
    --arg tid  "${SCHOOL_TENANT_ID}" \
    '{ parent_user_id: $puid, student_id: $sid, tenant_id: $tid,
       relationship: "parent", status: "active" }')"
  echo "  [OK] parent_links: parent -> students row ${row_id} (active)"
done

# ---------------------------------------------------------------------------
# Step 6 — counselor_assignments: counselor -> all 4 school students
# ---------------------------------------------------------------------------

hr
echo "Step 6 of 7: Upserting counselor_assignments (counselor -> 4 school students)..."

for row_id_var in STUDENT_G9_ROW_ID STUDENT_G10_ROW_ID STUDENT_G11_ROW_ID STUDENT_G12_ROW_ID; do
  row_id="${!row_id_var}"
  upsert_row "counselor_assignments" "$(jq -n \
    --arg tid  "${SCHOOL_TENANT_ID}" \
    --arg cuid "${COUNSELOR_ID}" \
    --arg sid  "${row_id}" \
    '{ tenant_id: $tid, counselor_user_id: $cuid, student_id: $sid }')"
  echo "  [OK] counselor_assignments: counselor -> students row ${row_id}"
done

# ---------------------------------------------------------------------------
# Step 7 — founder_users row + TOTP secret
# ---------------------------------------------------------------------------

hr
echo "Step 7 of 7: Upserting founder_users row for founder.test..."

# TOTP secret JBSWY3DPEHPK3PXP — plaintext placeholder acceptable in test env.
# In production this field holds a KMS-wrapped ciphertext. The founder-login
# Edge Function accepts the raw value in the dev project.
upsert_row "founder_users" "$(jq -n \
  --arg auid "${FOUNDER_ID}" \
  '{ auth_user_id: $auid,
     display_name: "Founder Test",
     totp_secret_cipher: "JBSWY3DPEHPK3PXP" }')"
echo "  [OK] founder_users: founder.test, totp_secret_cipher=JBSWY3DPEHPK3PXP"

# ---------------------------------------------------------------------------
# Summary table
# ---------------------------------------------------------------------------

hr
echo ""
echo "Seed complete. Test credentials:"
echo ""
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "ROLE" "EMAIL" "PASSWORD" "LOGIN SCREEN" "GRADE"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "----" "-----" "--------" "------------" "-----"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "admin"     "admin@dekudrenchprep.test"    "${PASSWORD}" "School login (Deku Drench Prep)" "—"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "counselor" "counselor@dekudrenchprep.test" "${PASSWORD}" "School login (Deku Drench Prep)" "—"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "student"   "student.g9@dekudrenchprep.test" "${PASSWORD}" "School login (Deku Drench Prep)" "9"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "student"   "student.g10@dekudrenchprep.test" "${PASSWORD}" "School login (Deku Drench Prep)" "10"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "student"   "student.g11@dekudrenchprep.test" "${PASSWORD}" "School login (Deku Drench Prep)" "11"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "student"   "student.g12@dekudrenchprep.test" "${PASSWORD}" "School login (Deku Drench Prep)" "12"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "parent"    "parent@dekudrenchprep.test"   "${PASSWORD}" "School login (Deku Drench Prep)" "—"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "student"   "private.user@ladder.test"     "${PASSWORD}" "B2C login (Landing -> Log in)" "11"
printf "%-11s  %-40s  %-16s  %-34s  %-5s\n" \
  "founder"   "founder.test  [Founder ID]"   "${PASSWORD}" "Founder backdoor (30-sec hold)" "—"
echo ""
echo "Founder login:  ID = founder.test  |  TOTP secret = JBSWY3DPEHPK3PXP"
echo "                Add secret to Google Authenticator / Authy manually."
echo ""
echo "Full credential details + per-login verification checklist:"
echo "  docs/test-credentials.md"
hr
