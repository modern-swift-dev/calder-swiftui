#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && !os(watchOS)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIImageTintTests {

    /// Helper to create a simple test image
    private func createTestImage(size: CGSize = CGSize(width: 100, height: 100), color: UIColor = .white) -> UIImage {
        color.asImage(size)
    }

    // MARK: - tint Tests

    @Test func `tint with red color`() {
        let image = createTestImage()
        let tintedImage = image.tint(.red)
        #expect(tintedImage != nil)
        if let tinted = tintedImage {
            #expect(tinted.size.width == 100)
            #expect(tinted.size.height == 100)
        }
    }

    @Test func `tint with blue color`() {
        let image = createTestImage()
        let tintedImage = image.tint(.blue)
        #expect(tintedImage != nil)
    }

    @Test func `tint with transparent color`() {
        let image = createTestImage()
        let tintedImage = image.tint(.clear)
        #expect(tintedImage != nil)
    }

    @Test func `tint small image`() {
        let image = createTestImage(size: CGSize(width: 10, height: 10))
        let tintedImage = image.tint(.green)
        #expect(tintedImage != nil)
        if let tinted = tintedImage {
            #expect(tinted.size.width == 10)
            #expect(tinted.size.height == 10)
        }
    }

    // MARK: - tintGradient Tests

    @Test func `tint gradient vertical`() {
        let image = createTestImage()
        let gradientImage = image.tintGradient(colors: [.red, .blue], vertical: true)
        #expect(gradientImage.size.width == 100)
        #expect(gradientImage.size.height == 100)
    }

    @Test func `tint gradient horizontal`() {
        let image = createTestImage()
        let gradientImage = image.tintGradient(colors: [.green, .yellow], vertical: false)
        #expect(gradientImage.size.width == 100)
        #expect(gradientImage.size.height == 100)
    }

    @Test func `tint gradient three colors`() {
        let image = createTestImage()
        let gradientImage = image.tintGradient(colors: [.red, .green, .blue])
        #expect(gradientImage.size.width == 100)
    }

    @Test func `tint gradient small image`() {
        let image = createTestImage(size: CGSize(width: 20, height: 20))
        let gradientImage = image.tintGradient(colors: [.purple, .orange])
        #expect(gradientImage.size.width == 20)
        #expect(gradientImage.size.height == 20)
    }

    @Test func `tint gradient default vertical`() {
        let image = createTestImage()
        let gradientImage = image.tintGradient(colors: [.cyan, .magenta])
        #expect(gradientImage.size.width == 100)
    }
}
#endif

#endif
