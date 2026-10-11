#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit) && canImport(WebKit) && !os(watchOS)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit
        import WebKit

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

            @Test func `last content size initially matches the scroll view`() {
                let config = WKWebViewConfiguration()
                let webView = SelfSizingWebView(frame: .zero, configuration: config)
                #expect(webView.lastContentSize == webView.scrollView.contentSize)
            }

            // MARK: - intrinsicContentSize Tests

            @Test func `intrinsic content size matches last content size`() {
                let config = WKWebViewConfiguration()
                let webView = SelfSizingWebView(frame: CGRect(x: 0, y: 0, width: 200, height: 300), configuration: config)
                #expect(webView.intrinsicContentSize == webView.lastContentSize)
            }

            // MARK: - contentSizeChanged Tests

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

            @Test func `loaded content size updates the last content size`() async throws {
                let webView = SelfSizingWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480), configuration: WKWebViewConfiguration())
                var reportedSizes: [CGSize] = []
                webView.contentSizeChanged = { reportedSizes.append($0) }

                webView.loadHTMLString(
                    "<html><head><meta name='viewport' content='width=device-width'></head><body style='margin:0'><div style='height:2000px'></div></body></html>",
                    baseURL: nil
                )
                let deadline = ContinuousClock.now + .seconds(10)
                while webView.lastContentSize.height < 2000, ContinuousClock.now < deadline {
                    try await Task.sleep(for: .milliseconds(100))
                }

                #expect(webView.lastContentSize.height == 2000)
                #expect(webView.intrinsicContentSize == webView.lastContentSize)
                #expect(reportedSizes.last == webView.lastContentSize)
            }

        }
    #endif

#endif
