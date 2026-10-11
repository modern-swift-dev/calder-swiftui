#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @MainActor struct StatusPillTests {
        private static func theme() -> Theme {
            var definition = ThemeDefinition()
            definition.textOverPrimary = ThemeColor(light: .red)
            definition.textOverSuccess = ThemeColor(light: .green)
            definition.textOverWarning = ThemeColor(light: .orange)
            definition.textOverError = ThemeColor(light: .purple)
            definition.textOverInfo = ThemeColor(light: .pink)
            return Theme(definition: definition, scheme: .light, contrast: .standard, dynamicTypeSize: .medium)
        }

        @Test func `success pill uses the text over success colour`() {
            #expect(StatusPill.Variant.success.foregroundToken(for: Self.theme()) == .green)
        }

        @Test func `info pill uses the text over primary colour`() {
            #expect(StatusPill.Variant.info.foregroundToken(for: Self.theme()) == .red)
        }

        @Test func `warn pill uses the text over warning colour`() {
            #expect(StatusPill.Variant.warn.foregroundToken(for: Self.theme()) == .orange)
        }

        @Test func `error pill uses the text over error colour`() {
            #expect(StatusPill.Variant.error.foregroundToken(for: Self.theme()) == .purple)
        }

        @Test func `custom pill has no theme foreground token`() {
            let variant = StatusPill.Variant.custom(background: Color.blue, foreground: Color.yellow)
            #expect(variant.foregroundToken(for: Self.theme()) == nil)
        }
    }

#endif
