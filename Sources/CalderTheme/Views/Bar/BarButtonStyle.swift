#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A customizable button style for toolbar and navigation bar buttons.
///
/// `BarButtonStyle` provides a consistent button appearance across the app with multiple visual variants.
/// It automatically applies theme colors, handles pressed and disabled states, and supports various
/// button types from simple text buttons to filled capsule buttons.
///
/// ## Variants
/// - `.title`: Headline text button for prominent actions
/// - `.regular`: Standard text button for common actions
/// - `.primary`: Filled capsule button with primary color
/// - `.secondary`: Outlined capsule button with primary color border
/// - `.destructive`: Filled capsule button with error/destructive color
///
/// ## Features
/// - Theme-aware coloring for all variants
/// - Automatic opacity adjustment for pressed and disabled states
/// - Variant-specific padding and typography
/// - Background styles ranging from transparent to filled capsules
///
/// ## Example
/// ```swift
/// Button("Save") { save() }
///     .buttonStyle(BarButtonStyle(variant: .primary))
///
/// Button("Cancel") { cancel() }
///     .buttonStyle(BarButtonStyle(variant: .secondary))
/// ```
public struct BarButtonStyle: ButtonStyle {

    /// Defines the visual appearance variants for bar buttons.
    public enum Variant {
        /// Headline text button for prominent title-level actions.
        case title
        /// Standard text button with minimal styling.
        case regular
        /// Filled capsule button using the primary theme color.
        case primary
        /// Outlined capsule button with primary color border.
        case secondary
        /// Filled capsule button using the error/destructive color.
        case destructive

        /// Returns the font style for the button variant.
        var font: Font {
            switch self {
                case .title:
                    .headline
                default:
                    .subheadline
            }
        }

        /// Returns the padding for the button variant.
        var padding: EdgeInsets {
            switch self {
                case .regular,
                     .title:
                    .init(horizontal: 6)
                case .primary,
                     .secondary,
                     .destructive:
                    .init(vertical: .small, horizontal: .medium)
            }
        }

        /// Returns the foreground (text) color for the button variant based on the current theme.
        func foregroundColor(theme: Theme) -> Color {
            switch self {
                case .regular,
                     .title:
                    theme.text1
                case .primary:
                    theme.textOverPrimary
                case .secondary:
                    theme.primary
                case .destructive:
                    theme.textOverError
            }
        }

        /// Returns the background view for the button variant based on the current theme.
        @ViewBuilder func backgroundColor(theme: Theme) -> some View {
            switch self {
                case .regular,
                     .title:
                    theme.transparent
                case .primary:
                    Capsule()
                        .fill(theme.primary)
                case .secondary:
                    Capsule()
                        .fill(theme.textOverPrimary)
                        .stroke(theme.primary, lineWidth: 1)
                case .destructive:
                    Capsule()
                        .fill(theme.error)
            }
        }

        /// Indicates whether this variant shares its disabled state styling with the background.
        var sharedBackgroundDisabled: Bool {
            switch self {
                case .primary,
                     .destructive,
                     .secondary:
                    true
                default:
                    false
            }
        }

        @MainActor func shadowColor(theme: Theme) -> Color {
            theme.shadow
        }
    }

    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) var enabled

    /// The visual variant to apply to the button. Defaults to `.regular`.
    var variant: Variant = .regular

    public init(variant: Variant) {
        self.variant = variant
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(variant.padding)
            .font(variant.font)
            .foregroundStyle(variant.foregroundColor(theme: theme))
            .background(variant.backgroundColor(theme: theme))
            .opacity(configuration.isPressed || !enabled ? 0.5 : 1)
            .shadow(color: variant.shadowColor(theme: theme), radius: 4, x: 2, y: 2)
    }
}

#endif
