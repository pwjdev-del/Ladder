import SwiftUI

// 7-period × 5-day schedule grid. Used by student (schedule builder) and
// counselor (approval review). Conflict overlay layer driven by
// ConflictOverlay.

public struct ScheduleCell: Identifiable, Sendable {
    public let id = UUID()
    public let period: String
    public let day: Int          // 1-5
    public let classTitle: String?
    public let hasConflict: Bool
}

public struct ScheduleGrid: View {
    public let cells: [ScheduleCell]
    public let periods: [String]
    public let days: [String]
    public let onTap: ((ScheduleCell) -> Void)?

    public init(cells: [ScheduleCell] = [],
                periods: [String] = ["P1", "P2", "P3", "P4", "P5", "P6", "P7"],
                days: [String] = ["Mon", "Tue", "Wed", "Thu", "Fri"],
                onTap: ((ScheduleCell) -> Void)? = nil) {
        self.cells = cells
        self.periods = periods
        self.days = days
        self.onTap = onTap
    }

    public var body: some View {
        VStack(spacing: 2) {
            // Header row
            HStack(spacing: 2) {
                Text("").frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day).font(.caption).frame(maxWidth: .infinity)
                }
            }
            // Body rows
            ForEach(periods, id: \.self) { period in
                HStack(spacing: 2) {
                    Text(period).font(.caption.monospaced()).frame(width: 40)
                    ForEach(1...days.count, id: \.self) { dayIdx in
                        let cell = cells.first(where: { $0.period == period && $0.day == dayIdx })
                        ScheduleCellView(cell: cell) { tapped in
                            onTap?(tapped)
                        }
                    }
                }
            }
        }
        .denseDynamicType()
    }
}

private struct ScheduleCellView: View {
    let cell: ScheduleCell?
    let onTap: (ScheduleCell) -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .frame(height: 40)
            .overlay(alignment: .center) {
                Text(cell?.classTitle ?? "—").font(.caption2)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(cell?.hasConflict == true ? Color.red : Color.clear, lineWidth: 2)
            )
            .onTapGesture {
                if let cell { onTap(cell) }
            }
            .accessibilityLabel(cell?.classTitle ?? "Empty")
    }

    private var fillColor: Color {
        if cell?.hasConflict == true { return Color.red.opacity(0.08) }
        if cell?.classTitle == nil { return Color.secondary.opacity(0.05) }
        return Color.accentColor.opacity(0.12)
    }
}
