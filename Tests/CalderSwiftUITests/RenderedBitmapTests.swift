#if canImport(SwiftUI)
    @testable import CalderSwiftUI
    import CoreGraphics
    import Testing

    @MainActor struct RenderedBitmapTests {

        @Test func `an opaque uniform render is retried and logged`() throws {
            var renders = [Self.image(fill: Self.opaqueRed), Self.image(fill: Self.opaqueRed, dot: Self.opaqueBlue)]
            var messages: [String] = []

            let bitmap = try #require(RenderedBitmap(attempting: { renders.removeFirst() }, log: { messages.append($0) }))

            #expect(renders.isEmpty)
            #expect(bitmap.pixel(x: 0, y: 0) == RenderedBitmap.Pixel(red: 0, green: 0, blue: 255, alpha: 255))
            #expect(messages.count == 1)
        }

        @Test func `a transparent render is retried`() throws {
            var renders = [Self.image(fill: nil), Self.image(fill: nil, dot: Self.opaqueBlue)]

            let bitmap = try #require(RenderedBitmap(attempting: { renders.removeFirst() }, log: { _ in }))

            #expect(renders.isEmpty)
            #expect(bitmap.pixel(x: 0, y: 0) == RenderedBitmap.Pixel(red: 0, green: 0, blue: 255, alpha: 255))
        }

        @Test func `a render that is never varied is returned after the last attempt`() throws {
            var attempts = 0
            var messages: [String] = []

            let bitmap = try #require(RenderedBitmap(attempting: {
                attempts += 1
                return Self.image(fill: Self.opaqueRed)
            }, log: { messages.append($0) }))

            #expect(attempts == 3)
            #expect(messages.count == 2)
            #expect(bitmap.pixel(x: 1, y: 1) == RenderedBitmap.Pixel(red: 255, green: 0, blue: 0, alpha: 255))
        }

        @Test func `a varied render is not retried or logged`() throws {
            var attempts = 0
            var messages: [String] = []

            _ = try #require(RenderedBitmap(attempting: {
                attempts += 1
                return Self.image(fill: Self.opaqueRed, dot: Self.opaqueBlue)
            }, log: { messages.append($0) }))

            #expect(attempts == 1)
            #expect(messages.isEmpty)
        }

        @Test func `a missing image returns nil without retrying`() {
            var attempts = 0

            let bitmap = RenderedBitmap(attempting: {
                attempts += 1
                return nil
            }, log: { _ in })

            #expect(bitmap == nil)
            #expect(attempts == 1)
        }

        private static let opaqueRed = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
        private static let opaqueBlue = CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)

        /// A 2x2 image filled with `fill` (transparent when `nil`), with its top-left pixel set to `dot` when given.
        private static func image(fill: CGColor?, dot: CGColor? = nil) -> CGImage? {
            guard let space = CGColorSpace(name: CGColorSpace.sRGB),
                  let context = CGContext(
                      data: nil,
                      width: 2,
                      height: 2,
                      bitsPerComponent: 8,
                      bytesPerRow: 0,
                      space: space,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                  ) else {
                return nil
            }
            if let fill {
                context.setFillColor(fill)
                context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
            }
            if let dot {
                context.setFillColor(dot)
                context.fill(CGRect(x: 0, y: 1, width: 1, height: 1))
            }
            return context.makeImage()
        }
    }
#endif
