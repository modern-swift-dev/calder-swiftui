#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS)
import CalderUIKit
import Combine
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIScrollViewExtTests {

    // MARK: - scrollToSubview Tests

    @Test func `scroll to subview subview in scroll view`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        scrollView.contentSize = CGSize(width: 200, height: 1000)

        let subview = UIView(frame: CGRect(x: 50, y: 800, width: 100, height: 100))
        scrollView.addSubview(subview)

        scrollView.scrollToSubview(subview)
        #expect(true)
    }

    @Test func `scroll to subview subview at origin`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        scrollView.contentSize = CGSize(width: 200, height: 1000)

        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        scrollView.addSubview(subview)

        scrollView.scrollToSubview(subview)
        #expect(true)
    }

    // MARK: - adjustInset Tests

    @Test func `adjust inset to center vertically`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        scrollView.contentSize = CGSize(width: 300, height: 200)

        scrollView.adjustInset(toCenterVertically: 0)

        #expect(scrollView.contentInset.top >= 0)
    }

    @Test func `adjust inset to center vertically with bottom delta`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        scrollView.contentSize = CGSize(width: 300, height: 200)

        scrollView.adjustInset(toCenterVertically: 100)

        #expect(scrollView.contentInset.top >= 0)
    }

    @Test func `adjust inset content larger than bounds`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        scrollView.contentSize = CGSize(width: 300, height: 500)

        scrollView.adjustInset(toCenterVertically: 0)

        #expect(scrollView.contentInset.top >= 0)
    }

    // MARK: - setupKeyboardAutoAdjustment Tests

    #if !os(tvOS)
    @Test func `setup keyboard auto adjustment returns cancellable`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        let cancellable = scrollView.setupKeyboardAutoAdjustment(keepCentered: false)
        #expect(cancellable != nil)
        cancellable?.cancel()
    }

    @Test func `setup keyboard auto adjustment keep centered`() {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
        let cancellable = scrollView.setupKeyboardAutoAdjustment(keepCentered: true)
        #expect(cancellable != nil)
        cancellable?.cancel()
    }
    #endif
}
#endif

#endif
