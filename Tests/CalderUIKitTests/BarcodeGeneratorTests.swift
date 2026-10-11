#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && canImport(CoreImage)
        import CalderUIKit
        import CoreImage
        import SwiftUI
        import Testing

        struct BarcodeGeneratorTests {

            // MARK: - createUIImage Tests

            @Test func `qr code create UI image`() {
                let image = BarcodeGenerator.qr.createUIImage(barcode: "hello world!")
                #expect(image != nil)
            }

            @Test func `code 128 create UI image`() {
                let image = BarcodeGenerator.code128.createUIImage(barcode: "hello world!")
                #expect(image != nil)
            }

            @Test func `pdf 417 create UI image`() {
                let image = BarcodeGenerator.pdf417.createUIImage(barcode: "pdf417")
                #expect(image != nil)
            }

            // MARK: - createCIImage Tests

            @Test func `qr code create CI image`() {
                let ciImage = BarcodeGenerator.qr.createCIImage("test data")
                #expect(ciImage != nil)
            }

            @Test func `code 128 create CI image`() {
                let ciImage = BarcodeGenerator.code128.createCIImage("ABC123")
                #expect(ciImage != nil)
            }

            @Test func `pdf 417 create CI image`() {
                let ciImage = BarcodeGenerator.pdf417.createCIImage("pdf417 data")
                #expect(ciImage != nil)
            }

            @Test func `create CI image with quiet space`() throws {
                let padded = try #require(BarcodeGenerator.code128.createCIImage("test"))
                let unpadded = try #require(BarcodeGenerator.code128.createCIImage("test", quietSpace: 0))
                #expect(unpadded.extent.width < padded.extent.width)
                #expect(unpadded.extent.height < padded.extent.height)
            }

            @Test func `create CI image empty string`() {
                // Code 128 needs at least one character.
                #expect(BarcodeGenerator.code128.createCIImage("") == nil)
            }

            // MARK: - createImage Tests (SwiftUI Image)

            @Test func `qr code create image`() {
                let image = BarcodeGenerator.qr.createImage(barcode: "SwiftUI test")
                #expect(image != nil)
            }

            @Test func `code 128 create image`() {
                let image = BarcodeGenerator.code128.createImage(barcode: "CODE128")
                #expect(image != nil)
            }

            @Test func `pdf 417 create image`() {
                let image = BarcodeGenerator.pdf417.createImage(barcode: "PDF417 test")
                #expect(image != nil)
            }

            @Test func `create image with quiet space`() {
                let image = BarcodeGenerator.qr.createImage(barcode: "quiet space test", quietSpace: 10.0)
                #expect(image != nil)
            }

            // MARK: - createUIImage with quietSpace Tests

            @Test func `qr code create UI image with quiet space`() {
                let image = BarcodeGenerator.qr.createUIImage(barcode: "test", quietSpace: 2.0)
                #expect(image != nil)
            }

            @Test func `code 128 create UI image with quiet space`() {
                let image = BarcodeGenerator.code128.createUIImage(barcode: "TEST123", quietSpace: 3.0)
                #expect(image != nil)
            }

            @Test func `pdf 417 create UI image with quiet space`() {
                let image = BarcodeGenerator.pdf417.createUIImage(barcode: "PDF", quietSpace: 1.0)
                #expect(image != nil)
            }

            // MARK: - Image Size Tests

            @Test func `qr code image has size`() {
                let image = BarcodeGenerator.qr.createUIImage(barcode: "size test")
                #expect(image != nil)
                #expect((image?.size.width ?? 0) > 0)
                #expect((image?.size.height ?? 0) > 0)
            }

            @Test func `code 128 image has size`() {
                let image = BarcodeGenerator.code128.createUIImage(barcode: "SIZE")
                #expect(image != nil)
                #expect((image?.size.width ?? 0) > 0)
                #expect((image?.size.height ?? 0) > 0)
            }

            @Test func `pdf 417 image has size`() {
                let image = BarcodeGenerator.pdf417.createUIImage(barcode: "SIZE TEST")
                #expect(image != nil)
                #expect((image?.size.width ?? 0) > 0)
                #expect((image?.size.height ?? 0) > 0)
            }

            // MARK: - Edge Cases

            @Test func `qr code long string`() {
                let longString = String(repeating: "A", count: 100)
                let image = BarcodeGenerator.qr.createUIImage(barcode: longString)
                #expect(image != nil)
            }

            @Test func `qr code special characters`() {
                let image = BarcodeGenerator.qr.createUIImage(barcode: "!@#$%^&*()")
                #expect(image != nil)
            }

            @Test func `qr code numeric only`() {
                let image = BarcodeGenerator.qr.createUIImage(barcode: "1234567890")
                #expect(image != nil)
            }

            @Test func `code 128 numeric only`() {
                let image = BarcodeGenerator.code128.createUIImage(barcode: "0123456789")
                #expect(image != nil)
            }

            // MARK: - Payload Encoding Tests

            @Test func `qr code encodes non-ASCII payload as UTF-8`() throws {
                let payload = "Café https://exämple.com/ü"
                let ciImage = try #require(BarcodeGenerator.qr.createCIImage(payload))
                let detector = try #require(CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: nil))

                let decoded = detector.features(in: ciImage).compactMap { ($0 as? CIQRCodeFeature)?.messageString }

                #expect(decoded == [payload])
            }

            @Test func `code 128 rejects non-ASCII payload`() {
                #expect(BarcodeGenerator.code128.createCIImage("Café") == nil)
                #expect(BarcodeGenerator.code128.createImage(barcode: "Café") == nil)
            }

            @Test func `pdf 417 rejects non-ASCII payload`() {
                #expect(BarcodeGenerator.pdf417.createCIImage("Café") == nil)
                #expect(BarcodeGenerator.pdf417.createImage(barcode: "Café") == nil)
            }

            // MARK: - Sharpness Tests

            @Test(arguments: [BarcodeGenerator.qr, .code128, .pdf417])
            func `barcode CI image has only black and white pixels`(generator: BarcodeGenerator) throws {
                let ciImage = try #require(generator.createCIImage("SHARP-123"))
                let cgImage = try #require(CIContext().createCGImage(ciImage, from: ciImage.extent))

                #expect(try blurredPixelCount(in: cgImage) == 0)
            }

            @Test func `code 128 bars use a whole number of pixels per module`() throws {
                let ciImage = try #require(BarcodeGenerator.code128.createCIImage("SHARP-123"))
                let cgImage = try #require(CIContext().createCGImage(ciImage, from: ciImage.extent))
                let pixels = try rgbaPixels(of: cgImage)
                let row = (cgImage.height / 2) * cgImage.width * 4
                let isDark = (0 ..< cgImage.width).map { pixels[row + $0 * 4] < 128 }

                var widths: [Int] = []
                var start = 0
                for x in 1 ... isDark.count where x == isDark.count || isDark[x] != isDark[start] {
                    widths.append(x - start)
                    start = x
                }
                // Code 128 bars and spaces span one to four modules; the outer runs are quiet zones.
                let elements = widths.dropFirst().dropLast()
                let module = try #require(elements.min())

                #expect(elements.allSatisfy { $0 % module == 0 && $0 / module <= 4 })
            }

            @Test(arguments: [BarcodeGenerator.qr, .code128, .pdf417])
            @MainActor func `displayed barcode is crisp at 2x and 3x`(generator: BarcodeGenerator) throws {
                let image = try #require(generator.createImage(barcode: "SHARP-123"))
                for scale in [2.0, 3.0] {
                    let renderer = ImageRenderer(content: image)
                    renderer.scale = scale
                    let cgImage = try #require(renderer.cgImage)

                    #expect(try blurredPixelCount(in: cgImage) == 0, "scale \(scale)")
                }
            }

            /// Counts pixels whose channels are neither near 0 nor near 255, which only appear when bars are smoothed.
            private func blurredPixelCount(in image: CGImage) throws -> Int {
                let pixels = try rgbaPixels(of: image)
                return stride(from: 0, to: pixels.count, by: 4).count { offset in
                    pixels[offset ..< offset + 4].contains { $0 > 15 && $0 < 240 }
                }
            }

            private func rgbaPixels(of image: CGImage) throws -> [UInt8] {
                let colorSpace = try #require(CGColorSpace(name: CGColorSpace.sRGB))
                let bytesPerRow = image.width * 4
                var pixels = [UInt8](repeating: 0, count: bytesPerRow * image.height)
                try pixels.withUnsafeMutableBytes { buffer in
                    let context = try #require(CGContext(
                        data: buffer.baseAddress,
                        width: image.width,
                        height: image.height,
                        bitsPerComponent: 8,
                        bytesPerRow: bytesPerRow,
                        space: colorSpace,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                    ))
                    context.interpolationQuality = .none
                    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
                }
                return pixels
            }
        }
    #endif

#endif
