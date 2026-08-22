#if canImport(SwiftUI)
import CalderSwiftUI
import CalderUIKit
import Foundation
import SwiftUI

/// A struct representing a theme color with support for light and dark modes,
/// as well as contrast variations for accessibility.
public struct ThemeColor {

    // MARK: - Properties

    /// The color used in light mode.
    private var light: Color

    /// The color used in dark mode, if provided.
    private var dark: Color?

    /// The high-contrast variant of the light mode color, if provided.
    private var lightContrast: Color?

    /// The high-contrast variant of the dark mode color, if provided.
    private var darkContrast: Color?

    // MARK: - Initializers

    /// Initializes a `ThemeColor` with explicit light and dark mode colors,
    /// along with optional high-contrast versions.
    /// - Parameters:
    ///   - light: The color to use in light mode.
    ///   - dark: The color to use in dark mode (optional).
    ///   - lightContrast: The high-contrast variant of the light mode color (optional).
    ///   - darkContrast: The high-contrast variant of the dark mode color (optional).
    public init(light: Color, dark: Color? = nil, lightContrast: Color? = nil, darkContrast: Color? = nil) {
        self.light = light
        self.dark = dark
        self.lightContrast = lightContrast
        self.darkContrast = darkContrast
    }

    /// Initializes a `ThemeColor` by darkening a base color.
    /// - Parameters:
    ///   - base: The base color to modify.
    ///   - ratio: The amount by which to darken the color (default is 0.5).
    ///   - lightContrastRatio: Optional ratio to generate a lighter contrast color.
    ///   - darkContrastRatio: Optional ratio to generate a darker contrast color.
    public init(darken base: Color, ratio: CGFloat = 0.5, lightContrastRatio: CGFloat? = nil, darkContrastRatio: CGFloat? = nil) {
        self.light = base
        self.dark = base.darken(amount: ratio)
        if let lightContrastRatio {
            self.lightContrast = base.lighten(amount: lightContrastRatio)
        }
        if let darkContrastRatio {
            self.darkContrast = base.lighten(amount: darkContrastRatio)
        }
    }

    /// Initializes a `ThemeColor` by lightening a base color.
    /// - Parameters:
    ///   - base: The base color to modify.
    ///   - ratio: The amount by which to lighten the color (default is 0.5).
    ///   - lightContrastRatio: Optional ratio to generate a darker contrast color.
    ///   - darkContrastRatio: Optional ratio to generate a lighter contrast color.
    public init(lighten base: Color, ratio: CGFloat = 0.5, lightContrastRatio: CGFloat? = nil, darkContrastRatio: CGFloat? = nil) {
        self.light = base
        self.dark = base.lighten(amount: ratio)
        if let lightContrastRatio {
            self.lightContrast = base.darken(amount: lightContrastRatio)
        }
        if let darkContrastRatio {
            self.darkContrast = base.lighten(amount: darkContrastRatio)
        }
    }

    /// Initializes a `ThemeColor` by lightening a color from an RGB hex string.
    /// - Parameters:
    ///   - rgb: The hex string representing the base color.
    ///   - ratio: The amount by which to lighten the color (default is 0.5).
    ///   - lightContrastRatio: Optional ratio to generate a darker contrast color.
    ///   - darkContrastRatio: Optional ratio to generate a lighter contrast color.
    public init(lighten rgb: String, ratio: CGFloat = 0.5, lightContrastRatio: CGFloat? = nil, darkContrastRatio: CGFloat? = nil) {
        let base = Color(rgb: rgb)
        self = .init(lighten: base, ratio: ratio, lightContrastRatio: lightContrastRatio, darkContrastRatio: darkContrastRatio)
    }

    /// Initializes a `ThemeColor` by darkening a color from an RGB hex string.
    /// - Parameters:
    ///   - rgb: The hex string representing the base color.
    ///   - ratio: The amount by which to darken the color (default is 0.5).
    ///   - lightContrastRatio: Optional ratio to generate a lighter contrast color.
    ///   - darkContrastRatio: Optional ratio to generate a darker contrast color.
    public init(darken rgb: String, ratio: CGFloat = 0.5, lightContrastRatio: CGFloat? = nil, darkContrastRatio: CGFloat? = nil) {
        let base = Color(rgb: rgb)
        self = .init(darken: base, ratio: ratio, lightContrastRatio: lightContrastRatio, darkContrastRatio: darkContrastRatio)
    }

    /// Initializes a `ThemeColor` from an RGB hex string, using it for all modes and contrasts.
    /// - Parameters:
    ///   - rgb: The hex string representing the base color.
    public init(rgb: String) {
        let base = Color(rgb: rgb)
        self.light = base
        self.dark = base
        self.lightContrast = base
        self.darkContrast = base
    }

    // MARK: - Methods

    /// Retrieves the appropriate color based on the given color scheme and contrast setting.
    /// - Parameters:
    ///   - scheme: The color scheme (`.light` or `.dark`). Defaults to `.light`.
    ///   - contrast: The contrast setting (`.increased` for high contrast). Defaults to `nil`.
    /// - Returns: The appropriate `Color` for the given scheme and contrast setting.
    public func getColor(scheme: ColorScheme = .light, contrast: ColorSchemeContrast? = nil) -> Color {
        if scheme == .dark {
            if contrast == .increased {
                return darkContrast ?? dark ?? light
            }
            return dark ?? light
        }
        if contrast == .increased {
            return lightContrast ?? light
        }
        return light
    }
}

#endif
