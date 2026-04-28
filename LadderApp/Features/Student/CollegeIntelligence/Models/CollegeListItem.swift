import Foundation

// CollegeListItem — view-model row that flattens a CollegeModel into the
// shape Discovery + Saved + the Match calculator consume.
//
// Promoted out of Features/Legacy/CollegeIntelligence/ViewModels/
// CollegeDiscoveryViewModel.swift in Phase 2c follow-up so
// Services/Data/CollegeScorecardService can compile in the active build.

struct CollegeListItem: Identifiable {
    let id: String
    let name: String
    let location: String
    let matchPercent: Int?
    let imageURL: String?
    let websiteURL: String?
    let tags: [String]
    let acceptanceRate: Double?
    let tuition: Int?
    let enrollment: Int?
    let satRange: String?
    let type: String

    let satAvg: Int?
    let sat25: Int?
    let sat75: Int?

    let testingPolicy: String?
    let applicationFee: String?
    let topMeritScholarship: String?
    let state: String?
    let programs: [String]

    init(from model: CollegeModel) {
        self.id = model.scorecardId.map(String.init) ?? model.name
        self.name = model.name
        self.location = [model.city, model.state].compactMap { $0 }.joined(separator: ", ")
        self.matchPercent = nil
        self.imageURL = model.imageURL
        self.websiteURL = model.websiteURL
        self.acceptanceRate = model.acceptanceRate
        self.tuition = model.inStateTuition
        self.enrollment = model.enrollment
        self.type = model.institutionType ?? "Unknown"
        self.state = model.state
        self.testingPolicy = model.testingPolicy
        self.applicationFee = model.applicationFee
        self.topMeritScholarship = model.topMeritScholarship
        self.programs = model.programs
        self.satAvg = model.satAvg

        if let m25 = model.satMath25, let r25 = model.satReading25 {
            self.sat25 = m25 + r25
        } else {
            self.sat25 = nil
        }
        if let m75 = model.satMath75, let r75 = model.satReading75 {
            self.sat75 = m75 + r75
        } else {
            self.sat75 = nil
        }

        if let sat25 = self.sat25, let sat75 = self.sat75 {
            self.satRange = "\(sat25)–\(sat75)"
        } else if let avg = model.satAvg {
            self.satRange = "\(avg)"
        } else {
            self.satRange = nil
        }

        var t: [String] = []
        if let type = model.institutionType { t.append(type) }
        if let size = model.sizeCategory { t.append(size) }
        if model.isHBCU { t.append("HBCU") }
        if model.testingPolicy?.lowercased().contains("optional") == true { t.append("Test-Optional") }
        self.tags = t
    }

    init(id: String, name: String, location: String, matchPercent: Int?, imageURL: String?, websiteURL: String? = nil, tags: [String], acceptanceRate: Double?, tuition: Int?, enrollment: Int?, satRange: String?, type: String) {
        self.id = id
        self.name = name
        self.location = location
        self.matchPercent = matchPercent
        self.imageURL = imageURL
        self.websiteURL = websiteURL
        self.tags = tags
        self.acceptanceRate = acceptanceRate
        self.tuition = tuition
        self.enrollment = enrollment
        self.satRange = satRange
        self.type = type
        self.satAvg = nil
        self.sat25 = nil
        self.sat75 = nil
        self.testingPolicy = nil
        self.applicationFee = nil
        self.topMeritScholarship = nil
        self.state = nil
        self.programs = []
    }

    static var sampleColleges: [CollegeListItem] {
        CollegeScorecardService.bundledTopColleges
    }
}
