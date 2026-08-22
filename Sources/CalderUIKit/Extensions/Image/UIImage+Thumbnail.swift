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
    /// - parameter target the CGSize
    /// - parameter keepAspectRatio the aspect ratio is to be preserved
    /// - Returns: The thumbnail
    @MainActor func resize(_ target: CGSize, _ keepAspectRatio: Bool = true, _ orientation: UIImage.Orientation? = nil) -> UIImage {
        if keepAspectRatio {
            guard let scaledImage = scaledCopy(scale, orientation) else {
                return self
            }
            let imageScale: CGFloat = min(target.width / size.width, target.height / size.height)

            let w: CGFloat = size.width * imageScale
            let h: CGFloat = size.height * imageScale
            let x: CGFloat = (target.width - w) / 2
            let y: CGFloat = (target.height - h) / 2
            let rect = CGRect(x: x, y: y, width: w, height: h)

            UIGraphicsBeginImageContextWithOptions(target, false, UIScreen.main.scale)
            scaledImage.draw(in: rect)
            let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return thumbnail?.withRenderingMode(renderingMode) ?? self
        }

        UIGraphicsBeginImageContextWithOptions(target, false, UIScreen.main.scale)
        draw(in: CGRect(0, 0, size.width, size.height))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail?.withRenderingMode(renderingMode) ?? self
    }

    /// Generate a resize copy of the original picture, with the new size specified as an absolute value.
    ///
    /// - parameters newSize: the actual size in pixels
    /// - parameters orientation: the orientation of the picture
    /// - returns: the newly resized image.
    @MainActor func resizeToFit(_ newSize: CGFloat, _ orientation: UIImage.Orientation? = nil) -> UIImage {
        let imageScale: CGFloat = newSize / max(size.height, size.width)
        guard let scaledImage = scaledCopy(imageScale, orientation) else {
            return self
        }
        let w: CGFloat = size.width * imageScale
        let h: CGFloat = size.height * imageScale
        let rect = CGRect(x: 0, y: 0, width: w, height: h)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        scaledImage.draw(in: rect)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnail?.withRenderingMode(renderingMode) ?? self
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
