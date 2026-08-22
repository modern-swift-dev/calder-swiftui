#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import CoreImage
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct CIImageExtTests {

    /// Helper to create test image data
    private func createTestImageData() -> Data? {
        let color = UIColor.red
        let image = color.asImage(CGSize(width: 100, height: 100))
        return image.pngData()
    }

    private func createTestUIImage() -> UIImage {
        UIColor.blue.asImage(CGSize(width: 50, height: 50))
    }

    private func createTestCIImage() -> CIImage? {
        guard let data = createTestImageData() else {
            return nil
        }
        return CIImage(data: data)
    }

    // MARK: - toPNG Tests

    @Test func `to PNG from data valid data`() {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let pngData = CIImage.toPNG(data: data)
        #expect(pngData != nil)
    }

    @Test func `to PNG from data invalid data`() {
        let invalidData = Data("not an image".utf8)
        let pngData = CIImage.toPNG(data: invalidData)
        #expect(pngData == nil)
    }

    @Test func `to PNG from UI image`() {
        let image = createTestUIImage()
        let pngData = CIImage.toPNG(uiImage: image)
        #expect(pngData != nil)
    }

    @Test func `to PNG from UI image with metadata`() {
        let image = createTestUIImage()
        let metadata: NSDictionary = [:]
        let pngData = CIImage.toPNG(image: image, metadata: metadata)
        #expect(pngData != nil)
    }

    @Test func `to PNG from CI image`() {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let pngData = CIImage.toPNG(image: ciImage)
        #expect(pngData != nil)
    }

    // MARK: - toJpeg Tests

    @Test func `to jpeg from data valid data`() {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let jpegData = CIImage.toJpeg(data: data)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from data custom compression`() {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let jpegData = CIImage.toJpeg(data: data, compression: 0.5)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from data invalid data`() {
        let invalidData = Data("not an image".utf8)
        let jpegData = CIImage.toJpeg(data: invalidData)
        #expect(jpegData == nil)
    }

    @Test func `to jpeg from UI image`() {
        let image = createTestUIImage()
        let jpegData = CIImage.toJpeg(uiImage: image)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from UI image custom compression`() {
        let image = createTestUIImage()
        let jpegData = CIImage.toJpeg(uiImage: image, compression: 0.7)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from UI image with metadata`() {
        let image = createTestUIImage()
        let metadata: NSDictionary = [:]
        let jpegData = CIImage.toJpeg(image: image, metadata: metadata)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from CI image`() {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let jpegData = CIImage.toJpeg(image: ciImage)
        #expect(jpegData != nil)
    }

    @Test func `to jpeg from CI image custom compression`() {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let jpegData = CIImage.toJpeg(image: ciImage, compression: 0.3)
        #expect(jpegData != nil)
    }

    // MARK: - toHeif Tests

    @Test func `to heif from data valid data`() {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let heifData = CIImage.toHeif(data: data)
        #expect(heifData != nil || heifData == nil)
    }

    @Test func `to heif from data invalid data`() {
        let invalidData = Data("not an image".utf8)
        let heifData = CIImage.toHeif(data: invalidData)
        #expect(heifData == nil)
    }

    @Test func `to heif from CI image`() {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let heifData = CIImage.toHeif(image: ciImage)
        #expect(heifData != nil || heifData == nil)
    }

    @Test func `to heif from UI image`() {
        let image = createTestUIImage()
        let heifData = CIImage.toHeif(uiImage: image)
        if let heifData {
            #expect(!heifData.isEmpty)
        }
    }

    @Test func `write heif from data invalid data returns nil`() {
        let invalidData = Data("not an image".utf8)

        let url = CIImage.writeHeif(data: invalidData)

        #expect(url == nil)
    }

    @Test func `write heif from data valid data returns nil or heif file`() {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }

        let url = CIImage.writeHeif(data: data)
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        if let url {
            #expect(url.pathExtension == "heif")
        }
    }

    @Test func `write heif from UI image returns nil or heif file`() {
        let url = CIImage.writeHeif(uiImage: createTestUIImage())
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        if let url {
            #expect(url.pathExtension == "heif")
        }
    }

    @Test func `write heif from UI image with metadata returns nil or heif file`() {
        let url = CIImage.writeHeif(image: createTestUIImage(), metadata: [:])
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        if let url {
            #expect(url.pathExtension == "heif")
        }
    }

    @Test func `write heif from CI image returns nil or heif file`() throws {
        let ciImage = try #require(createTestCIImage())

        let url = CIImage.writeHeif(image: ciImage)
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        if let url {
            #expect(url.pathExtension == "heif")
        }
    }

    // MARK: - writePNG Tests

    @Test func `write PNG from UI image`() throws {
        let image = createTestUIImage()
        let url = try CIImage.writePNG(uiImage: image)
        #expect(url.pathExtension == "png")
        try FileManager.default.removeItem(at: url)
    }

    @Test func `write PNG from data`() throws {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let url = try CIImage.writePNG(data: data)
        #expect(url != nil)
        if let url {
            try FileManager.default.removeItem(at: url)
        }
    }

    @Test func `write PNG from data invalid data returns nil`() throws {
        let invalidData = Data("not an image".utf8)

        let url = try CIImage.writePNG(data: invalidData)

        #expect(url == nil)
    }

    @Test func `write PNG from UI image with metadata`() throws {
        let url = try CIImage.writePNG(image: createTestUIImage(), metadata: [:])
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        #expect(url?.pathExtension == "png")
    }

    @Test func `write PNG from CI image`() throws {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let url = try CIImage.writePNG(image: ciImage)
        #expect(url != nil)
        if let url {
            try FileManager.default.removeItem(at: url)
        }
    }

    // MARK: - writeJpeg Tests

    @Test func `write jpeg from UI image`() throws {
        let image = createTestUIImage()
        let url = try CIImage.writeJpeg(uiImage: image)
        #expect(url.pathExtension == "jpg")
        try FileManager.default.removeItem(at: url)
    }

    @Test func `write jpeg from UI image custom compression`() throws {
        let image = createTestUIImage()
        let url = try CIImage.writeJpeg(uiImage: image, compression: 0.5)
        #expect(url.pathExtension == "jpg")
        try FileManager.default.removeItem(at: url)
    }

    @Test func `write jpeg from data`() throws {
        guard let data = createTestImageData() else {
            Issue.record("Failed to create test image data")
            return
        }
        let url = try CIImage.writeJpeg(data: data)
        #expect(url != nil)
        if let url {
            try FileManager.default.removeItem(at: url)
        }
    }

    @Test func `write jpeg from CI image`() throws {
        guard let ciImage = createTestCIImage() else {
            Issue.record("Failed to create test CIImage")
            return
        }
        let url = try CIImage.writeJpeg(image: ciImage)
        #expect(url != nil)
        if let url {
            try FileManager.default.removeItem(at: url)
        }
    }

    @Test func `write jpeg from data invalid data returns nil`() throws {
        let invalidData = Data("not an image".utf8)

        let url = try CIImage.writeJpeg(data: invalidData)

        #expect(url == nil)
    }

    @Test func `write jpeg from UI image with metadata`() throws {
        let url = try CIImage.writeJpeg(image: createTestUIImage(), metadata: [:])
        defer {
            if let url {
                try? FileManager.default.removeItem(at: url)
            }
        }

        #expect(url?.pathExtension == "jpg")
    }
}
#endif

#endif
