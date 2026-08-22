#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SwiftUI

/// A view representing a vertical stack of checkboxes for multi-selection.
/// - Displays each choice with a checkbox styled by `CheckboxToggleButtonStyle`.
public struct CheckboxGroup: View {

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

    /// The currently selected item IDs.
    @Binding public var selection: [Int64]

    /// Creates a CheckboxGroup.
    /// - Parameters:
    ///   - choices: Array of `Item` to display.
    ///   - selection: Binding to an array of selected IDs.
    public init(choices: [Item], selection: Binding<[Int64]>) {
        self.choices = choices
        _selection = selection
    }

    /// The view’s body, listing each choice as a styled `Toggle`.
    public var body: some View {
        VStack(alignment: .leading, spacing: .xs) {
            ForEach(choices) { choice in
                Toggle(isOn: .init(get: {
                    selection.contains(choice.id)
                }, set: { _ in
                    if selection.contains(choice.id) {
                        selection.removeAll { $0 == choice.id }
                    } else {
                        selection.append(choice.id)
                    }
                }), label: {
                    Text(verbatim: choice.text)
                })
                .applyCheckboxToggleStyle(fullWidth: true)
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

@MainActor enum CheckboxGroupPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("light") {
            CheckboxGroupPreviewHost()
        }
    }

    private struct CheckboxGroupPreviewHost: View {
        @State private var value: [Int64] = [1, 2]

        var body: some View {
            CheckboxGroup(choices: [
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
