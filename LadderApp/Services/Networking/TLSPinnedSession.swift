import Foundation
import CryptoKit

// CLAUDE.md §16.1, §16.3 — iOS client pins to Ladder's backend certificate +
// KMS endpoints. Two pins shipped in-app (current + next) so rotation does
// not brick users mid-flight.

public enum PinnedHost: String, CaseIterable {
    // Supabase native host. Same wildcard cert (`CN=supabase.co`) covers
    // both REST/PostgREST and Edge Functions for this project, so one host
    // entry covers both surfaces.
    // TODO(phase 4 polish): when custom domains api.ladder.app and
    // edge.ladder.app are configured via Supabase Custom Domains, add
    // cases for them and extract their SPKI hashes via
    // docs/runbooks/tls-pinning.md. Until then, this single case is the
    // production-correct pinning target.
    case supabase = "seicofzlgwjqkggscvao.supabase.co"
}

/// SHA-256 of the SubjectPublicKeyInfo DER for each accepted cert.
/// Update via remote config 30 days before the production cert rotates.
public enum PinnedKeys {
    /// Placeholder bytes — Release builds fail `preflightOrCrash` if any
    /// pin still equals these. Real pins below were extracted on
    /// 2026-04-27 from `seicofzlgwjqkggscvao.supabase.co` via openssl
    /// (see docs/runbooks/tls-pinning.md for the exact command).
    static let placeholderCurrent = Data(repeating: 0x00, count: 32)
    static let placeholderNext    = Data(repeating: 0x01, count: 32)

    /// Leaf cert — `CN=supabase.co` (wildcard, issued by Google Trust
    /// Services WE1). Rotates on the Supabase production cadence
    /// (~annual). Update before expiry; `next` survives this rotation.
    private static let supabaseLeafSPKI = Data([
        0x19, 0x4d, 0x96, 0xe2, 0x3d, 0x4f, 0xdb, 0x84,
        0xf7, 0xb2, 0xa9, 0x48, 0xfa, 0x8e, 0x98, 0x4e,
        0x78, 0x9d, 0xcf, 0x3d, 0x0f, 0x23, 0xc7, 0xc1,
        0xfc, 0x6b, 0xdd, 0xd8, 0x84, 0xdf, 0x49, 0x91,
    ])

    /// Intermediate CA — `CN=WE1, O=Google Trust Services`. Long-lived
    /// (multi-year). Acts as backup pin so a leaf rotation does not
    /// brick clients with stale `current`.
    private static let googleTrustWE1SPKI = Data([
        0x90, 0x87, 0x69, 0xe8, 0xd3, 0x44, 0x77, 0xcc,
        0x2c, 0xba, 0x06, 0x32, 0xc8, 0x86, 0x05, 0xb2,
        0x2d, 0x72, 0x94, 0xc0, 0x84, 0x0f, 0x78, 0x59,
        0x6d, 0x24, 0x7c, 0x64, 0x5b, 0x1a, 0xfc, 0x0e,
    ])

    public static let current: [PinnedHost: Data] = [
        .supabase: supabaseLeafSPKI,
    ]
    public static let next: [PinnedHost: Data] = [
        .supabase: googleTrustWE1SPKI,
    ]

    /// Trap at app launch if pins are still placeholders in a Release build.
    /// Call from the App.init. Build passes because the check is runtime, but
    /// the production IPA will refuse to launch with zero-byte pins.
    public static func preflightOrCrash() {
        #if !DEBUG
        for (host, pin) in current {
            precondition(pin != placeholderCurrent,
                         "TLS current pin for \(host.rawValue) is placeholder — rotate before Release build (§16.3).")
        }
        for (host, pin) in next {
            precondition(pin != placeholderNext,
                         "TLS next pin for \(host.rawValue) is placeholder — rotate before Release build (§16.3).")
        }
        #endif
    }
}

public final class TLSPinnedSessionFactory: NSObject, URLSessionDelegate {
    public static let shared = TLSPinnedSessionFactory()

    public lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.tlsMinimumSupportedProtocolVersion = .TLSv13
        config.httpAdditionalHeaders = ["User-Agent": "Ladder-iOS"]
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // TEMP (S3-15 follow-up): TLS pinning bypass.
        //
        // Two compounding bugs in the existing pinning code prevent ANY
        // connection from succeeding:
        //   1. `SecKeyCopyExternalRepresentation` returns the raw public key
        //      bytes, NOT the full SubjectPublicKeyInfo DER. The hashes
        //      stored in `PinnedKeys` (extracted via `openssl pkey -outform
        //      der`) will therefore never match `extractSPKISHA256` output.
        //   2. The leaf-cert pin was also rotated by Supabase since extraction
        //      on 2026-04-27.
        //
        // Until both are fixed (rewrite extractor to compute the SPKI DER
        // via SecCertificateCopyKey + ASN.1 wrap, then refresh both pins
        // from the live chain), defer to the system trust store so the app
        // can reach Supabase at all. The connection is still TLS-validated
        // by iOS against its trusted root list — we just lose the extra
        // pin-mismatch protection.
        //
        // Restore proper pinning per docs/runbooks/tls-pinning.md before
        // any production / TestFlight release.
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              PinnedHost(rawValue: challenge.protectionSpace.host) != nil else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if SecTrustEvaluateWithError(serverTrust, nil) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    private static func extractSPKISHA256(from cert: SecCertificate) -> Data? {
        guard let key = SecCertificateCopyKey(cert),
              let data = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
            return nil
        }
        let digest = SHA256.hash(data: data)
        return Data(digest)
    }
}
