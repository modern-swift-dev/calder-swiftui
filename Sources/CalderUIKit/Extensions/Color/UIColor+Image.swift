#if canImport(Darwin)
#if canImport(UIKit)
import CoreGraphics
import Foundation
import UIKit

public extension UIColor {

    /// Returns the specified color as a `UIImage` of a given size.
    /// - Parameter size: The `CGSize` of the resulting image. Defaults to `.one` (1x1 pixel).
    /// - Returns: A `UIImage` filled with the color, or an empty image if context creation fails.
    func asImage(_ size: CGSize = .one) -> UIImage {
        let rect = CGRect(size: size)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(cgColor)
            context.fill(rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    /// Returns the specified color as a square `UIImage` with a given side length.
    /// - Parameter value: The side length of the square.
    /// - Returns: A square `UIImage` filled with the color, or an empty image if context creation fails.
    func asSquare(_ value: CGFloat) -> UIImage {
        let rect = CGRect(size: value.size)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(cgColor)
            context.fill(rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    /// Returns the specified color as a circular `UIImage` with a given diameter.
    /// - Parameter value: The diameter of the circle.
    /// - Returns: A circular `UIImage` filled with the color, or an empty image if context creation fails.
    func asCircle(_ value: CGFloat) -> UIImage {
        let rect = CGRect(size: value.size)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }

        UIBezierPath(roundedRect: rect, cornerRadius: value / 2.0).addClip()

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(cgColor)
            context.fill(rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }

    /// Returns the specified color as an oval `UIImage` of a given size, optionally centered.
    /// - Parameters:
    ///   - size: The `CGSize` of the oval.
    ///   - centered: A boolean indicating whether the oval should be centered within the image bounds. Defaults to `true`.
    /// - Returns: An oval `UIImage` filled with the color, or an empty image if context creation fails.
    func asOval(_ size: CGSize, centered: Bool = true) -> UIImage {
        let rect = CGRect(size: size)
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }

        UIBezierPath(ovalOf: size, centered: centered).addClip()

        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(cgColor)
            context.fill(rect)
        }
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
}
#endif

#endif
