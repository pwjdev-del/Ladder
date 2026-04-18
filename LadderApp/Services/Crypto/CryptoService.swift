import Foundation
import CryptoKit
import Security

// CLAUDE.md §16.2 — on-device crypto. Keychain-backed sensitive storage,
// in-memory buffer clearing, envelope wrapping of secrets we cache on device
// (e.g., device-bound refresh token, biometrics-gated session key).
//
// This is NOT the tenant DEK — that never lives on a device. Tenant DEKs live
// only in the Edge Function runtime (see LadderBackend/crypto/envelope.ts).

public enum CryptoError: Error {
    case keychainStore(OSStatus)
    case keychainRead(OSStatus)
    case keychainDelete(OSStatus)
    case itemNotFound
    case decryptFailed
}

public struct KeychainService {
    public let service: String
    public let accessGroup: String?

    public init(service: String = "app.ladder.ios", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    public func set(_ value: Data, for key: String) throws {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]
        if let accessGroup { query[kSecAttrAccessGroup as String] = accessGroup }

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw CryptoError.keychainStore(status) }
    }

    public func get(_ key: String) throws -> Data {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        if let accessGroup { query[kSecAttrAccessGroup as String] = accessGroup }

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            if status == errSecItemNotFound { throw CryptoError.itemNotFound }
            throw CryptoError.keychainRead(status)
        }
        guard let data = result as? Data else { throw CryptoError.itemNotFound }
        return data
    }

    public func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw CryptoError.keychainDelete(status)
        }
    }
}

public struct SensitiveBuffer {
    /// Overwrite a Data value in place before discarding. Call this on any
    /// sensitive buffer when a screen dismisses (§16.2 "clear sensitive
    /// buffers as soon as a screen is dismissed").
    public static func zeroize(_ data: inout Data) {
        data.withUnsafeMutableBytes { bytes in
            guard let base = bytes.baseAddress else { return }
            memset_s(base, bytes.count, 0, bytes.count)
        }
    }
}
