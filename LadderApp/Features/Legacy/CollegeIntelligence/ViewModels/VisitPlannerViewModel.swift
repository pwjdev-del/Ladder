import SwiftUI
import SwiftData
import MapKit

// MARK: - Visit Planner ViewModel

@Observable
final class VisitPlannerViewModel {

    var savedColleges: [CollegeModel] = []
    var visits: [CollegeVisitModel] = []
    var searchText = ""
    var sortOrder: SortOrder = .date
    var filterStatus: VisitStatus? = nil

    // Plan visit sheet
    var showingPlanSheet = false
    var planningCollege: CollegeModel?
    var visitDate = Date()
    var visitTime = Date()
    var visitNotes = ""
    var includeTime = false

    // Map
    var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.8283, longitude: -98.5795),
        span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30)
    )

    enum SortOrder: String, CaseIterable {
        case date = "Visit Date"
        case alphabetical = "A-Z"
        case status = "Status"
    }

    enum VisitStatus: String, CaseIterable {
        case notPlanned = "Not Planned"
        case planned = "Planned"
        case visited = "Visited"
    }

    init() {}

    // MARK: - Load Data

    @MainActor
    func loadData(from context: ModelContext) {
        // Load saved colleges
        let profileDescriptor = FetchDescriptor<StudentProfileModel>()
        guard let profile = try? context.fetch(profileDescriptor).first else { return }

        let savedIds = Set(profile.savedCollegeIds)
        guard !savedIds.isEmpty else { return }

        let collegeDescriptor = FetchDescriptor<CollegeModel>(sortBy: [SortDescriptor(\.name)])
        guard let allColleges = try? context.fetch(collegeDescriptor) else { return }

        savedColleges = allColleges.filter { college in
            if let sid = college.supabaseId { return savedIds.contains(sid) }
            if let scid = college.scorecardId { return savedIds.contains(String(scid)) }
            return false
        }

        // Load visits
        let visitDescriptor = FetchDescriptor<CollegeVisitModel>(sortBy: [SortDescriptor(\.visitDate)])
        visits = (try? context.fetch(visitDescriptor)) ?? []

        updateMapRegion()
    }

    // MARK: - Filtered & Sorted Colleges

    var displayColleges: [CollegeVisitItem] {
        var items = savedColleges.map { college -> CollegeVisitItem in
            let visit = visitFor(college)
            let status: VisitStatus
            if let v = visit {
                status = v.hasVisited ? .visited : .planned
            } else {
                status = .notPlanned
            }
            return CollegeVisitItem(college: college, visit: visit, status: status)
        }

        // Filter by search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            items = items.filter { $0.college.name.lowercased().contains(query) }
        }

        // Filter by status
        if let filterStatus {
            items = items.filter { $0.status == filterStatus }
        }

        // Sort
        switch sortOrder {
        case .date:
            items.sort { a, b in
                let dateA = a.visit?.visitDate ?? .distantFuture
                let dateB = b.visit?.visitDate ?? .distantFuture
                return dateA < dateB
            }
        case .alphabetical:
            items.sort { $0.college.name < $1.college.name }
        case .status:
            let order: [VisitStatus] = [.visited, .planned, .notPlanned]
            items.sort { order.firstIndex(of: $0.status)! < order.firstIndex(of: $1.status)! }
        }

        return items
    }

    // MARK: - Map Annotations

    var mapAnnotations: [CollegeMapPin] {
        savedColleges.compactMap { college in
            guard let lat = college.latitude, let lon = college.longitude else { return nil }
            let visit = visitFor(college)
            let status: VisitStatus
            if let v = visit {
                status = v.hasVisited ? .visited : .planned
            } else {
                status = .notPlanned
            }
            return CollegeMapPin(
                id: college.supabaseId ?? String(college.scorecardId ?? 0),
                name: college.name,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                status: status
            )
        }
    }

    // MARK: - Visit CRUD

    func visitFor(_ college: CollegeModel) -> CollegeVisitModel? {
        let collegeKey = college.supabaseId ?? String(college.scorecardId ?? 0)
        return visits.first { $0.collegeId == collegeKey }
    }

    @MainActor
    func beginPlanVisit(for college: CollegeModel) {
        planningCollege = college
        let existing = visitFor(college)
        visitDate = existing?.visitDate ?? Date()
        visitTime = existing?.tourTime ?? Date()
        visitNotes = existing?.notes ?? ""
        includeTime = existing?.tourTime != nil
        showingPlanSheet = true
    }

    @MainActor
    func saveVisit(context: ModelContext) {
        guard let college = planningCollege else { return }
        let collegeKey = college.supabaseId ?? String(college.scorecardId ?? 0)

        if let existing = visitFor(college) {
            existing.visitDate = visitDate
            existing.tourTime = includeTime ? visitTime : nil
            existing.notes = visitNotes
        } else {
            let visit = CollegeVisitModel(collegeId: collegeKey, collegeName: college.name)
            visit.visitDate = visitDate
            visit.tourTime = includeTime ? visitTime : nil
            visit.notes = visitNotes
            context.insert(visit)
            visits.append(visit)
        }

        try? context.save()
        showingPlanSheet = false
    }

    @MainActor
    func markAsVisited(_ college: CollegeModel, context: ModelContext) {
        let collegeKey = college.supabaseId ?? String(college.scorecardId ?? 0)
        if let existing = visitFor(college) {
            existing.hasVisited = true
        } else {
            let visit = CollegeVisitModel(collegeId: collegeKey, collegeName: college.name)
            visit.visitDate = Date()
            visit.hasVisited = true
            context.insert(visit)
            visits.append(visit)
        }
        try? context.save()
    }

    @MainActor
    func updateNotes(for college: CollegeModel, notes: String, context: ModelContext) {
        if let existing = visitFor(college) {
            existing.notes = notes
            try? context.save()
        }
    }

    // MARK: - Add to Calendar

    func addToCalendar(college: CollegeModel) async -> Bool {
        let title = "Campus Visit: \(college.name)"
        let location = [college.city, college.state].compactMap { $0 }.joined(separator: ", ")
        return await CalendarManager.shared.addDeadline(
            title: title,
            date: visitDate,
            notes: visitNotes.isEmpty ? nil : visitNotes,
            location: location.isEmpty ? nil : location
        )
    }

    // MARK: - Map

    private func updateMapRegion() {
        let pins = mapAnnotations
        guard !pins.isEmpty else { return }

        let lats = pins.map { $0.coordinate.latitude }
        let lons = pins.map { $0.coordinate.longitude }
        let center = CLLocationCoordinate2D(
            latitude: (lats.min()! + lats.max()!) / 2,
            longitude: (lons.min()! + lons.max()!) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(5, (lats.max()! - lats.min()!) * 1.3),
            longitudeDelta: max(5, (lons.max()! - lons.min()!) * 1.3)
        )
        mapRegion = MKCoordinateRegion(center: center, span: span)
    }

    // MARK: - Stats

    var plannedCount: Int { visits.filter { !$0.hasVisited }.count }
    var visitedCount: Int { visits.filter { $0.hasVisited }.count }
}

// MARK: - Supporting Types

struct CollegeVisitItem: Identifiable {
    var id: String { college.supabaseId ?? String(college.scorecardId ?? 0) }
    let college: CollegeModel
    let visit: CollegeVisitModel?
    let status: VisitPlannerViewModel.VisitStatus
}

struct CollegeMapPin: Identifiable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let status: VisitPlannerViewModel.VisitStatus
}
