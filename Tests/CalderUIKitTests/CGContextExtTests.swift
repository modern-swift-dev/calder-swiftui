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

        struct CGContextExtTests {

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
                    strokeColor: CalderPlatformColor.red,
                    fillColor: CalderPlatformColor.blue
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
                    strokeColor: CalderPlatformColor.black,
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
                    strokeColor: CalderPlatformColor.gray,
                    fillColor: CalderPlatformColor.white
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
                    color: CalderPlatformColor.green
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
                    color: CalderPlatformColor.orange
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
                    color: CalderPlatformColor.purple
                )

                #expect(context.width == 100)
            }

            // MARK: - drawSquare Tests

            @Test func `draw square strokes over the fill`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))

                bitmap.context.drawSquare(
                    frame: CGRect(20.0, 20.0, 60.0, 60.0),
                    fillColor: CalderPlatformColor.yellow,
                    strokeWidth: 10.0,
                    strokeColor: CalderPlatformColor.black
                )

                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 16.5, y: 50.5)) == .black)
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 22.5, y: 50.5)) == .black)
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 50.5, y: 77.5)) == .black)
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 50.5, y: 50.5)) == .yellow)
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 5.5, y: 5.5)) == .clear)
            }

            @Test func `draw square without fill color only strokes`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))

                bitmap.context.drawSquare(
                    frame: CGRect(10.0, 10.0, 80.0, 80.0),
                    fillColor: nil,
                    strokeWidth: 4.0,
                    strokeColor: CalderPlatformColor.blue
                )

                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 10.5, y: 50.5)) == .blue)
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 50.5, y: 50.5)) == .clear)
            }

            // MARK: - drawText Tests

            @Test func `draw text paints the receiving context inside the rect`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(10.0, 10.0, 80.0, 30.0)

                bitmap.context.drawText(
                    text: "Hello",
                    rect: rect,
                    font: CalderPlatformFont.systemFont(ofSize: 20),
                    color: CalderPlatformColor.black
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
                    font: CalderPlatformFont.systemFont(ofSize: 60),
                    color: CalderPlatformColor.black
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
                    font: CalderPlatformFont.systemFont(ofSize: 12),
                    color: CalderPlatformColor.gray
                )

                #expect(bitmap.paintedPixelCount(inContextRect: CGRect(0, 0, 100, 100)) == 0)
            }

            // MARK: - drawStar Tests

            /// A point at `fraction` of the outer radius, `angle` radians clockwise from the tip pointing toward `minY`.
            private func starPoint(in rect: CGRect, angle: Double, fraction: Double) -> CGPoint {
                let radius = min(rect.width, rect.height) / 2.0 * fraction
                return CGPoint(x: rect.midX + radius * sin(angle), y: rect.midY - radius * cos(angle))
            }

            @Test(arguments: [3, 5, 6, 8])
            func `draw star is centred in the rect with one tip per point`(points: Int) throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(10.0, 10.0, 80.0, 80.0)

                bitmap.context.drawStar(rect: rect, color: CalderPlatformColor.red, nbPoint: UInt(points))

                #expect(bitmap.pixel(atContextPoint: CGPoint(x: rect.midX, y: rect.midY)) == .red)
                for index in 0 ..< points {
                    let tipAngle = 2.0 * Double.pi * Double(index) / Double(points)
                    let gapAngle = tipAngle + Double.pi / Double(points)
                    let tip = starPoint(in: rect, angle: tipAngle, fraction: 0.7)
                    let gap = starPoint(in: rect, angle: gapAngle, fraction: 0.7)
                    #expect(bitmap.pixel(atContextPoint: tip) == .red, "tip \(index) at \(tip)")
                    #expect(bitmap.pixel(atContextPoint: gap) == .clear, "gap \(index) at \(gap)")
                }
            }

            @Test func `draw star default has five points`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(20.0, 20.0, 60.0, 60.0)

                bitmap.context.drawStar(rect: rect, color: CalderPlatformColor.red)

                for index in 0 ..< 5 {
                    let tip = starPoint(in: rect, angle: 2.0 * Double.pi * Double(index) / 5.0, fraction: 0.7)
                    #expect(bitmap.pixel(atContextPoint: tip) == .red, "tip \(index) at \(tip)")
                }
                #expect(bitmap.pixel(atContextPoint: CGPoint(x: 22.5, y: 22.5)) == .clear)
            }

            @Test func `draw star stays within a non-square rect`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(10.0, 30.0, 80.0, 40.0)

                bitmap.context.drawStar(rect: rect, color: CalderPlatformColor.red, nbPoint: 5)

                let total = bitmap.paintedPixelCount(inContextRect: CGRect(0, 0, 100, 100))
                #expect(total > 0)
                #expect(bitmap.paintedPixelCount(inContextRect: rect) == total)
            }

            // MARK: - Deprecated names

            @available(*, deprecated)
            @Test func `deprecated NSUIColor and NSUIFont still draw`() throws {
                let bitmap = try #require(RGBABitmap(width: 100, height: 100))
                let rect = CGRect(20.0, 20.0, 60.0, 60.0)
                let font: NSUIFont = .systemFont(ofSize: 12)

                bitmap.context.drawStar(rect: rect, color: NSUIColor.red)

                let tip = starPoint(in: rect, angle: 0, fraction: 0.7)
                #expect(bitmap.pixel(atContextPoint: tip) == .red)
                #expect(font.pointSize == 12)
            }
        }
    #endif

#endif
