import SwiftUI

// Data-dense row component for counselor queue + admin dashboards.
// 44pt row height, sortable headers, sticky columns. Keeps Dynamic Type
// scale clamped to .xxxLarge so layouts do not explode.

public struct DenseColumn<Row>: Identifiable {
    public let id: String
    public let title: String
    public let width: CGFloat?
    public let render: (Row) -> AnyView
    public let sortable: Bool

    public init(id: String, title: String, width: CGFloat? = nil, sortable: Bool = true,
                render: @escaping (Row) -> AnyView) {
        self.id = id
        self.title = title
        self.width = width
        self.sortable = sortable
        self.render = render
    }
}

public struct DataDenseTable<Row: Identifiable>: View {
    public let rows: [Row]
    public let columns: [DenseColumn<Row>]
    public var onSort: ((String) -> Void)?

    public init(rows: [Row], columns: [DenseColumn<Row>], onSort: ((String) -> Void)? = nil) {
        self.rows = rows
        self.columns = columns
        self.onSort = onSort
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(rows) { row in
                        DenseRow(row: row, columns: columns)
                            .frame(minHeight: 44)
                        Divider()
                    }
                }
            }
        }
        .denseDynamicType()
    }

    private var header: some View {
        HStack(spacing: 12) {
            ForEach(columns) { col in
                Button {
                    if col.sortable { onSort?(col.id) }
                } label: {
                    Text(col.title)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: col.width, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

private struct DenseRow<Row: Identifiable>: View {
    let row: Row
    let columns: [DenseColumn<Row>]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(columns) { col in
                col.render(row)
                    .frame(width: col.width, alignment: .leading)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}
