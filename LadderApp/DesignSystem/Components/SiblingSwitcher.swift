import SwiftUI

public struct SiblingSwitcher<Item: Identifiable & Hashable>: View {
    public let items: [Item]
    @Binding public var selection: Item?
    public let label: (Item) -> String

    public init(items: [Item], selection: Binding<Item?>, label: @escaping (Item) -> String) {
        self.items = items
        self._selection = selection
        self.label = label
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    Button {
                        selection = item
                    } label: {
                        Text(label(item))
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(selection == item ? Color.accentColor : Color.secondary.opacity(0.15))
                            .foregroundStyle(selection == item ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}
