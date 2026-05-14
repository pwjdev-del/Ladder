// TODO(founder): confirm production domain before App Store submission. Currently using ladder.app as a placeholder.

import Foundation

/// Centralised legal URL constants.
///
/// All legal links in the app MUST reference these constants so that a domain
/// change is a single-line edit here. The founder must confirm the production
/// domain before any App Store submission (Day-band 6 checklist item).
///
/// School-scoped documents (DPA, liability) accept a `schoolID` parameter so
/// the server can serve the correct tenant-stamped PDF.
enum LegalURLs {
    private static let base = "https://ladder.app/legal"

    static let privacyPolicy = URL(string: "\(base)/privacy")!
    static let termsOfService = URL(string: "\(base)/terms")!
    static let dataProcessingAgreement = URL(string: "\(base)/dpa")!
    static let liabilityWaiver = URL(string: "\(base)/liability")!

    /// Returns the DPA URL scoped to a specific school tenant.
    static func dataProcessingAgreement(schoolID: String) -> URL {
        URL(string: "\(base)/dpa/\(schoolID)")!
    }

    /// Returns the liability-waiver URL scoped to a specific school tenant.
    static func liabilityWaiver(schoolID: String) -> URL {
        URL(string: "\(base)/liability/\(schoolID)")!
    }

    // ADD MORE HERE as needed
}
