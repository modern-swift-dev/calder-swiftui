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

            /// Returns the view controller at the top of the navigation stack.
            ///
            /// This is the last element of `viewControllers`. It doesn't look at view controllers
            /// presented modally on top of the stack.
            ///
            /// - Returns: The last `UIViewController` in the `viewControllers` array, or `nil` if empty.
            func lastViewController() -> UIViewController? {
                viewControllers.last
            }

            /// The previous name of ``lastViewController()``.
            ///
            /// Renamed because it's easily confused with UIKit's `topViewController` property.
            @available(*, deprecated, renamed: "lastViewController()")
            func topViewController() -> UIViewController? {
                lastViewController()
            }
        }
    #endif

#endif
