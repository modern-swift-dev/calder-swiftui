#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    // Expected percentages follow the iOS body text style sizes, so run only on iOS.
    #if os(iOS) && !targetEnvironment(macCatalyst)
        @testable import CalderUIKit
        import Foundation
        import Testing
        import UIKit
        import WebKit

        @MainActor struct UIContentSizeCategoryExtTests {
            private final class NavigationDelegate: NSObject, WKNavigationDelegate {
                var onFinish: (() -> Void)?

                func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                    onFinish?()
                    onFinish = nil
                }
            }

            // MARK: - webTextSizeAdjustment Tests

            /// Expected values follow Apple's body text style sizes (17 pt at `.large`).
            @Test(arguments: [
                (UIContentSizeCategory.unspecified, "auto"),
                (.extraSmall, "82%"),
                (.small, "88%"),
                (.medium, "94%"),
                (.large, "100%"),
                (.extraLarge, "112%"),
                (.extraExtraLarge, "124%"),
                (.extraExtraExtraLarge, "135%"),
                (.accessibilityMedium, "165%"),
                (.accessibilityLarge, "194%"),
                (.accessibilityExtraLarge, "235%"),
                (.accessibilityExtraExtraLarge, "276%"),
                (.accessibilityExtraExtraExtraLarge, "312%")
            ])
            func `web text size adjustment scales with the content size category`(
                category: UIContentSizeCategory,
                expected: String
            ) {
                #expect(category.webTextSizeAdjustment == expected)
            }

            // MARK: - adjust(webView:) Tests

            @Test func `adjust applies the text size adjustment to the page body`() async throws {
                let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
                let navigationDelegate = NavigationDelegate()
                webView.navigationDelegate = navigationDelegate
                await withCheckedContinuation { continuation in
                    navigationDelegate.onFinish = { continuation.resume() }
                    webView.loadHTMLString("<html><body>Text</body></html>", baseURL: nil)
                }

                UIContentSizeCategory.extraExtraLarge.adjust(webView: webView)

                let value = try await webView.evaluateJavaScript("document.body.style.webkitTextSizeAdjust")
                #expect(value as? String == "124%")
            }
        }
    #endif

#endif
