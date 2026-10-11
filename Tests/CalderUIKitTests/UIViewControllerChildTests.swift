#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(macOS) && !os(watchOS)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit

        @Suite(.serialized)
        @MainActor struct UIViewControllerChildTests {
            /// Records containment callbacks and whether its view was in a hierarchy at each callback.
            private final class ContainmentRecorder: UIViewController {
                enum Event: Equatable {
                    case willMove(toParent: Bool)
                    case didMove(toParent: Bool, viewAttached: Bool)
                }

                var events: [Event] = []

                override func willMove(toParent parent: UIViewController?) {
                    super.willMove(toParent: parent)
                    events.append(.willMove(toParent: parent != nil))
                }

                override func didMove(toParent parent: UIViewController?) {
                    super.didMove(toParent: parent)
                    events.append(.didMove(toParent: parent != nil, viewAttached: viewIfLoaded?.superview != nil))
                }
            }

            // MARK: - addChildViewController Tests

            @Test func `add child view controller adds to parent`() {
                let parent = UIViewController()
                let child = UIViewController()
                let containerView = UIView()
                parent.view.addSubview(containerView)

                parent.addChildViewController(child, toContainerView: containerView)

                #expect(child.parent === parent)
                #expect(parent.children.contains(child))
            }

            @Test func `add child view controller adds view to container`() {
                let parent = UIViewController()
                let child = UIViewController()
                let containerView = UIView()
                parent.view.addSubview(containerView)

                parent.addChildViewController(child, toContainerView: containerView)

                #expect(child.view.superview === containerView)
            }

            @Test func `add child view controller multiple children`() {
                let parent = UIViewController()
                let child1 = UIViewController()
                let child2 = UIViewController()
                let containerView = UIView()
                parent.view.addSubview(containerView)

                parent.addChildViewController(child1, toContainerView: containerView)
                parent.addChildViewController(child2, toContainerView: containerView)

                #expect(parent.children.count == 2)
                #expect(parent.children.contains(child1))
                #expect(parent.children.contains(child2))
            }

            // MARK: - removeViewAndControllerFromParentViewController Tests

            @Test func `remove view and controller removes from parent`() {
                let parent = UIViewController()
                let child = UIViewController()
                let containerView = UIView()
                parent.view.addSubview(containerView)
                parent.addChildViewController(child, toContainerView: containerView)

                child.removeViewAndControllerFromParentViewController()

                #expect(child.parent == nil)
                #expect(!parent.children.contains(child))
            }

            @Test func `remove view and controller removes view`() {
                let parent = UIViewController()
                let child = UIViewController()
                let containerView = UIView()
                parent.view.addSubview(containerView)
                parent.addChildViewController(child, toContainerView: containerView)

                child.removeViewAndControllerFromParentViewController()

                #expect(child.view.superview == nil)
            }

            @Test func `remove view and controller no parent does nothing`() {
                let orphanChild = UIViewController()

                // Should not crash when called on VC without parent
                orphanChild.removeViewAndControllerFromParentViewController()

                #expect(orphanChild.parent == nil)
            }

            // MARK: - transition Tests

            @Test func `transition returns new child`() {
                let parent = UIViewController()
                _ = parent.view // Load view

                let newChild = UIViewController()
                let result = parent.transition(fromChild: nil, toNewChild: newChild)

                #expect(result === newChild)
            }

            @Test func `initial transition fills the supplied container`() {
                let parent = UIViewController()
                parent.view.frame = CGRect(x: 0, y: 0, width: 400, height: 600)
                let container = UIView(frame: CGRect(x: 20, y: 30, width: 150, height: 200))
                parent.view.addSubview(container)
                let child = UIViewController()

                parent.transition(fromChild: nil, toNewChild: child, inContainerView: container, duration: 0)
                container.layoutIfNeeded()

                #expect(child.parent === parent)
                #expect(child.view.superview === container)
                #expect(child.view.frame == container.bounds)
            }

            @Test func `transition completion runs after the old child is removed`() async {
                let parent = UIViewController()
                let oldChild = UIViewController()
                parent.addChildViewController(oldChild, toContainerView: parent.view)

                let oldChildWasAttached = await withCheckedContinuation { continuation in
                    parent.transition(fromChild: oldChild, toNewChild: UIViewController(), duration: 0) {
                        continuation.resume(returning: oldChild.parent != nil || oldChild.view.superview != nil)
                    }
                }

                #expect(!oldChildWasAttached)
            }

            // MARK: - Containment Callback Tests

            @Test func `add child view controller sends containment callbacks once in order`() {
                let parent = UIViewController()
                let child = ContainmentRecorder()

                parent.addChildViewController(child, toContainerView: parent.view)

                #expect(child.events == [.willMove(toParent: true), .didMove(toParent: true, viewAttached: true)])
            }

            @Test func `remove view and controller sends containment callbacks once in order`() {
                let parent = UIViewController()
                let child = ContainmentRecorder()
                parent.addChildViewController(child, toContainerView: parent.view)
                child.events.removeAll()

                child.removeViewAndControllerFromParentViewController()

                #expect(child.events == [.willMove(toParent: false), .didMove(toParent: false, viewAttached: false)])
            }

            @Test func `transition sends containment callbacks once in UIKit's order`() async {
                let parent = UIViewController()
                let oldChild = ContainmentRecorder()
                let newChild = ContainmentRecorder()
                parent.addChildViewController(oldChild, toContainerView: parent.view)
                oldChild.events.removeAll()

                await withCheckedContinuation { continuation in
                    parent.transition(fromChild: oldChild, toNewChild: newChild, duration: 0) {
                        continuation.resume()
                    }
                    // Before the animation finishes, only the will-move callbacks have fired.
                    #expect(oldChild.events == [.willMove(toParent: false)])
                    #expect(newChild.events == [.willMove(toParent: true)])
                }

                #expect(oldChild.events == [.willMove(toParent: false), .didMove(toParent: false, viewAttached: false)])
                #expect(newChild.events == [.willMove(toParent: true), .didMove(toParent: true, viewAttached: true)])
            }

            // MARK: - fadeOut Tests

            @Test func `fade out completion runs after the view controller is removed`() async {
                let parent = UIViewController()
                let child = UIViewController()
                parent.addChildViewController(child, toContainerView: parent.view)

                let childWasAttached = await withCheckedContinuation { continuation in
                    child.fadeOut(duration: 0) {
                        continuation.resume(returning: child.parent != nil || child.view.superview != nil)
                    }
                }

                #expect(!childWasAttached)
            }

            @Test func `transition same child returns same`() {
                let parent = UIViewController()
                _ = parent.view // Load view

                let child = UIViewController()
                parent.addChildViewController(child, toContainerView: parent.view)

                let result = parent.transition(fromChild: child, toNewChild: child)

                #expect(result === child)
            }
        }
    #endif

#endif
