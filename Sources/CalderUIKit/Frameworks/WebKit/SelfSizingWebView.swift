#if canImport(Darwin)
#if canImport(UIKit) && canImport(WebKit)

import Combine
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

    /// The cancellables
    private var cancellables = Set<AnyCancellable>()

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
        publisher(for: \.scrollView.contentSize, options: .new)
            .removeDuplicates()
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] size in
                self?.lastContentSize = size
            }
            .store(in: &cancellables)
    }

}
#endif

#endif
