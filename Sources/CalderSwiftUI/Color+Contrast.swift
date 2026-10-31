#if canImport(SwiftUI)
    import Foundation
    import SwiftUI

    /// WCAG 2.x relative luminance and contrast-ratio arithmetic shared by the `Color`, `UIColor`, and `NSColor` helpers.
    enum WCAGContrast {

        /// Converts an sRGB-encoded channel to linear light, clamping it to `0...1`.
        static func linearized(_ channel: Double) -> Double {
            let value = min(max(channel, 0), 1)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        /// The relative luminance of a colour from linear-light channels, each clamped to `0...1`.
        static func relativeLuminance(linearRed: Double, linearGreen: Double, linearBlue: Double) -> Double {
            let clamp = { (value: Double) in min(max(value, 0), 1) }
            return 0.2126 * clamp(linearRed) + 0.7152 * clamp(linearGreen) + 0.0722 * clamp(linearBlue)
        }

        /// The relative luminance of a colour from sRGB-encoded channels.
        static func relativeLuminance(red: Double, green: Double, blue: Double) -> Double {
            relativeLuminance(linearRed: linearized(red), linearGreen: linearized(green), linearBlue: linearized(blue))
        }

        /// The contrast ratio, in `1...21`, between two relative luminances.
        static func ratio(_ first: Double, _ second: Double) -> Double {
            (max(first, second) + 0.05) / (min(first, second) + 0.05)
        }
    }

    public extension Color {

        /// The WCAG 2.x contrast ratio between this colour and another, from `1` (identical luminance) to `21` (black on white).
        ///
        /// Both colours are resolved in `environment` before they are compared, so dynamic colours and the
        /// colour scheme are taken into account. Opacity is ignored: each colour is treated as opaque.
        /// The ratio is symmetric, so `a.contrastRatio(with: b)` equals `b.contrastRatio(with: a)`.
        /// - Parameters:
        ///   - other: The colour to compare with.
        ///   - environment: The environment used to resolve both colours. Defaults to a default `EnvironmentValues`.
        /// - Returns: The contrast ratio, between `1` and `21`.
        func contrastRatio(with other: Color, in environment: EnvironmentValues = EnvironmentValues()) -> Double {
            WCAGContrast.ratio(relativeLuminance(in: environment), other.relativeLuminance(in: environment))
        }

        /// The candidate with the higher contrast ratio against this colour; `dark` wins a tie.
        internal func higherContrast(light: Color, dark: Color, in environment: EnvironmentValues) -> Color {
            contrastRatio(with: light, in: environment) > contrastRatio(with: dark, in: environment) ? light : dark
        }

        private func relativeLuminance(in environment: EnvironmentValues) -> Double {
            let resolved = resolve(in: environment)
            return WCAGContrast.relativeLuminance(
                linearRed: Double(resolved.linearRed),
                linearGreen: Double(resolved.linearGreen),
                linearBlue: Double(resolved.linearBlue)
            )
        }
    }

#endif
