#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SwiftUI

/// A view that composes the main body content for a list row, typically consisting of a title, subtitle, and caption.
///
/// This view handles the layout and styling of text elements within a list row, adhering to the app's theme.
public struct ListRowBody: View {

    @Environment(\.theme) var theme

    /// The primary title text for the row.
    public let title: String
    /// An optional secondary subtitle text for the row.
    public let subtitle: String?
    /// An optional caption text, usually smaller and less prominent, for the row.
    public let caption: String?

    /// Initializes a new `ListRowBody` view.
    ///
    /// - Parameters:
    ///   - title: The main title text.
    ///   - subtitle: An optional subtitle text. Defaults to `nil`.
    ///   - caption: An optional caption text. Defaults to `nil`.
    public init(title: String, subtitle: String? = nil, caption: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.caption = caption
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .xxxs) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.text1)
                .lineLimit(2)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(theme.text2)
                    .lineLimit(2)
            }

            if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(theme.text3)
                    .lineLimit(2)
            }
        }
    }
}

#endif
