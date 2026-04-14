import Foundation

enum DeadlineCalculator {
    /// Returns the application year for a student given their grad year
    /// Senior year apps go in (grad year - 1) cycle
    static func applicationYear(forGradYear gradYear: Int) -> Int {
        gradYear - 1  // Senior fall = grad year minus 1 in calendar terms
    }

    /// EA / ED Nov 1 of senior fall
    static func earlyDecisionDate(forGradYear gradYear: Int) -> Date {
        var components = DateComponents()
        components.year = applicationYear(forGradYear: gradYear)
        components.month = 11
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Regular Decision Jan 1-15 of grad year
    static func regularDecisionDate(forGradYear gradYear: Int) -> Date {
        var components = DateComponents()
        components.year = gradYear
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    /// FAFSA opens Oct 1 of senior year
    static func fafsaOpenDate(forGradYear gradYear: Int) -> Date {
        var components = DateComponents()
        components.year = applicationYear(forGradYear: gradYear)
        components.month = 10
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Format a date as "Month D, YYYY"
    static func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    /// Days from now to a future date
    static func daysUntil(_ date: Date) -> Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        return max(0, days)
    }
}
