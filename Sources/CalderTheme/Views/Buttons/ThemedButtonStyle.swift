#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A custom `ButtonStyle` that applies a consistent theme to buttons based on various text styles and visual variants.
public struct ThemedButtonStyle: ButtonStyle {
    /// The current theme, injected via Environment.
    @Environment(\.theme) private var theme

    /// The text style for the button, controlling font size and weight.
    public let style: ThemedButtonStyle.TextStyle
    /// The visual variant of the button, controlling its appearance (e.g., primary, secondary, pill).
    public let variant: ThemedButtonStyle.Variant
    /// A boolean indicating whether the button is enabled, affecting its visual state.
    @Environment(\.isEnabled) private var isEnabled: Bool

    /// Initializes a new `ThemedButtonStyle`.
    /// - Parameters:
    ///   - style: The text style for the button. Defaults to `.medium`.
    ///   - variant: The visual variant of the button. Defaults to `.primary(destructive: false)`.
    public init(style: ThemedButtonStyle.TextStyle = .medium, variant: ThemedButtonStyle.Variant = .primary(destructive: false)) {
        self.style = style
        self.variant = variant
    }

    /// Creates the visual representation of the button.
    /// - Parameter configuration: The `ButtonStyle.Configuration` containing the button's label.
    /// - Returns: A `View` representing the button's appearance.
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(variant.padding)
            .font(style.getFont(for: theme))
            .foregroundStyle(
                variant
                    .foregroundShapeStyle(
                        theme: theme,
                        enabled: isEnabled
                    )
            )
            .contentShape(variant.backgroundShape())
            .clipShape(variant.backgroundShape())
            .background(
                variant.backgroundView(
                    theme: theme,
                    enabled: isEnabled
                )
            )
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .shadow(color: variant.shadowColor(theme: theme), radius: 4, x: 2, y: 2)
    }
}

public extension Button {

    /// Applies the `ThemedButtonStyle` to the button.
    /// - Parameters:
    ///   - style: The text style to apply. Defaults to `.medium`.
    ///   - variant: The visual variant to apply. Defaults to `.primary(destructive: false)`.
    /// - Returns: A view with the themed button style applied.
    @MainActor func applyThemedStyle(
        _ style: ThemedButtonStyle.TextStyle = .medium,
        variant: ThemedButtonStyle.Variant = .primary(destructive: false)
    ) -> some View {
        buttonStyle(ThemedButtonStyle(style: style, variant: variant))
    }
}

#endif

#if canImport(SwiftUI)
import CalderUIKit
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum ThemedButtonStylePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("All") {
            PreviewContent(disabled: false)
        }

        PreviewSnapshot("Disabled") {
            PreviewContent(disabled: true)
        }
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme

        let disabled: Bool

        var body: some View {
            List {
                Group {
                    WrappingHStackLayout(alignment: .leading) {
                        Button("Primary", action: {})
                            .applyThemedStyle()
                        Button("Primary Destructive", action: {})
                            .applyThemedStyle(variant: .primary(destructive: true))
                        Button("Primary", action: {})
                            .applyThemedStyle(variant: .primary(custom: gradient))
                    }

                    WrappingHStackLayout(alignment: .leading) {
                        Button("Secondary", action: {})
                            .applyThemedStyle(variant: .secondary(destructive: false))
                        Button("Secondary Destructive", action: {})
                            .applyThemedStyle(variant: .secondary(destructive: true))
                        Button("Secondary", action: {})
                            .applyThemedStyle(variant: .secondary(custom: gradient))
                    }

                    WrappingHStackLayout(alignment: .leading) {
                        Button("Tertiary", action: {})
                            .applyThemedStyle(variant: .tertiary(destructive: false))
                        Button("Tertiary Destructive", action: {})
                            .applyThemedStyle(variant: .tertiary(destructive: true))
                        Button("Tertiary", action: {})
                            .applyThemedStyle(variant: .tertiary(custom: gradient))
                    }

                    WrappingHStackLayout(alignment: .leading) {
                        Button("Link", action: {})
                            .applyThemedStyle(variant: .link(destructive: false))
                        Button(disabled ? "Link" : "Link Destructive", action: {})
                            .applyThemedStyle(variant: .link(destructive: true))
                        Button("Link", action: {})
                            .applyThemedStyle(variant: .link(custom: gradient))
                    }

                    WrappingHStackLayout(alignment: .leading) {
                        Button(action: {}, label: statusLabel)
                            .applyThemedStyle(variant: .pill(bg: theme.error, fg: theme.textOverError))
                        Button(action: {}, label: statusLabel)
                            .applyThemedStyle(
                                variant: .pill(
                                    bg: gradient,
                                    fg: disabled ? theme.textOverPrimary : theme.textOverInfo
                                )
                            )
                    }

                    WrappingHStackLayout(alignment: .leading) {
                        Button(action: {}, label: trashLabel)
                            .applyThemedStyle(variant: .round(destructive: true))
                        Button(action: {}, label: trashLabel)
                            .applyThemedStyle(variant: .round(destructive: false))
                        Button(action: {}, label: trashLabel)
                            .applyThemedStyle(variant: .round(custom: gradient))
                    }
                }
                .disabled(disabled)
            }
            #if !os(macOS) && !os(watchOS)
            .listStyle(.grouped)
            #endif
        }

        private var gradient: LinearGradient {
            LinearGradient(colors: [theme.error, theme.success], startPoint: .leading, endPoint: .trailing)
        }

        private func statusLabel() -> some View {
            HStack(spacing: .xs) {
                Text("Status")
                Image(systemSymbol: .chevronDown)
            }
        }

        private func trashLabel() -> some View {
            Image(systemSymbol: .trash)
        }
    }
}
#endif
#endif
