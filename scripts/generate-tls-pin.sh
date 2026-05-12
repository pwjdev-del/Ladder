#!/usr/bin/env bash
# generate-tls-pin.sh
#
# Extracts the SPKI SHA-256 hash for a live TLS host and prints a Swift
# Data([UInt8]) literal ready to paste into TLSPinnedSession.swift.
#
# Usage:
#   ./scripts/generate-tls-pin.sh <hostname> [cert-index]
#
# Examples:
#   ./scripts/generate-tls-pin.sh seicofzlgwjqkggscvao.supabase.co
#   ./scripts/generate-tls-pin.sh seicofzlgwjqkggscvao.supabase.co 1   # intermediate
#
# cert-index controls which cert in the chain is hashed:
#   0  = leaf (default) — use for PinnedKeys.current
#   1  = intermediate   — use for PinnedKeys.next (longer-lived)
#
# Prerequisites: openssl, xxd (both ship with macOS).
#
# What this script does, step by step:
#   1. Connects to <hostname>:443 with SNI and dumps the full cert chain.
#   2. Splits the PEM chain into individual certs (using awk).
#   3. Picks cert at <cert-index> (0 = leaf, 1 = first intermediate, ...).
#   4. Extracts the SubjectPublicKeyInfo DER block from that cert.
#   5. Hashes that DER block with SHA-256.
#   6. Formats the 32-byte hash as a Swift [UInt8] literal.
#
# Why SPKI and not the full cert?
#   Cert serial numbers and validity periods change on every renewal.
#   The *public key* is reused across renewals (especially for CAs), so
#   SPKI pinning survives a standard cert rotation without an app update.
#   Use the leaf SPKI for your "current" pin; use an intermediate or backup
#   key SPKI for your "next" pin so a leaf rotation does not brick users.

set -euo pipefail

HOST="${1:-}"
CERT_INDEX="${2:-0}"

if [[ -z "$HOST" ]]; then
  echo "Usage: $0 <hostname> [cert-index]" >&2
  echo "  cert-index 0 = leaf (default), 1 = first intermediate" >&2
  exit 1
fi

echo "Connecting to $HOST:443 (cert index $CERT_INDEX)..." >&2

# ── Step 1: Fetch the full chain ────────────────────────────────────────────
RAW_CHAIN=$(echo "" | openssl s_client \
  -connect "${HOST}:443" \
  -servername "$HOST" \
  -showcerts 2>/dev/null)

if [[ -z "$RAW_CHAIN" ]]; then
  echo "ERROR: Could not connect to $HOST:443. Is the host reachable?" >&2
  exit 1
fi

# ── Step 2: Split chain into individual PEM certs ───────────────────────────
# awk collects lines between BEGIN/END CERTIFICATE markers into numbered files.
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

awk '
  /-----BEGIN CERTIFICATE-----/ { n++; file = "'$TMPDIR'/cert-" n ".pem" }
  file { print > file }
  /-----END CERTIFICATE-----/   { file = "" }
' <<< "$RAW_CHAIN"

CERT_FILE="$TMPDIR/cert-$((CERT_INDEX + 1)).pem"
if [[ ! -f "$CERT_FILE" ]]; then
  COUNT=$(ls "$TMPDIR"/cert-*.pem 2>/dev/null | wc -l | tr -d ' ')
  echo "ERROR: cert-index $CERT_INDEX requested but chain only has $COUNT cert(s)." >&2
  exit 1
fi

# ── Steps 3-5: Extract SPKI DER, hash with SHA-256 ──────────────────────────
HEX=$(openssl x509 -in "$CERT_FILE" -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | xxd -p -c 256)

if [[ ${#HEX} -ne 64 ]]; then
  echo "ERROR: Expected 64 hex chars (32 bytes), got ${#HEX}. Something went wrong." >&2
  exit 1
fi

# ── Step 6: Format as Swift Data([UInt8]) literal ───────────────────────────
SWIFT_BYTES=$(echo "$HEX" | sed 's/../0x&, /g' | sed 's/, $//')

# Split into 8-byte rows for readability
SWIFT_ROWS=$(echo "$SWIFT_BYTES" | awk '
  BEGIN { RS=", "; count=0; row="" }
  {
    if (count > 0) row = row ", "
    row = row $0
    count++
    if (count == 8) { print "        " row ","; row = ""; count = 0 }
  }
  END { if (row != "") print "        " row }
')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Host     : $HOST"
echo "Cert idx : $CERT_INDEX  (0=leaf → use for 'current'; 1=intermediate → use for 'next')"
echo "SHA-256  : $HEX"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Paste into LadderApp/Services/Networking/TLSPinnedSession.swift:"
echo ""
echo "    private static let supabaseLeafSPKI = Data(["
echo "$SWIFT_ROWS"
echo "    ])"
echo ""
echo "Then run:  ./scripts/check_tls_pins.sh"
echo "And confirm CI passes before opening the release PR."
