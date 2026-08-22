#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)

import Foundation
import UIKit

public extension UIViewController {
    /// A type alias for a common completion handler closure.
    typealias CompletionHandler = @Sendable () -> Void

    /// Helper method to add a `UIViewController` as a child view controller to a specified container view.
    /// - Parameters:
    ///   - child: The view controller to add as a child.
    ///   - containerView: The `UIView` that will contain the child view controller's root view.
    func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
        child.willMove(toParent: self)
        addChild(child)
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Helper method to remove a `UIViewController` and its view from its parent view controller hierarchy.
    func removeViewAndControllerFromParentViewController() {
        guard parent != nil else {
            return
        }

        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
        didMove(toParent: nil)
    }

    /// Transitions from an existing child view controller to a new child view controller with a fade animation.
    /// - Parameters:
    ///   - fromChild: The previous child view controller to be removed. If `nil`, the new child will simply fade in.
    ///   - newChild: The new child view controller to add.
    ///   - containerView: An optional view to insert the child in. If `nil`, the parent view controller's root view is used. Defaults to `nil`.
    ///   - duration: The duration of the transition animation. Defaults to 0.5 seconds.
    ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
    ///   - completion: An optional completion handler to call after the animation finishes.
    /// - Returns: The `newChild` view controller.
    @discardableResult func transition(
        fromChild child: UIViewController?,
        toNewChild newChild: UIViewController,
        inContainerView containerView: UIView? = nil,
        duration: TimeInterval = 0.5,
        delay: TimeInterval = 0.0,
        completion: CompletionHandler? = nil
    ) -> UIViewController {

        guard let child else {
            newChild.fadeIn(in: self, duration: duration, delay: delay, completion: completion)
            return newChild
        }

        guard child != newChild else {
            return child
        }

        newChild.view.alpha = 0
        addChildViewController(newChild, toContainerView: containerView ?? view)
        NSLayoutConstraint.activate {
            newChild.view.pinned(to: containerView ?? view)
        }

        UIView.animateKeyframes(withDuration: duration, delay: delay, options: .beginFromCurrentState, animations: {
            child.view.alpha = 0.0
            newChild.view.alpha = 1.0
        }, completion: { _ in
            Task { @MainActor in
                child.removeViewAndControllerFromParentViewController()
            }
            completion?()
        })
        return newChild
    }

    /// Fades in the view controller's view while adding it to a parent view controller's hierarchy.
    /// - Parameters:
    ///   - parent: The parent view controller to add this view controller to.
    ///   - duration: The duration of the fade-in animation. Defaults to 0.5 seconds.
    ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
    ///   - completion: An optional completion handler to call after the animation finishes.
    func fadeIn(
        in parent: UIViewController,
        duration: TimeInterval = 0.5,
        delay: TimeInterval = 0.0,
        completion: CompletionHandler? = nil
    ) {
        view.alpha = 0
        parent.addChildViewController(self, toContainerView: parent.view)
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: .beginFromCurrentState, animations: {
            self.view.alpha = 1.0
        }, completion: { _ in
            completion?()
        })
    }

    /// Fades out the view controller's view before removing it from the hierarchy.
    /// - Parameters:
    ///   - duration: The duration of the fade-out animation. Defaults to 0.5 seconds.
    ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
    ///   - completion: An optional completion handler to call after the animation finishes.
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: CompletionHandler? = nil) {
        UIView.animateKeyframes(withDuration: duration, delay: delay, options: .beginFromCurrentState, animations: {
            self.view.alpha = 0.0
        }, completion: { _ in
            Task { @MainActor in
                self.removeViewAndControllerFromParentViewController()
            }
            completion?()
        })
    }
}
#endif

#endif
