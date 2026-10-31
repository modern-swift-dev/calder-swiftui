#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit)
        import CalderUIKit
        import CoreGraphics
        import Foundation
        import Testing
        import UIKit

        @MainActor struct UIColorExtTests {

            // MARK: - alphaComponent Tests

            @Test func `alpha component fully opaque`() {
                let color = UIColor.red
                let alpha = color.alphaComponent()
                #expect(alpha == 1.0)
            }

            @Test func `alpha component semi transparent`() {
                let color = UIColor.blue.withAlphaComponent(0.5)
                let alpha = color.alphaComponent()
                #expect(abs(alpha - 0.5) < 0.01)
            }

            @Test func `alpha component fully transparent`() {
                let color = UIColor.green.withAlphaComponent(0.0)
                let alpha = color.alphaComponent()
                #expect(alpha == 0.0)
            }

            @Test func `alpha component custom alpha`() {
                let color = UIColor.black.withAlphaComponent(0.75)
                let alpha = color.alphaComponent()
                #expect(abs(alpha - 0.75) < 0.01)
            }

            // MARK: - asImage Tests

            @Test func `as image default size`() {
                let color = UIColor.red
                let image = color.asImage()
                #expect(image.size.width == 1)
                #expect(image.size.height == 1)
            }

            @Test func `as image custom size`() {
                let color = UIColor.blue
                let size = CGSize(width: 100, height: 50)
                let image = color.asImage(size)
                #expect(image.size.width == 100)
                #expect(image.size.height == 50)
            }

            @Test func `as image square size`() {
                let color = UIColor.green
                let size = CGSize(width: 64, height: 64)
                let image = color.asImage(size)
                #expect(image.size.width == 64)
                #expect(image.size.height == 64)
            }

            // MARK: - asSquare Tests

            @Test func `as square returns square image`() {
                let color = UIColor.yellow
                let image = color.asSquare(50)
                #expect(image.size.width == 50)
                #expect(image.size.height == 50)
            }

            @Test func `as square small size`() {
                let color = UIColor.purple
                let image = color.asSquare(1)
                #expect(image.size.width == 1)
                #expect(image.size.height == 1)
            }

            @Test func `as square large size`() {
                let color = UIColor.orange
                let image = color.asSquare(200)
                #expect(image.size.width == 200)
                #expect(image.size.height == 200)
            }

            // MARK: - asCircle Tests

            @Test func `as circle returns square image`() {
                let color = UIColor.cyan
                let image = color.asCircle(50)
                #expect(image.size.width == 50)
                #expect(image.size.height == 50)
            }

            @Test func `as circle small size`() {
                let color = UIColor.magenta
                let image = color.asCircle(10)
                #expect(image.size.width == 10)
                #expect(image.size.height == 10)
            }

            @Test func `as circle large size`() {
                let color = UIColor.brown
                let image = color.asCircle(150)
                #expect(image.size.width == 150)
                #expect(image.size.height == 150)
            }

            // MARK: - asOval Tests

            @Test func `as oval default`() {
                let color = UIColor.red
                let size = CGSize(width: 100, height: 50)
                let image = color.asOval(size)
                #expect(image.size.width == 100)
                #expect(image.size.height == 50)
            }

            @Test func `as oval draws the whole shape`() throws {
                let image = UIColor.red.asOval(CGSize(width: 40, height: 20))
                let bitmap = try #require(image.cgImage.flatMap { RGBABitmap(image: $0) })
                let scale = Int(image.scale)

                // The centre of every quadrant of the oval is painted, the corners are not.
                for (x, y) in [(10, 5), (30, 5), (10, 15), (30, 15), (20, 10)] {
                    #expect(bitmap.pixel(x: x * scale, y: y * scale) == .red)
                }
                #expect(bitmap.pixel(x: 0, y: 0) == .clear)
                #expect(bitmap.pixel(x: bitmap.width - 1, y: bitmap.height - 1) == .clear)
            }

            @Test func `as circle draws the whole shape`() throws {
                let image = UIColor.red.asCircle(20)
                let bitmap = try #require(image.cgImage.flatMap { RGBABitmap(image: $0) })
                let scale = Int(image.scale)

                for (x, y) in [(5, 5), (15, 5), (5, 15), (15, 15)] {
                    #expect(bitmap.pixel(x: x * scale, y: y * scale) == .red)
                }
                #expect(bitmap.pixel(x: 0, y: 0) == .clear)
            }

            #if !os(watchOS)
                @Test func `shape images render at the renderer format scale`() {
                    let scale = UIGraphicsImageRendererFormat().scale
                    #expect(UIColor.red.asImage(CGSize(width: 4, height: 4)).scale == scale)
                    #expect(UIColor.red.asSquare(4).scale == scale)
                    #expect(UIColor.red.asCircle(4).scale == scale)
                    #expect(UIColor.red.asOval(CGSize(width: 4, height: 2)).scale == scale)
                }
            #endif

            @Test func `shape images with zero size are empty`() {
                #expect(UIColor.red.asImage(.zero).size == .zero)
                #expect(UIColor.red.asSquare(0).size == .zero)
                #expect(UIColor.red.asCircle(0).size == .zero)
                #expect(UIColor.red.asOval(.zero).size == .zero)
                #expect(UIColor.red.asImage(CGSize(width: 10, height: 0)).size == .zero)
            }

            @Test func `as oval square size`() {
                let color = UIColor.yellow
                let size = CGSize(width: 100, height: 100)
                let image = color.asOval(size)
                #expect(image.size.width == 100)
                #expect(image.size.height == 100)
            }
        }
    #endif

#endif
