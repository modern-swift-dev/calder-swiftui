#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @MainActor struct TileTests {
        private static func theme() -> Theme {
            var definition = ThemeDefinition()
            definition.text1 = ThemeColor(light: .gray)
            definition.textOverPrimary = ThemeColor(light: .red)
            definition.textOverWarning = ThemeColor(light: .orange)
            definition.textOverError = ThemeColor(light: .purple)
            return Theme(definition: definition, scheme: .light, contrast: .standard, dynamicTypeSize: .medium)
        }

        @Test func `empty tile label uses the primary text colour`() {
            #expect(Tile.Variant.empty.labelForeground(theme: Self.theme()) == .gray)
        }

        @Test func `loading tile label uses the primary text colour`() {
            #expect(Tile.Variant.loading.labelForeground(theme: Self.theme()) == .gray)
        }

        @Test func `info tile label uses the text over primary colour`() {
            #expect(Tile.Variant.info.labelForeground(theme: Self.theme()) == .red)
        }

        @Test func `warn tile label uses the text over warning colour`() {
            #expect(Tile.Variant.warn.labelForeground(theme: Self.theme()) == .orange)
        }

        @Test func `error tile label uses the text over error colour`() {
            #expect(Tile.Variant.error.labelForeground(theme: Self.theme()) == .purple)
        }

        @Test func `caller icons are not mirrored in right to left layouts`() throws {
            let tile = Tile(icon: try Self.leftBarImage(), label: "Label", text: "1", variant: .info) {}
            let bitmap = try #require(RenderedBitmap(rendering: tile.iconView.environment(\.layoutDirection, .rightToLeft)))

            #expect(bitmap.width == 20)
            #expect(bitmap.pixel(x: 2, y: 10).alpha > 0)
            #expect(bitmap.pixel(x: 17, y: 10).alpha == 0)
        }

        /// A 20 by 20 image that is opaque only in its five leftmost columns.
        private static func leftBarImage() throws -> Image {
            let context = try #require(CGContext(
                data: nil,
                width: 20,
                height: 20,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
            context.fill(CGRect(x: 0, y: 0, width: 5, height: 20))
            return Image(decorative: try #require(context.makeImage()), scale: 1)
        }
    }

#endif
