#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if !os(macOS) && !os(watchOS)
        import CalderUIKit
        import Combine
        import Foundation
        import Testing
        import UIKit

        /// Posts keyboard notifications to the shared notification center, so the tests must not overlap.
        @Suite(.serialized)
        @MainActor struct UIScrollViewExtTests {

            // MARK: - scrollToSubview Tests

            @Test func `scroll to subview reveals a subview below the visible area`() async throws {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                scrollView.contentSize = CGSize(width: 200, height: 1000)

                let subview = UIView(frame: CGRect(x: 50, y: 800, width: 100, height: 100))
                scrollView.addSubview(subview)

                scrollView.scrollToSubview(subview)

                // The subview's bottom edge (900) aligns with the bottom of the 200 point viewport.
                try await waitUntil { scrollView.contentOffset.y == 700 }
            }

            @Test func `scroll to subview reveals a subview above the visible area`() async throws {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
                scrollView.contentSize = CGSize(width: 200, height: 1000)
                scrollView.contentOffset = CGPoint(x: 0, y: 500)

                let subview = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                scrollView.addSubview(subview)

                scrollView.scrollToSubview(subview)

                try await waitUntil { scrollView.contentOffset.y == 0 }
            }

            // MARK: - adjustInset Tests

            @Test func `adjust inset to center vertically`() {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                scrollView.contentSize = CGSize(width: 300, height: 200)

                scrollView.adjustInset(toCenterVertically: 0)

                // (500 - 200) / 2
                #expect(scrollView.contentInset.top == 150)
            }

            @Test func `adjust inset to center vertically with bottom delta`() {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                scrollView.contentSize = CGSize(width: 300, height: 200)

                scrollView.adjustInset(toCenterVertically: 100)

                // (500 - 200 - 100) / 2
                #expect(scrollView.contentInset.top == 100)
            }

            @Test func `adjust inset content larger than bounds`() {
                let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
                scrollView.contentInset.top = 40
                scrollView.contentSize = CGSize(width: 300, height: 500)

                scrollView.adjustInset(toCenterVertically: 0)

                #expect(scrollView.contentInset.top == 0)
            }

            // MARK: - setupKeyboardAutoAdjustment Tests

            #if !os(tvOS)
                @Test func `keyboard auto adjustment insets the bottom by the covered height`() async throws {
                    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                    scrollView.contentInset.bottom = 10
                    scrollView.contentSize = CGSize(width: 300, height: 100)
                    let cancellable = scrollView.setupKeyboardAutoAdjustment(keepCentered: false)
                    defer { cancellable?.cancel() }

                    // The subscription is set up asynchronously on the main run loop, so repost until it applies.
                    try await waitUntil {
                        postKeyboardFrame(CGRect(x: 0, y: 300, width: 300, height: 200))
                        return scrollView.contentInset.bottom == 210
                    }
                    #expect(scrollView.contentInset.top == 0)
                }

                @Test func `keyboard auto adjustment keep centered`() async throws {
                    let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 500))
                    scrollView.contentSize = CGSize(width: 300, height: 100)
                    let cancellable = scrollView.setupKeyboardAutoAdjustment(keepCentered: true)
                    defer { cancellable?.cancel() }

                    // The subscription is set up asynchronously on the main run loop, so repost until it applies.
                    // The top inset centers the content above the keyboard: (500 - 100 - 200) / 2.
                    try await waitUntil {
                        postKeyboardFrame(CGRect(x: 0, y: 300, width: 300, height: 200))
                        return scrollView.contentInset.top == 100
                    }
                    #expect(scrollView.contentInset.bottom == 200)
                }

                private func postKeyboardFrame(_ frame: CGRect) {
                    NotificationCenter.default.post(
                        name: UIResponder.keyboardWillChangeFrameNotification,
                        object: nil,
                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: frame)]
                    )
                }
            #endif

            // MARK: - Helpers

            private func waitUntil(_ condition: () -> Bool, sourceLocation: SourceLocation = #_sourceLocation) async throws {
                let deadline = ContinuousClock.now.advanced(by: .seconds(10))
                while !condition(), ContinuousClock.now < deadline {
                    try await Task.sleep(for: .milliseconds(10))
                }
                #expect(condition(), sourceLocation: sourceLocation)
            }
        }
    #endif

#endif
