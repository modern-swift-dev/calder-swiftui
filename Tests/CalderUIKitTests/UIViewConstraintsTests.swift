#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIViewConstraintsTests {

    // MARK: - pinned Tests

    @Test func `pinned to view`() {
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

    @Test func `pinned to layout guide`() {
        let superview = UIView()
        let view = UIView()
        let guide = UILayoutGuide()
        superview.addSubview(view)
        superview.addLayoutGuide(guide)

        let constraints = view.pinned(to: guide).asConstraints

        #expect(constraints.count == 4)
    }

    @Test func `pinned with trailing priority`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.pinned(to: superview, margin: .zero, trailingConstraintPriority: .defaultHigh).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[1].priority == .defaultHigh)
        #expect(constraints[3].priority == .defaultHigh)
    }

    @Test func `pinned with almost required priority`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.pinned(to: superview, margin: .init(both: 10), trailingConstraintPriority: .almostRequired).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[1].priority == .almostRequired)
    }

    // MARK: - size Tests

    @Test func `size equals CG size`() {
        let view = UIView()
        let size = CGSize(width: 100, height: 50)

        let constraints = view.size(equals: size).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 100)
        #expect(constraints[1].constant == 50)
    }

    @Test func `size equals CG float`() {
        let view = UIView()

        let constraints = view.size(equals: 75).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 75)
        #expect(constraints[1].constant == 75)
    }

    @Test func `size equals guide`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.size(equals: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.widthAnchor)
        #expect(constraints[1].firstAnchor == view.heightAnchor)
    }

    // MARK: - centered Tests

    @Test func `centered basic`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.centered(on: superview).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].firstAnchor == view.centerXAnchor)
        #expect(constraints[1].firstAnchor == view.centerYAnchor)
    }

    @Test func `centered with nil size`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.centered(on: superview, size: nil).asConstraints

        #expect(constraints.count == 2)
    }

    @Test func `centered with size`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.centered(on: superview, size: CGSize(width: 50, height: 50)).asConstraints

        #expect(constraints.count == 4)
        #expect(constraints[2].constant == 50)
        #expect(constraints[3].constant == 50)
    }

    // MARK: - verticallyCentered Tests

    @Test func `vertically centered basic`() {
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

    @Test func `vertically centered with margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.verticallyCentered(on: superview, margin: 10).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 10)
        #expect(constraints[1].constant == -10)
    }

    @Test func `vertically centered with top and bottom margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.verticallyCentered(on: superview, topMargin: 5, bottomMargin: 15).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 5)
        #expect(constraints[1].constant == -15)
    }

    // MARK: - horizontallyCentered Tests

    @Test func `horizontally centered basic`() {
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

    @Test func `horizontally centered with margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.horizontallyCentered(on: superview, margin: 20).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 20)
        #expect(constraints[1].constant == -20)
    }

    @Test func `horizontally centered with leading and trailing margin`() {
        let superview = UIView()
        let view = UIView()
        superview.addSubview(view)

        let constraints = view.horizontallyCentered(on: superview, leadingMargin: 8, trailingMargin: 16).asConstraints

        #expect(constraints.count == 2)
        #expect(constraints[0].constant == 8)
        #expect(constraints[1].constant == -16)
    }
}
#endif

#endif
