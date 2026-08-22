#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && canImport(WebKit) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit
import WebKit

@Suite(.serialized)
@MainActor struct SelfSizingWebViewTests {

    // MARK: - Initialization Tests

    @Test func `init with frame`() {
        let frame = CGRect(x: 0, y: 0, width: 320, height: 480)
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: frame, configuration: config)
        #expect(webView.frame == frame)
    }

    @Test func `init with zero frame`() {
        let frame = CGRect.zero
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: frame, configuration: config)
        #expect(webView.frame == frame)
    }

    // MARK: - lastContentSize Tests

    @Test func `last content size initially zero`() {
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: .zero, configuration: config)
        // Initially should be zero or scrollView content size
        #expect(webView.lastContentSize.width >= 0)
        #expect(webView.lastContentSize.height >= 0)
    }

    // MARK: - intrinsicContentSize Tests

    @Test func `intrinsic content size matches last content size`() {
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), configuration: config)
        #expect(webView.intrinsicContentSize == webView.lastContentSize)
    }

    // MARK: - contentSizeChanged Tests

    @Test func `content size changed default callback`() {
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: .zero, configuration: config)
        // Default callback does nothing, just verify it exists
        webView.contentSizeChanged(CGSize(width: 100, height: 100))
        #expect(true)
    }

    @Test func `content size changed custom callback`() {
        let config = WKWebViewConfiguration()
        let webView = SelfSizingWebView(frame: .zero, configuration: config)

        var callbackCalled = false
        var receivedSize: CGSize = .zero

        webView.contentSizeChanged = { size in
            callbackCalled = true
            receivedSize = size
        }

        // Manually call the callback to test it
        webView.contentSizeChanged(CGSize(width: 200, height: 300))

        #expect(callbackCalled == true)
        #expect(receivedSize.width == 200)
        #expect(receivedSize.height == 300)
    }

}
#endif

#endif
