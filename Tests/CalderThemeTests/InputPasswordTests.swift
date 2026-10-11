#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct InputPasswordTests {
        @Test(arguments: [(true, "Show password"), (false, "Hide password")])
        func `reveal button describes its action to VoiceOver`(isSecuredEntry: Bool, label: String) {
            let input = InputPassword(text: .constant("secret"), isSecuredEntry: isSecuredEntry)

            #expect(input.revealButtonAccessibilityLabel == label)
        }
    }
#endif
