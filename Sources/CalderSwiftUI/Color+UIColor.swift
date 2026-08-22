#if canImport(SwiftUI)
import CalderUIKit
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit

public extension UIColor {

    /// A contrasting UIColor for text layered on top of the current UIColor instance
    /// note: the possible outcome are charcoal and white
    var textColor: UIColor {
        contrastingTextColor()
    }

    /// A contrasting UIColor for text layered on top of the current UIColor instance
    func contrastingTextColor(light: UIColor = .white, dark: UIColor = .black) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        // https://en.wikipedia.org/wiki/Luma_(video)
        let luma: CGFloat = 0.299 * r + 0.587 * g + 0.114 * b
        let threshold: CGFloat = 0.5

        return luma > threshold ? dark : light
    }

    var asSwiftUIColor: Color {
        Color(uiColor: self)
    }
}

public extension Color {

    var rgb: String {
        UIColor(self).toRGB("#")
    }

    var rgba: String {
        UIColor(self).toRGBA("#")
    }

    /// Used when requiring to display text on top of another color. This
    /// will calculate the appropriate color that should have the correct
    /// contrasting effect in order to be legible.
    var textColor: Color {
        UIColor(self).textColor.asSwiftUIColor
    }

    func darken(amount: CGFloat = 0.15) -> Color {
        UIColor(self).darken(amount).asSwiftUIColor
    }

    func lighten(amount: CGFloat = 0.15) -> Color {
        UIColor(self).lighten(amount).asSwiftUIColor
    }

    func brighten(amount: CGFloat = 0.15) -> Color {
        UIColor(self).brighten(amount).asSwiftUIColor
    }

    func dim(amount: CGFloat = 0.15) -> Color {
        UIColor(self).dim(amount).asSwiftUIColor
    }

    /// A contrasting Color for text layered on top of the current Color instance
    func contrastingTextColor(light: Color = .white, dark: Color = .black) -> UIColor {
        UIColor(self).contrastingTextColor(light: UIColor(light), dark: UIColor(dark))
    }

    /// Return the UIColor for this SwiftUI Color
    var uiColor: UIColor {
        UIColor(self)
    }
}

#endif

#endif
