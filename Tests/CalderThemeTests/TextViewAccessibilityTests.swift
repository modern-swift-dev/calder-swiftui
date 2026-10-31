#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    /// SwiftUI backs `TextEditor` with a UIKit view whose label and hint can't be read from a hosted view,
    /// so these tests check that the text VoiceOver would otherwise read twice, the placeholder and the
    /// invalid message, is hidden because the editor carries it as its label and hint.
    @Suite(.serialized)
    @MainActor struct TextViewAccessibilityTests {
        @Test func `text view hides its placeholder and invalid message from VoiceOver`() {
            let view = TextView(text: .constant(""), invalid: true, invalidMessage: "Too short", placeholder: "Notes")

            let labels = AccessibilityTree.elements(of: view).compactMap(\.label)

            #expect(!labels.contains("Too short"))
            #expect(!labels.contains("Notes"))
        }

        @Test func `text view without a placeholder or invalid message exposes nothing extra`() {
            #expect(AccessibilityTree.elements(of: TextView(text: .constant(""))).isEmpty)
        }

        @available(iOS 26, *)
        @Test func `attributed text view hides its placeholder and invalid message from VoiceOver`() {
            let view = AttributedTextView(text: .constant(AttributedString()), invalid: true, invalidMessage: "Too short", placeholder: "Notes")

            let labels = AccessibilityTree.elements(of: view).compactMap(\.label)

            #expect(!labels.contains("Too short"))
            #expect(!labels.contains("Notes"))
        }
    }
#endif
