#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct NSLayoutYAxisAnchorExtTests {

    // MARK: - eq Tests

    @Test func `eq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eq(view2.topAnchor)

        #expect(constraint.firstAnchor === view1.topAnchor)
        #expect(constraint.constant == 0)
    }

    @Test func `eq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.bottomAnchor.eq(view2.bottomAnchor, constant: 10)

        #expect(constraint.constant == 10)
    }

    @Test func `eq center Y anchors`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.centerYAnchor.eq(view2.centerYAnchor)

        #expect(constraint.firstAnchor === view1.centerYAnchor)
    }

    // MARK: - leq Tests

    @Test func `leq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.leq(view2.topAnchor)

        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.constant == 0)
    }

    @Test func `leq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.bottomAnchor.leq(view2.bottomAnchor, constant: 20)

        #expect(constraint.constant == 20)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - geq Tests

    @Test func `geq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.geq(view2.topAnchor)

        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.constant == 0)
    }

    @Test func `geq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.bottomAnchor.geq(view2.bottomAnchor, constant: 15)

        #expect(constraint.constant == 15)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    // MARK: - eqBelow Tests

    @Test func `eq below anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eqBelow(view2.bottomAnchor)

        #expect(constraint.firstAnchor === view1.topAnchor)
    }

    @Test func `eq below anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eqBelow(view2.bottomAnchor, multiplier: 1.0)

        #expect(constraint.firstAnchor === view1.topAnchor)
    }

    // MARK: - leqBelow Tests

    @Test func `leq below anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.leqBelow(view2.bottomAnchor)

        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `leq below anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.leqBelow(view2.bottomAnchor, multiplier: 2.0)

        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - geqBelow Tests

    @Test func `geq below anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.geqBelow(view2.bottomAnchor)

        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `geq below anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.geqBelow(view2.bottomAnchor, multiplier: 0.5)

        #expect(constraint.relation == .greaterThanOrEqual)
    }
}
#endif

#endif
