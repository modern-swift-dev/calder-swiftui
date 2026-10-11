#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @MainActor struct InputPasswordTests {
        @Test(arguments: [(true, "Show password"), (false, "Hide password")])
        func `reveal button describes its action to VoiceOver`(isSecuredEntry: Bool, label: String) {
            let input = InputPassword(text: .constant("secret"), isSecuredEntry: isSecuredEntry)

            #expect(input.revealButtonAccessibilityLabel == label)
        }

        @Test(arguments: [(true, false, 2.0), (false, false, 0.0), (true, true, 2.0), (false, true, 2.0)])
        func `invalid input draws its border even when the border is hidden`(displayTextViewBorder: Bool, invalid: Bool, expectedWidth: CGFloat) {
            let input = InputPassword(text: .constant(""), invalid: invalid, invalidMessage: "Required", displayTextViewBorder: displayTextViewBorder)

            #expect(input.borderLineWidth == expectedWidth)
            _ = input.body
        }
    }
#endif
