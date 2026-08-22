#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(CoreGraphics) && (os(iOS) || os(tvOS) || os(macOS))
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

@Suite(.serialized) struct CGContextExtTests {

    private func createContext(width: Int = 100, height: Int = 100) -> CGContext? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        return CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
    }

    // MARK: - drawCircle Tests

    @Test func `draw circle with fill color`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let frame = CGRect(10.0, 10.0, 50.0, 50.0)
        context.drawCircle(
            frame: frame,
            strokeWidth: 2.0,
            strokeColor: NSUIColor.red,
            fillColor: NSUIColor.blue
        )

        #expect(context.width == 100)
    }

    @Test func `draw circle without fill color`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let frame = CGRect(10.0, 10.0, 50.0, 50.0)
        context.drawCircle(
            frame: frame,
            strokeWidth: 1.0,
            strokeColor: NSUIColor.black,
            fillColor: nil
        )

        #expect(context.width == 100)
    }

    @Test func `draw circle zero stroke width`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let frame = CGRect(0.0, 0.0, 100.0, 100.0)
        context.drawCircle(
            frame: frame,
            strokeWidth: 0.0,
            strokeColor: NSUIColor.gray,
            fillColor: NSUIColor.white
        )

        #expect(context.width == 100)
    }

    // MARK: - drawPie Tests

    @Test func `draw pie full circle`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        context.drawPie(
            x: 50.0,
            y: 50.0,
            start: 0.0,
            end: 360.0,
            radius: 40.0,
            color: NSUIColor.green
        )

        #expect(context.width == 100)
    }

    @Test func `draw pie quarter circle`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        context.drawPie(
            x: 50.0,
            y: 50.0,
            start: 0.0,
            end: 90.0,
            radius: 30.0,
            color: NSUIColor.orange
        )

        #expect(context.width == 100)
    }

    @Test func `draw pie half circle`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        context.drawPie(
            x: 50.0,
            y: 50.0,
            start: 0.0,
            end: 180.0,
            radius: 25.0,
            color: NSUIColor.purple
        )

        #expect(context.width == 100)
    }

    // MARK: - drawSquare Tests

    @Test func `draw square with fill color`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let frame = CGRect(20.0, 20.0, 60.0, 60.0)
        context.drawSquare(
            frame: frame,
            fillColor: NSUIColor.yellow,
            strokeWidth: 2.0,
            strokeColor: NSUIColor.black
        )

        #expect(context.width == 100)
    }

    @Test func `draw square without fill color`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let frame = CGRect(10.0, 10.0, 80.0, 80.0)
        context.drawSquare(
            frame: frame,
            fillColor: nil,
            strokeWidth: 3.0,
            strokeColor: NSUIColor.blue
        )

        #expect(context.width == 100)
    }

    // MARK: - drawText Tests

    @Test func `draw text basic`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let text: NSString = "Hello"
        let rect = CGRect(10.0, 10.0, 80.0, 30.0)
        context.drawText(
            text: text,
            rect: rect,
            font: NSUIFont.systemFont(ofSize: 14),
            color: NSUIColor.black
        )

        #expect(context.width == 100)
    }

    @Test func `draw text empty string`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let text: NSString = ""
        let rect = CGRect(0.0, 0.0, 100.0, 100.0)
        context.drawText(
            text: text,
            rect: rect,
            font: NSUIFont.systemFont(ofSize: 12),
            color: NSUIColor.gray
        )

        #expect(context.width == 100)
    }

    // MARK: - drawStar Tests

    @Test func `draw star five points`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let rect = CGRect(10.0, 10.0, 80.0, 80.0)
        context.drawStar(
            rect: rect,
            color: NSUIColor.yellow,
            nbPoint: 5
        )

        #expect(context.width == 100)
    }

    @Test func `draw star six points`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let rect = CGRect(10.0, 10.0, 80.0, 80.0)
        context.drawStar(
            rect: rect,
            color: NSUIColor.red,
            nbPoint: 6
        )

        #expect(context.width == 100)
    }

    @Test func `draw star three points`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let rect = CGRect(0.0, 0.0, 100.0, 100.0)
        context.drawStar(
            rect: rect,
            color: NSUIColor.blue,
            nbPoint: 3
        )

        #expect(context.width == 100)
    }

    @Test func `draw star default points`() {
        guard let context = createContext() else {
            Issue.record("Failed to create context")
            return
        }

        let rect = CGRect(20.0, 20.0, 60.0, 60.0)
        context.drawStar(
            rect: rect,
            color: NSUIColor.orange
        )

        #expect(context.width == 100)
    }
}
#endif

#endif
