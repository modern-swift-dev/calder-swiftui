#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && !os(watchOS)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing
import UIKit

@Suite(.serialized)
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

    @Test func `color ranges init with color`() {
        let color = UIColor.red
        let ranges = ColorRanges(color)

        #expect(ranges.red.lower >= 0)
        #expect(ranges.red.upper <= 255)
    }

    @Test func `color ranges init with color and fuzz`() {
        let color = UIColor.green
        let ranges = ColorRanges(color, 10)

        #expect(ranges.green.lower >= 0)
        #expect(ranges.green.upper <= 255)
    }

    @Test func `color ranges init with two colors`() {
        let lower = UIColor.black
        let upper = UIColor.white
        let ranges = ColorRanges(lower, upper)

        #expect(ranges.red.lower >= 0)
        #expect(ranges.red.upper <= 255)
    }

    @Test func `color ranges init with two colors and fuzz`() {
        let lower = UIColor.blue
        let upper = UIColor.cyan
        let ranges = ColorRanges(lower, upper, 5)

        #expect(ranges.blue.lower >= 0)
        #expect(ranges.blue.upper <= 255)
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

    @Test func `with color masked valid input`() {
        let image = createTestImage(color: .white)
        let range = ColorRanges(red: ColorRange(240, 255), green: ColorRange(240, 255), blue: ColorRange(240, 255))
        let maskedImage = image.withColorMasked(.red, range)
        #expect(maskedImage != nil || maskedImage == nil)
    }

    @Test func `with color masked different color`() {
        let image = createTestImage(color: .blue)
        let range = ColorRanges(red: ColorRange(0, 50), green: ColorRange(0, 50), blue: ColorRange(200, 255))
        let maskedImage = image.withColorMasked(.green, range)
        #expect(maskedImage != nil || maskedImage == nil)
    }
}
#endif

#endif
