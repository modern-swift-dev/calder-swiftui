#if canImport(SwiftUI)
import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct ThemePublicAPITests {

    @Test func `theme definition has a public default initializer`() {
        let definition = ThemeDefinition()

        #expect(type(of: definition.primary) == ThemeColor.self)
    }

    @Test func `theme appearance properties are public`() {
        let definition = ThemeDefinition()
        let theme = Theme(
            definition: definition,
            scheme: .dark,
            contrast: .increased,
            dynamicTypeSize: .medium
        )

        #expect(theme.definition.primary.getColor(scheme: .dark) == definition.primary.getColor(scheme: .dark))
        #expect(theme.scheme == .dark)
        #expect(theme.contrast == .increased)
        #expect(theme.border == definition.border.getColor(scheme: .dark, contrast: .increased))
        #expect(theme.shadow == definition.shadow.getColor(scheme: .dark, contrast: .increased))
    }
}
#endif
