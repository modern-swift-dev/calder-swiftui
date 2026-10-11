#if canImport(Darwin)
    #if canImport(UIKit) && canImport(WebKit)

        import Foundation
        import UIKit
        import WebKit

        /// A self-sizing webview that will invalidate it's intrinsic content size
        /// to the content.
        public class SelfSizingWebView: WKWebView {

            /// The last known content size
            public private(set) var lastContentSize: CGSize = .zero {
                didSet {
                    invalidateIntrinsicContentSize()
                    setNeedsUpdateConstraints()
                    setNeedsLayout()
                    contentSizeChanged(lastContentSize)
                }
            }

            /// Observes the scroll view's content size.
            private var contentSizeObservation: NSKeyValueObservation?

            /// The pending trailing update that applies the latest content size after a throttling interval.
            private var pendingContentSizeUpdate: Task<Void, Never>?

            /// The callback for the parent, in case they need to do something when the size changes
            public var contentSizeChanged: (CGSize) -> Void = { _ in }

            /// The Constructor
            override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
                super.init(frame: frame, configuration: configuration)
                configure()
            }

            /// Another constructor
            public required init?(coder: NSCoder) {
                super.init(coder: coder)
                configure()
            }

            override public var intrinsicContentSize: CGSize {
                lastContentSize
            }

            private func configure() {
                lastContentSize = scrollView.contentSize
                contentSizeObservation = scrollView.observe(\.contentSize, options: .new) { [weak self] _, _ in
                    // UIKit changes scroll view content sizes on the main thread.
                    MainActor.assumeIsolated {
                        self?.contentSizeDidChange()
                    }
                }
            }

            /// Applies content size changes at most once every half second, ending with the latest size.
            private func contentSizeDidChange() {
                guard pendingContentSizeUpdate == nil else {
                    return
                }
                applyContentSize()
                pendingContentSizeUpdate = Task { [weak self] in
                    try? await Task.sleep(for: .milliseconds(500))
                    self?.pendingContentSizeUpdate = nil
                    self?.applyContentSize()
                }
            }

            private func applyContentSize() {
                let size = scrollView.contentSize
                if size != lastContentSize {
                    lastContentSize = size
                }
            }

        }
    #endif

#endif
