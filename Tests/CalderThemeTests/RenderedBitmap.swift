#if canImport(SwiftUI)
    import CoreGraphics
    import SwiftUI

    /// The 8-bit premultiplied sRGB pixels of a SwiftUI view rendered by `ImageRenderer` at a scale of 1.
    struct RenderedBitmap: Equatable, CustomStringConvertible {

        /// One premultiplied RGBA pixel.
        struct Pixel: Equatable, CustomStringConvertible {
            let red: UInt8
            let green: UInt8
            let blue: UInt8
            let alpha: UInt8

            static let clear = Pixel(red: 0, green: 0, blue: 0, alpha: 0)

            var description: String {
                "RGBA(\(red), \(green), \(blue), \(alpha))"
            }

            /// Whether every channel differs from `other` by at most `tolerance`.
            func isClose(to other: Pixel, tolerance: Int = 3) -> Bool {
                abs(Int(red) - Int(other.red)) <= tolerance
                    && abs(Int(green) - Int(other.green)) <= tolerance
                    && abs(Int(blue) - Int(other.blue)) <= tolerance
                    && abs(Int(alpha) - Int(other.alpha)) <= tolerance
            }
        }

        let width: Int
        let height: Int
        private let bytes: [UInt8]

        var description: String {
            "RenderedBitmap(\(width)x\(height))"
        }

        /// Renders `view` at its ideal size, or returns `nil` when it produces no image.
        ///
        /// A completely blank result is rendered again up to twice, because `ImageRenderer` has
        /// intermittently produced uniform images on loaded CI simulators; a view that really is
        /// blank still returns its blank bitmap.
        @MainActor init?(rendering view: some View) {
            let renderer = ImageRenderer(content: view)
            renderer.scale = 1
            var rendered: RenderedBitmap?
            for _ in 0 ..< 3 {
                guard let image = renderer.cgImage, let bitmap = RenderedBitmap(image: image) else {
                    return nil
                }
                rendered = bitmap
                if !bitmap.isBlank {
                    break
                }
            }
            guard let rendered else {
                return nil
            }
            self = rendered
        }

        /// Whether every byte of the bitmap is zero, as in a fully transparent image.
        private var isBlank: Bool {
            bytes.allSatisfy { $0 == 0 }
        }

        /// Copies the pixels of `image`.
        init?(image: CGImage) {
            let width = image.width
            let height = image.height
            guard width > 0, height > 0, let space = CGColorSpace(name: CGColorSpace.sRGB) else {
                return nil
            }
            var bytes = [UInt8](repeating: 0, count: width * height * 4)
            let drawn = bytes.withUnsafeMutableBytes { buffer in
                guard let context = CGContext(
                    data: buffer.baseAddress,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                ) else {
                    return false
                }
                context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
                return true
            }
            guard drawn else {
                return nil
            }
            self.width = width
            self.height = height
            self.bytes = bytes
        }

        /// The pixel at column `x` and row `y`, where row 0 is the top row of the image.
        func pixel(x: Int, y: Int) -> Pixel {
            precondition((0 ..< width).contains(x) && (0 ..< height).contains(y), "Pixel (\(x), \(y)) is out of bounds")
            let offset = (y * width + x) * 4
            return Pixel(red: bytes[offset], green: bytes[offset + 1], blue: bytes[offset + 2], alpha: bytes[offset + 3])
        }
    }
#endif
