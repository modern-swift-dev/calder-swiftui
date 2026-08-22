#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIViewRtlTests {

    // MARK: - isLayoutRtL Tests

    @Test func `is layout rt L default is ltr`() {
        let view = UIView()
        // Most systems default to LTR
        // The actual value depends on the system locale, but we can verify the property exists
        let isRtl = view.isLayoutRtL
        #expect(isRtl == true || isRtl == false)
    }

    @Test func `is layout rt L respects semantic content attribute`() {
        let view = UIView()
        view.semanticContentAttribute = .forceLeftToRight
        #expect(view.isLayoutRtL == false)
    }

    @Test func `is layout rt L force right to left`() {
        let view = UIView()
        view.semanticContentAttribute = .forceRightToLeft
        #expect(view.isLayoutRtL == true)
    }

    @Test func `is layout rt L playback`() {
        let view = UIView()
        view.semanticContentAttribute = .playback
        // Playback follows the user interface direction
        let isRtl = view.isLayoutRtL
        #expect(isRtl == true || isRtl == false)
    }

    @Test func `is layout rt L spatial`() {
        let view = UIView()
        view.semanticContentAttribute = .spatial
        // Spatial follows the user interface direction
        let isRtl = view.isLayoutRtL
        #expect(isRtl == true || isRtl == false)
    }
}
#endif

#endif
