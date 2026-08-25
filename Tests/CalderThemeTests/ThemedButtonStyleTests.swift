#if canImport(SwiftUI)
import CalderSwiftUI
import CalderTheme
import CalderUIKit
import SwiftUI
import Testing

@MainActor struct ThemedButtonStyleTests {

    @Test func `standard variants use roomy padding`() {
        let expected = EdgeInsets(vertical: .small, horizontal: .medium)

        #expect(ThemedButtonStyle.Variant.primary().padding == expected)
        #expect(ThemedButtonStyle.Variant.secondary().padding == expected)
        #expect(ThemedButtonStyle.Variant.tertiary().padding == expected)
    }

    @Test func `pill variant uses compact padding`() {
        let variant = ThemedButtonStyle.Variant.pill(bg: Color.blue, fg: Color.white)

        #expect(variant.padding == EdgeInsets(vertical: .xxs, horizontal: .small))
    }

    @Test func `themed style applies to navigation links`() {
        _ = NavigationLink("Details", destination: EmptyView())
            .applyThemedStyle(variant: .primary())
    }
}
#endif
