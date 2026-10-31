#if canImport(SwiftUI)
    import CalderUIKit
    import Foundation
    import SwiftUI

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        import AppKit

        public extension NSColor {

            /// A contrasting color for text layered on top of this color: black or white.
            ///
            /// Deprecated because it shares its name with AppKit's `NSColor.textColor` system color.
            @available(*, deprecated, renamed: "contrastingTextColor()")
            var textColor: NSColor {
                contrastingTextColor()
            }

            /// A contrasting color for text layered on top of this color.
            ///
            /// Returns whichever of `light` and `dark` has the higher WCAG 2.x contrast ratio against this
            /// color (see ``contrastRatio(with:)``); `dark` wins a tie. Colors are converted to sRGB using the
            /// current appearance and alpha is ignored.
            /// - Parameters:
            ///   - light: The candidate for dark backgrounds. Defaults to white.
            ///   - dark: The candidate for light backgrounds. Defaults to black.
            /// - Returns: `light` or `dark`.
            func contrastingTextColor(light: NSColor = .white, dark: NSColor = .black) -> NSColor {
                contrastRatio(with: light) > contrastRatio(with: dark) ? light : dark
            }

            /// The WCAG 2.x contrast ratio between this color and another, from `1` to `21`.
            ///
            /// Colors are converted to sRGB using the current appearance and alpha is ignored.
            /// The ratio is symmetric.
            /// - Parameter other: The color to compare with.
            /// - Returns: The contrast ratio, between `1` and `21`.
            func contrastRatio(with other: NSColor) -> Double {
                WCAGContrast.ratio(relativeLuminance, other.relativeLuminance)
            }

            private var relativeLuminance: Double {
                // Convert to sRGB color space to safely extract RGB components
                let srgbColor = usingColorSpace(.sRGB) ?? self
                var r: CGFloat = 0
                var g: CGFloat = 0
                var b: CGFloat = 0
                var a: CGFloat = 0
                srgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                return WCAGContrast.relativeLuminance(red: Double(r), green: Double(g), blue: Double(b))
            }

            /// This color as a SwiftUI `Color`.
            var asSwiftUIColor: Color {
                Color(nsColor: self)
            }
        }

        public extension Color {

            /// The color as a `#`-prefixed hexadecimal RGB string, such as `#AABBCC`.
            ///
            /// See `NSColor.toRGB(_:)` in CalderUIKit for how channels are converted.
            var rgb: String {
                NSColor(self).toRGB("#")
            }

            /// The color as a `#`-prefixed hexadecimal RGBA string, such as `#AABBCCDD`.
            ///
            /// See `NSColor.toRGBA(_:)` in CalderUIKit for how channels are converted.
            var rgba: String {
                NSColor(self).toRGBA("#")
            }

            /// Used when requiring to display text on top of another color. This
            /// will calculate the appropriate color that should have the correct
            /// contrasting effect in order to be legible.
            var textColor: Color {
                higherContrast(light: .white, dark: .black, in: EnvironmentValues())
            }

            /// Returns a darker version of this color, blended towards black.
            ///
            /// The color is converted through `NSColor`, so dynamic colors resolve with the current environment of
            /// the platform. Alpha is blended as well, which is a no-op for black.
            /// - Parameter amount: How far to blend towards black, from `0` (unchanged) to `1` (black). Values
            ///   outside that range are clamped. Defaults to `0.15`.
            /// - Returns: The darkened color.
            func darken(amount: CGFloat = 0.15) -> Color {
                NSColor(self).darken(amount).asSwiftUIColor
            }

            /// Returns a lighter version of this color, blended towards white.
            ///
            /// The color is converted through `NSColor`, so dynamic colors resolve with the current environment of
            /// the platform.
            /// - Parameter amount: How far to blend towards white, from `0` (unchanged) to `1` (white). Values
            ///   outside that range are clamped. Defaults to `0.15`.
            /// - Returns: The lightened color.
            func lighten(amount: CGFloat = 0.15) -> Color {
                NSColor(self).lighten(amount).asSwiftUIColor
            }

            /// Returns a brighter version of this color by increasing its HSB brightness.
            ///
            /// Hue and saturation stay the same and alpha is preserved. Unlike ``lighten(amount:)``, this doesn't
            /// blend towards white.
            /// - Parameter amount: How much to add to the brightness, typically from `0` to `1`. Defaults to `0.15`.
            /// - Returns: The brightened color.
            func brighten(amount: CGFloat = 0.15) -> Color {
                NSColor(self).brighten(amount).asSwiftUIColor
            }

            /// Returns a dimmer version of this color by decreasing its HSB brightness.
            ///
            /// Hue and saturation stay the same and alpha is preserved. Unlike ``darken(amount:)``, this doesn't
            /// blend towards black.
            /// - Parameter amount: How much to subtract from the brightness, typically from `0` to `1`. Defaults to `0.15`.
            /// - Returns: The dimmed color.
            func dim(amount: CGFloat = 0.15) -> Color {
                NSColor(self).dim(amount).asSwiftUIColor
            }

            /// Return the UIColor for this SwiftUI Color
            var nsColor: NSColor {
                NSColor(self)
            }
        }

    #endif

#endif
