#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A reusable list row view that supports displaying an icon, a title, a subtitle,
/// a detail view, and an accessory icon.
///
/// The layout of the row adapts based on the `horizontalSizeClass`.
public struct ListRow<BodyContentType: View, HeaderContentType: View, DetailContentType: View>: View {
    private enum Presentation {
        case adaptive
        case card
    }

    /// Defines the positioning of the detail view in compact size classes.
    public enum CompactDetailPositionning: String {
        /// Positions the detail view at the top-leading corner.
        case topLeading
        /// Positions the detail view at the top-trailing corner.
        case topTrailing
        /// Positions the detail view at the trailing edge of the main content.
        case trailing
    }

    @Environment(\.theme) var theme

    /// The main content of the row, typically a title and optional subtitle, provided as a `ViewBuilder`.
    public let content: @Sendable @MainActor () -> BodyContentType

    /// An optional detail view displayed on the right side of the row (or top-leading/top-trailing in compact).
    public let detail: @Sendable @MainActor () -> DetailContentType?

    /// An optional header view, usually an icon or image, displayed at the leading edge of the row.
    public let header: @Sendable @MainActor () -> HeaderContentType?

    /// An optional accessory icon displayed at the end of the row (e.g., a chevron).
    public let accessory: Image?

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    /// The preferred positioning for the detail view when in a compact horizontal size class.
    public let compactDetailPositioning: CompactDetailPositionning
    private let presentation: Presentation
    private let cardBackground: AnyShapeStyle?

    /// Initializes a new instance of `ListRow`.
    /// - Parameters:
    ///   - content: A `ViewBuilder` for the main content of the row.
    ///   - header: An optional `ViewBuilder` for the leading header view. Defaults to `nil`.
    ///   - detail: An optional `ViewBuilder` for the detail view. Defaults to `nil`.
    ///   - accessory: An optional `Image` to use as an accessory icon. Defaults to `nil`.
    ///   - compactDetailPositioning: The position of the detail view in compact size classes. Defaults to `.trailing`.
    public init(
        content: @escaping @Sendable @MainActor () -> BodyContentType,
        header: (@escaping @Sendable @MainActor () -> HeaderContentType?) = { nil },
        detail: (@escaping @Sendable @MainActor () -> DetailContentType?) = { nil },
        accessory: Image? = nil,
        compactDetailPositioning: CompactDetailPositionning = .trailing
    ) {
        self.header = header
        self.content = content
        self.detail = detail
        self.accessory = accessory
        self.compactDetailPositioning = compactDetailPositioning
        presentation = .adaptive
        cardBackground = nil
    }

    /// Initializes a new instance of `ListRow` with an SF Symbol as the accessory.
    /// - Parameters:
    ///   - content: A `ViewBuilder` for the main content of the row.
    ///   - header: An optional `ViewBuilder` for the leading header view. Defaults to `nil`.
    ///   - detail: An optional `ViewBuilder` for the detail view. Defaults to `nil`.
    ///   - symbol: The `SFSymbol` to use as the accessory icon.
    ///   - compactDetailPositioning: The position of the detail view in compact size classes. Defaults to `.trailing`.
    public init(
        content: @escaping @Sendable @MainActor () -> BodyContentType,
        header: (@escaping @Sendable @MainActor () -> HeaderContentType?) = { nil },
        detail: (@escaping @Sendable @MainActor () -> DetailContentType?) = { nil },
        symbol: SFSymbol,
        compactDetailPositioning: CompactDetailPositionning = .trailing
    ) {
        self.header = header
        self.content = content
        self.detail = detail
        self.accessory = .init(systemSymbol: symbol)
        self.compactDetailPositioning = compactDetailPositioning
        presentation = .adaptive
        cardBackground = nil
    }

    public var body: some View {
        if presentation == .card {
            cardBody
        } else {
            adaptiveBody
        }
    }

