#if canImport(CoreGraphics)
    import CoreGraphics

    /// A zero-filled 8-bit premultiplied RGBA sRGB bitmap used to inspect rendered pixels in tests.
    struct RGBABitmap {

        /// One premultiplied RGBA pixel.
        struct Pixel: Equatable, CustomStringConvertible {
            let red: UInt8
            let green: UInt8
            let blue: UInt8
            let alpha: UInt8

            static let clear = Pixel(red: 0, green: 0, blue: 0, alpha: 0)
            static let black = Pixel(red: 0, green: 0, blue: 0, alpha: 255)
            static let white = Pixel(red: 255, green: 255, blue: 255, alpha: 255)
            static let red = Pixel(red: 255, green: 0, blue: 0, alpha: 255)
            static let green = Pixel(red: 0, green: 255, blue: 0, alpha: 255)
            static let blue = Pixel(red: 0, green: 0, blue: 255, alpha: 255)
            static let yellow = Pixel(red: 255, green: 255, blue: 0, alpha: 255)

            var description: String {
                "RGBA(\(red), \(green), \(blue), \(alpha))"
            }
        }

        let width: Int
        let height: Int
        let context: CGContext

        /// Creates an empty bitmap. Its context uses Core Graphics coordinates, with the origin at the bottom-left.
        init?(width: Int, height: Int) {
            guard let space = CGColorSpace(name: CGColorSpace.sRGB),
                  let context = CGContext(
                      data: nil,
                      width: width,
                      height: height,
                      bitsPerComponent: 8,
                      bytesPerRow: width * 4,
                      space: space,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  ) else {
                return nil
            }
            self.width = width
            self.height = height
            self.context = context
        }

        /// Creates a bitmap containing `image` at its pixel size.
        init?(image: CGImage) {
            self.init(width: image.width, height: image.height)
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        }

        /// The pixel at column `x` and row `y`, where row 0 is the top row of the image.
        func pixel(x: Int, y: Int) -> Pixel {
            precondition((0 ..< width).contains(x) && (0 ..< height).contains(y), "Pixel (\(x), \(y)) is out of bounds")
            guard let data = context.data else {
                return .clear
            }
            let offset = y * context.bytesPerRow + x * 4
            let bytes = data.assumingMemoryBound(to: UInt8.self)
            return Pixel(red: bytes[offset], green: bytes[offset + 1], blue: bytes[offset + 2], alpha: bytes[offset + 3])
        }

        /// The pixel containing `point`, expressed in the unflipped user space of ``context``.
        func pixel(atContextPoint point: CGPoint) -> Pixel {
            pixel(x: Int(point.x.rounded(.down)), y: height - 1 - Int(point.y.rounded(.down)))
        }

        /// The number of non-transparent pixels whose context-space pixel square lies inside `rect`.
        func paintedPixelCount(inContextRect rect: CGRect) -> Int {
            var count = 0
            for y in 0 ..< height {
                for x in 0 ..< width {
                    let square = CGRect(x: x, y: height - 1 - y, width: 1, height: 1)
                    if rect.contains(square), pixel(x: x, y: y).alpha > 0 {
                        count += 1
                    }
                }
            }
            return count
        }
    }
#endif
