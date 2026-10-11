#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderSwiftUI
    import Foundation
    import SwiftUI
    import Testing

    struct StringLocalizableStringKeyTests {

        // MARK: - localizedKey

        @Test(arguments: ["Hello", "", "Hello, %@ World!", "Hello 你好 مرحبا", "Hello\nWorld", "Item %d of %d"])
        func `localized key uses the string as the key`(string: String) {
            #expect(string.localizedKey == LocalizedStringKey(string))
        }

        @Test func `different strings produce different keys`() {
            #expect("Hello".localizedKey != "World".localizedKey)
            #expect("Hello".localizedKey != "hello".localizedKey)
        }
    }

#endif
