#if canImport(SwiftUI)
import CalderSwiftUI
import SnapshotPreviews
import SwiftUI

/// A view that arranges its subviews in horizontal line and wraps them to the next lines if necessary.
///
/// This layout provides a flexible way to display a collection of views that
/// automatically flow to the next line when the available horizontal space is exhausted.
public struct WrappingHStackLayout: Layout {
    /// The guide for aligning the subviews in this stack. This guide has the same screen coordinate for every subview.
    public var alignment: Alignment

    /// The distance between adjacent subviews in a row or `nil` if you want the stack to choose a default distance.
    public var horizontalSpacing: CGFloat?

    /// The distance between consequtive rows or`nil` if you want the stack to choose a default distance.
    public var verticalSpacing: CGFloat?

    /// Creates a wrapping horizontal stack with the given spacings and alignment.
    ///
    /// - Parameters:
    ///   - alignment: The guide for aligning the subviews in this stack. This guide has the same screen coordinate for every subview.
    ///   - horizontalSpacing: The distance between adjacent subviews in a row or `nil` if you want the stack to choose a default distance.
    ///   - verticalSpacing: The distance between consequtive rows or`nil` if you want the stack to choose a default distance.
    ///   - content: A view builder that creates the content of this stack.
    @inlinable public init(
        alignment: Alignment = .center,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil
    ) {
        self.alignment = alignment
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal

        return properties
    }

    /// A shared computation between `sizeThatFits` and `placeSubviews`.
    public struct Cache {

        /// The minimal size of the view.
        var minSize: CGSize

        /// The cached rows.
        var rows: (Int, [Row])?
    }

    /// Creates a new cache for the layout.
    /// - Parameter subviews: The subviews to consider for the cache.
    /// - Returns: A `Cache` instance initialized with the minimal size.
    public func makeCache(subviews: Subviews) -> Cache {
        Cache(minSize: minSize(subviews: subviews))
    }

