#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A capsule‐shaped label showing status text with customizable background and foreground styles.
public struct StatusPill: View {

    /// Predefined color variants or custom colors for the pill.
    public enum Variant {
        /// A custom variant allowing specification of distinct background and foreground styles.
        /// - Parameters:
        ///   - background: The custom background shape style for the pill.
        ///   - foreground: The custom foreground shape style for the text.
        case custom(background: any ShapeStyle, foreground: any ShapeStyle)
        /// An informational variant, typically used for neutral statuses.
        case info

        /// A success variant, typically used for positive outcomes.
        case success

        /// A warning variant, typically used for cautionary messages.
        case warn

        /// An error variant, typically used for critical issues.
        case error

        /// Provides the appropriate background color style for the given variant based on the theme.
        /// - Parameter theme: The current theme environment.
        /// - Returns: An `AnyShapeStyle` representing the background color.
        func backgroundColor(for theme: Theme) -> AnyShapeStyle {
            let style: any ShapeStyle = switch self {
                case let .custom(background, _):
                    background
                case .info:
                    LinearGradient(darken: theme.primary)
                case .success:
                    LinearGradient(darken: theme.success)
                case .warn:
                    LinearGradient(darken: theme.warning)
                case .error:
                    LinearGradient(darken: theme.error)
            }
            return AnyShapeStyle(style)
        }

        /// Provides the appropriate foreground color style for the given variant based on the theme.
        /// - Parameter theme: The current theme environment.
        /// - Returns: An `AnyShapeStyle` representing the foreground color.
        func foregroundColor(for theme: Theme) -> AnyShapeStyle {
            let style: any ShapeStyle = switch self {
                case let .custom(_, foreground):
                    foreground
                case .info:
                    theme.textOverPrimary
                case .success:
                    theme.textOverInfo
                case .warn:
                    theme.textOverWarning
                case .error:
                    theme.textOverError
            }
            return AnyShapeStyle(style)
        }
    }

    @Environment(\.theme) var theme
    public let text: String
    public let variant: Variant

    /// Creates a custom-status pill with specified background and foreground colors.
    /// - Parameters:
    ///   - text: The label text displayed within the pill.
    ///   - background: Custom background color.
    ///   - foreground: Custom foreground color for the text.
    public init(text: String, background: Color, foreground: Color) {
        self.text = text
        self.variant = .custom(background: background, foreground: foreground)
    }

    /// Creates a status pill with a predefined variant.
    /// - Parameters:
    ///   - text: The label text displayed within the pill.
    ///   - variant: The predefined style variant.
    public init(text: String, variant: Variant) {
        self.text = text
        self.variant = variant
    }

    /// The content and behavior of the `StatusPill`.
    public var body: some View {
        Text(verbatim: text)
            .padding(EdgeInsets(vertical: .xxs, horizontal: .small))
            .font(.caption)
            .foregroundStyle(variant.foregroundColor(for: theme))
            .background(variant.backgroundColor(for: theme))
            .contentShape(Capsule())
            .clipShape(Capsule())
    }
}

#endif

#if canImport(SwiftUI)
import SnapshotPreviews
import SwiftUI

#if DEBUG
@MainActor enum StatusPillPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device

    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") {
            PreviewContent()
        }
    }

    private struct PreviewContent: View {
        @Environment(\.theme) private var theme

        var body: some View {
            VStack {
                StatusPill(text: "Status", background: theme.error, foreground: theme.textOverInfo)
                StatusPill(text: "Status", variant: .info)
                StatusPill(text: "Status", variant: .success)
                StatusPill(text: "Status", variant: .warn)
                StatusPill(text: "Status", variant: .error)
            }
            .padding()
        }
    }
}
#endif
#endif
