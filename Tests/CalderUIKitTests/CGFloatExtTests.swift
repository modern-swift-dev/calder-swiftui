#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(CoreGraphics)
import CalderUIKit
import CoreGraphics
import Foundation
import Testing

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

@Suite(.serialized) struct CGFloatExtTests {

    // MARK: - CGFloat+Ext Tests

    @Test func `size returns CG size with equal width and height`() {
        let value: CGFloat = 42.0
        let result = value.size
        #expect(result.width == 42.0)
        #expect(result.height == 42.0)
    }

    @Test func `size with zero`() {
        let value: CGFloat = 0.0
        let result = value.size
        #expect(result.width == 0.0)
        #expect(result.height == 0.0)
    }

    @Test func `point returns CG point with equal X and Y`() {
        let value: CGFloat = 15.5
        let result = value.point
        #expect(result.x == 15.5)
        #expect(result.y == 15.5)
    }

    @Test func `point with negative value`() {
        let value: CGFloat = -10.0
        let result = value.point
        #expect(result.x == -10.0)
        #expect(result.y == -10.0)
    }

    @Test func `rect returns CG rect with zero origin and equal size`() {
        let value: CGFloat = 100.0
        let result = value.rect
        #expect(result.origin == .zero)
        #expect(result.size.width == 100.0)
        #expect(result.size.height == 100.0)
    }

    @Test func `debug description formats correctly`() {
        let value: CGFloat = 25.5
        #expect(value.debugDescription == "CGFloat(25.5)")
    }

    #if canImport(UIKit) && !os(watchOS)
    @Test func `ui edge inset returns uniform edge insets`() {
        let value: CGFloat = 10.0
        let result = value.uiEdgeInset
        #expect(result.top == 10.0)
        #expect(result.left == 10.0)
        #expect(result.bottom == 10.0)
        #expect(result.right == 10.0)
    }

    @Test func `directional edge inset returns uniform directional insets`() {
        let value: CGFloat = 8.0
        let result = value.directionalEdgeInset
        #expect(result.top == 8.0)
        #expect(result.leading == 8.0)
        #expect(result.bottom == 8.0)
        #expect(result.trailing == 8.0)
    }
    #endif

    #if canImport(SwiftUI)
    @Test func `edge inset returns uniform swift UI edge insets`() {
        let value: CGFloat = 12.0
        let result = value.edgeInset
        #expect(result.top == 12.0)
        #expect(result.leading == 12.0)
        #expect(result.bottom == 12.0)
        #expect(result.trailing == 12.0)
    }
    #endif

    // MARK: - CGFloat+Spacing Tests

    @Test func `spacing xxxs`() {
        #expect(CGFloat.xxxs == 2.0)
    }

    @Test func `spacing xxs`() {
        #expect(CGFloat.xxs == 4.0)
    }

    @Test func `spacing xs`() {
        #expect(CGFloat.xs == 8.0)
    }

    @Test func `spacing small`() {
        #expect(CGFloat.small == 12.0)
    }

    @Test func `spacing medium`() {
        #expect(CGFloat.medium == 16.0)
    }

    @Test func `spacing large`() {
        #expect(CGFloat.large == 24.0)
    }

    @Test func `spacing xl`() {
        #expect(CGFloat.xl == 32.0)
    }

    @Test func `spacing xxl`() {
        #expect(CGFloat.xxl == 48.0)
    }

    @Test func `spacing xxxl`() {
        #expect(CGFloat.xxxl == 60.0)
    }
}
#endif

#endif
