#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIFontExtTests {

    // MARK: - scaledSystemFont Tests

    @Test func `scaled system font default weight`() {
        let font = UIFont.scaledSystemFont(ofSize: 16)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font bold weight`() {
        let font = UIFont.scaledSystemFont(ofSize: 14, weight: .bold)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font light weight`() {
        let font = UIFont.scaledSystemFont(ofSize: 12, weight: .light)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font with italic trait`() {
        let font = UIFont.scaledSystemFont(ofSize: 16, traits: .traitItalic)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font with bold trait`() {
        let font = UIFont.scaledSystemFont(ofSize: 16, traits: .traitBold)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font with expanded trait`() {
        let font = UIFont.scaledSystemFont(ofSize: 16, traits: .traitExpanded)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font with trait collection`() {
        let traitCollection = UITraitCollection(preferredContentSizeCategory: .large)
        let font = UIFont.scaledSystemFont(ofSize: 16, compatibleWith: traitCollection)
        #expect(font.pointSize > 0)
    }

    @Test func `scaled system font with weight and traits`() {
        let font = UIFont.scaledSystemFont(ofSize: 18, weight: .semibold, traits: .traitBold)
        #expect(font.pointSize > 0)
    }

    // MARK: - scaledFont Tests

    @Test func `scaled font base font`() {
        let baseFont = UIFont.systemFont(ofSize: 14)
        let scaledFont = UIFont.scaledFont(base: baseFont)
        #expect(scaledFont.pointSize > 0)
    }

    @Test func `scaled font with traits`() {
        let baseFont = UIFont.systemFont(ofSize: 14)
        let scaledFont = UIFont.scaledFont(base: baseFont, traits: .traitItalic)
        #expect(scaledFont.pointSize > 0)
    }

    @Test func `scaled font with empty traits`() {
        let baseFont = UIFont.systemFont(ofSize: 14)
        let scaledFont = UIFont.scaledFont(base: baseFont, traits: [])
        #expect(scaledFont.pointSize > 0)
    }

    @Test func `scaled font with trait collection`() {
        let baseFont = UIFont.systemFont(ofSize: 14)
        let traitCollection = UITraitCollection(preferredContentSizeCategory: .extraLarge)
        let scaledFont = UIFont.scaledFont(base: baseFont, compatibleWith: traitCollection)
        #expect(scaledFont.pointSize > 0)
    }

    @Test func `scaled font custom font`() {
        let baseFont = UIFont.boldSystemFont(ofSize: 16)
        let scaledFont = UIFont.scaledFont(base: baseFont)
        #expect(scaledFont.pointSize > 0)
    }
}
#endif

#endif
