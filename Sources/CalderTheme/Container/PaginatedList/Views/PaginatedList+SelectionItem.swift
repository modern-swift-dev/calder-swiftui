#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SnapshotPreviews
import SwiftUI

public extension PaginatedList {
    /// A list item view specifically designed for selection, combining custom content with a selection indicator.
    struct SelectionItem<Content: View>: View {

        /// A `ViewBuilder` closure that provides the main content of the selectable item.
        public let builder: () -> Content
        /// A boolean indicating the selection state of the item.
        public let selected: Bool

        /// Initializes a new `SelectionItem` view.
        /// - Parameters:
        ///   - selected: The initial selection state of the item.
        ///   - builder: A `ViewBuilder` that creates the content for the list item.
        public init(selected: Bool, @ViewBuilder builder: @escaping () -> Content) {
            self.selected = selected
            self.builder = builder
        }

        public var body: some View {
            HStack(alignment: .center, spacing: .small) {
                builder()
                Spacer()
                SelectionIndicator(selected: selected)
            }
            .padding(.trailing, .small)
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
        }
    }
}

#endif

#if DEBUG
@MainActor enum PaginatedListSelectionItemPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .fixed(width: 320, height: 64)

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("unselected") { item(selected: false) }
        PreviewSnapshot("selected") { item(selected: true) }
    }

    private static func item(selected: Bool) -> some View {
        PaginatedList.SelectionItem(selected: selected) {
            Text(verbatim: "Test")
        }
        .padding()
    }
}
#endif
