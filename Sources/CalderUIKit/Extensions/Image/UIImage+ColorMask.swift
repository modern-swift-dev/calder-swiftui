#if canImport(Darwin)
    #if canImport(UIKit) && !os(watchOS)
        import CalderStdLib
        import Foundation
        import UIKit

        /// A simple struct that allows to easily define a range of values for color masking.
        public struct ColorRange {
            private static let MIN = 0.cgf
            private static let MAX = 255.cgf
            private static let MAX_RANGE = Self.MIN ... Self.MAX

            /// The Lower Bound. Value between 0 and 255.
            public private(set) var lower: CGFloat = 0

            /// The Upper Bound. Value between 0 and 255.
            public private(set) var upper: CGFloat = 0

            /// Initializes a `ColorRange` with specified lower and upper bounds.
            /// - Parameters:
            ///   - lower: The lower range value, between 0 and 255.
            ///   - upper: The upper range value, between 0 and 255.
            public init(_ lower: CGFloat, _ upper: CGFloat) {
                precondition(lower <= upper)
                self.lower = Self.MAX_RANGE.clampedValue(lower)
                self.upper = Self.MAX_RANGE.clampedValue(upper)
            }
        }

        /// A convenience struct to define a trio of color ranges for color masking.
        public struct ColorRanges {
            private static let MIN = 0.cgf
            private static let MAX = 255.cgf
            private static let MAX_RANGE = Self.MIN ... Self.MAX

            /// Red Color Range.
            public private(set) var red = ColorRange(0, 255)

            /// Green Color Range.
            public private(set) var green = ColorRange(0, 255)

            /// Blue Color Range.
            public private(set) var blue = ColorRange(0, 255)

            /// Initializes a `ColorRanges` with individual red, green, and blue color ranges.
            /// - Parameters:
            ///   - red: The `ColorRange` for the red component.
            ///   - green: The `ColorRange` for the green component.
            ///   - blue: The `ColorRange` for the blue component.
            public init(red: ColorRange, green: ColorRange, blue: ColorRange) {
                self.red = red
                self.blue = blue
                self.green = green
            }

            /// Initializes a `ColorRanges` based on a single color with a fudging offset.
            ///
            /// The color's red, green, and blue components are converted to the 0–255 scale used by the ranges.
            /// - Parameters:
            ///   - color: The source `UIColor`.
            ///   - fuzz: The fudging offset, between 0 and 255, to apply to each color component's range. Defaults to 0.0.
            public init(_ color: UIColor, _ fuzz: CGFloat = 0.0) {
                self.init(color, color, fuzz)
            }

            /// Initializes a `ColorRanges` based on a lower and upper color with a fudging offset.
            ///
            /// The colors' red, green, and blue components are converted to the 0–255 scale used by the ranges.
            /// Each component range spans the smaller to the larger of the two colors' components, so the colors
            /// don't need to be ordered component by component.
            /// - Parameters:
            ///   - lower: One bound `UIColor`.
            ///   - upper: The other bound `UIColor`.
            ///   - fuzz: The fudging offset, between 0 and 255, to apply to the ranges. Defaults to 0.0.
            public init(_ lower: UIColor, _ upper: UIColor, _ fuzz: CGFloat = 0.0) {
                var (red1, green1, blue1, alpha1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                lower.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)

                var (red2, green2, blue2, alpha2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                upper.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

                let adjustment = Self.MAX_RANGE.clampedValue(fuzz)
                red = Self.range(red1, red2, adjustment)
                green = Self.range(green1, green2, adjustment)
                blue = Self.range(blue1, blue2, adjustment)
            }

            /// A 0–255 range spanning two 0–1 color components, widened by `adjustment`.
            private static func range(_ component1: CGFloat, _ component2: CGFloat, _ adjustment: CGFloat) -> ColorRange {
                ColorRange(min(component1, component2) * MAX - adjustment, max(component1, component2) * MAX + adjustment)
            }
        }

        public extension UIGraphicsImageRendererFormat {
            /// Utility method that returns a transparent image renderer format.
            static func transparent() -> UIGraphicsImageRendererFormat {
                let value = UIGraphicsImageRendererFormat()
                value.opaque = false
                return value
            }

            /// Utility method that returns an opaque image renderer format.
            static func opaque() -> UIGraphicsImageRendererFormat {
                let value = UIGraphicsImageRendererFormat()
                value.opaque = true
                return value
            }
        }

        public extension UIImage {
            /// Renders an image without its alpha channel, removing any transparency.
            /// - Returns: A new `UIImage` with a fully opaque background.
            func withNoAlphaChannel() -> UIImage {
                let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.opaque())
                return renderer.image { [weak self] _ in
                    self?.draw(at: .zero)
                }
            }

            /// Masks specific colors within an image with a substitute color.
            ///
            /// Pixels whose red, green, and blue components, on a 0–255 scale, all fall within `range` are
            /// replaced with `color`. Other pixels keep their original color.
            /// - Parameters:
            ///   - color: The `UIColor` to use as the substitute for the masked range.
            ///   - range: The `ColorRanges` defining the color components to be masked.
            /// - Returns: A new `UIImage` with the specified colors masked, or `nil` if the image's `cgImage` is unavailable.
            func withColorMasked(_ color: UIColor, _ range: ColorRanges) -> UIImage? {
                let maskingColors: [CGFloat] = [range.red.lower, range.red.upper, range.green.lower, range.green.upper, range.blue.lower, range.blue.upper]
                let bounds = CGRect(origin: .zero, size: size)

                // Color masking requires 8-bit components and no alpha channel.
                if let imageToMask = cgImage,
                   let maskedImage = Self.opaqueRGBImage(imageToMask)?.copy(maskingColorComponents: maskingColors) {
                    let renderer = UIGraphicsImageRenderer(size: size, format: UIGraphicsImageRendererFormat.transparent())
                    return renderer.image { context in

                        let cgContext: CGContext = context.cgContext
                        cgContext.translateBy(x: 0, y: self.size.height)
                        cgContext.scaleBy(x: 1.0, y: -1.0)
                        cgContext.clip(to: bounds, mask: imageToMask)
                        cgContext.setFillColor(color.cgColor)
                        cgContext.fill(bounds)
                        cgContext.draw(maskedImage, in: bounds)
                    }
                }
                return nil
            }

            /// Redraws `image` into an 8-bit sRGB bitmap without an alpha channel, over a black background.
            private static func opaqueRGBImage(_ image: CGImage) -> CGImage? {
                guard let space = CGColorSpace(name: CGColorSpace.sRGB),
                      let context = CGContext(
                          data: nil,
                          width: image.width,
                          height: image.height,
                          bitsPerComponent: 8,
                          bytesPerRow: 0,
                          space: space,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
                      ) else {
                    return nil
                }
                context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
                return context.makeImage()
            }
        }
    #endif

#endif
