#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && !os(watchOS)
        import CalderUIKit
        import CoreGraphics
        import Foundation
        import Testing
        import UIKit

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

            // MARK: - Data URL payload Tests

            /// The decoded payload of a `data:<mimeType>;base64,` URL, decoded strictly so any line break fails.
            private func payload(of url: URL?, mimeType: String) throws -> Data {
                let string = try #require(url?.absoluteString)
                let prefix = "data:\(mimeType);base64,"
                #expect(string.hasPrefix(prefix))
                return try #require(Data(base64Encoded: String(string.dropFirst(prefix.count))))
            }

            @Test func `base 64 URL png encodes PNG bytes without line breaks`() throws {
                let url = createTestImage().base64URLPng()

                #expect(url?.absoluteString.contains(where: \.isNewline) == false)
                let data = try payload(of: url, mimeType: "image/png")
                #expect(Array(data.prefix(8)) == [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
            }

            @Test func `base 64 URL jpg encodes JPEG bytes without line breaks`() throws {
                let url = createTestImage().base64URLJpg()

                #expect(url?.absoluteString.contains(where: \.isNewline) == false)
                let data = try payload(of: url, mimeType: "image/jpeg")
                #expect(Array(data.prefix(3)) == [0xFF, 0xD8, 0xFF])
                #expect(UIImage(data: data) != nil)
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

                /// A 1x image whose left half is red and right half is blue.
                private func createSplitImage(size: CGSize) -> UIImage {
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = 1
                    format.preferredRange = .standard
                    return UIGraphicsImageRenderer(size: size, format: format).image { context in
                        UIColor.red.setFill()
                        context.fill(CGRect(x: 0, y: 0, width: size.width / 2, height: size.height))
                        UIColor.blue.setFill()
                        context.fill(CGRect(x: size.width / 2, y: 0, width: size.width / 2, height: size.height))
                    }
                }

                /// The pixel at a fraction of the image's pixel width and height, measured from the top-left corner.
                private func pixel(of image: UIImage, atX x: Double, y: Double) throws -> RGBABitmap.Pixel {
                    let bitmap = try #require(image.cgImage.flatMap { RGBABitmap(image: $0) })
                    return bitmap.pixel(x: Int(Double(bitmap.width) * x), y: Int(Double(bitmap.height) * y))
                }

                @Test func `resize without aspect ratio scales the whole image`() throws {
                    let image = createSplitImage(size: CGSize(width: 100, height: 50))

                    let resized = image.resize(CGSize(width: 40, height: 40), false)

                    #expect(resized.size == CGSize(width: 40, height: 40))
                    #expect(try pixel(of: resized, atX: 0.1, y: 0.9) == .red)
                    #expect(try pixel(of: resized, atX: 0.4, y: 0.5) == .red)
                    #expect(try pixel(of: resized, atX: 0.6, y: 0.5) == .blue)
                    #expect(try pixel(of: resized, atX: 0.9, y: 0.9) == .blue)
                }

                @Test func `resize with aspect ratio letterboxes the scaled image`() throws {
                    let image = createSplitImage(size: CGSize(width: 100, height: 50))

                    let resized = image.resize(CGSize(width: 40, height: 40), true)

                    #expect(resized.size == CGSize(width: 40, height: 40))
                    #expect(try pixel(of: resized, atX: 0.1, y: 0.5) == .red)
                    #expect(try pixel(of: resized, atX: 0.9, y: 0.5) == .blue)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.1) == .clear)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.9) == .clear)
                }

                @Test(arguments: [true, false])
                func `resize respects an orientation override`(keepAspectRatio: Bool) throws {
                    let image = createSplitImage(size: CGSize(width: 200, height: 100))

                    // `.right` rotates the image 90 degrees clockwise, moving its left (red) half to the top.
                    let resized = image.resize(CGSize(width: 50, height: 100), keepAspectRatio, .right)

                    #expect(resized.size == CGSize(width: 50, height: 100))
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.05) == .red)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.45) == .red)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.55) == .blue)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.95) == .blue)
                }

                // MARK: - resizeToFit Tests

                @Test func `resize to fit respects an orientation override`() throws {
                    let image = createSplitImage(size: CGSize(width: 200, height: 100))

                    let resized = image.resizeToFit(100, .right)

                    #expect(resized.size == CGSize(width: 50, height: 100))
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.05) == .red)
                    #expect(try pixel(of: resized, atX: 0.5, y: 0.95) == .blue)
                }

                @Test func `resize to fit scales the whole image`() throws {
                    let image = createSplitImage(size: CGSize(width: 200, height: 100))

                    let resized = image.resizeToFit(100)

                    #expect(resized.size == CGSize(width: 100, height: 50))
                    #expect(try pixel(of: resized, atX: 0.05, y: 0.5) == .red)
                    #expect(try pixel(of: resized, atX: 0.95, y: 0.5) == .blue)
                }

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
