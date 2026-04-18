import Foundation
import CryptoKit

// CLAUDE.md §16.1, §16.3 — iOS client pins to Ladder's backend certificate +
// KMS endpoints. Two pins shipped in-app (current + next) so rotation does
// not brick users mid-flight.

public enum PinnedHost: String, CaseIterable {
    case supabaseAPI = "api.ladder.app"
    case supabaseFunctions = "edge.ladder.app"
    case awsKMS = "kms.us-east-1.amazonaws.com"
}

/// SHA-256 of the SubjectPublicKeyInfo DER for each accepted cert.
/// Update via remote config 30 days before the production cert rotates.
public enum PinnedKeys {
    public static let current: [PinnedHost: Data] = [
        // Placeholder values — replace with real SPKI hashes before production.
        .supabaseAPI: Data(repeating: 0x00, count: 32),
        .supabaseFunctions: Data(repeating: 0x00, count: 32),
        .awsKMS: Data(repeating: 0x00, count: 32),
    ]
    public static let next: [PinnedHost: Data] = [
        .supabaseAPI: Data(repeating: 0x01, count: 32),
        .supabaseFunctions: Data(repeating: 0x01, count: 32),
        .awsKMS: Data(repeating: 0x01, count: 32),
    ]
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
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let host = PinnedHost(rawValue: challenge.protectionSpace.host) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard SecTrustEvaluateWithError(serverTrust, nil) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        let chainCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<chainCount {
            guard let cert = SecTrustGetCertificateAtIndex(serverTrust, i),
                  let spki = Self.extractSPKISHA256(from: cert) else { continue }
            if spki == PinnedKeys.current[host] || spki == PinnedKeys.next[host] {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }
        // No pin matched — refuse the connection.
        completionHandler(.cancelAuthenticationChallenge, nil)
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
