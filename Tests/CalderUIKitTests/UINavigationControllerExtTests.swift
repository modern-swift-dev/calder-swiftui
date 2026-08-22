#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UINavigationControllerExtTests {

    // MARK: - rootViewController Tests

    @Test func `root view controller empty`() {
        let navController = UINavigationController()
        let root = navController.rootViewController()
        #expect(root == nil)
    }

    @Test func `root view controller single view controller`() {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        let root = navController.rootViewController()
        #expect(root === viewController)
    }

    @Test func `root view controller multiple view controllers`() {
        let firstVC = UIViewController()
        let secondVC = UIViewController()
        let navController = UINavigationController(rootViewController: firstVC)
        navController.pushViewController(secondVC, animated: false)

        let root = navController.rootViewController()
        #expect(root === firstVC)
    }

    // MARK: - topViewController Tests

    @Test func `top view controller empty`() {
        let navController = UINavigationController()
        let top = navController.topViewController()
        #expect(top == nil)
    }

    @Test func `top view controller single view controller`() {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        let top = navController.topViewController()
        #expect(top === viewController)
    }

    @Test func `top view controller multiple view controllers`() {
        let firstVC = UIViewController()
        let secondVC = UIViewController()
        let navController = UINavigationController(rootViewController: firstVC)
        navController.pushViewController(secondVC, animated: false)

        let top = navController.topViewController()
        #expect(top === secondVC)
    }

    @Test func `top view controller after pop`() {
        let firstVC = UIViewController()
        let secondVC = UIViewController()
        let navController = UINavigationController(rootViewController: firstVC)
        navController.pushViewController(secondVC, animated: false)
        navController.popViewController(animated: false)

        let top = navController.topViewController()
        #expect(top === firstVC)
    }
}
#endif

#endif
