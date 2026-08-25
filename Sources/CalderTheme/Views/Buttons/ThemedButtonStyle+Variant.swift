#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

public extension ThemedButtonStyle {
    /// Defines the visual variants available for `ThemedButtonStyle`.
    enum Variant {

        /// A primary button variant, typically for main actions.
        /// - Parameters:
        ///   - destructive: If `true`, applies a destructive color theme. Defaults to `false`.
        ///   - custom: An optional custom `ShapeStyle` to use for the background. If `nil`, the default primary color/gradient is used.
        case primary(destructive: Bool = false, custom: (any ShapeStyle)? = nil)

        /// A secondary button variant, typically for less prominent actions.
        /// - Parameters:
        ///   - destructive: If `true`, applies a destructive color theme. Defaults to `false`.
        ///   - custom: An optional custom `ShapeStyle` to use for the stroke. If `nil`, the default secondary color/gradient is used.
        case secondary(destructive: Bool = false, custom: (any ShapeStyle)? = nil)

        /// A tertiary button variant, typically for least prominent actions, often without a solid background.
        /// - Parameters:
        ///   - destructive: If `true`, applies a destructive color theme. Defaults to `false`.
        ///   - custom: An optional custom `ShapeStyle` to use for the foreground. If `nil`, the default tertiary color/gradient is used.
        case tertiary(destructive: Bool = false, custom: (any ShapeStyle)? = nil)

        /// A pill-shaped button variant, often used for status indicators or tags.
        /// - Parameters:
        ///   - bg: The `ShapeStyle` for the background of the pill.
        ///   - fg: The `ShapeStyle` for the foreground (text/icon) of the pill.
        case pill(bg: any ShapeStyle, fg: any ShapeStyle)

        /// A link-style button variant, appearing as clickable text.
        /// - Parameters:
        ///   - destructive: If `true`, applies a destructive color theme. Defaults to `false`.
        ///   - custom: An optional custom `ShapeStyle` to use for the foreground. If `nil`, the default link color/gradient is used.
        case link(destructive: Bool = false, custom: (any ShapeStyle)? = nil)

        /// A round button variant, often used for icon-only actions.
        /// - Parameters:
        ///   - destructive: If `true`, applies a destructive color theme. Defaults to `false`.
        ///   - custom: An optional custom `ShapeStyle` to use for the background. If `nil`, the default round button color/gradient is used.
        case round(destructive: Bool = false, custom: (any ShapeStyle)? = nil)

        /// The padding to apply to the button's content.
        @MainActor public var padding: EdgeInsets {
            switch self {
                case .primary,
                     .secondary,
                     .tertiary:
                    .init(vertical: .small, horizontal: .medium)
                case .pill:
                    .init(vertical: .xxs, horizontal: .small)
                case .link:
                    .init(vertical: .xxxs, horizontal: 0)
                case .round:
                    .init(all: .xs)
            }
        }

        /// Returns the foreground `ShapeStyle` for the button variant, adjusted for enabled state.
        /// - Parameters:
        ///   - theme: The current `Theme` to use for color definitions.
        ///   - enabled: A boolean indicating if the button is enabled.
        /// - Returns: An `AnyShapeStyle` representing the foreground color.
        @MainActor func foregroundShapeStyle(theme: Theme, enabled: Bool) -> AnyShapeStyle {
            switch self {
                case .primary,
                     .round:
                    AnyShapeStyle(theme.textOverPrimary.opacity(enabled ? 1.0 : 0.5))
                case let .secondary(destructive, gradient):
                    if let gradient {
                        AnyShapeStyle(AnyShapeStyle(gradient).opacity(enabled ? 1.0 : 0.5))
                    } else {
                        AnyShapeStyle((destructive ? LinearGradient(darken: theme.error) : LinearGradient(darken: theme.primary)).opacity(enabled ? 1.0 : 0.5))
                    }
                case let .tertiary(destructive, gradient),
                     let .link(destructive, gradient):
                    if let gradient {
                        AnyShapeStyle(AnyShapeStyle(gradient).opacity(enabled ? 1.0 : 0.5))
                    } else {
                        AnyShapeStyle((destructive ? LinearGradient(darken: theme.error) : LinearGradient(darken: theme.primary)).opacity(enabled ? 1.0 : 0.5))
                    }
                case let .pill(_, foreground):
                    AnyShapeStyle(AnyShapeStyle(foreground).opacity(enabled ? 1.0 : 0.5))
            }
        }

        /// Returns the background `Shape` for the button variant.
        /// - Returns: An `AnyShape` representing the button's background shape.
        @MainActor func backgroundShape() -> AnyShape {
            let shape: any Shape = switch self {
                case .primary,
                     .secondary:
                    RoundedRectangle(cornerRadius: .small)
                case .tertiary,
                     .link:
                    Rectangle()
                case .pill:
                    Capsule()
                case .round:
                    Circle()
            }

            return AnyShape(shape)
        }

        /// Returns the background `View` for the button variant, adjusted for enabled state.
        /// - Parameters:
        ///   - theme: The current `Theme` to use for color definitions.
        ///   - enabled: A boolean indicating if the button is enabled.
        /// - Returns: A `View` representing the button's background.
        @MainActor @ViewBuilder func backgroundView(theme: Theme, enabled: Bool) -> some View {
            switch self {
                case let .primary(destructive, gradient),
                     let .round(destructive, gradient):

                    if let gradient {
                        backgroundShape()
                            .fill(AnyShapeStyle(gradient).opacity(enabled ? 1.0 : 0.5))
                    } else {
                        backgroundShape()
                            .fill((destructive ? LinearGradient(darken: theme.error) : LinearGradient(darken: theme.primary)).opacity(enabled ? 1.0 : 0.5))
                    }
                case let .secondary(destructive, gradient):
                    if let gradient {
                        backgroundShape()
                            .stroke(AnyShapeStyle(gradient).opacity(enabled ? 1.0 : 0.5), lineWidth: 1)
                    } else {
                        backgroundShape()
                            .stroke((destructive ? LinearGradient(darken: theme.error) : LinearGradient(darken: theme.primary)).opacity(enabled ? 1.0 : 0.5), lineWidth: 1)
                    }
                case .tertiary:
                    backgroundShape().fill(Color.clear)
                case let .pill(bg, _):
                    backgroundShape()
                        .fill(AnyShapeStyle(bg).opacity(enabled ? 1.0 : 0.5))
                case .link:
                    backgroundShape().fill(Color.clear)
            }
        }

        @MainActor func shadowColor(theme: Theme) -> Color {
            switch self {
                case .primary,
                     .secondary,
                     .round,
                     .pill:
                    theme.shadow
                case .tertiary,
                     .link:
                    theme.transparent
            }
        }
    }
}

#endif
