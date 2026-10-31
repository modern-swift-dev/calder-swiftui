#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct AttributedTextViewCounterTests {
        @available(iOS 26, *)
        @Test func `attributed text view shows the same counter as text view`() {
            let plain = AccessibilityTree.elements(of: TextView(text: .constant("Hello"), maxLength: 100)).compactMap(\.label)
            let attributed = AccessibilityTree.elements(of: AttributedTextView(text: .constant(AttributedString("Hello")), maxLength: 100)).compactMap(\.label)

            #expect(plain == ["5 / 100 characters"])
            #expect(attributed == plain)
        }

        @available(iOS 26, *)
        @Test func `attributed text view counter uses the environment locale`() {
            let view = AttributedTextView(text: .constant(AttributedString(String(repeating: "a", count: 1200))), maxLength: 5000)
                .environment(\.locale, Locale(identifier: "de_DE"))

            #expect(AccessibilityTree.elements(of: view).compactMap(\.label) == ["1.200 / 5.000 characters"])
        }

        @available(iOS 26, *)
        @Test func `attributed text view has no counter without a limit`() {
            let view = AttributedTextView(text: .constant(AttributedString("Hello")))

            #expect(AccessibilityTree.elements(of: view).isEmpty)
        }

        @available(iOS 26, *)
        @Test func `attributed text view counts characters not runs`() {
            var text = AttributedString("Hel")
            var bold = AttributedString("lo")
            bold.inlinePresentationIntent = .stronglyEmphasized
            text.append(bold)

            let labels = AccessibilityTree.elements(of: AttributedTextView(text: .constant(text), maxLength: 10)).compactMap(\.label)

            #expect(labels == ["5 / 10 characters"])
        }
    }
#endif
