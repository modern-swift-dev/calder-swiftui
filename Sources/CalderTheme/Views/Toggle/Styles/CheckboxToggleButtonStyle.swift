#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A toggle style that renders a checkbox icon alongside the label.
/// The checkbox is filled when the toggle is on, and outlined when off.
/// - Leading placement and full-width layout can be configured.
public struct CheckboxToggleButtonStyle: ToggleStyle {
    /// Injected theme for color and font styles.
    @Environment(\.theme) private var theme
    /// Indicates whether the toggle is enabled.
    @Environment(\.isEnabled) private var isEnabled: Bool

    /// The text style applied to the toggle label.
    public let style: ThemedButtonStyle.TextStyle
    /// If true, the toggle stretches to fill its container.
    public let fullWidth: Bool
    /// If true, the checkbox icon appears before the label.
    public let leading: Bool

    /// Creates a checkbox toggle style.
    /// - Parameters:
    ///   - style: The font style for the label (default `.medium`).
    ///   - fullWidth: Whether to occupy full horizontal space (default `false`).
    ///   - leading: Whether the icon is placed before the label (default `true`).
    public init(style: ThemedButtonStyle.TextStyle = .medium, fullWidth: Bool = false, leading: Bool = true) {
        self.style = style
        self.fullWidth = fullWidth
        self.leading = leading
    }

    /// Builds the view for the checkbox toggle.
    /// - Parameter configuration: Provides the toggle’s isOn binding and label view.
    /// - Returns: A view representing the styled toggle button.
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            if isEnabled {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: .xs) {
                if leading {
                    Image(systemSymbol: configuration.isOn ? .checkmarkSquareFill : .square)
                        .imageScale(.large)
                        .foregroundColor(configuration.isOn ? theme.primary : theme.text2)
                }

                configuration.label
                    .font(ThemedButtonStyle.TextStyle.medium.getFont(for: theme))
                    .foregroundColor(configuration.isOn ? theme.text1 : theme.text2)

                if fullWidth {
                    Spacer()
                }

                if !leading {
                    Image(systemSymbol: configuration.isOn ? .checkmarkSquareFill : .square)
                        .imageScale(.large)
                        .foregroundColor(configuration.isOn ? theme.primary : theme.text2)
                }
            }
            .padding(ThemedToggleButtonStyle.Variant.primary.padding)
            .font(style.getFont(for: theme))
            .foregroundStyle(configuration.isOn ? theme.text1 : theme.text2)
            .background(configuration.isOn ? theme.primary.opacity(0.05) : Color.clear)
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .overlay(
                RoundedRectangle(cornerRadius: .xxs)
                    .stroke(configuration.isOn ? theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

public extension Toggle {
    /// Applies a checkbox toggle style to this Toggle.
    /// - Parameters:
    ///   - style: Text style for the label (default `.large`).
    ///   - fullWidth: Whether the toggle occupies full width (default `false`).
    /// - Returns: A Toggle styled as a checkbox.
    @MainActor func applyCheckboxToggleStyle(style: ThemedButtonStyle.TextStyle = .large, fullWidth: Bool = false) -> some View {
        toggleStyle(CheckboxToggleButtonStyle(style: style, fullWidth: fullWidth))
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

@MainActor enum CheckboxToggleButtonStylePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("checked") {
            CheckboxToggleButtonStylePreviewHost(initialValue: true)
        }

        PreviewSnapshot("unchecked") {
            CheckboxToggleButtonStylePreviewHost(initialValue: false)
        }

        PreviewSnapshot("disabled") {
            CheckboxToggleButtonStylePreviewHost(initialValue: true, disabled: true)
        }

        PreviewSnapshot("unchecked-disabled") {
            CheckboxToggleButtonStylePreviewHost(initialValue: false, disabled: true)
        }
    }

    private struct CheckboxToggleButtonStylePreviewHost: View {
        @State private var value: Bool

        private let disabled: Bool

        init(initialValue: Bool, disabled: Bool = false) {
            _value = State(initialValue: initialValue)
            self.disabled = disabled
        }

        var body: some View {
            Toggle(isOn: $value) {
                Text(verbatim: "On or Off")
            }
            .applyCheckboxToggleStyle()
            .disabled(disabled)
        }
    }
}
#endif
#endif
