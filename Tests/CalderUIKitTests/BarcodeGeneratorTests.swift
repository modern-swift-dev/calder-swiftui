#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && canImport(CoreImage)
import CalderUIKit
import CoreImage
import SwiftUI
import Testing

@Suite(.serialized) struct BarcodeGeneratorTests {

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

    @Test func `create CI image with quiet space`() {
        let ciImage = BarcodeGenerator.qr.createCIImage("test", quietSpace: 5.0)
        #expect(ciImage != nil)
    }

    @Test func `create CI image empty string`() {
        _ = BarcodeGenerator.qr.createCIImage("")
        // Empty string might still produce an image depending on filter
        #expect(true) // Just verify it doesn't crash
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
}
#endif

#endif
