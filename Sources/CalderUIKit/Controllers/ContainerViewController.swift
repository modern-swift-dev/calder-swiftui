#if canImport(Darwin)
#if !os(macOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
import UIKit

/// A base view controller that allows its `currentViewController` to dictate various appearance settings
/// such as status bar style, status bar hidden state, screen edges deferring system gestures, and home indicator auto-hidden state.
open class ContainerViewController: UIViewController {
    /// The currently active view controller that delegates its appearance settings to the system.
    /// Setting this property automatically triggers an update for status bar appearance, home indicator visibility,
    /// and screen edges deferring system gestures.
    open var currentViewController: UIViewController? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }

    /// The child view controller that determines the preferred status bar style.
    override public var childForStatusBarStyle: UIViewController? {
        currentViewController
    }

    /// The child view controller that determines whether the status bar is hidden.
    override public var childForStatusBarHidden: UIViewController? {
        currentViewController
    }

    /// The child view controller that determines the preferred screen edges for deferring system gestures.
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        currentViewController
    }

    /// The child view controller that determines whether the home indicator is automatically hidden.
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        currentViewController
    }
}
#endif

#endif
