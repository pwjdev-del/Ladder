import SwiftUI

// MARK: - AdaptiveContainer
// Shared layout primitive for iPad parity (T022). Used by T023-T027.
// Stitch source: docs/design/stitch-batches/_shared-header.md
//
// Switches between:
//   compact (iPhone, iPad portrait-multitask) — shows `primary` pane only, full-width
//   regular (iPad full-screen portrait + landscape) — HStack: primary (40%) | Divider | detail (60%)
//
// Primary pane max-width is capped at 480pt on regular to prevent a login form
// stretching 1024pt wide on an iPad Pro 12.9". Detail pane fills the remaining space.

/// Splits content into a primary pane and an optional detail pane on iPad regular width.
/// On compact (iPhone or iPad multitask) only the primary pane is shown.
public struct AdaptiveContainer<Primary: View, Detail: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let primaryMaxWidth: CGFloat
    private let primary: () -> Primary
    private let detail: () -> Detail

    /// - Parameters:
    ///   - primaryMaxWidth: Maximum width for the primary pane on regular size class (default 480).
    ///   - primary: Always-visible pane (full-width on compact, left column on regular).
    ///   - detail: Optional pane shown on regular width only (right column, fills remaining space).
    public init(
        primaryMaxWidth: CGFloat = 480,
        @ViewBuilder primary: @escaping () -> Primary,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.primaryMaxWidth = primaryMaxWidth
        self.primary = primary
        self.detail = detail
    }

    public var body: some View {
        if sizeClass == .regular {
            HStack(spacing: 0) {
                primary()
                    .frame(maxWidth: primaryMaxWidth)

                Divider()
                    .overlay(LadderBrand.cream100.opacity(0.15))

                detail()
                    .frame(maxWidth: .infinity)
            }
        } else {
            primary()
        }
    }
}

// Convenience initialiser when there is no detail pane (single-column screens).
extension AdaptiveContainer where Detail == EmptyView {
    public init(
        primaryMaxWidth: CGFloat = 480,
        @ViewBuilder primary: @escaping () -> Primary
    ) {
        self.init(primaryMaxWidth: primaryMaxWidth, primary: primary, detail: { EmptyView() })
    }
}

// MARK: - AdaptiveStack
// Switches axis based on horizontal size class.
// Useful for form rows, button stacks, and stat grids that benefit from
// horizontal spread on iPad but should stay vertical on iPhone.

/// Lays out content vertically on compact and horizontally on regular size class.
public struct AdaptiveStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let compactSpacing: CGFloat
    private let regularSpacing: CGFloat
    private let alignment: Alignment
    private let content: () -> Content

    public init(
        compactSpacing: CGFloat = 12,
        regularSpacing: CGFloat = 24,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.compactSpacing = compactSpacing
        self.regularSpacing = regularSpacing
        self.alignment = alignment
        self.content = content
    }

    public var body: some View {
        if sizeClass == .regular {
            HStack(alignment: alignment.vertical, spacing: regularSpacing) {
                content()
            }
        } else {
            VStack(alignment: alignment.horizontal, spacing: compactSpacing) {
                content()
            }
        }
    }
}

// MARK: - MaxWidthContainer
// Caps content at a maximum width and centers it horizontally.
// Use on single-column flows (login, signup, landing CTAs) so they don't
// stretch absurdly wide on iPad Pro 12.9" or iPad Pro 13" (M4).

/// Centers content within a capped width — prevents single-column flows from
/// becoming unreadably wide on large iPad screens.
public struct MaxWidthContainer<Content: View>: View {
    private let maxWidth: CGFloat
    private let content: () -> Content

    /// - Parameter maxWidth: Maximum content width (default 480).
    public init(maxWidth: CGFloat = 480, @ViewBuilder content: @escaping () -> Content) {
        self.maxWidth = maxWidth
        self.content = content
    }

    public var body: some View {
        content()
            .frame(maxWidth: maxWidth)
            .frame(maxWidth: .infinity) // centres within the parent
    }
}

// MARK: - Alignment helper

private extension Alignment {
    var horizontal: HorizontalAlignment {
        switch self {
        case .leading, .topLeading, .bottomLeading: return .leading
        case .trailing, .topTrailing, .bottomTrailing: return .trailing
        default: return .center
        }
    }

    var vertical: VerticalAlignment {
        switch self {
        case .top, .topLeading, .topTrailing: return .top
        case .bottom, .bottomLeading, .bottomTrailing: return .bottom
        default: return .center
        }
    }
}

// MARK: - FlowLayout
// Shared wrapping layout used across the app for chip rows and tag clouds.
// Declared here once so individual feature files don't redeclare it.

/// Wraps child views into rows, breaking to a new row when the available width
/// is exceeded. Use for chip rows, tag clouds, and keyword lists.
public struct FlowLayout: Layout {
    public var spacing: CGFloat

    public init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for v in subviews {
            let size = v.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: y + rowHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for v in subviews {
            let size = v.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            v.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

// MARK: - Previews

#if DEBUG
#Preview("AdaptiveContainer — iPhone 15", traits: .sizeThatFitsLayout) {
    AdaptiveContainer {
        Text("Primary").frame(maxWidth: .infinity, maxHeight: .infinity).background(.green.opacity(0.2))
    } detail: {
        Text("Detail").frame(maxWidth: .infinity, maxHeight: .infinity).background(.blue.opacity(0.2))
    }
    .frame(width: 393, height: 852)
}

#Preview("AdaptiveContainer — iPad Air 10.9 portrait", traits: .sizeThatFitsLayout) {
    AdaptiveContainer {
        Text("Primary").frame(maxWidth: .infinity, maxHeight: .infinity).background(.green.opacity(0.2))
    } detail: {
        Text("Detail").frame(maxWidth: .infinity, maxHeight: .infinity).background(.blue.opacity(0.2))
    }
    .frame(width: 820, height: 1180)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("AdaptiveContainer — iPad Pro 12.9 landscape", traits: .sizeThatFitsLayout) {
    AdaptiveContainer {
        Text("Primary").frame(maxWidth: .infinity, maxHeight: .infinity).background(.green.opacity(0.2))
    } detail: {
        Text("Detail").frame(maxWidth: .infinity, maxHeight: .infinity).background(.blue.opacity(0.2))
    }
    .frame(width: 1366, height: 1024)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("MaxWidthContainer — iPad Pro 12.9", traits: .sizeThatFitsLayout) {
    MaxWidthContainer(maxWidth: 480) {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.green.opacity(0.3))
            .frame(height: 200)
    }
    .frame(width: 1366)
    .environment(\.horizontalSizeClass, .regular)
}
#endif
