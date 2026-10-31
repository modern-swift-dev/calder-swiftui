#if canImport(Darwin)
    #if canImport(UIKit)
        import CoreGraphics
        import Foundation
        import UIKit

        public extension UIColor {

            /// Returns the specified color as a `UIImage` of a given size.
            /// - Parameter size: The `CGSize` of the resulting image. Defaults to `.one` (1x1 point).
            /// - Returns: A `UIImage` filled with the color, rendered at the scale of the default `UIGraphicsImageRendererFormat`,
            ///   or an empty image if `size` has a non-positive width or height.
            func asImage(_ size: CGSize = .one) -> UIImage {
                filledImage(size: size, clip: nil)
            }

            /// Returns the specified color as a square `UIImage` with a given side length.
            /// - Parameter value: The side length of the square.
            /// - Returns: A square `UIImage` filled with the color, rendered at the scale of the default `UIGraphicsImageRendererFormat`,
            ///   or an empty image if `value` isn't positive.
            func asSquare(_ value: CGFloat) -> UIImage {
                filledImage(size: value.size, clip: nil)
            }

            /// Returns the specified color as a circular `UIImage` with a given diameter.
            /// - Parameter value: The diameter of the circle.
            /// - Returns: A circular `UIImage` filled with the color, rendered at the scale of the default `UIGraphicsImageRendererFormat`,
            ///   or an empty image if `value` isn't positive.
            func asCircle(_ value: CGFloat) -> UIImage {
                filledImage(size: value.size) { UIBezierPath(ovalIn: $0) }
            }

            /// Returns the specified color as an oval `UIImage` that fills the given size.
            /// - Parameter size: The `CGSize` of the image; the oval touches all four edges.
            /// - Returns: An oval `UIImage` filled with the color, rendered at the scale of the default `UIGraphicsImageRendererFormat`,
            ///   or an empty image if `size` has a non-positive width or height.
            func asOval(_ size: CGSize) -> UIImage {
                filledImage(size: size) { UIBezierPath(ovalIn: $0) }
            }

            private func filledImage(size: CGSize, clip: ((CGRect) -> UIBezierPath)?) -> UIImage {
                guard size.width > 0, size.height > 0 else {
                    return UIImage()
                }
                let rect = CGRect(origin: .zero, size: size)
                #if os(watchOS)
                    // watchOS has no `UIGraphicsImageRenderer`; a scale of 0 uses the main screen's scale.
                    UIGraphicsBeginImageContextWithOptions(size, false, 0)
                    defer { UIGraphicsEndImageContext() }
                    clip?(rect).addClip()
                    if let context = UIGraphicsGetCurrentContext() {
                        context.setFillColor(cgColor)
                        context.fill(rect)
                    }
                    return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                #else
                    let format = UIGraphicsImageRendererFormat()
                    format.opaque = false
                    return UIGraphicsImageRenderer(size: size, format: format).image { context in
                        clip?(rect).addClip()
                        context.cgContext.setFillColor(cgColor)
                        context.cgContext.fill(rect)
                    }
                #endif
            }
        }
    #endif

#endif
