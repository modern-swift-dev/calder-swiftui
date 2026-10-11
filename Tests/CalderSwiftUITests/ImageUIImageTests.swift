#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit)
        @testable import CalderSwiftUI
        import Foundation
        import SwiftUI
        import Testing
        import UIKit

        @MainActor struct ImageUIImageTests {

            // MARK: - UIImage asSwiftUIImage

            @Test func `colored UI image renders its pixels`() throws {
                let uiImage = try Self.filledImage(.red, size: CGSize(width: 10, height: 10))

                let bitmap = try #require(RenderedBitmap(rendering: uiImage.asSwiftUIImage))

                #expect(bitmap.width == 10)
                #expect(bitmap.height == 10)
                #expect(bitmap.pixel(x: 5, y: 5).isClose(to: RenderedBitmap.Pixel(red: 255, green: 0, blue: 0, alpha: 255)))
            }

            @Test func `blank UI image renders transparent`() throws {
                let uiImage = try Self.filledImage(.clear, size: CGSize(width: 1, height: 1))

                let bitmap = try #require(RenderedBitmap(rendering: uiImage.asSwiftUIImage))

                #expect(bitmap.width == 1)
                #expect(bitmap.pixel(x: 0, y: 0) == .clear)
            }

            @Test(arguments: ["star", "star.fill", "heart", "person", "gear", "bell"])
            func `system image renders at its point size`(name: String) throws {
                let uiImage = try #require(UIImage(systemName: name))

                let bitmap = try #require(RenderedBitmap(rendering: uiImage.asSwiftUIImage))

                #expect(bitmap.width == Int(uiImage.size.width.rounded(.up)))
                #expect(bitmap.height == Int(uiImage.size.height.rounded(.up)))
            }

            @Test func `symbol configuration sizes the rendered image`() throws {
                let small = try #require(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12)))
                let large = try #require(UIImage(systemName: "heart", withConfiguration: UIImage.SymbolConfiguration(pointSize: 48)))

                let smallBitmap = try #require(RenderedBitmap(rendering: small.asSwiftUIImage))
                let largeBitmap = try #require(RenderedBitmap(rendering: large.asSwiftUIImage))

                #expect(largeBitmap.width > smallBitmap.width * 3)
            }

            // MARK: - Helpers

            /// Draws a 1x-scale image filled with `color`. `UIGraphicsImageRenderer` is unavailable on watchOS.
            private static func filledImage(_ color: UIColor, size: CGSize) throws -> UIImage {
                UIGraphicsBeginImageContextWithOptions(size, false, 1)
                defer { UIGraphicsEndImageContext() }
                color.setFill()
                UIRectFill(CGRect(origin: .zero, size: size))
                return try #require(UIGraphicsGetImageFromCurrentImageContext())
            }
        }
    #endif

#endif