    private var adaptiveBody: some View {
        Group {
            if horizontalSizeClass == .regular {
                HStack(alignment: .center, spacing: .small) {
                    if let header = header() {
                        header
                            .accessibilityIdentifier("list-row-header")
                    }

                    content()
                        .accessibilityIdentifier("list-row-body")

                    Spacer()

                    if let detail = detail() {
                        detail
                            .accessibilityIdentifier("list-row-detail-view")
                    }

                    if let accessory {
                        accessory
                            .symbolRenderingMode(.monochrome)
                            .renderingMode(.template)
                            .flipsForRightToLeftLayoutDirection(true)
                            .imageScale(.small)
                            .foregroundStyle(theme.text3)
                            .accessibilityIdentifier("list-row-accessory-view")
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: .small) {
                    if compactDetailPositioning == .topLeading, let detail = detail() {
                        detail
                            .accessibilityIdentifier("list-row-detail-view")
                    } else if compactDetailPositioning == .topTrailing, let detail = detail() {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()

                            detail
                                .accessibilityIdentifier("list-row-detail-view")
                        }
                    }

                    HStack(alignment: .center, spacing: .small) {
                        if let header = header() {
                            header
                                .accessibilityIdentifier("list-row-header")
                        }

                        content()
                            .accessibilityIdentifier("list-row-body")

                        Spacer()

                        if let detail = detail(), compactDetailPositioning == .trailing {
                            detail
                                .accessibilityIdentifier("list-row-detail-view")
                        }

                        if let accessory {
                            accessory
                                .symbolRenderingMode(.monochrome)
                                .renderingMode(.template)
                                .flipsForRightToLeftLayoutDirection(true)
                                .imageScale(.small)
                                .foregroundStyle(theme.text3)
                                .accessibilityIdentifier("list-row-accessory-view")
                        }
                    }
                }
            }
        }
        .padding(.medium)
        .background(theme.background1)
        .listRowInsets(.zero)
    }

    private var cardBody: some View {
        HStack(spacing: .xs) {
            if let header = header() {
                header
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .font(.body)
                    .foregroundStyle(theme.text2)
            }

            content()

            Spacer()

            if let detail = detail() {
                detail
                    .font(.caption)
                    .foregroundStyle(theme.text2)
                    .multilineTextAlignment(.trailing)
            }

            if let accessory {
                accessory
                    .font(.subheadline)
                    .foregroundStyle(theme.text3)
            }
        }
        .padding(.small)
        .background(cardBackground ?? AnyShapeStyle(Material.thin))
        .contentShape(RoundedRectangle(cornerRadius: .small))
        .clipShape(RoundedRectangle(cornerRadius: .small))
        .overlay {
            RoundedRectangle(cornerRadius: .small)
                .stroke(theme.border, lineWidth: 1)
                .shadow(color: theme.shadow, radius: 4, x: 2, y: 2)
        }
    }
}

public extension ListRow where BodyContentType == ListRowBody, HeaderContentType == Image, DetailContentType == Text {
    /// Initializes a compact, card-styled list row.
    init(
        icon: SFSymbol? = nil,
        title: String,
        subtitle: String? = nil,
        caption: String? = nil,
        detail: String? = nil,
        background: (any ShapeStyle)? = nil,
        showChevron: Bool = true
    ) {
        content = { ListRowBody(title: title, subtitle: subtitle, caption: caption) }
        header = {
            icon.map {
                Image(systemSymbol: $0)
                    .resizable()
            }
        }
        self.detail = { detail.map { Text($0) } }
        accessory = showChevron ? Image(systemSymbol: .chevronRight) : nil
        compactDetailPositioning = .trailing
        presentation = .card
        cardBackground = background.map { AnyShapeStyle($0) }
    }
}

#endif

#if DEBUG
@MainActor enum ListRowPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") { Content() }
        PreviewSnapshot("card") { CardContent() }
    }

    private struct Content: View {
        @Environment(\.theme) private var theme

        var body: some View {
            AdaptativeStack { _ in
                row
                row
            }
            .padding()
            .background(theme.backgroundGradient)
        }

        private var row: some View {
            ListRow(content: {
                ListRowBody(title: "Title", subtitle: "Subtitle")
            }, header: {
                FramedIcon(icon: Image(systemSymbol: .eye))
            }, detail: {
                StatusPill(text: "Beta", background: theme.success, foreground: theme.textOverSuccess)
            })
            .cardify()
        }
    }

    private struct CardContent: View {
        @Environment(\.theme) private var theme

        var body: some View {
            VStack(spacing: .small) {
                ListRow(
                    icon: .eye,
                    title: "Title",
                    subtitle: "Subtitle",
                    caption: "Caption",
                    detail: "Detail"
                )

                ListRow(
                    title: "Custom background",
                    detail: "No chevron",
                    background: theme.background2,
                    showChevron: false
                )

                Spacer()
            }
            .padding()
            .background(theme.backgroundGradient)
        }
    }
}
#endif
