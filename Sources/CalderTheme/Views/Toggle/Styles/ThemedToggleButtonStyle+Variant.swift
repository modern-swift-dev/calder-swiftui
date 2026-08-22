#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SwiftUI

public extension ThemedToggleButtonStyle {
    /// Defines the available visual variants for `ThemedToggleButtonStyle`.
    enum Variant {
        /// Primary filled style.
        case primary
        /// Secondary outlined style.
        case secondary
        /// Tertiary transparent style.
        case tertiary
        /// Pill-shaped filled style.
        case pill
        /// Link-style transparent text-only.
        case link
        /// Round circular style.
        case round

        /// The padding to apply inside the toggle for each variant.
        @MainActor public var padding: EdgeInsets {
            switch self {
                case .primary,
                     .secondary,
                     .tertiary:
                    .init(vertical: .small, horizontal: .medium)
                case .pill:
                    .init(vertical: .xs, horizontal: .medium)
                case .link:
                    .init(vertical: .xxxs, horizontal: 0)
                case .round:
                    .init(all: .xs)
            }
        }

        /// Returns the foreground shape style for the given state.
        /// - Parameters:
        ///   - theme: The current theme.
        ///   - isOn: Whether the toggle is on.
        ///   - enabled: Whether the toggle is enabled.
        /// - Returns: A shape style for the foreground.
        @MainActor func foregroundShapeStyle(theme: Theme, isOn: Bool, enabled: Bool) -> AnyShapeStyle {
            AnyShapeStyle(foregroundColor(theme: theme, isOn: isOn, enabled: enabled))
        }

        /// The shape used as the background/cutout for this variant.
        /// - Returns: A shape instance.
        @MainActor func backgroundShape() -> AnyShape {
            let shape: any Shape = switch self {
                case .primary,
                     .secondary:
                    RoundedRectangle(cornerRadius: .xxs)
                case .tertiary,
                     .link:
                    Rectangle()
                case .round:
                    Circle()
                case .pill:
                    Capsule()
            }
            return AnyShape(shape)
        }

        /// Computes the opacity to apply based on toggle state.
        /// - Parameters:
        ///   - isOn: Whether the toggle is on.
        ///   - enabled: Whether the toggle is enabled.
        /// - Returns: A CGFloat opacity value.
        @MainActor func opacity(isOn: Bool, enabled: Bool) -> CGFloat {
            if isOn {
                return enabled ? 1.0 : 0.5
            }
            return enabled ? 1 : 0.5
        }

        /// Determines the foreground color for this variant.
        /// - Parameters:
        ///   - theme: The theme for color values.
        ///   - isOn: Whether toggle is on.
        ///   - enabled: Whether toggle is enabled.
        /// - Returns: A Color for the foreground.
        @MainActor func foregroundColor(theme: Theme, isOn: Bool, enabled: Bool) -> Color {
            if isOn {
                switch self {
                    case .primary,
                         .round,
                         .pill:
                        return enabled ? theme.textOverPrimary : theme.primary
                    default:
                        return theme.primary
                }
            }
            return theme.text2.opacity(enabled ? 1 : 0.75)
        }

        /// Determines the background color for this variant.
        /// - Parameters:
        ///   - theme: The theme for color values.
        ///   - isOn: Whether toggle is on.
        ///   - enabled: Whether toggle is enabled.
        /// - Returns: A Color for the background.
        @MainActor func backgroundColor(theme: Theme, isOn: Bool, enabled: Bool) -> Color {
            if isOn {
                return enabled ? theme.primary : theme.primary.opacity(0.5)
            }
            return theme.background3
        }

        /// Builds the background view for this variant.
        /// - Parameters:
        ///   - theme: The theme instance.
        ///   - isOn: Whether toggle is on.
        ///   - enabled: Whether toggle is enabled.
        /// - Returns: A SwiftUI view for the background.
        @MainActor @ViewBuilder func backgroundView(theme: Theme, isOn: Bool, enabled: Bool) -> some View {
            switch self {
                case .primary,
                     .round,
                     .pill:
                    backgroundShape()
                        .fill(backgroundColor(theme: theme, isOn: isOn, enabled: enabled))
                case .secondary:
                    backgroundShape()
                        .stroke(backgroundColor(theme: theme, isOn: isOn, enabled: enabled), lineWidth: 1)
                case .tertiary,
                     .link:
                    backgroundShape().fill(Color.clear)
            }
        }
    }
}

#endif
