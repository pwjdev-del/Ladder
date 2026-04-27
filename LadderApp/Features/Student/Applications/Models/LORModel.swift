import Foundation
import SwiftData

// MARK: - Letter of Recommendation Model

@Model
final class LetterOfRecModel {
    var recommenderName: String
    var recommenderRole: String // "Teacher", "Counselor", "Coach", "Other"
    var subject: String?
    var requestedAt: Date?
    var dueDate: Date?
    var status: String = "not_requested" // not_requested, requested, in_progress, submitted, received
    var collegesFor: [String] = []
    var notes: String?
    var createdAt: Date

    init(recommenderName: String, recommenderRole: String) {
        self.recommenderName = recommenderName
        self.recommenderRole = recommenderRole
        self.createdAt = Date()
    }
}
