#if canImport(SwiftUI)
import Foundation
import SwiftUI

public extension ThemedButtonStyle {

    /// Defines the text styles available for `ThemedButtonStyle`.
    enum TextStyle: String, CaseIterable {

        /// A very prominent text style, typically the largest and boldest font.
        case veryProminent

        /// A prominent text style, larger than normal.
        case prominent

        /// A large text style, often used for specific UI elements like filters.
        case large

        /// The standard, medium-sized text style, commonly used for most buttons.
        case medium

        /// The smallest text style, often used for less prominent actions like "forgot password" links.
        case small

        /// Returns the `Font` corresponding to the text style for a given theme.
        /// - Parameter theme: The `Theme` object to retrieve font definitions from.
        /// - Returns: The `Font` for the specified text style.
        public func getFont(for theme: Theme) -> Font {
            switch self {
                case .veryProminent:
                    .title3
                case .prominent:
                    .headline
                case .large:
                    .subheadline
                case .medium:
                    .body
                case .small:
                    .caption
            }
        }
    }

}

#endif
