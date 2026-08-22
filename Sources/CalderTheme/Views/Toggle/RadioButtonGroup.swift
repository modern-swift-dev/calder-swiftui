#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A view representing a vertical stack of radio buttons for single selection.
/// - Displays each choice with a radio button styled by `RadioButtonToggleButtonStyle`.
public struct RadioButtonGroup: View {
    /// Represents a single selectable item.
    public struct Item: Identifiable {
        /// Unique identifier.
        public let id: Int64
        /// Display text for this item.
        public var text: String

        /// Creates a new item.
        /// - Parameters:
        ///   - id: Unique integer ID.
        ///   - text: Label text.
        public init(id: Int64, text: String) {
            self.id = id
            self.text = text
        }
    }

    /// The list of available choices.
    public let choices: [Item]

    @Environment(\.theme) var theme
    /// The currently selected item ID.
    @Binding public var selection: Int64?

    /// Creates a RadioButtonGroup.
    /// - Parameters:
    ///   - choices: Array of `Item` to display.
    ///   - selection: Binding to the selected ID.
    public init(choices: [Item], selection: Binding<Int64?>) {
        self.choices = choices
        _selection = selection
    }

    /// The view’s body, listing each choice as a styled `Toggle`.
    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            ForEach(choices) { choice in

                Toggle(isOn: .init(get: {
                    selection == choice.id
                }, set: { _ in
                    selection = choice.id
                }), label: {
                    Text(verbatim: choice.text)
                })
                .applyRadioButtonToggleStyle(fullWidth: true)
            }
        }
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SnapshotPreviews
import SwiftUI

@MainActor enum RadioButtonGroupPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            RadioButtonGroupPreviewHost()
        }
    }

    private struct RadioButtonGroupPreviewHost: View {
        @State private var value: Int64? = 2

        var body: some View {
            RadioButtonGroup(choices: [
                .init(id: 1, text: "Choice 1"),
                .init(id: 2, text: "Choice 2"),
                .init(id: 3, text: "Choice 3")
            ], selection: $value)
                .padding(.small)
        }
    }
}
#endif
#endif
