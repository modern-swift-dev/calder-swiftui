#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct ColorSystemTests {

    // MARK: - System Gray Colors

    @Test func `system gray exists`() {
        let color = Color.systemGray
        #expect(type(of: color) == Color.self)
    }

    @Test func `system gray 2 exists`() {
        let color = Color.systemGray2
        #expect(type(of: color) == Color.self)
    }

    @Test func `system gray 3 exists`() {
        let color = Color.systemGray3
        #expect(type(of: color) == Color.self)
    }

    @Test func `system gray 4 exists`() {
        let color = Color.systemGray4
        #expect(type(of: color) == Color.self)
    }

    @Test func `system gray 5 exists`() {
        let color = Color.systemGray5
        #expect(type(of: color) == Color.self)
    }

    @Test func `system gray 6 exists`() {
        let color = Color.systemGray6
        #expect(type(of: color) == Color.self)
    }

    // MARK: - Label Colors

    @Test func `label color exists`() {
        let color = Color.label
        #expect(type(of: color) == Color.self)
    }

    @Test func `secondary label exists`() {
        let color = Color.secondaryLabel
        #expect(type(of: color) == Color.self)
    }

    @Test func `tertiary label exists`() {
        let color = Color.tertiaryLabel
        #expect(type(of: color) == Color.self)
    }

    @Test func `quaternary label exists`() {
        let color = Color.quaternaryLabel
        #expect(type(of: color) == Color.self)
    }

    // MARK: - Interactive Colors

    @Test func `link color exists`() {
        let color = Color.link
        #expect(type(of: color) == Color.self)
    }

    @Test func `placeholder text exists`() {
        let color = Color.placeholderText
        #expect(type(of: color) == Color.self)
    }

    // MARK: - Separator Colors

    @Test func `separator color exists`() {
        let color = Color.separator
        #expect(type(of: color) == Color.self)
    }

    #if canImport(UIKit) && !os(watchOS)
    @Test func `opaque separator exists`() {
        let color = Color.opaqueSeparator
        #expect(type(of: color) == Color.self)
    }

    #elseif os(watchOS)
    @Test func `opaque separator exists watch OS`() {
        let color = Color.opaqueSeparator
        #expect(type(of: color) == Color.self)
    }
    #endif

    // MARK: - Background Colors

    @Test func `system background exists`() {
        let color = Color.systemBackground
        #expect(type(of: color) == Color.self)
    }

    @Test func `secondary system background exists`() {
        let color = Color.secondarySystemBackground
        #expect(type(of: color) == Color.self)
    }

    @Test func `tertiary system background exists`() {
        let color = Color.tertiarySystemBackground
        #expect(type(of: color) == Color.self)
    }

    // MARK: - Grouped Background Colors

    @Test func `system grouped background exists`() {
        let color = Color.systemGroupedBackground
        #expect(type(of: color) == Color.self)
    }

    @Test func `secondary system grouped background exists`() {
        let color = Color.secondarySystemGroupedBackground
        #expect(type(of: color) == Color.self)
    }

    @Test func `tertiary system grouped background exists`() {
        let color = Color.tertiarySystemGroupedBackground
        #expect(type(of: color) == Color.self)
    }

    // MARK: - Fill Colors (UIKit and watchOS only)

    #if (canImport(UIKit) && !os(watchOS)) || os(watchOS)
    @Test func `system fill exists`() {
        let color = Color.systemFill
        #expect(type(of: color) == Color.self)
    }

    @Test func `secondary system fill exists`() {
        let color = Color.secondarySystemFill
        #expect(type(of: color) == Color.self)
    }

    @Test func `tertiary system fill exists`() {
        let color = Color.tertiarySystemFill
        #expect(type(of: color) == Color.self)
    }

    @Test func `quaternary system fill exists`() {
        let color = Color.quaternarySystemFill
        #expect(type(of: color) == Color.self)
    }
    #endif

    // MARK: - Static Text Colors (UIKit and watchOS only)

    #if (canImport(UIKit) && !os(watchOS)) || os(watchOS)
    @Test func `light text exists`() {
        let color = Color.lightText
        #expect(type(of: color) == Color.self)
    }

    @Test func `dark text exists`() {
        let color = Color.darkText
        #expect(type(of: color) == Color.self)
    }
    #endif

    // MARK: - Color Usage in Views

    @Test func `system colors can be used in views`() {
        _ = Text("Test")
            .foregroundStyle(Color.label)
            .background(Color.systemBackground)
    }

    @Test func `gray colors can be used in views`() {
        _ = Rectangle()
            .fill(Color.systemGray)
            .overlay(
                Rectangle().fill(Color.systemGray3)
            )
    }

    @Test func `separator colors can be used in views`() {
        _ = Divider()
            .background(Color.separator)
    }
}

#endif
