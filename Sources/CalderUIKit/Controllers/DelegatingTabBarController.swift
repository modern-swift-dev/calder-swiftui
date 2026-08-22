#if canImport(Darwin)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import UIKit

/// A `UITabBarController` subclass that delegates various appearance settings (status bar, home indicator,
/// and system gestures) to its `selectedViewController`.
open class DelegatingTabBarController: UITabBarController {
    /// The currently selected view controller.
    /// Setting this property automatically triggers an update for status bar appearance, home indicator visibility,
    /// and screen edges deferring system gestures.
    override open var selectedViewController: UIViewController? {
        didSet {
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// The child view controller that determines the preferred status bar style.
    override public var childForStatusBarStyle: UIViewController? {
        selectedViewController
    }

    /// The child view controller that determines whether the status bar is hidden.
    override public var childForStatusBarHidden: UIViewController? {
        selectedViewController
    }

    /// The child view controller that determines the preferred screen edges for deferring system gestures.
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        selectedViewController
    }

    /// The child view controller that determines whether the home indicator is automatically hidden.
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        selectedViewController
    }
}
#endif

#endif
