#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && !os(watchOS)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIImageExtTests {

    /// Helper to create a simple test image
    private func createTestImage(size: CGSize = CGSize(width: 100, height: 100), color: UIColor = .red) -> UIImage {
        color.asImage(size)
    }

    // MARK: - base64 Tests

    @Test func `base 64 returns data`() {
        let image = createTestImage()
        let data = image.base64()
        #expect(data != nil)
    }

    @Test func `base 64 small image`() {
        let image = createTestImage(size: CGSize(width: 10, height: 10))
        let data = image.base64()
        #expect(data != nil)
        #expect((data?.count ?? 0) > 0)
    }

    // MARK: - base64String Tests

    @Test func `base 64 string returns string`() {
        let image = createTestImage()
        let string = image.base64String()
        #expect(string != nil)
        #expect(string?.isEmpty == false)
    }

    @Test func `base 64 string is valid base 64`() {
        let image = createTestImage(size: CGSize(width: 10, height: 10))
        let string = image.base64String()
        #expect(string != nil)
        if let string {
            let decoded = Data(base64Encoded: string, options: .ignoreUnknownCharacters)
            #expect(decoded != nil)
        }
    }

    // MARK: - base64URLPng Tests

    @Test func `base 64 URL png returns URL`() {
        let image = createTestImage()
        let url = image.base64URLPng()
        #expect(url != nil)
    }

    @Test func `base 64 URL png has data scheme`() {
        let image = createTestImage()
        let url = image.base64URLPng()
        #expect(url?.scheme == "data")
    }

    @Test func `base 64 URL png contains png mime type`() {
        let image = createTestImage()
        let url = image.base64URLPng()
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("image/png"))
    }

    // MARK: - base64URLJpg Tests

    @Test func `base 64 URL jpg returns URL`() {
        let image = createTestImage()
        let url = image.base64URLJpg()
        #expect(url != nil)
    }

    @Test func `base 64 URL jpg has data scheme`() {
        let image = createTestImage()
        let url = image.base64URLJpg()
        #expect(url?.scheme == "data")
    }

    @Test func `base 64 URL jpg contains jpeg mime type`() {
        let image = createTestImage()
        let url = image.base64URLJpg()
        let urlString = url?.absoluteString ?? ""
        #expect(urlString.contains("image/jpeg"))
    }

    #if !os(visionOS)
    // MARK: - resize Tests

    @Test func `resize with aspect ratio`() {
        let image = createTestImage(size: CGSize(width: 200, height: 100))
        let resized = image.resize(CGSize(width: 100, height: 50), true)
        #expect(resized.size.width == 100)
        #expect(resized.size.height == 50)
    }

    @Test func `resize without aspect ratio`() {
        let image = createTestImage(size: CGSize(width: 100, height: 100))
        let resized = image.resize(CGSize(width: 50, height: 50), false)
        #expect(resized.size.width == 50)
        #expect(resized.size.height == 50)
    }

    @Test func `resize to smaller size`() {
        let image = createTestImage(size: CGSize(width: 200, height: 200))
        let resized = image.resize(CGSize(width: 50, height: 50))
        #expect(resized.size.width == 50)
        #expect(resized.size.height == 50)
    }

    // MARK: - resizeToFit Tests

    @Test func `resize to fit square image`() {
        let image = createTestImage(size: CGSize(width: 200, height: 200))
        let resized = image.resizeToFit(100)
        #expect(resized.size.width <= 100)
        #expect(resized.size.height <= 100)
    }

    @Test func `resize to fit landscape image`() {
        let image = createTestImage(size: CGSize(width: 200, height: 100))
        let resized = image.resizeToFit(100)
        #expect(max(resized.size.width, resized.size.height) <= 100)
    }

    @Test func `resize to fit portrait image`() {
        let image = createTestImage(size: CGSize(width: 100, height: 200))
        let resized = image.resizeToFit(100)
        #expect(max(resized.size.width, resized.size.height) <= 100)
    }

    // MARK: - scaledCopy Tests

    @Test func `scaled copy returns image`() {
        let image = createTestImage()
        let scaled = image.scaledCopy(2.0)
        #expect(scaled != nil)
    }

    @Test func `scaled copy with orientation`() {
        let image = createTestImage()
        let scaled = image.scaledCopy(1.0, .right)
        #expect(scaled != nil)
        #expect(scaled?.imageOrientation == .right)
    }

    @Test func `scaled copy default orientation`() {
        let image = createTestImage()
        let scaled = image.scaledCopy(1.0)
        #expect(scaled != nil)
    }

    // MARK: - init from data Tests

    @Test func `init thumbnail size valid data`() throws {
        let originalImage = createTestImage(size: CGSize(width: 200, height: 200))
        guard let pngData = originalImage.pngData() else {
            Issue.record("Failed to create PNG data")
            return
        }

        let thumbnail = try #require(UIImage(data: pngData, thumbnailSize: CGSize(width: 50, height: 50)))
        #expect(thumbnail.size.width <= 50 || thumbnail.size.height <= 50)
    }

    @Test func `init thumbnail size invalid data`() {
        let invalidData = Data("not an image".utf8)
        let thumbnail = UIImage(data: invalidData, thumbnailSize: CGSize(width: 50, height: 50))
        #expect(thumbnail == nil)
    }
    #endif
}
#endif

#endif
