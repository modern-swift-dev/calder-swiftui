#if canImport(Darwin)
    #if !os(macOS) && !os(watchOS)

        import Foundation
        import UIKit

        public extension UIViewController {
            /// A completion handler called on the main actor after an animated containment change finishes.
            typealias CompletionHandler = @MainActor () -> Void

            /// Helper method to add a `UIViewController` as a child view controller to a specified container view.
            ///
            /// The child receives `willMove(toParent:)` once, from `addChild(_:)`, before its view is added,
            /// and `didMove(toParent:)` once after its view is in the container.
            /// - Parameters:
            ///   - child: The view controller to add as a child.
            ///   - containerView: The `UIView` that will contain the child view controller's root view.
            func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
                addChild(child)
                containerView.addSubview(child.view)
                child.didMove(toParent: self)
            }

            /// Helper method to remove a `UIViewController` and its view from its parent view controller hierarchy.
            ///
            /// The view controller receives `willMove(toParent:)` once before its view is removed,
            /// and `didMove(toParent:)` once, from `removeFromParent()`, after its view is removed.
            func removeViewAndControllerFromParentViewController() {
                guard parent != nil else {
                    return
                }

                willMove(toParent: nil)
                view.removeFromSuperview()
                removeFromParent()
            }

            /// Transitions from an existing child view controller to a new child view controller with a fade animation.
            /// The new child fills the selected container, including when there is no previous child.
            /// - Parameters:
            ///   - fromChild: The previous child view controller to be removed. If `nil`, the new child will simply fade in.
            ///   - newChild: The new child view controller to add.
            ///   - containerView: An optional view to insert the child in. If `nil`, the parent view controller's root view is used. Defaults to `nil`.
            ///   - duration: The duration of the transition animation. Defaults to 0.5 seconds.
            ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
            ///   - completion: An optional completion handler called on the main actor after the animation finishes
            ///     and the previous child has been removed.
            /// - Returns: The `newChild` view controller.
            @discardableResult func transition(
                fromChild child: UIViewController?,
                toNewChild newChild: UIViewController,
                inContainerView containerView: UIView? = nil,
                duration: TimeInterval = 0.5,
                delay: TimeInterval = 0.0,
                completion: CompletionHandler? = nil
            ) -> UIViewController {

                guard child !== newChild else {
                    return newChild
                }

                // UIKit's containment order: the outgoing child is told first, the incoming child
                // receives `didMove(toParent:)` only after the transition finishes.
                let outgoingChild = child?.parent == nil ? nil : child
                outgoingChild?.willMove(toParent: nil)

                let container: UIView = containerView ?? view
                newChild.view.alpha = 0
                newChild.view.translatesAutoresizingMaskIntoConstraints = false
                addChild(newChild)
                container.addSubview(newChild.view)
                NSLayoutConstraint.activate {
                    newChild.view.pinned(to: container)
                }

                UIView.animateKeyframes(withDuration: duration, delay: delay, options: .beginFromCurrentState, animations: {
                    child?.view.alpha = 0.0
                    newChild.view.alpha = 1.0
                }, completion: { _ in
                    // UIKit calls animation completions on the main thread.
                    MainActor.assumeIsolated {
                        outgoingChild?.view.removeFromSuperview()
                        outgoingChild?.removeFromParent()
                        newChild.didMove(toParent: self)
                        completion?()
                    }
                })
                return newChild
            }

            /// Fades in the view controller's view while adding it to a parent view controller's hierarchy.
            /// - Parameters:
            ///   - parent: The parent view controller to add this view controller to.
            ///   - duration: The duration of the fade-in animation. Defaults to 0.5 seconds.
            ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
            ///   - completion: An optional completion handler called on the main actor after the animation finishes.
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
                    // UIKit calls animation completions on the main thread.
                    MainActor.assumeIsolated {
                        completion?()
                    }
                })
            }

            /// Fades out the view controller's view before removing it from the hierarchy.
            /// - Parameters:
            ///   - duration: The duration of the fade-out animation. Defaults to 0.5 seconds.
            ///   - delay: The delay before starting the animation. Defaults to 0.0 seconds.
            ///   - completion: An optional completion handler called on the main actor after the animation finishes
            ///     and the view controller has been removed.
            func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: CompletionHandler? = nil) {
                UIView.animateKeyframes(withDuration: duration, delay: delay, options: .beginFromCurrentState, animations: {
                    self.view.alpha = 0.0
                }, completion: { _ in
                    // UIKit calls animation completions on the main thread.
                    MainActor.assumeIsolated {
                        self.removeViewAndControllerFromParentViewController()
                        completion?()
                    }
                })
            }
        }
    #endif

#endif
