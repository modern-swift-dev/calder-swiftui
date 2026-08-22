#if canImport(Darwin)
#if canImport(UIKit) && !os(watchOS)
import Foundation
import UIKit

public extension UIImage {

    /// Tints an image with the specified color.
    /// - Parameter tintColor: The `UIColor` to apply as a tint.
    /// - Returns: A new `UIImage` with the applied tint, or `nil` if the image's `cgImage` is unavailable.
    func tint(_ tintColor: UIColor) -> UIImage? {
        let bounds = CGRect(origin: .zero, size: size)
        let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.transparent())
        if let cgImage {
            return renderer.image { context in
                let cgContext: CGContext = context.cgContext
                cgContext.translateBy(x: 0, y: self.size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                // draw tint color
                cgContext.setBlendMode(CGBlendMode.normal)
                cgContext.setFillColor(tintColor.cgColor)
                cgContext.fill(bounds)
                // mask by alpha values of original image
                cgContext.setBlendMode(CGBlendMode.destinationIn)
                cgContext.draw(cgImage, in: bounds)
            }
        }
        return nil
    }

    /// Tints an image using a linear gradient of specified colors.
    /// - Parameters:
    ///   - colors: An array of `UIColor` objects to use for the gradient. The gradient will transition between these colors.
    ///   - vertical: A boolean indicating whether the gradient should be applied vertically (`true`) or horizontally (`false`). Defaults to `true`.
    /// - Returns: A new `UIImage` with the applied gradient tint. If the context cannot be created, an empty `UIImage` is returned.
    func tintGradient(colors: [UIColor], vertical: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext(),
              let cgImage else {
            UIGraphicsEndImageContext()
            return UIImage()
        }
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1, y: -1)
        context.setBlendMode(.normal)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        // Create gradient
        let cgColors = colors.map(\.cgColor) as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        guard let gradient = CGGradient(colorsSpace: space, colors: cgColors, locations: nil) else {
            UIGraphicsEndImageContext()
            return UIImage()
        }

        // Apply gradient
        context.clip(to: rect, mask: cgImage)
        if vertical {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: size.height), options: .drawsAfterEndLocation)
        } else {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: .drawsAfterEndLocation)
        }
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return gradientImage ?? UIImage()
    }
}
#endif

#endif
