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

            func darken(amount: CGFloat = 0.15) -> Color {
                NSColor(self).darken(amount).asSwiftUIColor
            }

            func lighten(amount: CGFloat = 0.15) -> Color {
                NSColor(self).lighten(amount).asSwiftUIColor
            }

            func brighten(amount: CGFloat = 0.15) -> Color {
                NSColor(self).brighten(amount).asSwiftUIColor
            }

            func dim(amount: CGFloat = 0.15) -> Color {
                NSColor(self).dim(amount).asSwiftUIColor
            }

            /// A contrasting Color for text layered on top of the current Color instance
            func contrastingTextColor(light: Color = .white, dark: Color = .black) -> NSColor {
                NSColor(higherContrast(light: light, dark: dark, in: EnvironmentValues()))
            }

            /// Return the UIColor for this SwiftUI Color
            var nsColor: NSColor {
                NSColor(self)
            }
        }

    #endif

#endif
