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

        @Test func `themed style applies to navigation links`() throws {
            let link = NavigationLink("Details", destination: EmptyView())
                .applyThemedStyle(variant: .pill(bg: Color.blue, fg: Color.white))
            let button = Button("Details") {}
                .applyThemedStyle(variant: .pill(bg: Color.blue, fg: Color.white))
            let unstyled = NavigationLink("Details", destination: EmptyView())

            let rendered = try #require(RenderedBitmap(rendering: link))

            // Outside a navigation stack a link is disabled, so it must look like a disabled themed button.
            #expect(try rendered == #require(RenderedBitmap(rendering: button.disabled(true))))
            #expect(try rendered != #require(RenderedBitmap(rendering: unstyled)))
        }
    }
#endif
