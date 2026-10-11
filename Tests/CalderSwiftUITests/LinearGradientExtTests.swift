#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct LinearGradientExtTests {

        private typealias Pixel = RenderedBitmap.Pixel

        // Use explicit RGB colors to avoid macOS catalog color issues
        private static let testRed = Color(red: 1, green: 0, blue: 0)
        private static let testGreen = Color(red: 0, green: 1, blue: 0)
        private static let testWhite = Color(red: 1, green: 1, blue: 1)
        private static let testBlack = Color(red: 0, green: 0, blue: 0)
        private static let testPurple = Color(red: 0.4, green: 0, blue: 0.4)

        // MARK: - init(darken:)

        @Test func `darken runs from the color to an eighth darker by default`() throws {
            let bitmap = try Self.render(LinearGradient(darken: Self.testRed))

            Self.expect(bitmap.top, near: Self.rgb(255, 0, 0))
            Self.expect(bitmap.bottom, near: Self.rgb(223, 0, 0))
        }

        @Test(arguments: [(CGFloat(0), UInt8(255)), (0.3, 179), (1, 0)])
        func `darken blends the end color toward black by the amount`(amount: CGFloat, endRed: UInt8) throws {
            let bitmap = try Self.render(LinearGradient(darken: Self.testRed, amount: amount))

            Self.expect(bitmap.top, near: Self.rgb(255, 0, 0))
            Self.expect(bitmap.bottom, near: Self.rgb(endRed, 0, 0))
        }

        @Test func `darken white ends in a light gray`() throws {
            let bitmap = try Self.render(LinearGradient(darken: Self.testWhite))

            Self.expect(bitmap.top, near: Self.rgb(255, 255, 255))
            Self.expect(bitmap.bottom, near: Self.rgb(223, 223, 223))
        }

        @Test func `darken follows custom start and end points`() throws {
            let bitmap = try Self.render(LinearGradient(darken: Self.testGreen, start: .leading, end: .trailing))

            Self.expect(bitmap.leading, near: Self.rgb(0, 255, 0))
            Self.expect(bitmap.trailing, near: Self.rgb(0, 223, 0))
            Self.expect(bitmap.top, near: bitmap.bottom)
        }

        @Test func `darken with all parameters runs diagonally`() throws {
            let gradient = LinearGradient(darken: Self.testPurple, amount: 0.5, start: .topLeading, end: .bottomTrailing)
            let bitmap = try Self.render(gradient)

            Self.expect(bitmap.topLeading, near: Self.rgb(102, 0, 102))
            Self.expect(bitmap.bottomTrailing, near: Self.rgb(51, 0, 51))
        }

        // MARK: - init(lighten:)

        @Test func `lighten runs from the color to an eighth lighter by default`() throws {
            let bitmap = try Self.render(LinearGradient(lighten: Self.testRed))

            Self.expect(bitmap.top, near: Self.rgb(255, 0, 0))
            Self.expect(bitmap.bottom, near: Self.rgb(255, 32, 32))
        }

        @Test(arguments: [(CGFloat(0), UInt8(0)), (0.3, 77), (1, 255)])
        func `lighten blends the end color toward white by the amount`(amount: CGFloat, endGreenAndBlue: UInt8) throws {
            let bitmap = try Self.render(LinearGradient(lighten: Self.testRed, amount: amount))

            Self.expect(bitmap.top, near: Self.rgb(255, 0, 0))
            Self.expect(bitmap.bottom, near: Self.rgb(255, endGreenAndBlue, endGreenAndBlue))
        }

        @Test func `lighten black ends in a dark gray`() throws {
            let bitmap = try Self.render(LinearGradient(lighten: Self.testBlack))

            Self.expect(bitmap.top, near: Self.rgb(0, 0, 0))
            Self.expect(bitmap.bottom, near: Self.rgb(32, 32, 32))
        }

        @Test func `lighten follows custom start and end points`() throws {
            let bitmap = try Self.render(LinearGradient(lighten: Self.testGreen, start: .bottom, end: .top))

            Self.expect(bitmap.bottom, near: Self.rgb(0, 255, 0))
            Self.expect(bitmap.top, near: Self.rgb(32, 255, 32))
            Self.expect(bitmap.leading, near: bitmap.trailing)
        }

        @Test func `lighten with all parameters runs diagonally`() throws {
            let gradient = LinearGradient(lighten: Self.testPurple, amount: 0.5, start: .topLeading, end: .bottomTrailing)
            let bitmap = try Self.render(gradient)

            Self.expect(bitmap.topLeading, near: Self.rgb(102, 0, 102))
            Self.expect(bitmap.bottomTrailing, near: Self.rgb(179, 128, 179))
        }

        // MARK: - Helpers

        private static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Pixel {
            Pixel(red: red, green: green, blue: blue, alpha: 255)
        }

        /// Renders the gradient large enough that edge pixels sit within 0.05% of the gradient's end points.
        private static func render(_ gradient: LinearGradient) throws -> RenderedBitmap {
            try #require(RenderedBitmap(rendering: Rectangle().fill(gradient).frame(width: 1000, height: 1000)))
        }

        /// Allows for the rounding of saturated colors through the renderer's working color space.
        private static func expect(_ pixel: Pixel, near expected: Pixel, sourceLocation: SourceLocation = #_sourceLocation) {
            #expect(pixel.isClose(to: expected, tolerance: 6), "\(pixel) is not close to \(expected)", sourceLocation: sourceLocation)
        }
    }

    private extension RenderedBitmap {
        var top: Pixel {
            pixel(x: width / 2, y: 0)
        }

        var bottom: Pixel {
            pixel(x: width / 2, y: height - 1)
        }

        var leading: Pixel {
            pixel(x: 0, y: height / 2)
        }

        var trailing: Pixel {
            pixel(x: width - 1, y: height / 2)
        }

        var topLeading: Pixel {
            pixel(x: 0, y: 0)
        }

        var bottomTrailing: Pixel {
            pixel(x: width - 1, y: height - 1)
        }
    }

#endif
