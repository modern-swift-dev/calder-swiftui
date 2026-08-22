#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct NSLayoutDimensionExtTests {

    // MARK: - eq (constant) Tests

    @Test func `eq constant`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100)

        #expect(constraint.constant == 100)
        #expect(constraint.firstAnchor === view.widthAnchor)
    }

    @Test func `eq constant zero`() {
        let view = UIView()
        let constraint = view.heightAnchor.eq(0)

        #expect(constraint.constant == 0)
    }

    // MARK: - eq (anchor) Tests

    @Test func `eq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor)

        #expect(constraint.firstAnchor === view1.widthAnchor)
        #expect(constraint.multiplier == 1.0)
        #expect(constraint.constant == 0.0)
    }

    @Test func `eq anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor, multiplier: 0.5)

        #expect(constraint.multiplier == 0.5)
    }

    @Test func `eq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.heightAnchor.eq(view2.heightAnchor, constant: 10)

        #expect(constraint.constant == 10)
    }

    @Test func `eq anchor with multiplier and constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor, multiplier: 2.0, constant: 20)

        #expect(constraint.multiplier == 2.0)
        #expect(constraint.constant == 20)
    }

    // MARK: - leq (constant) Tests

    @Test func `leq constant`() {
        let view = UIView()
        let constraint = view.widthAnchor.leq(200)

        #expect(constraint.constant == 200)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - leq (anchor) Tests

    @Test func `leq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.leq(view2.widthAnchor)

        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.multiplier == 1.0)
    }

    @Test func `leq anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.heightAnchor.leq(view2.heightAnchor, multiplier: 0.75)

        #expect(constraint.multiplier == 0.75)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    // MARK: - geq (constant) Tests

    @Test func `geq constant`() {
        let view = UIView()
        let constraint = view.heightAnchor.geq(50)

        #expect(constraint.constant == 50)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    // MARK: - geq (anchor) Tests

    @Test func `geq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.geq(view2.widthAnchor)

        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.multiplier == 1.0)
    }

    @Test func `geq anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.heightAnchor.geq(view2.heightAnchor, multiplier: 1.5)

        #expect(constraint.multiplier == 1.5)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `geq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.geq(view2.widthAnchor, constant: 30)

        #expect(constraint.constant == 30)
        #expect(constraint.relation == .greaterThanOrEqual)
    }
}
#endif

#endif
