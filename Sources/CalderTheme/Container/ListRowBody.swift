#if canImport(SwiftUI)
    import CalderUIKit
    import Foundation
    import SwiftUI

    /// A view that composes the main body content for a list row, typically consisting of a title, subtitle, and caption.
    ///
    /// This view handles the layout and styling of text elements within a list row, adhering to the app's theme.
    public struct ListRowBody: View {

        @Environment(\.theme) var theme

        private let titleText: LocalizableText
        private let subtitleText: LocalizableText?
        private let captionText: LocalizableText?

        /// The primary title text for the row.
        ///
        /// A title created from a `LocalizedStringResource` is resolved for the current locale.
        public var title: String {
            titleText.resolved
        }

        /// An optional secondary subtitle text for the row.
        ///
        /// A subtitle created from a `LocalizedStringResource` is resolved for the current locale.
        public var subtitle: String? {
            subtitleText?.resolved
        }

        /// An optional caption text, usually smaller and less prominent, for the row.
        ///
        /// A caption created from a `LocalizedStringResource` is resolved for the current locale.
        public var caption: String? {
            captionText?.resolved
        }

        /// Initializes a new `ListRowBody` view that displays its text verbatim.
        ///
        /// - Parameters:
        ///   - title: The main title text.
        ///   - subtitle: An optional subtitle text. Defaults to `nil`.
        ///   - caption: An optional caption text. Defaults to `nil`.
        public init(title: String, subtitle: String? = nil, caption: String? = nil) {
            titleText = .verbatim(title)
            subtitleText = subtitle.map(LocalizableText.verbatim)
            captionText = caption.map(LocalizableText.verbatim)
        }

        /// Initializes a new `ListRowBody` view with localized text.
        ///
        /// SwiftUI looks up each resource in its bundle and table using the environment's locale.
        ///
        /// - Parameters:
        ///   - title: The localized main title.
        ///   - subtitle: An optional localized subtitle. Defaults to `nil`.
        ///   - caption: An optional localized caption. Defaults to `nil`.
        public init(title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, caption: LocalizedStringResource? = nil) {
            titleText = .localized(title)
            subtitleText = subtitle.map(LocalizableText.localized)
            captionText = caption.map(LocalizableText.localized)
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: .xxxs) {
                titleText.text
                    .font(.headline)
                    .foregroundStyle(theme.text1)
                    .lineLimit(2)

                if let subtitleText {
                    subtitleText.text
                        .font(.subheadline)
                        .foregroundStyle(theme.text2)
                        .lineLimit(2)
                }

                if let captionText {
                    captionText.text
                        .font(.caption)
                        .foregroundStyle(theme.text3)
                        .lineLimit(2)
                }
            }
        }
    }

#endif
