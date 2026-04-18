import Foundation
import SwiftData

// MARK: - Financial Aid Package Model

@Model
final class FinancialAidPackageModel {
    var collegeId: String
    var collegeName: String
    var tuitionCost: Int = 0
    var roomBoardCost: Int = 0
    var feesCost: Int = 0
    var grantAid: Int = 0
    var scholarshipAid: Int = 0
    var loanAmount: Int = 0
    var workStudy: Int = 0
    var createdAt: Date

    var totalCost: Int { tuitionCost + roomBoardCost + feesCost }
    var totalAid: Int { grantAid + scholarshipAid }
    var netCost: Int { totalCost - totalAid }

    init(collegeId: String, collegeName: String) {
        self.collegeId = collegeId
        self.collegeName = collegeName
        self.createdAt = Date()
    }
}
