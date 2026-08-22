#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct DelegatingTabBarControllerTests {

    // MARK: - selectedViewController Tests

    @Test func `selected view controller default`() {
        let tabBarController = DelegatingTabBarController()
        #expect(tabBarController.selectedViewController == nil)
    }

    @Test func `selected view controller with tabs`() {
        let tabBarController = DelegatingTabBarController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        tabBarController.viewControllers = [vc1, vc2]

        #expect(tabBarController.selectedViewController === vc1)
    }

    @Test func `selected view controller can change`() {
        let tabBarController = DelegatingTabBarController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        tabBarController.viewControllers = [vc1, vc2]

        tabBarController.selectedViewController = vc2
        #expect(tabBarController.selectedViewController === vc2)
    }

    // MARK: - childForStatusBarStyle Tests

    @Test func `child for status bar style returns selected view controller`() {
        let tabBarController = DelegatingTabBarController()
        let vc = UIViewController()
        tabBarController.viewControllers = [vc]

        #expect(tabBarController.childForStatusBarStyle === tabBarController.selectedViewController)
    }

    // MARK: - childForStatusBarHidden Tests

    @Test func `child for status bar hidden returns selected view controller`() {
        let tabBarController = DelegatingTabBarController()
        let vc = UIViewController()
        tabBarController.viewControllers = [vc]

        #expect(tabBarController.childForStatusBarHidden === tabBarController.selectedViewController)
    }

    // MARK: - childForScreenEdgesDeferringSystemGestures Tests

    @Test func `child for screen edges deferring system gestures returns selected view controller`() {
        let tabBarController = DelegatingTabBarController()
        let vc = UIViewController()
        tabBarController.viewControllers = [vc]

        #expect(tabBarController.childForScreenEdgesDeferringSystemGestures === tabBarController.selectedViewController)
    }

    // MARK: - childForHomeIndicatorAutoHidden Tests

    @Test func `child for home indicator auto hidden returns selected view controller`() {
        let tabBarController = DelegatingTabBarController()
        let vc = UIViewController()
        tabBarController.viewControllers = [vc]

        #expect(tabBarController.childForHomeIndicatorAutoHidden === tabBarController.selectedViewController)
    }

    // MARK: - didSet behavior Tests

    @Test func `selected view controller did set triggers updates`() {
        let tabBarController = DelegatingTabBarController()
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        tabBarController.viewControllers = [vc1, vc2]

        // Changing selected VC should not crash and should update properly
        tabBarController.selectedViewController = vc2
        tabBarController.selectedViewController = vc1
        #expect(tabBarController.selectedViewController === vc1)
    }
}
#endif

#endif
