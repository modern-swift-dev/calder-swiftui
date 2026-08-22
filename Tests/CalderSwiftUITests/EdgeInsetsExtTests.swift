#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(SwiftUI)
@testable import CalderSwiftUI
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct EdgeInsetsExtTests {

    // MARK: - Zero

    @Test func `zero edge insets`() {
        let insets = EdgeInsets.zero
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }

    // MARK: - Init with vertical

    @Test func `init with vertical`() {
        let insets = EdgeInsets(vertical: 10)
        #expect(insets.top == 10)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 10)
        #expect(insets.trailing == 0)
    }

    @Test func `init with vertical zero`() {
        let insets = EdgeInsets(vertical: 0)
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }

    // MARK: - Init with horizontal

    @Test func `init with horizontal`() {
        let insets = EdgeInsets(horizontal: 15)
        #expect(insets.top == 0)
        #expect(insets.leading == 15)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 15)
    }

    @Test func `init with horizontal zero`() {
        let insets = EdgeInsets(horizontal: 0)
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }

    // MARK: - Init with vertical and horizontal

    @Test func `init with vertical and horizontal`() {
        let insets = EdgeInsets(vertical: 10, horizontal: 20)
        #expect(insets.top == 10)
        #expect(insets.leading == 20)
        #expect(insets.bottom == 10)
        #expect(insets.trailing == 20)
    }

    @Test func `init with vertical and horizontal different values`() {
        let insets = EdgeInsets(vertical: 5, horizontal: 15)
        #expect(insets.top == 5)
        #expect(insets.leading == 15)
        #expect(insets.bottom == 5)
        #expect(insets.trailing == 15)
    }

    // MARK: - Init with all

    @Test func `init with all`() {
        let insets = EdgeInsets(all: 25)
        #expect(insets.top == 25)
        #expect(insets.leading == 25)
        #expect(insets.bottom == 25)
        #expect(insets.trailing == 25)
    }

    @Test func `init with all zero`() {
        let insets = EdgeInsets(all: 0)
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }

    // MARK: - CGFloat asEdgeInsets

    @Test func `cg float as edge insets`() {
        let value: CGFloat = 12
        let insets = value.asEdgeInsets
        #expect(insets.top == 12)
        #expect(insets.leading == 12)
        #expect(insets.bottom == 12)
        #expect(insets.trailing == 12)
    }

    @Test func `cg float zero as edge insets`() {
        let value: CGFloat = 0
        let insets = value.asEdgeInsets
        #expect(insets.top == 0)
        #expect(insets.leading == 0)
        #expect(insets.bottom == 0)
        #expect(insets.trailing == 0)
    }

    @Test func `cg float negative as edge insets`() {
        let value: CGFloat = -5
        let insets = value.asEdgeInsets
        #expect(insets.top == -5)
        #expect(insets.leading == -5)
        #expect(insets.bottom == -5)
        #expect(insets.trailing == -5)
    }

    @Test func `cg float decimal as edge insets`() {
        let value: CGFloat = 7.5
        let insets = value.asEdgeInsets
        #expect(insets.top == 7.5)
        #expect(insets.leading == 7.5)
        #expect(insets.bottom == 7.5)
        #expect(insets.trailing == 7.5)
    }
}
#endif

#endif
