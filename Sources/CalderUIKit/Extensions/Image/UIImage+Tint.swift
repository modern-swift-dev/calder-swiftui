#if canImport(Darwin)
    #if canImport(UIKit) && !os(watchOS)
        import Foundation
        import UIKit

        public extension UIImage {

            /// Tints an image with the specified color.
            /// - Parameter tintColor: The `UIColor` to apply as a tint.
            /// - Returns: A new `UIImage` with the applied tint, or `nil` if the image's `cgImage` is unavailable or its size is empty.
            func tint(_ tintColor: UIColor) -> UIImage? {
                guard size.width > 0, size.height > 0 else {
                    return nil
                }
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
            /// - Returns: A new `UIImage` with the applied gradient tint. If the image has no `cgImage` or an empty size, or the gradient cannot be created, an empty `UIImage` is returned. The result keeps the image's scale.
            func tintGradient(colors: [UIColor], vertical: Bool = true) -> UIImage {
                guard size.width > 0, size.height > 0, let cgImage else {
                    return UIImage()
                }
                let cgColors = colors.map(\.cgColor) as CFArray
                guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: nil) else {
                    return UIImage()
                }

                let format = UIGraphicsImageRendererFormat.transparent()
                format.scale = scale
                let rect = CGRect(origin: .zero, size: size)
                let end = vertical ? CGPoint(x: 0, y: size.height) : CGPoint(x: size.width, y: 0)
                return UIGraphicsImageRenderer(size: size, format: format).image { context in
                    let cgContext = context.cgContext
                    cgContext.translateBy(x: 0, y: size.height)
                    cgContext.scaleBy(x: 1, y: -1)
                    cgContext.setBlendMode(.normal)
                    cgContext.clip(to: rect, mask: cgImage)
                    cgContext.drawLinearGradient(gradient, start: .zero, end: end, options: .drawsAfterEndLocation)
                }
            }
        }
    #endif

#endif
