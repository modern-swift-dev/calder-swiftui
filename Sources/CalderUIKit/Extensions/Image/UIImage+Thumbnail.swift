#if canImport(Darwin)
    #if canImport(UIKit) && !os(watchOS) && !os(visionOS)
        import Foundation
        import ImageIO
        import UIKit

        public extension UIImage {

            convenience init?(data: Data, thumbnailSize newSize: CGSize) {
                let data = data as CFData
                guard let source = CGImageSourceCreateWithData(data, nil) else {
                    return nil
                }

                let options: [CFString: Any] = [
                    kCGImageSourceCreateThumbnailWithTransform: true,
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: max(newSize.width, newSize.height)
                ]

                guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                    return nil
                }
                self.init(cgImage: thumbnail)
            }

            /// Generate a thumbnail
            ///
            /// The image is drawn with `orientation` applied, so an orientation that swaps width and height is
            /// taken into account. The result uses the main screen's preferred scale and a transparent background.
            ///
            /// - Parameters:
            ///   - target: The size of the thumbnail, in points.
            ///   - keepAspectRatio: `true` to fit the whole image inside `target`, centred, preserving its aspect
            ///     ratio; `false` to stretch the whole image to fill `target`.
            ///   - orientation: The orientation to apply instead of the image's own orientation; ignored when the
            ///     image isn't backed by a `CGImage`.
            /// - Returns: The thumbnail.
            @MainActor func resize(_ target: CGSize, _ keepAspectRatio: Bool = true, _ orientation: UIImage.Orientation? = nil) -> UIImage {
                let orientedImage = scaledCopy(scale, orientation) ?? self

                var rect = CGRect(origin: .zero, size: target)
                if keepAspectRatio {
                    let imageSize = orientedImage.size
                    let imageScale: CGFloat = min(target.width / imageSize.width, target.height / imageSize.height)

                    let w: CGFloat = imageSize.width * imageScale
                    let h: CGFloat = imageSize.height * imageScale
                    rect = CGRect(x: (target.width - w) / 2, y: (target.height - h) / 2, width: w, height: h)
                }

                return Self.render(orientedImage, in: rect, canvasSize: target).withRenderingMode(renderingMode)
            }

            /// Generate a resize copy of the original picture, with the new size specified as an absolute value.
            ///
            /// The longer side of the image, after applying `orientation`, becomes `newSize` points. The result uses
            /// the main screen's preferred scale.
            ///
            /// - Parameters:
            ///   - newSize: The length of the longer side, in points.
            ///   - orientation: The orientation to apply instead of the image's own orientation.
            /// - Returns: The newly resized image, or the receiver if it isn't backed by a `CGImage`.
            @MainActor func resizeToFit(_ newSize: CGFloat, _ orientation: UIImage.Orientation? = nil) -> UIImage {
                guard let orientedImage = scaledCopy(scale, orientation) else {
                    return self
                }
                let imageSize = orientedImage.size
                let imageScale: CGFloat = newSize / max(imageSize.height, imageSize.width)
                let rect = CGRect(x: 0, y: 0, width: imageSize.width * imageScale, height: imageSize.height * imageScale)
                return Self.render(orientedImage, in: rect, canvasSize: rect.size).withRenderingMode(renderingMode)
            }

            /// Draws `image` into `rect` on a transparent canvas of `canvasSize` points at the main screen's preferred scale.
            @MainActor private static func render(_ image: UIImage, in rect: CGRect, canvasSize: CGSize) -> UIImage {
                let format = UIGraphicsImageRendererFormat.preferred()
                format.opaque = false
                format.preferredRange = .standard
                return UIGraphicsImageRenderer(size: canvasSize, format: format).image { _ in
                    image.draw(in: rect)
                }
            }

            /// Generate a scaled copy
            ///
            /// - parameter scale
            /// - Returns: The scaled image, or nil if cgImage is unavailable
            func scaledCopy(_ scale: CGFloat, _ orientation: UIImage.Orientation? = nil) -> UIImage? {
                guard let cgImage else {
                    return nil
                }
                return UIImage(
                    cgImage: cgImage,
                    scale: scale,
                    orientation: orientation ?? imageOrientation
                ).withRenderingMode(renderingMode)
            }
        }
    #endif

#endif
