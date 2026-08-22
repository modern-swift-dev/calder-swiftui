#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct FormButtonTests {

    @Test func `normal button stores values and builds body`() {
        let button = FormButton(text: "Apply Filters", destructive: false) {}

        #expect(button.text == "Apply Filters")
        #expect(!button.destructive)
        _ = button.body
    }

    @Test func `destructive button stores values and builds body`() {
        let button = FormButton(text: "Reset Filters", destructive: true) {}

        #expect(button.text == "Reset Filters")
        #expect(button.destructive)
        _ = button.body
    }
}

#endif
