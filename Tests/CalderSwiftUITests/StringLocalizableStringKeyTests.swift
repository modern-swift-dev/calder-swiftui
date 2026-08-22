#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct StringLocalizableStringKeyTests {

    // MARK: - localizedKey

    @Test func `localized key returns localized string key`() {
        let string = "Hello"
        let key = string.localizedKey
        // LocalizedStringKey is opaque, but we can verify it's created
        // by using it in a Text view context
        _ = Text(key)
    }

    @Test func `localized key with empty string`() {
        let string = ""
        let key = string.localizedKey
        _ = Text(key)
    }

    @Test func `localized key with special characters`() {
        let string = "Hello, %@ World!"
        let key = string.localizedKey
        _ = Text(key)
    }

    @Test func `localized key with unicode`() {
        let string = "Hello 你好 مرحبا"
        let key = string.localizedKey
        _ = Text(key)
    }

    @Test func `localized key with newlines`() {
        let string = "Hello\nWorld"
        let key = string.localizedKey
        _ = Text(key)
    }

    @Test func `localized key with numbers`() {
        let string = "Item %d of %d"
        let key = string.localizedKey
        _ = Text(key)
    }
}

#endif
