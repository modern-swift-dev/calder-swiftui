#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && !os(tvOS)
@testable import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct AttributedTextViewTests {

    @available(iOS 26, macOS 26, *)
    @Test func `constructs body with placeholder and invalid message`() {
        var text = AttributedString("")
        let view = AttributedTextView(
            text: Binding(get: { text }, set: { text = $0 }),
            invalid: true,
            invalidMessage: "Invalid",
            placeholder: "Placeholder",
            displayTextViewBorder: true,
            maxLength: 10
        )

        #expect(view.text == AttributedString(""))
        #expect(view.invalid)
        #expect(view.invalidMessage == "Invalid")
        #expect(view.placeholder == "Placeholder")
        #expect(view.displayTextViewBorder)
        #expect(view.maxLength == 10)
        _ = view.body
    }

    @available(iOS 26, macOS 26, *)
    @Test func `constructs body with filled text and no border`() {
        var text = AttributedString("Hello")
        let view = AttributedTextView(
            text: Binding(get: { text }, set: { text = $0 }),
            displayTextViewBorder: false
        )

        #expect(view.text == AttributedString("Hello"))
        #expect(!view.invalid)
        #expect(view.invalidMessage == nil)
        #expect(view.placeholder == nil)
        #expect(!view.displayTextViewBorder)
        #expect(view.maxLength == nil)
        _ = view.body
    }
}
#endif

#endif
