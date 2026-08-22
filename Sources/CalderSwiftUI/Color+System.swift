#if canImport(SwiftUI)
#if canImport(UIKit) && !os(watchOS)
import SwiftUI
import UIKit

public extension Color {

    // MARK: - System Gray Colors

    /// A gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray
    static var systemGray: Color {
        Color(uiColor: .systemGray)
    }

    #if os(tvOS)
    /// A secondary gray fallback for tvOS.
    static var systemGray2: Color {
        .gray
    }

    /// A tertiary gray fallback for tvOS.
    static var systemGray3: Color {
        .gray
    }

    /// A quaternary gray fallback for tvOS.
    static var systemGray4: Color {
        .gray
    }

    /// A fifth-level gray fallback for tvOS.
    static var systemGray5: Color {
        .gray
    }

    /// A sixth-level gray fallback for tvOS.
    static var systemGray6: Color {
        .gray
    }
    #else
    /// A secondary gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray2
    static var systemGray2: Color {
        Color(uiColor: .systemGray2)
    }

    /// A tertiary gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray3
    static var systemGray3: Color {
        Color(uiColor: .systemGray3)
    }

    /// A quaternary gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray4
    static var systemGray4: Color {
        Color(uiColor: .systemGray4)
    }

    /// A quinary gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray5
    static var systemGray5: Color {
        Color(uiColor: .systemGray5)
    }

    /// A senary gray color that adapts to the current appearance.
    /// Equivalent to UIColor.systemGray6
    static var systemGray6: Color {
        Color(uiColor: .systemGray6)
    }
    #endif

    // MARK: - Label Colors

    /// The primary label color that adapts to the current appearance.
    /// Use for primary text content.
    /// Equivalent to UIColor.label
    static var label: Color {
        Color(uiColor: .label)
    }

    /// The secondary label color that adapts to the current appearance.
    /// Use for secondary text content with less emphasis.
    /// Equivalent to UIColor.secondaryLabel
    static var secondaryLabel: Color {
        Color(uiColor: .secondaryLabel)
    }

    /// The tertiary label color that adapts to the current appearance.
    /// Use for tertiary text content with minimal emphasis.
    /// Equivalent to UIColor.tertiaryLabel
    static var tertiaryLabel: Color {
        Color(uiColor: .tertiaryLabel)
    }

    /// The quaternary label color that adapts to the current appearance.
    /// Use for quaternary text content or disabled text.
    /// Equivalent to UIColor.quaternaryLabel
    static var quaternaryLabel: Color {
        Color(uiColor: .quaternaryLabel)
    }

    // MARK: - Interactive Colors

    /// The standard link color that adapts to the current appearance.
    /// Use for clickable links and interactive text.
    /// Equivalent to UIColor.link
    static var link: Color {
        Color(uiColor: .link)
    }

    /// The placeholder text color that adapts to the current appearance.
    /// Use for placeholder text in text fields.
    /// Equivalent to UIColor.placeholderText
    static var placeholderText: Color {
        Color(uiColor: .placeholderText)
    }

    // MARK: - Separator Colors

    /// A separator color that adapts to the current appearance.
    /// Use for thin separator lines that allow content to show through.
    /// Equivalent to UIColor.separator
    static var separator: Color {
        Color(uiColor: .separator)
    }

    /// An opaque separator color that adapts to the current appearance.
    /// Use for separator lines that completely hide content behind them.
    /// Equivalent to UIColor.opaqueSeparator
    static var opaqueSeparator: Color {
        Color(uiColor: .opaqueSeparator)
    }

    // MARK: - Background Colors

    #if os(tvOS)
    /// The primary background fallback for tvOS.
    static var systemBackground: Color {
        .black
    }

    /// The secondary background fallback for tvOS.
    static var secondarySystemBackground: Color {
        .black
    }

    /// The tertiary background fallback for tvOS.
    static var tertiarySystemBackground: Color {
        .black
    }
    #else
    /// The primary system background color that adapts to the current appearance.
    /// Use for the main background of your interface.
    /// Equivalent to UIColor.systemBackground
    static var systemBackground: Color {
        Color(uiColor: .systemBackground)
    }

