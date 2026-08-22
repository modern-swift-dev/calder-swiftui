#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if os(iOS) || targetEnvironment(macCatalyst)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized) struct UIFontTests {
    @Test func xxxl() {
        let baseFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        let scaledFont = UIFont.scaledFont(base: baseFont, compatibleWith: UITraitCollection(preferredContentSizeCategory: .extraExtraExtraLarge))
        #expect(scaledFont.pointSize == 13)
    }

    @Test func weight() {
        let baseFont = UIFont.systemFont(ofSize: 10, weight: .regular)
        let scaledFont = UIFont.scaledFont(base: baseFont, compatibleWith: UITraitCollection(legibilityWeight: .bold))
        #expect(scaledFont.fontDescriptor.postscriptName == ".SFUI-Semibold")
    }
}
#endif

#endif
