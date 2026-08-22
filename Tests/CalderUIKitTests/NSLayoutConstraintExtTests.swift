#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct NSLayoutConstraintExtTests {

    // MARK: - UILayoutPriority Tests

    @Test func `almost required is 999`() {
        #expect(UILayoutPriority.almostRequired.rawValue == 999)
    }

    @Test func `almost required less than required`() {
        #expect(UILayoutPriority.almostRequired < .required)
    }

    @Test func `almost required greater than default high`() {
        #expect(UILayoutPriority.almostRequired > .defaultHigh)
    }

    // MARK: - NSLayoutDimension Tests

    @Test func `dimension eq constant`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100)
        #expect(constraint.constant == 100)
        #expect(constraint.relation == .equal)
    }

    @Test func `dimension eq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor)
        #expect(constraint.relation == .equal)
        #expect(constraint.multiplier == 1.0)
        #expect(constraint.constant == 0.0)
    }

    @Test func `dimension eq anchor with multiplier`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor, multiplier: 2.0)
        #expect(constraint.multiplier == 2.0)
    }

    @Test func `dimension eq anchor with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.eq(view2.widthAnchor, constant: 10)
        #expect(constraint.constant == 10)
    }

    @Test func `dimension leq constant`() {
        let view = UIView()
        let constraint = view.heightAnchor.leq(200)
        #expect(constraint.constant == 200)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `dimension leq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.heightAnchor.leq(view2.heightAnchor)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `dimension leq anchor with multiplier and constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.leq(view2.widthAnchor, multiplier: 0.5, constant: 20)
        #expect(constraint.relation == .lessThanOrEqual)
        #expect(constraint.multiplier == 0.5)
        #expect(constraint.constant == 20)
    }

    @Test func `dimension geq constant`() {
        let view = UIView()
        let constraint = view.widthAnchor.geq(50)
        #expect(constraint.constant == 50)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `dimension geq anchor`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.widthAnchor.geq(view2.widthAnchor)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `dimension geq anchor with multiplier and constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.heightAnchor.geq(view2.heightAnchor, multiplier: 1.5, constant: -10)
        #expect(constraint.relation == .greaterThanOrEqual)
        #expect(constraint.multiplier == 1.5)
        #expect(constraint.constant == -10)
    }

    // MARK: - NSLayoutXAxisAnchor Tests

    @Test func `x axis eq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eq(view2.leadingAnchor)
        #expect(constraint.relation == .equal)
        #expect(constraint.constant == 0)
    }

    @Test func `x axis eq with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eq(view2.leadingAnchor, constant: 16)
        #expect(constraint.constant == 16)
    }

    @Test func `x axis leq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.trailingAnchor.leq(view2.trailingAnchor)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `x axis leq with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.trailingAnchor.leq(view2.trailingAnchor, constant: -8)
        #expect(constraint.constant == -8)
    }

    @Test func `x axis geq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.centerXAnchor.geq(view2.centerXAnchor)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `x axis geq with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.centerXAnchor.geq(view2.centerXAnchor, constant: 20)
        #expect(constraint.constant == 20)
    }

    @Test func `x axis eq after`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.eqAfter(view2.trailingAnchor, multiplier: 1.0)
        #expect(constraint.relation == .equal)
    }

    @Test func `x axis leq after`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.leqAfter(view2.trailingAnchor, multiplier: 1.0)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `x axis geq after`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.leadingAnchor.geqAfter(view2.trailingAnchor, multiplier: 1.0)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    // MARK: - NSLayoutYAxisAnchor Tests

    @Test func `y axis eq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eq(view2.topAnchor)
        #expect(constraint.relation == .equal)
        #expect(constraint.constant == 0)
    }

    @Test func `y axis eq with constant`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eq(view2.topAnchor, constant: 12)
        #expect(constraint.constant == 12)
    }

    @Test func `y axis leq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.bottomAnchor.leq(view2.bottomAnchor)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `y axis geq`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.centerYAnchor.geq(view2.centerYAnchor)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    @Test func `y axis eq below`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.eqBelow(view2.bottomAnchor, multiplier: 1.0)
        #expect(constraint.relation == .equal)
    }

    @Test func `y axis leq below`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.leqBelow(view2.bottomAnchor, multiplier: 1.0)
        #expect(constraint.relation == .lessThanOrEqual)
    }

    @Test func `y axis geq below`() {
        let view1 = UIView()
        let view2 = UIView()
        let constraint = view1.topAnchor.geqBelow(view2.bottomAnchor, multiplier: 1.0)
        #expect(constraint.relation == .greaterThanOrEqual)
    }

    // MARK: - Constraint Activation Tests

    @Test func `constraint activate`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100)
        #expect(constraint.isActive == false)
        let activated = constraint.activate()
        #expect(activated.isActive == true)
        #expect(activated === constraint)
    }

    @Test func `constraint array activate`() {
        let view = UIView()
        let constraints = [
            view.widthAnchor.eq(100),
            view.heightAnchor.eq(50)
        ]
        #expect(constraints.count(where: { !$0.isActive }) == 2)
        constraints.activate()
        #expect(constraints.filter(\.isActive).count == 2)
    }

    @Test func `constraint array deactivate`() {
        let view = UIView()
        let constraints = [
            view.widthAnchor.eq(100).activate(),
            view.heightAnchor.eq(50).activate()
        ]
        #expect(constraints.filter(\.isActive).count == 2)
        constraints.deactivate()
        #expect(constraints.count(where: { !$0.isActive }) == 2)
    }

    // MARK: - Constraint Assignment Tests

    @Test func `constraint assign to`() {
        let view = UIView()
        var storedConstraint: NSLayoutConstraint?
        let constraint = view.widthAnchor.eq(100).assign(to: &storedConstraint)
        #expect(storedConstraint === constraint)
    }

    // MARK: - Constraint with(identifier:) Tests

    @Test func `constraint with identifier`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).with(identifier: "testConstraint")
        #expect(constraint.identifier == "testConstraint")
    }

    @Test func `constraint with identifier empty string`() {
        let view = UIView()
        let constraint = view.heightAnchor.eq(50).with(identifier: "")
        #expect(constraint.identifier == "")
    }

    // MARK: - Constraint with(constant:) Tests

    @Test func `constraint with constant`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).with(constant: 200)
        #expect(constraint.constant == 200)
    }

    @Test func `constraint with constant negative`() {
        let view = UIView()
        let constraint = view.heightAnchor.eq(100).with(constant: -50)
        #expect(constraint.constant == -50)
    }

    @Test func `constraint with constant zero`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).with(constant: 0)
        #expect(constraint.constant == 0)
    }

    // MARK: - Constraint with(priority:) Tests

    @Test func `constraint with priority required`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).with(priority: .required)
        #expect(constraint.priority == .required)
    }

    @Test func `constraint with priority default high`() {
        let view = UIView()
        let constraint = view.heightAnchor.eq(50).with(priority: .defaultHigh)
        #expect(constraint.priority == .defaultHigh)
    }

    @Test func `constraint with priority default low`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).with(priority: .defaultLow)
        #expect(constraint.priority == .defaultLow)
    }

    @Test func `constraint with priority almost required`() {
        let view = UIView()
        let constraint = view.heightAnchor.eq(75).with(priority: .almostRequired)
        #expect(constraint.priority == .almostRequired)
    }

    // MARK: - Constraint deactivate Tests

    @Test func `constraint deactivate`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100).activate()
        #expect(constraint.isActive == true)
        let deactivated = constraint.deactivate()
        #expect(deactivated.isActive == false)
        #expect(deactivated === constraint)
    }

    @Test func `constraint deactivate already inactive`() {
        let view = UIView()
        let constraint = view.widthAnchor.eq(100)
        #expect(constraint.isActive == false)
        let deactivated = constraint.deactivate()
        #expect(deactivated.isActive == false)
    }

    // MARK: - Chaining Tests

    @Test func `constraint chaining multiple modifiers`() {
        let view = UIView()
        var storedConstraint: NSLayoutConstraint?

        let constraint = view.widthAnchor.eq(100)
            .with(identifier: "width")
            .with(priority: .defaultHigh)
            .with(constant: 150)
            .assign(to: &storedConstraint)
            .activate()

        #expect(constraint.identifier == "width")
        #expect(constraint.priority == .defaultHigh)
        #expect(constraint.constant == 150)
        #expect(constraint.isActive == true)
        #expect(storedConstraint === constraint)
    }
}
#endif

#endif