    /// The secondary system background color that adapts to the current appearance.
    /// Use for content layered on top of the primary background.
    /// Equivalent to UIColor.secondarySystemBackground
    static var secondarySystemBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }

    /// The tertiary system background color that adapts to the current appearance.
    /// Use for content layered on top of secondary backgrounds.
    /// Equivalent to UIColor.tertiarySystemBackground
    static var tertiarySystemBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
    #endif

    // MARK: - Grouped Background Colors

    #if os(tvOS)
    /// The primary grouped background fallback for tvOS.
    static var systemGroupedBackground: Color {
        .black
    }

    /// The secondary grouped background fallback for tvOS.
    static var secondarySystemGroupedBackground: Color {
        .black
    }

    /// The tertiary grouped background fallback for tvOS.
    static var tertiarySystemGroupedBackground: Color {
        .black
    }
    #else
    /// The primary grouped background color that adapts to the current appearance.
    /// Use for grouped content like table view sections.
    /// Equivalent to UIColor.systemGroupedBackground
    static var systemGroupedBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }

    /// The secondary grouped background color that adapts to the current appearance.
    /// Use for grouped content layered on top of the primary grouped background.
    /// Equivalent to UIColor.secondarySystemGroupedBackground
    static var secondarySystemGroupedBackground: Color {
        Color(uiColor: .secondarySystemGroupedBackground)
    }

    /// The tertiary grouped background color that adapts to the current appearance.
    /// Use for grouped content layered on top of secondary grouped backgrounds.
    /// Equivalent to UIColor.tertiarySystemGroupedBackground
    static var tertiarySystemGroupedBackground: Color {
        Color(uiColor: .tertiarySystemGroupedBackground)
    }
    #endif

    // MARK: - Fill Colors

    #if os(tvOS)
    /// The primary fill fallback for tvOS.
    static var systemFill: Color {
        .gray
    }

    /// The secondary fill fallback for tvOS.
    static var secondarySystemFill: Color {
        .gray
    }

    /// The tertiary fill fallback for tvOS.
    static var tertiarySystemFill: Color {
        .gray
    }

    /// The quaternary fill fallback for tvOS.
    static var quaternarySystemFill: Color {
        .gray
    }
    #else
    /// The primary system fill color that adapts to the current appearance.
    /// Use for thin and small shapes.
    /// Equivalent to UIColor.systemFill
    static var systemFill: Color {
        Color(uiColor: .systemFill)
    }

    /// The secondary system fill color that adapts to the current appearance.
    /// Use for medium-size shapes.
    /// Equivalent to UIColor.secondarySystemFill
    static var secondarySystemFill: Color {
        Color(uiColor: .secondarySystemFill)
    }

    /// The tertiary system fill color that adapts to the current appearance.
    /// Use for large shapes.
    /// Equivalent to UIColor.tertiarySystemFill
    static var tertiarySystemFill: Color {
        Color(uiColor: .tertiarySystemFill)
    }

    /// The quaternary system fill color that adapts to the current appearance.
    /// Use for large areas containing complex content.
    /// Equivalent to UIColor.quaternarySystemFill
    static var quaternarySystemFill: Color {
        Color(uiColor: .quaternarySystemFill)
    }
    #endif

    // MARK: - Static Text Colors

    #if os(tvOS)
    /// A light text fallback for tvOS.
    static var lightText: Color {
        .white
    }

    /// A dark text fallback for tvOS.
    static var darkText: Color {
        .black
    }
    #else
    /// A light text color for use on dark backgrounds.
    /// This color does not adapt to appearance changes.
    /// Equivalent to UIColor.lightText
    static var lightText: Color {
        Color(uiColor: .lightText)
    }

    /// A dark text color for use on light backgrounds.
    /// This color does not adapt to appearance changes.
    /// Equivalent to UIColor.darkText
    static var darkText: Color {
        Color(uiColor: .darkText)
    }
    #endif
}

#elseif canImport(AppKit)
import AppKit
import SwiftUI

public extension Color {

    // MARK: - Label Colors

    /// The primary label color that adapts to the current appearance.
    static var label: Color {
        Color(nsColor: .labelColor)
    }

    /// The secondary label color that adapts to the current appearance.
    static var secondaryLabel: Color {
        Color(nsColor: .secondaryLabelColor)
    }

    /// The tertiary label color that adapts to the current appearance.
    static var tertiaryLabel: Color {
        Color(nsColor: .tertiaryLabelColor)
    }

    /// The quaternary label color that adapts to the current appearance.
    static var quaternaryLabel: Color {
        Color(nsColor: .quaternaryLabelColor)
    }

    // MARK: - Interactive Colors

    /// The standard link color that adapts to the current appearance.
    static var link: Color {
        Color(nsColor: .linkColor)
    }

    /// The placeholder text color that adapts to the current appearance.
    static var placeholderText: Color {
        Color(nsColor: .placeholderTextColor)
    }

    // MARK: - Separator Colors

    /// A separator color that adapts to the current appearance.
    static var separator: Color {
        Color(nsColor: .separatorColor)
    }

    // MARK: - Background Colors

