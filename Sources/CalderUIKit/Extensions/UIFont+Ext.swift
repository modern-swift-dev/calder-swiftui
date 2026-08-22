#if canImport(Darwin)
#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

public extension UIFont {

    /// Returns a system font of a specified size, weight, and symbolic traits, scaled for accessibility.
    /// - Parameters:
    ///   - size: The point size of the font.
    ///   - weight: The weight of the font. Defaults to `.regular`.
    ///   - traits: The symbolic traits to apply to the font. Defaults to an empty optionset.
    ///   - compatibleWith: The trait collection to use for dynamic font size scaling. Defaults to `UITraitCollection.current`.
    /// - Returns: The scaled `UIFont`.
    static func scaledSystemFont(
        ofSize size: CGFloat,
        weight: UIFont.Weight = .regular,
        traits: UIFontDescriptor.SymbolicTraits = [],
        compatibleWith collection: UITraitCollection = UITraitCollection.current
    ) -> UIFont {
        scaledFont(
            base: .systemFont(ofSize: size, weight: weight),
            traits: traits,
            compatibleWith: collection
        )
    }

    /// Returns a scaled version of a base font with specified symbolic traits, optimized for accessibility.
    /// - Parameters:
    ///   - font: The base `UIFont` to scale.
    ///   - traits: The list of symbolic traits to apply. Defaults to an empty optionset.
    ///   - compatibleWith: The trait collection to use for dynamic font size scaling. Defaults to `UITraitCollection.current`.
    /// - Returns: The scaled `UIFont` according to weight, symbolic traits, and trait collection.
    static func scaledFont(
        base font: UIFont,
        traits: UIFontDescriptor.SymbolicTraits = [],
        compatibleWith: UITraitCollection = UITraitCollection.current
    ) -> UIFont {
        if !traits.isEmpty, let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: descriptor, size: font.pointSize)
            return UIFontMetrics.default.scaledFont(for: newFont, compatibleWith: compatibleWith)
        }
        return UIFontMetrics.default.scaledFont(for: font, compatibleWith: compatibleWith)
    }
}
#endif

#endif
