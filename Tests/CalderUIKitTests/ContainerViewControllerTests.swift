#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct ContainerViewControllerTests {

    // MARK: - Initialization

    @Test func `init current view controller is nil`() {
        let container = ContainerViewController()
        #expect(container.currentViewController == nil)
    }

    // MARK: - currentViewController

    @Test func `set current view controller updates value`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        #expect(container.currentViewController === child)
    }

    @Test func `set current view controller can be set to nil`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        container.currentViewController = nil
        #expect(container.currentViewController == nil)
    }

    @Test func `set current view controller can be changed`() {
        let container = ContainerViewController()
        let child1 = UIViewController()
        let child2 = UIViewController()
        container.currentViewController = child1
        container.currentViewController = child2
        #expect(container.currentViewController === child2)
    }

    // MARK: - Child View Controller Delegation

    @Test func `child for status bar style returns current view controller`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        #expect(container.childForStatusBarStyle === child)
    }

    @Test func `child for status bar style nil when no current view controller`() {
        let container = ContainerViewController()
        #expect(container.childForStatusBarStyle == nil)
    }

    @Test func `child for status bar hidden returns current view controller`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        #expect(container.childForStatusBarHidden === child)
    }

    @Test func `child for screen edges deferring system gestures returns current view controller`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        #expect(container.childForScreenEdgesDeferringSystemGestures === child)
    }

    @Test func `child for home indicator auto hidden returns current view controller`() {
        let container = ContainerViewController()
        let child = UIViewController()
        container.currentViewController = child
        #expect(container.childForHomeIndicatorAutoHidden === child)
    }
}
#endif

#endif
