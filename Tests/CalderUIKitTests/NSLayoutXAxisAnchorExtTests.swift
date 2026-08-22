#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct NSLayoutXAxisAnchorExtTests {

    // MARK: - eq Tests

    @Test func `eq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eq(view2.leadingAnchor)

        #expect(constraint.firstAnchor === view1.leadingAnchor)
        #expect(constraint.constant == 0)
    }

    @Test func `eq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.trailingAnchor.eq(view2.trailingAnchor, constant: 10)

        #expect(constraint.constant == 10)
    }

    @Test func `eq center X anchors`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.centerXAnchor.eq(view2.centerXAnchor)

        #expect(constraint.firstAnchor === view1.centerXAnchor)
    }

    // MARK: - leq Tests

    @Test func `leq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.leq(view2.leadingAnchor)

        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.constant == 0)
    }

    @Test func `leq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.trailingAnchor.leq(view2.trailingAnchor, constant: 20)

        #expect(constraint.constant == 20)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - geq Tests

    @Test func `geq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.geq(view2.leadingAnchor)

        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.constant == 0)
    }

    @Test func `geq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.trailingAnchor.geq(view2.trailingAnchor, constant: 15)

        #expect(constraint.constant == 15)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    // MARK: - eqAfter Tests

    @Test func `eq after anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eqAfter(view2.trailingAnchor)

        #expect(constraint.firstAnchor === view1.leadingAnchor)
    }

    @Test func `eq after anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eqAfter(view2.trailingAnchor, multiplier: 1.0)

        #expect(constraint.firstAnchor === view1.leadingAnchor)
    }

    // MARK: - leqAfter Tests

    @Test func `leq after anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.leqAfter(view2.trailingAnchor)

        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `leq after anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.leqAfter(view2.trailingAnchor, multiplier: 2.0)

        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - geqAfter Tests

    @Test func `geq after anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.geqAfter(view2.trailingAnchor)

        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `geq after anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.geqAfter(view2.trailingAnchor, multiplier: 0.5)

        #expect(constraint.relation == .greaterThanOrEqual)
    }
}
#endif

#endif
