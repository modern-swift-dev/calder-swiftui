#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && !os(watchOS)
        import CalderUIKit
        import CoreGraphics
        import Foundation
        import Testing
        import UIKit

        @MainActor struct UIImageColorMaskTests {

            /// Helper to create a simple test image
            private func createTestImage(size: CGSize = CGSize(width: 100, height: 100), color: UIColor = .red) -> UIImage {
                color.asImage(size)
            }

            // MARK: - ColorRange Tests

            @Test func `color range valid range`() {
                let range = ColorRange(0, 255)
                #expect(range.lower == 0)
                #expect(range.upper == 255)
            }

            @Test func `color range clamped values`() {
                let range = ColorRange(50, 200)
                #expect(range.lower == 50)
                #expect(range.upper == 200)
            }

            @Test func `color range clamped to max`() {
                let range = ColorRange(0, 300)
                #expect(range.upper == 255)
            }

            @Test func `color range clamped to min`() {
                let range = ColorRange(-10, 100)
                #expect(range.lower == 0)
            }

            // MARK: - ColorRanges Tests

            @Test func `color ranges init with ranges`() {
                let red = ColorRange(0, 50)
                let green = ColorRange(100, 150)
                let blue = ColorRange(200, 255)
                let ranges = ColorRanges(red: red, green: green, blue: blue)

                #expect(ranges.red.lower == 0)
                #expect(ranges.red.upper == 50)
                #expect(ranges.green.lower == 100)
                #expect(ranges.green.upper == 150)
                #expect(ranges.blue.lower == 200)
                #expect(ranges.blue.upper == 255)
            }

            private func bounds(_ range: ColorRange) -> [CGFloat] {
                [range.lower, range.upper]
            }

            @Test func `color ranges init with color uses 0 to 255 components`() {
                let ranges = ColorRanges(UIColor.red)

                #expect(bounds(ranges.red) == [255, 255])
                #expect(bounds(ranges.green) == [0, 0])
                #expect(bounds(ranges.blue) == [0, 0])
            }

            @Test func `color ranges init with color and fuzz`() {
                let ranges = ColorRanges(UIColor.green, 10)

                #expect(bounds(ranges.red) == [0, 10])
                #expect(bounds(ranges.green) == [245, 255])
                #expect(bounds(ranges.blue) == [0, 10])
            }

            @Test func `color ranges init with two colors`() {
                let ranges = ColorRanges(UIColor.black, UIColor.white)

                #expect(bounds(ranges.red) == [0, 255])
                #expect(bounds(ranges.green) == [0, 255])
                #expect(bounds(ranges.blue) == [0, 255])
            }

            @Test func `color ranges init with two colors and fuzz`() {
                let ranges = ColorRanges(UIColor.blue, UIColor.cyan, 5)

                #expect(bounds(ranges.red) == [0, 5])
                #expect(bounds(ranges.green) == [0, 255])
                #expect(bounds(ranges.blue) == [250, 255])
            }

            @Test func `color ranges init with unordered colors is normalised`() {
                let ranges = ColorRanges(UIColor(red: 0.75, green: 0.25, blue: 1, alpha: 1), UIColor(red: 0.25, green: 0.75, blue: 0, alpha: 1))

                #expect(bounds(ranges.red) == [63.75, 191.25])
                #expect(bounds(ranges.green) == [63.75, 191.25])
                #expect(bounds(ranges.blue) == [0, 255])
            }

            // MARK: - UIGraphicsImageRendererFormat Tests

            @Test func `renderer format transparent`() {
                let format = UIGraphicsImageRendererFormat.transparent()
                #expect(format.opaque == false)
            }

            @Test func `renderer format opaque`() {
                let format = UIGraphicsImageRendererFormat.opaque()
                #expect(format.opaque == true)
            }

            // MARK: - UIImage withNoAlphaChannel Tests

            @Test func `with no alpha channel returns image`() {
                let image = createTestImage()
                let opaqueImage = image.withNoAlphaChannel()
                #expect(opaqueImage.size.width == 100)
                #expect(opaqueImage.size.height == 100)
            }

            // MARK: - UIImage withColorMasked Tests

            /// A 1x image whose left half is `left` and right half is `right`.
            private func createSplitImage(left: UIColor, right: UIColor, size: CGSize = CGSize(width: 20, height: 10)) -> UIImage {
                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                format.preferredRange = .standard
                return UIGraphicsImageRenderer(size: size, format: format).image { context in
                    left.setFill()
                    context.fill(CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
                    right.setFill()
                    context.fill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
                }
            }

            /// The pixels at the centre of the left and right halves of `image`.
            private func halfPixels(of image: UIImage) throws -> (left: RGBABitmap.Pixel, right: RGBABitmap.Pixel) {
                let bitmap = try #require(image.cgImage.flatMap { RGBABitmap(image: $0) })
                let y = bitmap.height / 2
                return (bitmap.pixel(x: bitmap.width / 4, y: y), bitmap.pixel(x: bitmap.width * 3 / 4, y: y))
            }

            @Test func `with color masked replaces pixels matching a colour`() throws {
                let image = createSplitImage(left: .white, right: .blue)

                let masked = try #require(image.withColorMasked(.red, ColorRanges(UIColor.white)))

                let pixels = try halfPixels(of: masked)
                #expect(pixels.left == .red)
                #expect(pixels.right == .blue)
            }

            @Test func `with color masked replaces pixels within explicit ranges`() throws {
                let image = createSplitImage(left: .white, right: .blue)
                let range = ColorRanges(red: ColorRange(0, 50), green: ColorRange(0, 50), blue: ColorRange(200, 255))

                let masked = try #require(image.withColorMasked(.green, range))

                let pixels = try halfPixels(of: masked)
                #expect(pixels.left == .white)
                #expect(pixels.right == .green)
            }

            @Test func `with color masked accepts unordered colour bounds`() throws {
                let image = createSplitImage(left: .white, right: .black)

                let masked = try #require(image.withColorMasked(.red, ColorRanges(UIColor.white, UIColor(white: 0.5, alpha: 1))))

                let pixels = try halfPixels(of: masked)
                #expect(pixels.left == .red)
                #expect(pixels.right == .black)
            }
        }
    #endif

#endif
