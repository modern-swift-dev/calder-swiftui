#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UILayoutPriorityExtTests {

    // MARK: - almostRequired Tests

    @Test func `almost required value`() {
        let priority = UILayoutPriority.almostRequired
        #expect(priority.rawValue == 999)
    }

    @Test func `almost required less than required`() {
        let almostRequired = UILayoutPriority.almostRequired
        let required = UILayoutPriority.required
        #expect(almostRequired < required)
    }

    @Test func `almost required greater than default high`() {
        let almostRequired = UILayoutPriority.almostRequired
        let defaultHigh = UILayoutPriority.defaultHigh
        #expect(almostRequired > defaultHigh)
    }

    @Test func `almost required can be used in constraint`() {
        let view = UIView()
        let constraint = view.widthAnchor.constraint(equalToConstant: 100)
        constraint.priority = .almostRequired
        #expect(constraint.priority == .almostRequired)
    }
}
#endif

#endif