    /// Updates the existing cache with new subview information.
    /// - Parameters:
    ///   - cache: A binding to the cache to update.
    ///   - subviews: The current subviews to consider.
    public func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache.minSize = minSize(subviews: subviews)
    }

    /// Asks the layout to recommend a size for the container.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the container.
    ///   - subviews: The subviews of the container.
    ///   - cache: The layout's cache.
    /// - Returns: The recommended size that fits the subviews within the proposed size.
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        let rows = arrangeRows(proposal: proposal, subviews: subviews, cache: &cache)

        if rows.isEmpty {
            return cache.minSize
        }

        let width = proposal.width ?? rows.map(\.width).reduce(.zero) { max($0, $1) }

        var height: CGFloat = .zero
        if let lastRow = rows.last {
            height = lastRow.yOffset + lastRow.height
        }

        return CGSize(width: width, height: height)
    }

    /// Places the subviews within the given bounds.
    ///
    /// - Parameters:
    ///   - bounds: The bounding rectangle in which to place the subviews.
    ///   - proposal: The proposed size for the container.
    ///   - subviews: The subviews to place.
    ///   - cache: The layout's cache.
    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        let rows = arrangeRows(proposal: proposal, subviews: subviews, cache: &cache)

        let anchor = UnitPoint(alignment)

        for row in rows {
            for element in row.elements {
                let x: CGFloat = element.xOffset + anchor.x * (bounds.width - row.width)
                let y: CGFloat = row.yOffset + anchor.y * (row.height - element.size.height)
                let point = CGPoint(x: x + bounds.minX, y: y + bounds.minY)

                subviews[element.index].place(at: point, anchor: .topLeading, proposal: proposal)
            }
        }
    }

    /// A structure representing a single row of subviews within the `WrappingHStackLayout`.
    struct Row {
        /// An array of tuples, each containing the index of the subview, its size, and its x-offset within the row.
        var elements: [(index: Int, size: CGSize, xOffset: CGFloat)] = []
        /// The y-offset of the row from the top of the layout container.
        var yOffset: CGFloat = .zero
        /// The total width of the row.
        var width: CGFloat = .zero
        /// The height of the tallest subview in the row.
        var height: CGFloat = .zero
    }

    /// Arranges the subviews into rows based on the proposed size and layout properties.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the layout.
    ///   - subviews: The subviews to arrange.
    ///   - cache: The layout's cache.
    /// - Returns: An array of `Row` structures, representing the organized layout of subviews.
    private func arrangeRows(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> [Row] {
        if subviews.isEmpty {
            return []
        }

        if cache.minSize.width > proposal.width ?? .infinity,
           cache.minSize.height > proposal.height ?? .infinity {
            return []
        }

        let sizes = subviews.map { $0.sizeThatFits(proposal) }

        let hash = computeHash(proposal: proposal, sizes: sizes)
        if let (oldHash, oldRows) = cache.rows,
           oldHash == hash {
            return oldRows
        }

        var currentX = CGFloat.zero
        var currentRow = Row()
        var rows = [Row]()

        for index in subviews.indices {
            var spacing = CGFloat.zero
            if let previousIndex = currentRow.elements.last?.index {
                spacing = horizontalSpacing(subviews[previousIndex], subviews[index])
            }

            let size = sizes[index]

            if currentX + size.width + spacing > proposal.width ?? .infinity,
               !currentRow.elements.isEmpty {
                currentRow.width = currentX
                rows.append(currentRow)
                currentRow = Row()
                spacing = .zero
                currentX = .zero
            }

            currentRow.elements.append((index, sizes[index], currentX + spacing))
            currentX += size.width + spacing
        }

        if !currentRow.elements.isEmpty {
            currentRow.width = currentX
            rows.append(currentRow)
        }

        var currentY = CGFloat.zero
        var previousMaxHeightIndex: Int?

        for index in rows.indices {
            let maxHeightIndex = rows[index].elements
                // swiftlint:disable:next force_unwrapping
                .max { $0.size.height < $1.size.height }!
                .index

            let size = sizes[maxHeightIndex]

            var spacing = CGFloat.zero
            if let previousMaxHeightIndex {
                spacing = verticalSpacing(subviews[previousMaxHeightIndex], subviews[maxHeightIndex])
            }

            rows[index].yOffset = currentY + spacing
            currentY += size.height + spacing
            rows[index].height = size.height
            previousMaxHeightIndex = maxHeightIndex
        }

        cache.rows = (hash, rows)

        return rows
    }

    /// Computes a hash value based on the proposed size and the sizes of the subviews.
    /// This is used for caching layout calculations.
    ///
    /// - Parameters:
    ///   - proposal: The proposed size for the layout.
    ///   - sizes: An array of `CGSize` values for each subview.
    /// - Returns: An integer hash value.
    private func computeHash(proposal: ProposedViewSize, sizes: [CGSize]) -> Int {
        let proposal = proposal.replacingUnspecifiedDimensions(by: .infinity)

        var hasher = Hasher()

        for size in [proposal] + sizes {
            hasher.combine(size.width)
            hasher.combine(size.height)
        }

        return hasher.finalize()
    }

    /// Calculates the minimum size required to fit all subviews without wrapping.
    /// - Parameter subviews: The subviews to measure.
    /// - Returns: A `CGSize` representing the minimum size.
    private func minSize(subviews: Subviews) -> CGSize {
        subviews
            .map { $0.sizeThatFits(.zero) }
            .reduce(CGSize.zero) { CGSize(width: max($0.width, $1.width), height: max($0.height, $1.height)) }
    }

    /// Determines the horizontal spacing between two adjacent subviews.
    /// - Parameters:
    ///   - lhs: The left-hand side subview.
    ///   - rhs: The right-hand side subview.
    /// - Returns: The calculated horizontal spacing.
    private func horizontalSpacing(_ lhs: LayoutSubview, _ rhs: LayoutSubview) -> CGFloat {
        if let horizontalSpacing {
            return horizontalSpacing
        }

        return lhs.spacing.distance(to: rhs.spacing, along: .horizontal)
    }

    /// Determines the vertical spacing between two adjacent rows.
    /// - Parameters:
    ///   - lhs: A subview from the top row.
    ///   - rhs: A subview from the bottom row.
    /// - Returns: The calculated vertical spacing.
    private func verticalSpacing(_ lhs: LayoutSubview, _ rhs: LayoutSubview) -> CGFloat {
        if let verticalSpacing {
            return verticalSpacing
        }

        return lhs.spacing.distance(to: rhs.spacing, along: .vertical)
    }
}

private extension CGSize {
    /// A `CGSize` representing an infinite width and height.
    static var infinity: Self {
        .init(width: CGFloat.infinity, height: CGFloat.infinity)
    }
}

private extension UnitPoint {
    /// Initializes a `UnitPoint` from a SwiftUI `Alignment`.
    /// - Parameter alignment: The `Alignment` to convert.
    init(_ alignment: Alignment) {
        switch alignment {
            case .leading:
                self = .leading
            case .topLeading:
                self = .topLeading
            case .top:
                self = .top
            case .topTrailing:
                self = .topTrailing
            case .trailing:
                self = .trailing
            case .bottomTrailing:
                self = .bottomTrailing
            case .bottom:
                self = .bottom
            case .bottomLeading:
                self = .bottomLeading
            default:
                self = .center
        }
    }
}

#endif

#if DEBUG
@MainActor enum WrappingHStackLayoutPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            Content()
        }
    }

    private struct Content: View {
        @Environment(\.theme) private var theme

        var body: some View {
            WrappingHStackLayout(alignment: .leading) {
                Button("Tertiary", action: {})
                    .applyThemedStyle(variant: .tertiary(destructive: false))
                Button("Tertiary Destructive", action: {})
                    .applyThemedStyle(variant: .tertiary(destructive: true))
                Button("Tertiary", action: {})
                    .applyThemedStyle(
                        variant: .tertiary(
                            custom: LinearGradient(
                                colors: [theme.error, theme.success],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
            }
        }
    }
}
#endif
