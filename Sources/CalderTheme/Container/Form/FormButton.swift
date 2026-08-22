#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A styled button designed for use within forms, adhering to the application's theme.
///
/// This button provides a consistent look and feel for actions within a form,
/// with an option for a destructive visual style.
public struct FormButton: View {

    /// The theme
    @Environment(\.theme) private var theme
    /// The text displayed on the button.
    public let text: String
    /// A boolean indicating if the button has a destructive action,
    /// which alters its visual style to indicate a potentially unrecoverable operation.
    public let destructive: Bool
    /// The action to perform when the button is tapped.
    public let action: @Sendable @MainActor () -> Void

    /// The horizontal size class
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// Initializes a new `FormButton`.
    ///
    /// - Parameters:
    ///   - text: The text to display on the button.
    ///   - destructive: A boolean value indicating if the button's action is destructive.
    ///                  Defaults to `false`.
    ///   - action: The closure to execute when the button is tapped.
    public init(text: String, destructive: Bool = false, action: @escaping @Sendable @MainActor () -> Void) {
        self.text = text
        self.destructive = destructive
        self.action = action
    }

    public var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text(text)
                Spacer()
            }
            .padding(.vertical, .medium)
        })
        .applyThemedStyle(variant: .tertiary(destructive: destructive, custom: nil))
        #if !os(macOS) && !os(watchOS)
            .listRowInsets(.zero)
        #if !os(tvOS)
            .listRowSpacing(0)
        #endif
        #endif
    }
}

#endif

#if DEBUG
@MainActor enum FormButtonPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Normal Button") { Content(destructive: false) }
        PreviewSnapshot("Destructive Button") { Content(destructive: true) }
    }

    private struct Content: View {
        let destructive: Bool

        var body: some View {
            NavigationStack {
                List {
                    Section {
                        FormButton(
                            text: destructive ? "Reset Filters" : "Apply Filters",
                            destructive: destructive,
                            action: {}
                        )
                    }
                }
                #if !os(macOS) && !os(watchOS)
                .listStyle(.grouped)
                #if !os(tvOS)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                #endif
            }
        }
    }
}
#endif
