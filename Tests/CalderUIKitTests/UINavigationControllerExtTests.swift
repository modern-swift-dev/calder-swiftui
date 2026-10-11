#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(macOS) && !os(watchOS)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit

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

            // MARK: - lastViewController Tests

            @Test func `last view controller empty`() {
                let navController = UINavigationController()
                let top = navController.lastViewController()
                #expect(top == nil)
            }

            @Test func `last view controller single view controller`() {
                let viewController = UIViewController()
                let navController = UINavigationController(rootViewController: viewController)
                let top = navController.lastViewController()
                #expect(top === viewController)
            }

            @Test func `last view controller multiple view controllers`() {
                let firstVC = UIViewController()
                let secondVC = UIViewController()
                let navController = UINavigationController(rootViewController: firstVC)
                navController.pushViewController(secondVC, animated: false)

                let top = navController.lastViewController()
                #expect(top === secondVC)
            }

            @Test func `last view controller after pop`() {
                let firstVC = UIViewController()
                let secondVC = UIViewController()
                let navController = UINavigationController(rootViewController: firstVC)
                navController.pushViewController(secondVC, animated: false)
                navController.popViewController(animated: false)

                let top = navController.lastViewController()
                #expect(top === firstVC)
            }

            @available(*, deprecated)
            @Test func `deprecated topViewController forwards to lastViewController`() {
                let firstVC = UIViewController()
                let secondVC = UIViewController()
                let navController = UINavigationController(rootViewController: firstVC)
                navController.pushViewController(secondVC, animated: false)

                #expect(navController.topViewController() === secondVC)
            }
        }
    #endif

#endif
