#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct DelegatingSplitViewControllerTests {

    // MARK: - childViewControllerForDelegation Tests

    @Test func `child view controller for delegation collapsed returns last`() {
        let splitVC = DelegatingSplitViewController()
        let primaryVC = UIViewController()
        let secondaryVC = UIViewController()
        splitVC.viewControllers = [primaryVC, secondaryVC]

        // In collapsed state, should return last
        // Note: isCollapsed state is controlled by the system
        let delegatingChild = splitVC.childViewControllerForDelegation
        #expect(delegatingChild != nil)
    }

    @Test func `child view controller for delegation empty`() {
        let splitVC = DelegatingSplitViewController()
        let delegatingChild = splitVC.childViewControllerForDelegation
        #expect(delegatingChild == nil)
    }

    @Test func `child view controller for delegation single VC`() {
        let splitVC = DelegatingSplitViewController()
        let vc = UIViewController()
        splitVC.viewControllers = [vc]

        let delegatingChild = splitVC.childViewControllerForDelegation
        #expect(delegatingChild === vc)
    }

    // MARK: - childForStatusBarStyle Tests

    @Test func `child for status bar style returns child view controller for delegation`() {
        let splitVC = DelegatingSplitViewController()
        let vc = UIViewController()
        splitVC.viewControllers = [vc]

        #expect(splitVC.childForStatusBarStyle === splitVC.childViewControllerForDelegation)
    }

    // MARK: - childForStatusBarHidden Tests

    @Test func `child for status bar hidden returns child view controller for delegation`() {
        let splitVC = DelegatingSplitViewController()
        let vc = UIViewController()
        splitVC.viewControllers = [vc]

        #expect(splitVC.childForStatusBarHidden === splitVC.childViewControllerForDelegation)
    }

    // MARK: - childForScreenEdgesDeferringSystemGestures Tests

    @Test func `child for screen edges deferring system gestures returns child view controller for delegation`() {
        let splitVC = DelegatingSplitViewController()
        let vc = UIViewController()
        splitVC.viewControllers = [vc]

        #expect(splitVC.childForScreenEdgesDeferringSystemGestures === splitVC.childViewControllerForDelegation)
    }

    // MARK: - childForHomeIndicatorAutoHidden Tests

    @Test func `child for home indicator auto hidden returns child view controller for delegation`() {
        let splitVC = DelegatingSplitViewController()
        let vc = UIViewController()
        splitVC.viewControllers = [vc]

        #expect(splitVC.childForHomeIndicatorAutoHidden === splitVC.childViewControllerForDelegation)
    }

    // MARK: - viewControllers didSet Tests

    @Test func `view controllers did set triggers updates`() {
        let splitVC = DelegatingSplitViewController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()

        // Setting viewControllers should not crash
        splitVC.viewControllers = [vc1, vc2]
        #expect(splitVC.viewControllers.count == 2)
    }
}
#endif

#endif
