#if canImport(Darwin)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import Foundation
import UIKit

/// Please do not add more logic here, this is used only to force
/// the status bar style according to the child view controller
/// A `UINavigationController` subclass that delegates various appearance settings (status bar, home indicator,
/// and system gestures) to its `topViewController`.
/// This class is intended to solely handle appearance delegation and should not contain additional logic.
open class DelegatingNavigationController: UINavigationController {
    /// The child view controller that determines the preferred status bar style.
    override public var childForStatusBarStyle: UIViewController? {
        topViewController
    }

    /// The child view controller that determines whether the status bar is hidden.
    override public var childForStatusBarHidden: UIViewController? {
        topViewController
    }

    /// The child view controller that determines the preferred screen edges for deferring system gestures.
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        topViewController
    }

    /// The child view controller that determines whether the home indicator is automatically hidden.
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        topViewController
    }

    /// Sets the view controllers for the navigation stack.
    /// After setting the view controllers, this method forces an update of the status bar appearance,
    /// screen edges deferring system gestures, and home indicator auto-hidden state.
    /// - Parameters:
    ///   - viewControllers: An array of `UIViewController` objects to place in the navigation stack.
    ///   - animated: A Boolean value indicating whether the change should be animated.
    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        setNeedsStatusBarAppearanceUpdate()
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
}
#endif

#endif
