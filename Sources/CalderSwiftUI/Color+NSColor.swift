#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SwiftUI

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSColor {

    /// A contrasting UIColor for text layered on top of the current UIColor instance
    /// note: the possible outcome are charcoal and white
    var textColor: NSColor {
        contrastingTextColor()
    }

    /// A contrasting UIColor for text layered on top of the current UIColor instance
    func contrastingTextColor(light: NSColor = .white, dark: NSColor = .black) -> NSColor {
        // Convert to sRGB color space to safely extract RGB components
        let srgbColor = usingColorSpace(.sRGB) ?? self
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        srgbColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        // https://en.wikipedia.org/wiki/Luma_(video)
        let luma: CGFloat = 0.299 * r + 0.587 * g + 0.114 * b
        let threshold: CGFloat = 0.5

        return luma > threshold ? dark : light
    }

    var asSwiftUIColor: Color {
        Color(nsColor: self)
    }
}

public extension Color {

    var rgb: String {
        NSColor(self).toRGB("#")
    }

    var rgba: String {
        NSColor(self).toRGBA("#")
    }

    /// Used when requiring to display text on top of another color. This
    /// will calculate the appropriate color that should have the correct
    /// contrasting effect in order to be legible.
    var textColor: Color {
        NSColor(self).textColor.asSwiftUIColor
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
        NSColor(self).contrastingTextColor(light: NSColor(light), dark: NSColor(dark))
    }

    /// Return the UIColor for this SwiftUI Color
    var nsColor: NSColor {
        NSColor(self)
    }
}

#endif

#endif
