#if canImport(Darwin)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import UIKit

/// A `UISplitViewController` subclass that delegates various appearance settings (status bar, home indicator,
/// and system gestures) to a chosen child view controller based on its current display mode and collapse state.
open class DelegatingSplitViewController: UISplitViewController {
    /// The child view controller that is chosen to delegate appearance settings.
    /// In a collapsed state, it defaults to the last view controller.
    /// When display mode is `.oneOverSecondary`, it defaults to the first view controller (primary).
    /// Otherwise, it defaults to the last view controller (secondary).
    open var childViewControllerForDelegation: UIViewController? {
        if isCollapsed {
            return viewControllers.last
        }

        if displayMode == .oneOverSecondary {
            return viewControllers.first
        }

        return viewControllers.last
    }

    /// The array of view controllers currently managed by the split view controller.
    /// Setting this property automatically triggers an update for status bar appearance, home indicator visibility,
    /// and screen edges deferring system gestures.
    override open var viewControllers: [UIViewController] {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    /// The child view controller that determines the preferred status bar style.
    override public var childForStatusBarStyle: UIViewController? {
        childViewControllerForDelegation
    }

    /// The child view controller that determines whether the status bar is hidden.
    override public var childForStatusBarHidden: UIViewController? {
        childViewControllerForDelegation
    }

    /// The child view controller that determines the preferred screen edges for deferring system gestures.
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        childViewControllerForDelegation
    }

    /// The child view controller that determines whether the home indicator is automatically hidden.
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        childViewControllerForDelegation
    }
}
#endif

#endif
