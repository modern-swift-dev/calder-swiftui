#if canImport(Darwin)
import CalderStdLib
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSColor {
    /// Returns a lighter/brighter version of the original color.
    /// - Parameter amount: The intensity of the blending, typically a value between 0.0 and 1.0.
    /// - Returns: The newly lightened color.
    func lighten(_ amount: CGFloat) -> NSColor {
        blend(with: .white, intensity: amount)
    }

    /// Returns a darker version of the original color.
    /// - Parameter amount: The intensity of the blending, typically a value between 0.0 and 1.0.
    /// - Returns: The newly darkened color.
    func darken(_ amount: CGFloat) -> NSColor {
        blend(with: .black, intensity: amount)
    }

    /// Blends the color with another specified color.
    /// - Parameters:
    ///   - color: The `UIColor` to blend with.
    ///   - intensity: The intensity of the blending, where 0.0 means no blending (returns original color)
    ///                and 1.0 means full blending (returns `color`). Defaults to 0.0.
    /// - Returns: The newly blended color.
    func blend(with color: NSColor, intensity: CGFloat = 0.0) -> NSColor {
        // swiftlint:disable identifier_name
        let range = (0.0 ... 1.0)
        let intensity2 = range.clampedValue(intensity)
        let intensity1 = 1.0 - intensity2

        // Convert to sRGB color space to safely extract RGB components
        let color1 = usingColorSpace(.sRGB) ?? self
        let color2 = color.usingColorSpace(.sRGB) ?? color

        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)

        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return NSColor(
            red: range.clampedValue(intensity1 * r1 + intensity2 * r2),
            green: range.clampedValue(intensity1 * g1 + intensity2 * g2),
            blue: range.clampedValue(intensity1 * b1 + intensity2 * b2),
            alpha: range.clampedValue(intensity1 * a1 + intensity2 * a2)
        )
        // swiftlint:enable identifier_name
    }

    /// Returns a brighter version of the original color by increasing its brightness component.
    /// - Parameter amount: The amount by which to increase the brightness, typically a value between 0.0 and 1.0.
    /// - Returns: The newly brightened color.
    func brighten(_ amount: CGFloat) -> NSColor {
        // Convert to sRGB color space to safely extract HSB components
        let color1 = usingColorSpace(.sRGB) ?? self
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color1.getHue(&r1, saturation: &g1, brightness: &b1, alpha: &a1)

        return NSColor(
            hue: r1,
            saturation: g1,
            brightness: b1 * (1.0 + amount),
            alpha: 1
        )
    }

    /// Returns a dimmer version of the original color by decreasing its brightness component.
    /// - Parameter amount: The amount by which to decrease the brightness, typically a value between 0.0 and 1.0.
    /// - Returns: The newly dimmed color.
    func dim(_ amount: CGFloat) -> NSColor {
        // Convert to sRGB color space to safely extract HSB components
        let color1 = usingColorSpace(.sRGB) ?? self
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        color1.getHue(&r1, saturation: &g1, brightness: &b1, alpha: &a1)

        return NSColor(
            hue: r1,
            saturation: g1,
            brightness: b1 * (1.0 - amount),
            alpha: 1
        )
    }
}
#endif

#endif
