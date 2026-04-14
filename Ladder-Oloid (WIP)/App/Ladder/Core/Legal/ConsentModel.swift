import SwiftUI
import SwiftData

// MARK: - Consent Record Model
// Stores when and what the user agreed to. Persisted locally via SwiftData
// and synced to backend when AWS is wired up.

@Model
final class ConsentRecord {
    var id: String
    var userId: String
    var termsAccepted: Bool
    var privacyAccepted: Bool
    var ageVerified: Bool
    var waiverAccepted: Bool
    var ferpaAcknowledged: Bool
    var aiDisclaimerAccepted: Bool
    var coppaParentalConsent: Bool
    var parentEmail: String?
    var consentDate: Date
    var termsVersion: String
    var privacyVersion: String
    var ipAddress: String?

    init(
        userId: String,
        termsAccepted: Bool = false,
        privacyAccepted: Bool = false,
        ageVerified: Bool = false,
        waiverAccepted: Bool = false,
        ferpaAcknowledged: Bool = false,
        aiDisclaimerAccepted: Bool = false,
        coppaParentalConsent: Bool = false,
        parentEmail: String? = nil
    ) {
        self.id = UUID().uuidString
        self.userId = userId
        self.termsAccepted = termsAccepted
        self.privacyAccepted = privacyAccepted
        self.ageVerified = ageVerified
        self.waiverAccepted = waiverAccepted
        self.ferpaAcknowledged = ferpaAcknowledged
        self.aiDisclaimerAccepted = aiDisclaimerAccepted
        self.coppaParentalConsent = coppaParentalConsent
        self.parentEmail = parentEmail
        self.consentDate = Date()
        self.termsVersion = LegalTexts.lastUpdated
        self.privacyVersion = LegalTexts.lastUpdated
        self.ipAddress = nil
    }

    var allRequiredConsentsGiven: Bool {
        termsAccepted && privacyAccepted && ageVerified && waiverAccepted && aiDisclaimerAccepted
    }
}

// MARK: - Consent Manager
// Handles checking and saving consent state

@Observable
final class ConsentManager {
    var hasConsented: Bool = false

    func checkConsent() {
        // Check UserDefaults for consent (lightweight check on launch)
        hasConsented = UserDefaults.standard.bool(forKey: "ladder_consent_given")
    }

    func recordConsent() {
        UserDefaults.standard.set(true, forKey: "ladder_consent_given")
        UserDefaults.standard.set(Date().ISO8601Format(), forKey: "ladder_consent_date")
        UserDefaults.standard.set(LegalTexts.lastUpdated, forKey: "ladder_consent_version")
        hasConsented = true
    }

    func revokeConsent() {
        UserDefaults.standard.removeObject(forKey: "ladder_consent_given")
        UserDefaults.standard.removeObject(forKey: "ladder_consent_date")
        UserDefaults.standard.removeObject(forKey: "ladder_consent_version")
        hasConsented = false
    }

    var consentNeedsUpdate: Bool {
        let savedVersion = UserDefaults.standard.string(forKey: "ladder_consent_version") ?? ""
        return savedVersion != LegalTexts.lastUpdated
    }
}
