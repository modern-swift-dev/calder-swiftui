#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct LayoutConstraintBuilderTests {

    @Test func `constraint builder single`() {
        let view = UIView()
        var constraint: NSLayoutConstraint?
        NSLayoutConstraint.activate {
            view.widthAnchor.eq(20).assign(to: &constraint)
        }
        #expect(constraint?.isActive == true)
    }

    @Test func `constraint builder multi`() {
        let view = UIView()
        let constraints = NSLayoutConstraint.activate {
            view.widthAnchor.eq(20)
            view.heightAnchor.eq(20)
        }
        #expect(constraints.count == 2)
    }

    @Test func `constraint builder optional nil`() {
        let view = UIView()
        let optional: NSLayoutConstraint? = nil
        let constraints = NSLayoutConstraint.activate {
            view.widthAnchor.eq(20)
            optional
        }
        #expect(constraints.count == 1)
    }

    @Test func `constraint builder optional not nil`() {
        let view = UIView()
        let optional: NSLayoutConstraint? = view.heightAnchor.eq(20)
        let constraints = NSLayoutConstraint.activate {
            view.widthAnchor.eq(20)
            optional
        }
        #expect(constraints.count == 2)
    }

    @Test func `constraint builder condition first`() {
        let view = UIView()
        let constraints = createIfElseConstraints(view: view, value: true)
        #expect(constraints.count == 1)
        #expect(constraints.first?.firstAnchor == view.widthAnchor)
    }

    @Test func `constraint builder condition second`() {
        let view = UIView()
        let constraints = createIfElseConstraints(view: view, value: false)
        #expect(constraints.count == 1)
        #expect(constraints.first?.firstAnchor == view.heightAnchor)
    }

    @discardableResult private func createIfElseConstraints(view: UIView, value: Bool) -> [NSLayoutConstraint] {
        NSLayoutConstraint.activate {
            if value {
                view.widthAnchor.eq(20)
            } else {
                view.heightAnchor.eq(20)
            }
        }
    }

    @Test func `constraint builder condition array`() {
        let view = UIView()
        let values: [NSLayoutConstraint] = [
            view.widthAnchor.eq(20),
            view.heightAnchor.eq(20)
        ]
        let constraints = NSLayoutConstraint.activate {
            values
        }
        #expect(constraints.count == 2)
    }

    @Test func `constraint activate`() {
        let view = UIView()
        let constraints: [NSLayoutConstraint] = [
            view.widthAnchor.eq(20)
        ]

        #expect(constraints.allSatisfy { !$0.isActive } == true)

        constraints.activate()

        #expect(constraints.allSatisfy(\.isActive) == true)
    }

    @Test func `constraint deactivate`() {
        let view = UIView()
        let constraints: [NSLayoutConstraint] = [
            view.widthAnchor.eq(20).activate()
        ]

        #expect(constraints.allSatisfy(\.isActive) == true)

        constraints.deactivate()

        #expect(constraints.allSatisfy { !$0.isActive } == true)
    }

    @Test func `constraint sugar syntax equality`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        #expect(view.leadingAnchor.eq(superview.leadingAnchor).relation == .equal)
        #expect(view.trailingAnchor.eq(superview.trailingAnchor).relation == .equal)
        #expect(view.topAnchor.eq(superview.topAnchor).relation == .equal)
        #expect(view.bottomAnchor.eq(superview.bottomAnchor).relation == .equal)
        #expect(view.widthAnchor.eq(superview.widthAnchor).relation == .equal)
        #expect(view.heightAnchor.eq(superview.heightAnchor).relation == .equal)
        #expect(view.widthAnchor.eq(20).relation == .equal)
        #expect(view.heightAnchor.eq(20).relation == .equal)
        #expect(view.centerYAnchor.eq(superview.centerYAnchor).relation == .equal)
        #expect(view.centerXAnchor.eq(superview.centerXAnchor).relation == .equal)
        #expect(view.centerYAnchor.eqBelow(superview.centerYAnchor).relation == .equal)
        #expect(view.centerXAnchor.eqAfter(superview.centerXAnchor).relation == .equal)
    }

    @Test func `constraint sugar syntax less than or equal`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        #expect(view.leadingAnchor.leq(superview.leadingAnchor).relation == .lessThanOrEqual)
        #expect(view.trailingAnchor.leq(superview.trailingAnchor).relation == .lessThanOrEqual)
        #expect(view.topAnchor.leq(superview.topAnchor).relation == .lessThanOrEqual)
        #expect(view.bottomAnchor.leq(superview.bottomAnchor).relation == .lessThanOrEqual)
        #expect(view.widthAnchor.leq(superview.widthAnchor).relation == .lessThanOrEqual)
        #expect(view.heightAnchor.leq(superview.heightAnchor).relation == .lessThanOrEqual)
        #expect(view.widthAnchor.leq(20).relation == .lessThanOrEqual)
        #expect(view.heightAnchor.leq(20).relation == .lessThanOrEqual)
        #expect(view.centerYAnchor.leq(superview.centerYAnchor).relation == .lessThanOrEqual)
        #expect(view.centerXAnchor.leq(superview.centerXAnchor).relation == .lessThanOrEqual)
        #expect(view.centerYAnchor.leqBelow(superview.centerYAnchor).relation == .lessThanOrEqual)
        #expect(view.centerXAnchor.leqAfter(superview.centerXAnchor).relation == .lessThanOrEqual)
    }

    @Test func `constraint sugar syntax greater than or equal`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        #expect(view.leadingAnchor.geq(superview.leadingAnchor).relation == .greaterThanOrEqual)
        #expect(view.trailingAnchor.geq(superview.trailingAnchor).relation == .greaterThanOrEqual)
        #expect(view.topAnchor.geq(superview.topAnchor).relation == .greaterThanOrEqual)
        #expect(view.bottomAnchor.geq(superview.bottomAnchor).relation == .greaterThanOrEqual)
        #expect(view.widthAnchor.geq(superview.widthAnchor).relation == .greaterThanOrEqual)
        #expect(view.heightAnchor.geq(superview.heightAnchor).relation == .greaterThanOrEqual)
        #expect(view.widthAnchor.geq(20).relation == .greaterThanOrEqual)
        #expect(view.heightAnchor.geq(20).relation == .greaterThanOrEqual)
        #expect(view.centerYAnchor.geq(superview.centerYAnchor).relation == .greaterThanOrEqual)
        #expect(view.centerXAnchor.geq(superview.centerXAnchor).relation == .greaterThanOrEqual)
        #expect(view.centerYAnchor.geqBelow(superview.centerYAnchor).relation == .greaterThanOrEqual)
        #expect(view.centerXAnchor.geqAfter(superview.centerXAnchor).relation == .greaterThanOrEqual)
    }

    @Test func `pinned to`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.pinned(to: superview).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[0].firstAnchor == view.topAnchor)
        #expect(constraints[1].firstAnchor == view.bottomAnchor)
        #expect(constraints[2].firstAnchor == view.leadingAnchor)
        #expect(constraints[3].firstAnchor == view.trailingAnchor)
    }

    @Test func `pinned to with margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.pinned(to: superview, margin: .init(both: 1)).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[0].firstAnchor == view.topAnchor)
        #expect(constraints[1].firstAnchor == view.bottomAnchor)
        #expect(constraints[2].firstAnchor == view.leadingAnchor)
        #expect(constraints[3].firstAnchor == view.trailingAnchor)
        #expect(constraints[0].constant == 1)
        #expect(constraints[1].constant == -1)
        #expect(constraints[2].constant == 1)
        #expect(constraints[3].constant == -1)
    }

    @Test func `centered on`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.centered(on: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.centerXAnchor)
        #expect(constraints[1].firstAnchor == view.centerYAnchor)
    }

    @Test func `centered on sized`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.centered(on: superview, size: .init(width: 1, height: 1)).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[0].firstAnchor == view.centerXAnchor)
        #expect(constraints[1].firstAnchor == view.centerYAnchor)
        #expect(constraints[2].firstAnchor == view.widthAnchor)
        #expect(constraints[3].firstAnchor == view.heightAnchor)
        #expect(constraints[2].constant == 1)
        #expect(constraints[3].constant == 1)
    }

    @Test func `size equals`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.size(equals: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.widthAnchor)
        #expect(constraints[1].firstAnchor == view.heightAnchor)
    }

    @Test func `size equals float`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.size(equals: 30).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.widthAnchor)
        #expect(constraints[1].firstAnchor == view.heightAnchor)
        #expect(constraints[0].constant == 30)
        #expect(constraints[1].constant == 30)
    }

    @Test func `vertically centered`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.verticallyCentered(on: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.topAnchor)
        #expect(constraints[1].firstAnchor == view.bottomAnchor)
        #expect(constraints[0].constant == 0)
        #expect(constraints[1].constant == 0)
    }

    @Test func `vertically centered margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.verticallyCentered(on: superview, topMargin: 15, bottomMargin: 20).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.topAnchor)
        #expect(constraints[1].firstAnchor == view.bottomAnchor)
        #expect(constraints[0].constant == 15)
        #expect(constraints[1].constant == -20)
    }

    @Test func `hozirontally centered`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.horizontallyCentered(on: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.leadingAnchor)
        #expect(constraints[1].firstAnchor == view.trailingAnchor)
        #expect(constraints[0].constant == 0)
        #expect(constraints[1].constant == 0)
    }

    @Test func `hozirontally centered margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.horizontallyCentered(on: superview, leadingMargin: 15, trailingMargin: 20).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.leadingAnchor)
        #expect(constraints[1].firstAnchor == view.trailingAnchor)
        #expect(constraints[0].constant == 15)
        #expect(constraints[1].constant == -20)
    }
}
#endif

#endif
