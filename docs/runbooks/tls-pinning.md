# TLS Pinning Runbook

Owner: iOS / Security
Related code: `LadderApp/Services/Networking/TLSPinnedSession.swift`
Related guard: `scripts/check_tls_pins.sh` (CI gate, see Task 3)
Related spec: CLAUDE.md §16.1, §16.3

---

## What is SPKI pinning?

Subject Public Key Info (SPKI) pinning verifies the server's TLS certificate
chain by hashing the **public key**, not the full certificate. The iOS client
ships a SHA-256 of the expected SPKI for each pinned host. On every TLS
handshake, the client extracts the SPKI of each cert in the chain, hashes it,
and refuses the connection unless the hash matches an in-app pin. This defeats
attackers who hold a rogue CA-signed cert: they would need the *private key*
of the pinned public key to impersonate Ladder's backend.

## Why two pins (current + next)?

A single pin is a footgun: if the cert rotates and the app cannot update its
pin in time, every installed client is bricked until users update. We ship two
pins so that during a rotation we can swap the server cert to the "next" key
and existing clients still trust it. Policy:

- `current` — SPKI hash of the active production cert (Supabase API + Edge).
- `next`    — SPKI hash of the **backup** key. Either:
  - the staging cert's SPKI (if staging uses a stable separate key), OR
  - a long-lived backup CA-issued key held in cold storage,
  - whichever rotates *less often* than `current`.

Never set `next == current`. Never leave `next` as a placeholder in Release.

---

## Step 1 — Extract SPKI SHA-256 from a live host

```sh
HOST=api.ladder.app   # or edge.ladder.app
openssl s_client -connect "$HOST":443 -servername "$HOST" -showcerts < /dev/null \
  | openssl x509 -pubkey -noout \
  | openssl pkey -pubin -outform DER \
  | openssl dgst -sha256 -binary \
  | xxd -p -c 256
```

Output is a 64-char hex string, e.g.

```
e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

If the host serves a chain (leaf -> intermediate -> root), repeat with
`openssl x509 -pubkey -noout` reading from each cert in the chain. We pin the
**leaf** for `current` and a stable backup (intermediate's SPKI or staging's
leaf SPKI) for `next`.

## Step 2 — Convert hex to a Swift `Data` byte literal

The 64-char hex `e3b0c4...b855` becomes:

```swift
Data([
    0xe3, 0xb0, 0xc4, 0x42, 0x98, 0xfc, 0x1c, 0x14,
    0x9a, 0xfb, 0xf4, 0xc8, 0x99, 0x6f, 0xb9, 0x24,
    0x27, 0xae, 0x41, 0xe4, 0x64, 0x9b, 0x93, 0x4c,
    0xa4, 0x95, 0x99, 0x1b, 0x78, 0x52, 0xb8, 0x55,
])
```

One-liner to format any hex string:

```sh
echo "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" \
  | sed 's/../0x&, /g; s/, $//'
```

## Step 3 — Paste into TLSPinnedSession.swift

File: `LadderApp/Services/Networking/TLSPinnedSession.swift`, lines 18-30.

Diff (illustrative — do **not** copy these placeholder bytes):

```diff
 public enum PinnedKeys {
-    static let placeholderCurrent = Data(repeating: 0x00, count: 32)
-    static let placeholderNext    = Data(repeating: 0x01, count: 32)
+    // Removed placeholders. Real SPKI hashes inlined per host below.

     public static let current: [PinnedHost: Data] = [
-        .supabaseAPI: placeholderCurrent,
-        .supabaseFunctions: placeholderCurrent,
+        .supabaseAPI:       Data([ /* 32 bytes from Step 2, api.ladder.app  */ ]),
+        .supabaseFunctions: Data([ /* 32 bytes from Step 2, edge.ladder.app */ ]),
     ]
     public static let next: [PinnedHost: Data] = [
-        .supabaseAPI: placeholderNext,
-        .supabaseFunctions: placeholderNext,
+        .supabaseAPI:       Data([ /* 32 bytes — backup key for api  */ ]),
+        .supabaseFunctions: Data([ /* 32 bytes — backup key for edge */ ]),
     ]
```

Keep `preflightOrCrash()` intact; it remains the runtime safety net.

---

## Rotation policy

- **Calendar reminder:** 30 days before any pinned cert expires.
- One-line script for a local cron / launchd / GitHub Action reminder:

  ```sh
  for h in api.ladder.app edge.ladder.app; do
    exp=$(echo | openssl s_client -connect "$h":443 -servername "$h" 2>/dev/null \
          | openssl x509 -noout -enddate | cut -d= -f2)
    echo "$h expires: $exp"
  done
  ```

### Roll-forward sequence

1. Generate / receive the new server key. Compute its SPKI SHA-256.
2. Ship app version N with `current = OLD`, `next = NEW`.
3. Wait for adoption (App Store stats, ~14 days for >90% in our cohort).
4. Switch the server to present `NEW` cert.
5. Ship app version N+1 with `current = NEW`, `next = NEWER backup`.

Never advance step 4 before step 3 reports adoption is high enough. Stragglers
who skipped version N will be bricked until they update — that is acceptable
only after a deliberate sunset.

---

## Test plan

### Simulator (Debug build)

Debug builds use placeholder pins; `preflightOrCrash()` is `#if !DEBUG`-gated
so the app launches. To validate pinning logic in Debug, temporarily set
`current` to the real hash from Step 1 and confirm:

- App reaches the Supabase host successfully (handshake passes the pin check).
- Flip one byte of the pin in `current`; relaunch; the request should fail
  with `cancelAuthenticationChallenge` (no network reachable for that host).

### Device (Release build)

1. Archive a Release build with `current` and `next` populated.
2. Install on a physical device.
3. Confirm app launches (no `precondition` crash in `preflightOrCrash()`).
4. Run the auth flow end to end; verify successful API and Edge calls.
5. Negative test: connect device to a proxy that injects a different valid
   cert (Charles, Proxyman, mitmproxy). The app must refuse the connection.
   This is the only test that actually proves pinning works.

---

## CI gate

`scripts/check_tls_pins.sh` greps for the placeholder patterns and **fails
the build** on `release/*` and `main` if either is still present. Feature
branches receive a warning only. The script is wired into
`docs/ci-pending/ci.yml` as a step in the `lint` job. That workflow is **not
yet active** — Phase 4 will move it to `.github/workflows/ci.yml`. Until then
the gate runs only when a developer invokes it manually:

```sh
./scripts/check_tls_pins.sh
```

Run it locally before opening any PR that touches `TLSPinnedSession.swift`.

---

## Open question for ops

Production Supabase project URL is required to run Step 1. The default
`api.ladder.app` and `edge.ladder.app` host names in
`TLSPinnedSession.swift` may not yet route to a real cert — confirm with the
infra owner before extracting.
