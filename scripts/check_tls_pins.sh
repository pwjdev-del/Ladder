#!/usr/bin/env bash
# check_tls_pins.sh — fail CI on release/main if TLS pins are still placeholders.
# Wired into docs/ci-pending/ci.yml. See docs/runbooks/tls-pinning.md.
set -euo pipefail

PIN_FILE="LadderApp/Services/Networking/TLSPinnedSession.swift"
RUNBOOK="docs/runbooks/tls-pinning.md"

# Detect repo root so the script works from any cwd.
if [ -n "${GITHUB_WORKSPACE:-}" ]; then
  cd "$GITHUB_WORKSPACE"
elif git rev-parse --show-toplevel >/dev/null 2>&1; then
  cd "$(git rev-parse --show-toplevel)"
fi

if [ ! -f "$PIN_FILE" ]; then
  echo "check_tls_pins: cannot find $PIN_FILE — wrong cwd?" >&2
  exit 2
fi

# Detect current branch. Prefer GitHub Actions env, fall back to git.
BRANCH="${GITHUB_REF_NAME:-}"
if [ -z "$BRANCH" ]; then
  BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
fi

# Detect "placeholder pin used as a real value" vs "placeholder constant
# declared for preflightOrCrash safety comparison". Real values appear as
# dict entries — `host: placeholderCurrent,` or inline `Data(repeating:..)`.
# We accept the file ONLY if no PinnedHost case maps to a placeholder.
#
# Strategy: extract the lines inside `current: [PinnedHost: Data] = [ ... ]`
# and `next: [PinnedHost: Data] = [ ... ]` blocks, then look for placeholder
# tokens in those blocks only. A placeholder constant DECLARATION (the
# `static let placeholderCurrent = Data(repeating:...)` line) is not a
# violation; only a dict-value usage is.
PLACEHOLDER_TOKENS='placeholderCurrent|placeholderNext|Data\(repeating: 0x0[01], count: 32\)'

extract_dict_block() {
  # $1 = "current" or "next"; prints lines between the opening `[` and `]`.
  # Uses index() instead of regex to avoid awk regex quoting headaches.
  awk -v key="public static let $1:" '
    index($0, key)              {inside = 1; next}
    inside && $0 ~ /^[[:space:]]*\]/ {inside = 0}
    inside                      {print}
  ' "$PIN_FILE"
}

found_current=0
found_next=0
extract_dict_block current | grep -E -q "$PLACEHOLDER_TOKENS" && found_current=1 || true
extract_dict_block next    | grep -E -q "$PLACEHOLDER_TOKENS" && found_next=1    || true

if [ "$found_current" -eq 0 ] && [ "$found_next" -eq 0 ]; then
  echo "check_tls_pins: OK — no placeholder pins found in $PIN_FILE."
  exit 0
fi

# Placeholders are present. Decide based on branch.
case "$BRANCH" in
  main|release/*)
    echo "check_tls_pins: FAIL on protected branch '$BRANCH'." >&2
    echo "  Placeholder current pin found: $found_current" >&2
    echo "  Placeholder next    pin found: $found_next"    >&2
    echo "" >&2
    echo "  Real SPKI SHA-256 hashes for api.ladder.app and edge.ladder.app" >&2
    echo "  must be inlined into $PIN_FILE before this branch can ship." >&2
    echo "" >&2
    echo "  Step-by-step extraction + paste instructions:" >&2
    echo "    $RUNBOOK" >&2
    exit 1
    ;;
  *)
    echo "check_tls_pins: WARN on feature branch '$BRANCH'." >&2
    echo "  Placeholder current pin found: $found_current" >&2
    echo "  Placeholder next    pin found: $found_next"    >&2
    echo "  This is a non-blocking warning. The same check FAILS on main / release/*." >&2
    echo "  Fix before opening a release PR. See $RUNBOOK." >&2
    exit 0
    ;;
esac
