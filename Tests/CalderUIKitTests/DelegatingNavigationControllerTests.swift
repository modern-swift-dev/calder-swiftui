#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct DelegatingNavigationControllerTests {

    // MARK: - Initialization

    @Test func `init empty`() {
        let nav = DelegatingNavigationController()
        #expect(nav.viewControllers.isEmpty)
        #expect(nav.topViewController == nil)
    }

    @Test func `init with root view controller`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        #expect(nav.viewControllers.count == 1)
        #expect(nav.topViewController === root)
    }

    // MARK: - Child View Controller Delegation

    @Test func `child for status bar style returns top view controller`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        #expect(nav.childForStatusBarStyle === root)
    }

    @Test func `child for status bar style nil when empty`() {
        let nav = DelegatingNavigationController()
        #expect(nav.childForStatusBarStyle == nil)
    }

    @Test func `child for status bar hidden returns top view controller`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        #expect(nav.childForStatusBarHidden === root)
    }

    @Test func `child for screen edges deferring system gestures returns top view controller`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        #expect(nav.childForScreenEdgesDeferringSystemGestures === root)
    }

    @Test func `child for home indicator auto hidden returns top view controller`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        #expect(nav.childForHomeIndicatorAutoHidden === root)
    }

    // MARK: - setViewControllers

    @Test func `set view controllers updates stack`() {
        let nav = DelegatingNavigationController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        nav.setViewControllers([vc1, vc2], animated: false)
        #expect(nav.viewControllers.count == 2)
        #expect(nav.topViewController === vc2)
    }

    @Test func `set view controllers empty array`() {
        let root = UIViewController()
        let nav = DelegatingNavigationController(rootViewController: root)
        nav.setViewControllers([], animated: false)
        #expect(nav.viewControllers.isEmpty)
    }

    @Test func `child for status bar style updates after set view controllers`() {
        let nav = DelegatingNavigationController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        nav.setViewControllers([vc1, vc2], animated: false)
        #expect(nav.childForStatusBarStyle === vc2)
    }
}
#endif

#endif
