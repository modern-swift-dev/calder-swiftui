#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        import AppKit
        @testable import CalderSwiftUI
        import Foundation
        import SwiftUI
        import Testing

        @MainActor struct NSImageTests {

            @Test func `colored NS image renders its pixels`() throws {
                let nsImage = Self.filledImage(.red, size: NSSize(width: 10, height: 10))

                let bitmap = try #require(RenderedBitmap(rendering: nsImage.asSwiftUIImage))

                #expect(bitmap.width == 10)
                #expect(bitmap.height == 10)
                #expect(bitmap.pixel(x: 5, y: 5).isClose(to: RenderedBitmap.Pixel(red: 255, green: 0, blue: 0, alpha: 255)))
            }

            @Test func `blank NS image renders transparent`() throws {
                let nsImage = Self.filledImage(.clear, size: NSSize(width: 1, height: 1))

                let bitmap = try #require(RenderedBitmap(rendering: nsImage.asSwiftUIImage))

                #expect(bitmap.width == 1)
                #expect(bitmap.pixel(x: 0, y: 0) == .clear)
            }

            @Test(arguments: ["star", "star.fill", "heart", "person", "gear", "bell"])
            func `system image renders at its point size`(name: String) throws {
                let nsImage = try #require(NSImage(systemSymbolName: name, accessibilityDescription: nil))

                let bitmap = try #require(RenderedBitmap(rendering: nsImage.asSwiftUIImage))

                #expect(bitmap.width == Int(nsImage.size.width.rounded(.up)))
                #expect(bitmap.height == Int(nsImage.size.height.rounded(.up)))
            }

            // MARK: - Helpers

            private static func filledImage(_ color: NSColor, size: NSSize) -> NSImage {
                NSImage(size: size, flipped: false) { rect in
                    color.setFill()
                    rect.fill()
                    return true
                }
            }
        }
    #endif

#endif
