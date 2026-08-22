#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit) && canImport(WebKit) && !os(watchOS)
import CalderUIKit
import Foundation
import Testing
import UIKit
import WebKit

@Suite(.serialized)
@MainActor struct UIContentSizeCategoryExtTests {

    // MARK: - adjust(webView:) Tests

    @Test func `adjust with unspecified category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.unspecified.adjust(webView: webView)
        // Just verify it doesn't crash
        #expect(true)
    }

    @Test func `adjust with extra small category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.extraSmall.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with small category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.small.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with medium category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.medium.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.large.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.extraLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with extra extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.extraExtraLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with extra extra extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.extraExtraExtraLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with accessibility medium category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.accessibilityMedium.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with accessibility large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.accessibilityLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with accessibility extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.accessibilityExtraLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with accessibility extra extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.accessibilityExtraExtraLarge.adjust(webView: webView)
        #expect(true)
    }

    @Test func `adjust with accessibility extra extra extra large category`() {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: config)

        UIContentSizeCategory.accessibilityExtraExtraExtraLarge.adjust(webView: webView)
        #expect(true)
    }
}
#endif

#endif
