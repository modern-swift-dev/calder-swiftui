#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

/// A toggle style that renders a radio button icon alongside the label.
/// The radio button is filled when on, and hollow when off.
public struct RadioButtonToggleButtonStyle: ToggleStyle {
    /// Injected theme for colors and fonts.
    @Environment(\.theme) private var theme
    /// Indicates whether the toggle is enabled.
    @Environment(\.isEnabled) private var isEnabled: Bool

    /// The text style for the label.
    public let style: ThemedButtonStyle.TextStyle
    /// If true, the toggle stretches to fill its container.
    public let fullWidth: Bool

    /// Creates a radio button toggle style.
    /// - Parameters:
    ///   - style: The font style for the label (default `.medium`).
    ///   - fullWidth: Whether to fill horizontal space (default `false`).
    public init(style: ThemedButtonStyle.TextStyle = .medium, fullWidth: Bool = false) {
        self.style = style
        self.fullWidth = fullWidth
    }

    /// Builds the view for the radio button toggle.
    /// - Parameter configuration: Provides toggle state and label.
    /// - Returns: A styled Toggle view with a radio button.
    public func makeBody(configuration: Configuration) -> some View {
        Button {
            if isEnabled {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: .xs) {
                Image(systemSymbol: configuration.isOn ? .checkmarkCircleFill : .circle)
                    .imageScale(.large)
                    .foregroundColor(configuration.isOn ? theme.primary : theme.text2)

                configuration.label
                    .font(ThemedButtonStyle.TextStyle.medium.getFont(for: theme))
                    .foregroundColor(configuration.isOn ? theme.text1 : theme.text2)

                if fullWidth {
                    Spacer()
                }
            }
            .padding(ThemedToggleButtonStyle.Variant.primary.padding)
            .font(style.getFont(for: theme))
            .foregroundColor(configuration.isOn ? theme.text1 : theme.text2)
            .background(configuration.isOn ? theme.primary.opacity(0.05) : theme.transparent)
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .overlay(
                RoundedRectangle(cornerRadius: .xxs)
                    .stroke(configuration.isOn ? theme.primary : theme.transparent, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

public extension Toggle {
    /// Applies a radio button toggle style to this Toggle.
    /// - Parameters:
    ///   - style: The font style for the label (default `.large`).
    ///   - fullWidth: Whether to fill horizontal space (default `false`).
    /// - Returns: A Toggle styled as a radio button.
    @MainActor func applyRadioButtonToggleStyle(style: ThemedButtonStyle.TextStyle = .large, fullWidth: Bool = false) -> some View {
        toggleStyle(RadioButtonToggleButtonStyle(style: style, fullWidth: fullWidth))
    }
}

#endif

#if DEBUG
#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

@MainActor enum RadioButtonToggleButtonStylePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    @SnapshotBuilder static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("checked") {
            RadioButtonToggleButtonStylePreviewHost(initialValue: true)
        }

        PreviewSnapshot("unchecked") {
            RadioButtonToggleButtonStylePreviewHost(initialValue: false)
        }

        PreviewSnapshot("disabled") {
            RadioButtonToggleButtonStylePreviewHost(initialValue: true, disabled: true)
        }

        PreviewSnapshot("unchecked-disabled") {
            RadioButtonToggleButtonStylePreviewHost(initialValue: false, disabled: true)
        }
    }

    private struct RadioButtonToggleButtonStylePreviewHost: View {
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
            .applyRadioButtonToggleStyle()
            .disabled(disabled)
        }
    }
}
#endif
#endif
