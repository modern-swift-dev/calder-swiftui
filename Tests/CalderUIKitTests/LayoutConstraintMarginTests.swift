#if canImport(CoreGraphics)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

@Suite(.serialized) struct LayoutConstraintMarginTests {

    // MARK: - Static Properties

    @Test func `zero has all zero margins`() {
        let margin = LayoutConstraintMargin.zero
        #expect(margin.top == 0)
        #expect(margin.bottom == 0)
        #expect(margin.leading == 0)
        #expect(margin.trailing == 0)
    }

    // MARK: - Full Initializer

    @Test func `init with all values`() {
        let margin = LayoutConstraintMargin(
            top: 10,
            leading: 20,
            bottom: 30,
            trailing: 40
        )
        #expect(margin.top == 10)
        #expect(margin.leading == 20)
        #expect(margin.bottom == 30)
        #expect(margin.trailing == 40)
    }

    @Test func `init with negative values`() {
        let margin = LayoutConstraintMargin(
            top: -5,
            leading: -10,
            bottom: -15,
            trailing: -20
        )
        #expect(margin.top == -5)
        #expect(margin.leading == -10)
        #expect(margin.bottom == -15)
        #expect(margin.trailing == -20)
    }

    // MARK: - Vertical Initializer

    @Test func `init vertical sets top and bottom`() {
        let margin = LayoutConstraintMargin(vertical: 20)
        #expect(margin.top == 20)
        #expect(margin.bottom == 20)
        #expect(margin.leading == 0)
        #expect(margin.trailing == 0)
    }

    @Test func `init vertical with divider`() {
        let margin = LayoutConstraintMargin(vertical: 20, divider: 2)
        #expect(margin.top == 10)
        #expect(margin.bottom == 10)
        #expect(margin.leading == 0)
        #expect(margin.trailing == 0)
    }

    @Test func `init vertical default divider`() {
        let margin = LayoutConstraintMargin(vertical: 30)
        #expect(margin.top == 30)
        #expect(margin.bottom == 30)
    }

    // MARK: - Horizontal Initializer

    @Test func `init horizontal sets leading and trailing`() {
        let margin = LayoutConstraintMargin(horizontal: 15)
        #expect(margin.top == 0)
        #expect(margin.bottom == 0)
        #expect(margin.leading == 15)
        #expect(margin.trailing == 15)
    }

    @Test func `init horizontal with divider`() {
        let margin = LayoutConstraintMargin(horizontal: 30, divider: 2)
        #expect(margin.leading == 15)
        #expect(margin.trailing == 15)
    }

    @Test func `init horizontal default divider`() {
        let margin = LayoutConstraintMargin(horizontal: 24)
        #expect(margin.leading == 24)
        #expect(margin.trailing == 24)
    }

    // MARK: - Both Initializer

    @Test func `init both sets all sides`() {
        let margin = LayoutConstraintMargin(both: 10)
        #expect(margin.top == 10)
        #expect(margin.bottom == 10)
        #expect(margin.leading == 10)
        #expect(margin.trailing == 10)
    }

    @Test func `init both with divider`() {
        let margin = LayoutConstraintMargin(both: 40, divider: 2)
        #expect(margin.top == 20)
        #expect(margin.bottom == 20)
        #expect(margin.leading == 20)
        #expect(margin.trailing == 20)
    }

    @Test func `init both zero value`() {
        let margin = LayoutConstraintMargin(both: 0)
        #expect(margin.top == 0)
        #expect(margin.bottom == 0)
        #expect(margin.leading == 0)
        #expect(margin.trailing == 0)
    }

    // MARK: - Horizontal/Vertical Initializer

    @Test func `init horizontal vertical sets both directions`() {
        let margin = LayoutConstraintMargin(horizontal: 10, vertical: 20)
        #expect(margin.top == 20)
        #expect(margin.bottom == 20)
        #expect(margin.leading == 10)
        #expect(margin.trailing == 10)
    }

    @Test func `init horizontal vertical with divider`() {
        let margin = LayoutConstraintMargin(horizontal: 20, vertical: 40, divider: 2)
        #expect(margin.top == 20)
        #expect(margin.bottom == 20)
        #expect(margin.leading == 10)
        #expect(margin.trailing == 10)
    }

    @Test func `init horizontal vertical different values`() {
        let margin = LayoutConstraintMargin(horizontal: 16, vertical: 8)
        #expect(margin.top == 8)
        #expect(margin.bottom == 8)
        #expect(margin.leading == 16)
        #expect(margin.trailing == 16)
    }

    // MARK: - Sendable Conformance

    @Test func `margin is sendable`() async {
        let margin = LayoutConstraintMargin(both: 10)
        let task = Task {
            margin.top
        }
        #expect(await task.value == 10)
    }

    // MARK: - Edge Cases

    @Test func `init with fractional values`() {
        let margin = LayoutConstraintMargin(both: 15.5)
        #expect(margin.top == 15.5)
        #expect(margin.bottom == 15.5)
        #expect(margin.leading == 15.5)
        #expect(margin.trailing == 15.5)
    }

    @Test func `init with large values`() {
        let margin = LayoutConstraintMargin(both: 1000)
        #expect(margin.top == 1000)
        #expect(margin.bottom == 1000)
        #expect(margin.leading == 1000)
        #expect(margin.trailing == 1000)
    }
}
#endif
