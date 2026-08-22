#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

public extension UINavigationController {

    /// Returns the root view controller of the navigation stack.
    /// - Returns: The first `UIViewController` in the `viewControllers` array, or `nil` if empty.
    func rootViewController() -> UIViewController? {
        viewControllers.first
    }

    /// Returns the top view controller currently on the navigation stack.
    /// - Returns: The last `UIViewController` in the `viewControllers` array, or `nil` if empty.
    func topViewController() -> UIViewController? {
        viewControllers.last
    }
}
#endif

#endif
