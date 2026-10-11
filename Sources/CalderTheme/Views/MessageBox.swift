#if canImport(SwiftUI)
    import CalderStdLib
    import CalderSwiftUI
    import CalderUIKit
    import Foundation
    import SFSafeSymbols
    import SwiftUI

    /// A customizable message box with icon, title, and body text.
    /// Supports built-in variants for success, info, warning, error, header, or custom styling.
    ///
    /// Use `MessageBox` to display important information to the user in a visually distinct way.
    /// It offers several predefined `Variant` styles for common use cases (success, info, warn, error, header),
    /// and a `custom` variant for complete control over its appearance.
    ///
    /// VoiceOver reads the message box as one element: the severity of a built-in variant
    /// (for example, "Warning"), then the title and message. A custom variant's icon is decorative.
    public struct MessageBox: View {

        /// The available visual variants of the message box.
        public enum Variant {
            /// A success variant, typically used for positive feedback.
            case success

            /// An informational variant, typically used for general messages.
            case info

            /// A warning variant, typically used for cautionary messages.
            case warn

            /// An error variant, typically used for critical issues or failures.
            case error

            /// A custom variant allowing specification of distinct icon, background, and foreground styles.
            /// - Parameters:
            ///   - icon: The custom icon `Image` for this variant.
            ///   - background: The custom background `ShapeStyle` for the message box.
            ///   - foreground: The custom foreground `ShapeStyle` for the text.
            case custom(icon: Image, background: any ShapeStyle, foreground: any ShapeStyle)

            /// The default SF Safe Symbols icon associated with each variant.
            /// For `.custom` variants, it returns the `icon` provided during initialization.
            var defaultIcon: Image {
                switch self {
                    case .success: Image(systemSymbol: .handsClap)
                    case .info: Image(systemSymbol: .exclamationmarkCircle)
                    case .warn: Image(systemSymbol: .exclamationmarkTriangleFill)
                    case .error: Image(systemSymbol: .flameFill)
                    case let .custom(icon, _, _): icon
                }
            }

            /// The severity announced by assistive technologies in place of the icon's symbol name,
            /// or `nil` for `.custom` variants, whose icon is treated as decorative.
            var accessibilitySeverity: LocalizedStringResource? {
                switch self {
                    case .success: LocalizedStringResource("messageBox.severity.success", bundle: .module)
                    case .info: LocalizedStringResource("messageBox.severity.info", bundle: .module)
                    case .warn: LocalizedStringResource("messageBox.severity.warning", bundle: .module)
                    case .error: LocalizedStringResource("messageBox.severity.error", bundle: .module)
                    case .custom: nil
                }
            }

            /// Provides the appropriate background color style for the given variant based on the theme.
            /// - Parameter theme: The current theme environment.
            /// - Returns: An `AnyShapeStyle` representing the background color.
            func backgroundColor(theme: Theme) -> AnyShapeStyle {
                AnyShapeStyle(Material.regular)
            }

            /// Provides the appropriate icon color style for the given variant based on the theme.
            /// - Parameter theme: The current theme environment.
            /// - Returns: An `AnyShapeStyle` representing the icon color.
            func iconColor(theme: Theme) -> AnyShapeStyle {
                let style: any ShapeStyle = switch self {
                    case .success: theme.success
                    case .info: theme.primary
                    case .warn: theme.warning
                    case .error: theme.error
                    case let .custom(_, _, foreground): foreground
                }
                return AnyShapeStyle(style)
            }

            /// Provides the appropriate foreground color style for the given variant based on the theme.
            /// - Parameter theme: The current theme environment.
            /// - Returns: An `AnyShapeStyle` representing the foreground color for the title and message.
            func foregroundColor(theme: Theme) -> AnyShapeStyle {
                let style: any ShapeStyle = switch self {
                    case let .custom(_, _, foreground): foreground
                    default: theme.text1
                }
                return AnyShapeStyle(style)
            }
        }

        @Environment(\.horizontalSizeClass) var horizontalSizeClass
        @Environment(\.theme) var theme
        /// The visual variant of the message box.
        public let variant: Variant
        /// The icon displayed next to the title and message.
        public let icon: Image
        private let titleText: LocalizableText
        private let messageText: LocalizableText

        /// The title text to display in the message box.
        ///
        /// A title created from a `LocalizedStringResource` is resolved for the current locale.
        public var title: String {
            titleText.resolved
        }

        /// The main body text to display in the message box.
        ///
        /// A message created from a `LocalizedStringResource` is resolved for the current locale.
        public var message: String {
            messageText.resolved
        }

        /// Creates a new message box that displays its title and message verbatim.
        /// - Parameters:
        ///   - variant: The style variant to use.
        ///   - icon: Optional override icon (defaults to the variant’s default).
        ///   - title: Title text to display unchanged. An empty title isn't displayed.
        ///   - message: Body text to display unchanged. An empty message isn't displayed.
        public init(variant: Variant, icon: Image? = nil, title: String, message: String) {
            self.init(variant: variant, icon: icon, titleText: .verbatim(title), messageText: .verbatim(message))
        }

        /// Creates a new message box with a localized title and message.
        ///
        /// SwiftUI looks up each resource in its bundle and table using the environment's locale.
        /// - Parameters:
        ///   - variant: The style variant to use.
        ///   - icon: Optional override icon (defaults to the variant’s default).
        ///   - title: Localized title to display. A title that resolves to an empty string isn't displayed.
        ///   - message: Localized body text to display. A message that resolves to an empty string isn't displayed.
        public init(variant: Variant, icon: Image? = nil, title: LocalizedStringResource, message: LocalizedStringResource) {
            self.init(variant: variant, icon: icon, titleText: .localized(title), messageText: .localized(message))
        }

        private init(variant: Variant, icon: Image?, titleText: LocalizableText, messageText: LocalizableText) {
            self.variant = variant
            self.icon = icon ?? variant.defaultIcon
            self.titleText = titleText
            self.messageText = messageText
        }

        /// The content and behavior of the `MessageBox`.
        public var body: some View {
            HStack(alignment: .top, spacing: .xs) {
                icon
                    .font(.title3)
                    .foregroundStyle(variant.iconColor(theme: theme))
                    .accessibilityLabel(variant.accessibilitySeverity.map { Text($0) } ?? Text(verbatim: ""))
                    .accessibilityHidden(variant.accessibilitySeverity == nil)

                VStack(alignment: .leading, spacing: .xxxs) {
                    if !title.isEmpty {
                        titleText.text
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    }

                    if !message.isEmpty {
                        messageText.text
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                .foregroundStyle(variant.foregroundColor(theme: theme))

                Spacer()
            }
            .padding(.medium)
            .background(variant.backgroundColor(theme: theme))
            .contentShape(RoundedRectangle(cornerRadius: .xxs))
            .clipShape(RoundedRectangle(cornerRadius: .xxs))
            .shadow(color: theme.shadow, radius: 4, x: 2, y: 2)
            .accessibilityElement(children: .combine)
        }

    }

#endif

#if DEBUG && canImport(SwiftUI)
    import CalderStdLib
    import CalderSwiftUI
    import SFSafeSymbols
    import SnapshotPreviews
    import SwiftUI

    @MainActor enum MessageBoxPreviews: PreviewProvider, SnapshotProvider {
        static let defaultLayout: PreviewSnapshotLayout = .device

        static var snapshots: [PreviewSnapshot] {
            PreviewSnapshot("success") {
                PreviewContent(kind: .success)
            }

            PreviewSnapshot("info") {
                PreviewContent(kind: .info)
            }

            PreviewSnapshot("warn") {
                PreviewContent(kind: .warn)
            }

            PreviewSnapshot("error") {
                PreviewContent(kind: .error)
            }

            PreviewSnapshot("custom") {
                PreviewContent(kind: .custom)
            }
        }

        private enum Kind: Equatable {
            case custom
            case error
            case info
            case success
            case warn
        }

        private struct PreviewContent: View {
            @Environment(\.theme) private var theme

            let kind: Kind

            var body: some View {
                VStack {
                    if kind == .custom {
                        customMessageBox(lighten: true)
                        customMessageBox(lighten: false)
                    } else {
                        MessageBox(variant: variant, title: .lorem(25), message: .lorem(125))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(theme.backgroundGradient)
            }

            private var variant: MessageBox.Variant {
                switch kind {
                    case .custom:
                        .success
                    case .error:
                        .error
                    case .info:
                        .info
                    case .success:
                        .success
                    case .warn:
                        .warn
                }
            }

            private func customMessageBox(lighten: Bool) -> some View {
                let background = if lighten {
                    LinearGradient(lighten: theme.success, amount: 0.2, start: .top, end: .bottom)
                } else {
                    LinearGradient(darken: theme.success, amount: 0.2, start: .top, end: .bottom)
                }

                return MessageBox(
                    variant: .custom(
                        icon: Image(systemSymbol: .handsClap),
                        background: background,
                        foreground: theme.text1
                    ),
                    title: .lorem(25),
                    message: .lorem(125)
                )
            }
        }
    }
#endif
