#if canImport(SwiftUI)
import CalderSwiftUI
import SwiftUI

/// A customizable toggle style supporting multiple visual variants (primary, secondary, tertiary, pill, link, round).
public struct ThemedToggleButtonStyle: ToggleStyle {
    /// Injected theme for color and font definitions.
    @Environment(\.theme) private var theme
    /// Indicates whether the toggle is enabled.
    @Environment(\.isEnabled) private var isEnabled: Bool

    /// The visual variant to apply.
    public let variant: ThemedToggleButtonStyle.Variant
    /// The font style for the toggle label.
    public let style: ThemedButtonStyle.TextStyle

    /// Creates a styled toggle with specified variant and text style.
    /// - Parameters:
    ///   - variant: The toggle’s visual variant (default `.primary`).
    ///   - style: The font style for the label (default `.medium`).
    public init(
        variant: ThemedToggleButtonStyle.Variant = .primary,
        style: ThemedButtonStyle.TextStyle = .medium
    ) {
        self.style = style
        self.variant = variant
    }

    /// Builds the view for this styled toggle.
    /// - Parameter configuration: Provides the toggle’s state and label view.
    /// - Returns: A styled Toggle button view.
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            if isEnabled {
                configuration.isOn.toggle()
            }
        } label: {
            configuration.label
                .padding(variant.padding)
                .font(style.getFont(for: theme))
                .foregroundStyle(
                    variant.foregroundShapeStyle(
                        theme: theme,
                        isOn: configuration.isOn,
                        enabled: isEnabled
                    )
                )
                .contentShape(variant.backgroundShape())
                .clipShape(variant.backgroundShape())
                .background(
                    variant.backgroundView(
                        theme: theme,
                        isOn: configuration.isOn,
                        enabled: isEnabled
                    )
                )
        }
        .buttonStyle(.plain)
    }
}

public extension Toggle {
    /// Applies a themed toggle style to this Toggle.
    /// - Parameters:
    ///   - variant: The visual variant to use (default `.primary`).
    ///   - style: The font style for the label (default `.medium`).
    /// - Returns: A Toggle styled with `ThemedToggleButtonStyle`.
    @MainActor func applyThemedToggleStyle(
        variant: ThemedToggleButtonStyle.Variant = .primary,
        style: ThemedButtonStyle.TextStyle = .medium
    ) -> some View {
        toggleStyle(ThemedToggleButtonStyle(variant: variant, style: style))
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

@MainActor enum ThemedToggleButtonStylePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("normal-on") {
            ThemedToggleButtonStylePreviewHost(initialValue: true)
        }

        PreviewSnapshot("normal-off") {
            ThemedToggleButtonStylePreviewHost(initialValue: false)
        }

        PreviewSnapshot("disabled-on") {
            ThemedToggleButtonStylePreviewHost(initialValue: true, disabled: true)
        }

        PreviewSnapshot("disabled-off") {
            ThemedToggleButtonStylePreviewHost(initialValue: false, disabled: true)
        }
    }

    private struct ThemedToggleButtonStylePreviewHost: View {
        @State private var value: Bool

        private let disabled: Bool

        init(initialValue: Bool, disabled: Bool = false) {
            _value = State(initialValue: initialValue)
            self.disabled = disabled
        }

        var body: some View {
            WrappingHStackLayout {
                Toggle(isOn: $value) {
                    Label(
                        title: { Text(verbatim: "Label") },
                        icon: { Image(systemName: "42.circle") }
                    )
                }
                .applyThemedToggleStyle(variant: .primary)

                Toggle(isOn: $value) {
                    Label(
                        title: { Text(verbatim: "Label") },
                        icon: { Image(systemName: "42.circle") }
                    )
                }
                .applyThemedToggleStyle(variant: .secondary)

                Toggle(isOn: $value) {
                    Image(systemName: "42.circle")
                }
                .applyThemedToggleStyle(variant: .round)

                Toggle(isOn: $value) {
                    Label(
                        title: { Text(verbatim: "Label") },
                        icon: { Image(systemName: "42.circle") }
                    )
                }
                .applyThemedToggleStyle(variant: .tertiary)

                Toggle(isOn: $value) {
                    Label(
                        title: { Text(verbatim: "Label") },
                        icon: { Image(systemName: "42.circle") }
                    )
                }
                .applyThemedToggleStyle(variant: .pill)

                Toggle(isOn: $value) {
                    Label(
                        title: { Text(verbatim: "Label") },
                        icon: { Image(systemName: "42.circle") }
                    )
                }
                .applyThemedToggleStyle(variant: .link)
            }
            .disabled(disabled)
        }
    }
}
#endif
#endif
