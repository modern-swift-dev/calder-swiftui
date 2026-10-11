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
    }

#endif
