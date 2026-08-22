#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A wrapping horizontal control presenting multiple tappable items,
/// allowing single‐choice selection by binding to a selected ID.
///
/// This control displays a list of selectable segments, dynamically arranging them
/// in a horizontal flow that wraps to the next line if space is insufficient.
/// It supports single-choice selection, visually highlighting the currently selected item.
///
/// - Important: The `IDType` for the `Item` must conform to `Identifiable`, `Hashable`, and `Sendable`.
public struct SegmentedControl<IDType: Identifiable & Hashable & Sendable>: View {

    /// Represents an individual segment with ID and display title.
    public struct Item: Identifiable, Equatable, Hashable, Sendable {
        /// The unique identifier for this segment.
        public let id: IDType
        /// The display text for this segment.
        public let title: String

        /// Creates a new segment item.
        /// - Parameters:
        ///   - id: Unique identifier for this segment.
        ///   - title: Display text.
        public init(id: IDType, title: String) {
            self.id = id
            self.title = title
        }
    }

    @Environment(\.theme) var theme

    /// Array of segments to show.
    public let items: [Item]

    /// Binding to the currently selected segment's ID.
    @Binding public var selectedItem: Item.ID

    /// Creates a segmented control.
    /// - Parameters:
    ///   - items: List of `Item` segments to display.
    ///   - selectedItem: Binding to the selected item ID. This value will be updated
    ///     when a new segment is tapped.
    public init(items: [Item], selectedItem: Binding<Item.ID>) {
        self.items = items
        _selectedItem = selectedItem
    }

    /// The content and behavior of the `SegmentedControl`.
    public var body: some View {
        WrappingHStackLayout(alignment: .center, horizontalSpacing: .xs, verticalSpacing: .xs) {
            ForEach(items) { item in
                Button(action: {
                    if item.id != selectedItem {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedItem = item.id
                        }
                    }
                }, label: {
                    HStack(alignment: .center, spacing: 0) {
                        Text(item.title)
                            .multilineTextAlignment(.center)
                    }
                })
                .applyThemedStyle(
                    .medium,
                    variant: item.id == selectedItem ? .primary() :
                        .tertiary(
                            destructive: false,
                            custom: AnyShapeStyle(theme.text1)
                        )
                )
                .accessibilityIdentifier("segmented-control-item-\(item.id)")
                .id("segmented-control-item-\(item.id)")
            }
        }
        .padding(.xs)
        .background(theme.background3)
        .transition(.opacity)
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import CalderStdLib
import SnapshotPreviews
import SwiftUI

@MainActor enum SegmentedControlPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("normal") {
            SegmentedControlPreviewHost(items: Array(SegmentedControlPreviewChoice.allCases.prefix(3)))
        }

        PreviewSnapshot("too-many") {
            SegmentedControlPreviewHost(items: SegmentedControlPreviewChoice.allCases)
        }
    }

    private struct SegmentedControlPreviewHost: View {
        @State private var selection = SegmentedControlPreviewChoice.title1

        let items: [SegmentedControlPreviewChoice]

        var body: some View {
            SegmentedControl<SegmentedControlPreviewChoice>(
                items: items.map { .init(id: $0, title: .lorem(5)) },
                selectedItem: $selection
            )
        }
    }

    private enum SegmentedControlPreviewChoice: String, CaseIterable, Hashable, Identifiable, Sendable {
        case title1
        case title2
        case title3
        case title4
        case title5
        case title6
        case title7
        case title8
        case title9

        var id: Self {
            self
        }
    }
}
#endif
#endif