    /// The primary system background color that adapts to the current appearance.
    static var systemBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }

    /// The secondary system background color that adapts to the current appearance.
    static var secondarySystemBackground: Color {
        Color(nsColor: .controlBackgroundColor)
    }

    /// The tertiary system background color that adapts to the current appearance.
    static var tertiarySystemBackground: Color {
        Color(nsColor: .textBackgroundColor)
    }

    // MARK: - Grouped Background Colors

    /// The primary grouped background color that adapts to the current appearance.
    static var systemGroupedBackground: Color {
        Color(nsColor: .windowBackgroundColor)
    }

    /// The secondary grouped background color that adapts to the current appearance.
    static var secondarySystemGroupedBackground: Color {
        Color(nsColor: .controlBackgroundColor)
    }

    /// The tertiary grouped background color that adapts to the current appearance.
    static var tertiarySystemGroupedBackground: Color {
        Color(nsColor: .textBackgroundColor)
    }

    // MARK: - System Gray Colors

    /// A gray color that adapts to the current appearance.
    static var systemGray: Color {
        Color(nsColor: .systemGray)
    }

    /// A secondary gray color that adapts to the current appearance.
    static var systemGray2: Color {
        Color(nsColor: .systemGray)
    }

    /// A tertiary gray color that adapts to the current appearance.
    static var systemGray3: Color {
        Color(nsColor: .systemGray)
    }

    /// A quaternary gray color that adapts to the current appearance.
    static var systemGray4: Color {
        Color(nsColor: .systemGray)
    }

    /// A quinary gray color that adapts to the current appearance.
    static var systemGray5: Color {
        Color(nsColor: .systemGray)
    }

    /// A senary gray color that adapts to the current appearance.
    static var systemGray6: Color {
        Color(nsColor: .systemGray)
    }
}

#elseif os(watchOS)
import SwiftUI

public extension Color {

    // MARK: - System Gray Colors

    /// A gray color that adapts to the current appearance.
    static var systemGray: Color {
        Color.gray
    }

    /// A secondary gray color that adapts to the current appearance.
    static var systemGray2: Color {
        Color.gray.opacity(0.9)
    }

    /// A tertiary gray color that adapts to the current appearance.
    static var systemGray3: Color {
        Color.gray.opacity(0.8)
    }

    /// A quaternary gray color that adapts to the current appearance.
    static var systemGray4: Color {
        Color.gray.opacity(0.7)
    }

    /// A quinary gray color that adapts to the current appearance.
    static var systemGray5: Color {
        Color.gray.opacity(0.6)
    }

    /// A senary gray color that adapts to the current appearance.
    static var systemGray6: Color {
        Color.gray.opacity(0.5)
    }

    // MARK: - Label Colors

    /// The primary label color that adapts to the current appearance.
    static var label: Color {
        Color.primary
    }

    /// The secondary label color that adapts to the current appearance.
    static var secondaryLabel: Color {
        Color.secondary
    }

    /// The tertiary label color that adapts to the current appearance.
    static var tertiaryLabel: Color {
        Color.secondary.opacity(0.7)
    }

    /// The quaternary label color that adapts to the current appearance.
    static var quaternaryLabel: Color {
        Color.secondary.opacity(0.5)
    }

    // MARK: - Interactive Colors

    /// The standard link color that adapts to the current appearance.
    static var link: Color {
        Color.blue
    }

    /// The placeholder text color that adapts to the current appearance.
    static var placeholderText: Color {
        Color.gray
    }

    // MARK: - Separator Colors

    /// A separator color that adapts to the current appearance.
    static var separator: Color {
        Color.gray.opacity(0.3)
    }

    /// An opaque separator color that adapts to the current appearance.
    static var opaqueSeparator: Color {
        Color.gray
    }

    // MARK: - Background Colors

    /// The primary system background color that adapts to the current appearance.
    static var systemBackground: Color {
        Color.black
    }

    /// The secondary system background color that adapts to the current appearance.
    static var secondarySystemBackground: Color {
        Color(white: 0.1)
    }

    /// The tertiary system background color that adapts to the current appearance.
    static var tertiarySystemBackground: Color {
        Color(white: 0.15)
    }

    // MARK: - Grouped Background Colors

    /// The primary grouped background color that adapts to the current appearance.
    static var systemGroupedBackground: Color {
        Color.black
    }

    /// The secondary grouped background color that adapts to the current appearance.
    static var secondarySystemGroupedBackground: Color {
        Color(white: 0.1)
    }

    /// The tertiary grouped background color that adapts to the current appearance.
    static var tertiarySystemGroupedBackground: Color {
        Color(white: 0.15)
    }

    // MARK: - Fill Colors

    /// The primary system fill color that adapts to the current appearance.
    static var systemFill: Color {
        Color.gray.opacity(0.2)
    }

    /// The secondary system fill color that adapts to the current appearance.
    static var secondarySystemFill: Color {
        Color.gray.opacity(0.15)
    }

    /// The tertiary system fill color that adapts to the current appearance.
    static var tertiarySystemFill: Color {
        Color.gray.opacity(0.1)
    }

    /// The quaternary system fill color that adapts to the current appearance.
    static var quaternarySystemFill: Color {
        Color.gray.opacity(0.05)
    }

    // MARK: - Static Text Colors

    /// A light text color for use on dark backgrounds.
    static var lightText: Color {
        Color.white
    }

    /// A dark text color for use on light backgrounds.
    static var darkText: Color {
        Color.black
    }
}

#endif

#endif
