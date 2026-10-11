#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct InputTextTests {
        @Test(arguments: [(true, false, 1.0), (false, false, 0.0), (true, true, 1.0), (false, true, 1.0)])
        func `invalid input draws its border even when the border is hidden`(displayTextViewBorder: Bool, invalid: Bool, expectedWidth: CGFloat) {
            let input = InputText(text: .constant(""), displayTextViewBorder: displayTextViewBorder, invalid: invalid, invalidMessage: "Required")

            #expect(input.borderLineWidth == expectedWidth)
            _ = input.body
        }
    }
#endif
