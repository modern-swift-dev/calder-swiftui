#if canImport(SwiftUI)
import CalderSwiftUI
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A theme definition that defines various colors and fonts used throughout the UI.
public struct ThemeDefinition {

    /// Creates a theme definition with Calder's default colors.
    public init() {}

    // MARK: - Primary Colors
    public var primary: ThemeColor = .init(lighten: "#066CDB", ratio: 0.1)
    public var textOverPrimary: ThemeColor = .init(light: .white, dark: .white)
    public var secondary: ThemeColor = .init(lighten: "#615AE4", ratio: 0.1)
    public var textOverSecondary: ThemeColor = .init(light: .white, dark: .white)

    // MARK: - Background & Surface Colors

    public var background1: ThemeColor = .init(
        light: .systemBackground,
        dark: .systemBackground
    )

    public var background2: ThemeColor = .init(
        light: .secondarySystemBackground,
        dark: .secondarySystemBackground
    )

    public var background3: ThemeColor = .init(
        light: .tertiarySystemBackground,
        dark: .tertiarySystemBackground
    )

    // MARK: - Borders
    public var border: ThemeColor = .init(
        light: .quaternaryLabel,
        dark: .quaternaryLabel
    )

    public var shadow: ThemeColor = .init(
        light: .tertiaryLabel,
        dark: .clear
    )

    // MARK: - Text Colors

    /// Primary text color, typically used for high-emphasis text.
    public var text1: ThemeColor = .init(
        light: .label,
        dark: .label
    )
    public var text2: ThemeColor = .init(
        light: .secondaryLabel,
        dark: .secondaryLabel
    )
    public var text3: ThemeColor = .init(
        light: .tertiaryLabel,
        dark: .tertiaryLabel
    )

    /// TextField
    public var textField: ThemeColor = .init(
        light: .tertiarySystemBackground,
        dark: .tertiarySystemBackground
    )
    public var textFieldEdit: ThemeColor = .init(
        light: .primary,
        dark: .primary
    )
    public var textFieldPlaceholder: ThemeColor = .init(
        light: .placeholderText,
        dark: .placeholderText
    )

    public var success: ThemeColor = .init(lighten: "#4E9A53", ratio: 0.1)
    public var textOverSuccess: ThemeColor = .init(light: .white, dark: .white)
    public var inProgress: ThemeColor = .init(lighten: "#F2994A", ratio: 0.1)
    public var textOverInProgress: ThemeColor = .init(light: .black, dark: .black)
    public var warning: ThemeColor = .init(lighten: "#F2C94C", ratio: 0.1)
    public var textOverWarning: ThemeColor = .init(light: .black, dark: .black)
    public var error: ThemeColor = .init(darken: "#EB5757", ratio: 0.1)
    public var textOverError: ThemeColor = .init(light: .white, dark: .white)
    public var info: ThemeColor = .init(lighten: "#066CDB", ratio: 0.15)
    public var textOverInfo: ThemeColor = .init(light: .white, dark: .white)
    public var inactive: ThemeColor = .init(light: .systemGroupedBackground, dark: .systemGroupedBackground)
    public var textOverInactive: ThemeColor = .init(light: .secondaryLabel, dark: .secondaryLabel)

}

#endif
