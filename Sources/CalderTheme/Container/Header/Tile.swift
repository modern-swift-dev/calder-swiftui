#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import Foundation
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

/// A customizable tile view used within headers or other container views.
///
/// This view displays an icon, a label, and a text value, with different visual
/// variants for various states like "empty", "loading", "info", "warn", and "error".
/// It also supports an expand option for layout adjustments and a tap action.
public struct Tile: View {
    @Environment(\.theme) var theme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    /// The SF Symbol image to display on the tile.
    let icon: Image

    /// The main label text for the tile.
    let label: String

    /// The primary text value displayed on the tile, often a count.
    let text: String

    /// The visual variant of the tile, determining its appearance.
    let variant: Variant

    /// A boolean indicating whether the tile should expand to fill available space.
    var expand: Bool = false

    /// The action to perform when the tile is tapped.
    let action: @MainActor @Sendable () -> Void

    /// Initializes a new `Tile` view.
    ///
    /// - Parameters:
    ///   - icon: The SF Symbol image to display.
    ///   - label: The main label text.
    ///   - text: The primary text value.
    ///   - variant: The visual style variant.
    ///   - expand: If `true`, the tile expands vertically. Defaults to `false`.
    ///   - action: The closure to execute when the tile is tapped.
    public init(
        icon: Image,
        label: String,
        text: String,
        variant: Variant,
        expand: Bool = false,
        action: @escaping @MainActor @Sendable () -> Void
    ) {
        self.icon = icon
        self.label = label
        self.text = text
        self.variant = variant
        self.expand = expand
        self.action = action
    }

    public var body: some View {
        Button(
            action: {
                action()
            },
            label: {
                VStack(alignment: .leading, spacing: .medium) {
                    HStack(alignment: .center, spacing: .small) {
                        icon
                            .symbolRenderingMode(.monochrome)
                            .renderingMode(.template)
                            .flipsForRightToLeftLayoutDirection(true)
                            .imageScale(.small)
                            .font(.title3)
                            .foregroundColor(variant.foregroundColor(theme: theme))

                        Text(variant.text(candidate: label, length: 10))
                            .font(.title3)
                            .foregroundStyle(theme.textOverPrimary)

                        Spacer()
                    }

                    if expand {
                        Spacer()
                    }

                    HStack(alignment: .center, spacing: .small) {
                        Text(verbatim: variant.text(candidate: text, length: 2))
                            .font(.headline)
                            .foregroundStyle(variant.countForeground(theme: theme))

                        Spacer()

                        Image(systemSymbol: .chevronRight)
                            .symbolRenderingMode(.monochrome)
                            .renderingMode(.template)
                            .flipsForRightToLeftLayoutDirection(true)
                            .imageScale(.small)
                            .font(.subheadline)
                            .foregroundColor(variant.foregroundColor(theme: theme))
                    }

                }
                .padding(.medium)
                .background(variant.backgroundColor(theme: theme))
                .redacted(reason: variant.redacted)
                .clipShape(RoundedRectangle(cornerRadius: .xxs))
                .contentShape(RoundedRectangle(cornerRadius: .xxs))
            }
        )
        .buttonStyle(.plain)
    }
}

public extension Tile {

    /// Defines the visual variants for a `Tile` view.
    enum Variant {
        /// Represents an empty or default state, typically with a subdued appearance.
        case empty

        /// Represents a loading state, typically showing a placeholder animation.
        case loading

        /// Represents an informational state, often styled with a primary color.
        case info

        /// Represents a warning state, often styled with a warning color.
        case warn

        /// Represents an error state, often styled with an error color.
        case error

        /// Returns the background style for the tile based on its variant.
        /// - Parameter theme: The current theme applied to the environment.
        /// - Returns: An `AnyShapeStyle` representing the background.
        func backgroundColor(theme: Theme) -> AnyShapeStyle {
            switch self {
                case .empty,
                     .loading: AnyShapeStyle(Material.regular)
                case .info: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                theme.primary,
                                theme.primary.darken(
                                    amount: 0.25
                                )
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                case .warn: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                theme.warning,
                                theme.warning.darken(
                                    amount: 0.3
                                )
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                case .error: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                theme.error,
                                theme.error.darken(
                                    amount: 0.3
                                )
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }

        /// Returns the foreground color for the tile's icon and label.
        /// - Parameter theme: The current theme applied to the environment.
        /// - Returns: A `Color` for the foreground elements.
        func foregroundColor(theme: Theme) -> Color {
            switch self {
                case .empty,
                     .loading:
                    theme.text2
                case .info:
                    theme.textOverPrimary
                case .warn:
                    theme.textOverWarning
                case .error:
                    theme.textOverError
            }
        }

        /// Returns the foreground color for the tile's text count.
        /// - Parameter theme: The current theme applied to the environment.
        /// - Returns: A `Color` for the text count.
        func countForeground(theme: Theme) -> Color {
            switch self {
                case .empty:
                    theme.text3
                case .loading:
                    theme.text2
                case .info:
                    theme.textOverPrimary
                case .warn:
                    theme.textOverWarning
                case .error:
                    theme.textOverError
            }
        }

        /// Returns the redaction reasons for the tile based on its variant.
        /// - Returns: A `RedactionReasons` set.
        var redacted: RedactionReasons {
            if self == .loading {
                return .placeholder
            }
            return []
        }

        /// Provides the appropriate text content for the tile based on its variant.
        /// - Parameters:
        ///   - candidate: The original text candidate.
        ///   - length: The desired length for lorem ipsum text in loading state. Defaults to 5.
        /// - Returns: A `String` to be displayed.
        func text(candidate: String, length: Int = 5) -> String {
            if self == .loading {
                return .lorem(length)
            }
            return candidate
        }
    }
}

#endif

#if DEBUG
@MainActor enum TilePreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("Tiles") {
            List {
                Header(mode: .plain) {
                    Tiles { hclass in
                        Tile(icon: Image(systemSymbol: .checkmarkCircle), label: "To-Do", text: "12", variant: .info, expand: hclass == .regular, action: {})
                    } secondaryTiles: { _ in
                        [
                            Tile(icon: Image(systemSymbol: .xmarkOctagon), label: "Overdue", text: "12", variant: .error, action: {}),
                            Tile(icon: Image(systemSymbol: .hourglass), label: "Loading", text: "12", variant: .loading, action: {}),
                            Tile(icon: Image(systemSymbol: .exclamationmarkTriangle), label: "Warn", text: "12", variant: .warn, action: {}),
                            Tile(icon: Image(systemSymbol: .cloud), label: "Empty", text: "12", variant: .empty, action: {})
                        ]
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
#endif
