#if canImport(SwiftUI)
import Foundation
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

public extension PaginatedList {
    /// A visual indicator for selection state, typically a checkmark for selected and a circle for unselected.
    struct SelectionIndicator: View {
        @Environment(\.theme) var theme
        /// A boolean indicating whether the item is selected.
        let selected: Bool

        /// Initializes a new `SelectionIndicator` view.
        /// - Parameter selected: The selection state.
        public init(selected: Bool) {
            self.selected = selected
        }

        public var body: some View {
            if selected {
                Image(systemSymbol: .checkmarkCircleFill)
                    .font(.title3)
                    .foregroundStyle(theme.primary)
            } else {
                Image(systemSymbol: .circle)
                    .font(.title3)
                    .foregroundStyle(theme.text3.opacity(0.5))
            }
        }
    }
}

#endif

#if DEBUG
@MainActor enum PaginatedListSelectionIndicatorPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .sizeThatFits

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("selected") { PaginatedList.SelectionIndicator(selected: true).padding() }
        PreviewSnapshot("unselected") { PaginatedList.SelectionIndicator(selected: false).padding() }
    }
}
#endif
