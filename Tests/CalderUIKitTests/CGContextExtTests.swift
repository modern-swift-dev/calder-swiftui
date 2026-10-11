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

            @Test func `draw text paints the receiving context inside the rect`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(10.0, 10.0, 80.0, 30.0)

                bitmap.context.drawText(
                    text: "Hello",
                    rect: rect,
                    font: NSUIFont.systemFont(ofSize: 20),
                    color: NSUIColor.black
                )

                let total = bitmap.paintedPixelCount(inContextRect: CGRect(0, 0, 100, 100))
                #expect(bitmap.paintedPixelCount(inContextRect: rect) > 20)
                #expect(bitmap.paintedPixelCount(inContextRect: rect) == total)
            }

            @Test(arguments: [false, true])
            func `draw text is upright in unflipped and flipped contexts`(flipped: Bool) throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                if flipped {
                    bitmap.context.translateBy(x: 0, y: 100)
                    bitmap.context.scaleBy(x: 1, y: -1)
                }

                bitmap.context.drawText(
                    text: "T",
                    rect: CGRect(0.0, 0.0, 100.0, 100.0),
                    font: NSUIFont.systemFont(ofSize: 60),
                    color: NSUIColor.black
                )

                // Rows count from the top of the image. An upright "T" has its wide bar above its narrow stem.
                let inkPerRow = (0 ..< bitmap.height).map { y in
                    (0 ..< bitmap.width).count { bitmap.pixel(x: $0, y: y).alpha > 0 }
                }
                let inkedRows = inkPerRow.indices.filter { inkPerRow[$0] > 0 }
                let top = try #require(inkedRows.first)
                let bottom = try #require(inkedRows.last)
                #expect(inkPerRow[top + 2] > 3 * inkPerRow[bottom - 2], "rows: \(inkPerRow[top + 2]) vs \(inkPerRow[bottom - 2])")
            }

            @Test func `draw text empty string paints nothing`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))

                bitmap.context.drawText(
                    text: "",
                    rect: CGRect(0.0, 0.0, 100.0, 100.0),
                    font: NSUIFont.systemFont(ofSize: 12),
                    color: NSUIColor.gray
                )

                #expect(bitmap.paintedPixelCount(inContextRect: CGRect(0, 0, 100, 100)) == 0)
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
