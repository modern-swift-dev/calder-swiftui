#if canImport(Darwin)
    #if canImport(UIKit) && canImport(WebKit)
        import CalderStdLib
        import Foundation
        import UIKit
        import WebKit

        public extension UIContentSizeCategory {

            /// The CSS `-webkit-text-size-adjust` value for this category, such as `"112%"`.
            ///
            /// The percentage is the body text style's scaled size relative to its size at
            /// `large`. The value is `"auto"` for `unspecified`.
            internal var webTextSizeAdjustment: String {
                guard self != .unspecified else {
                    return "auto"
                }
                let baseSize = Self.large.bodyPointSize
                let ratio = (bodyPointSize / baseSize).double

                let numberFormat = NumberFormatter()
                numberFormat.locale = .posix
                numberFormat.numberStyle = .percent
                return numberFormat.string(for: ratio.asNumber) ?? "auto"
            }

            private var bodyPointSize: CGFloat {
                let traits = UITraitCollection(preferredContentSizeCategory: self)
                return UIFont.preferredFont(forTextStyle: .body, compatibleWith: traits).pointSize
            }

            /// Applies this content size category to the text of a web view's page.
            ///
            /// Sets the page body's `-webkit-text-size-adjust` style to the body text style's scale
            /// for this category relative to `large`, or to `auto` for `unspecified`. Call it after
            /// the page finishes loading and again when the category changes.
            /// - Parameter webView: The web view whose loaded page should be adjusted.
            @MainActor func adjust(webView: WKWebView) {
                let javascript = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(webTextSizeAdjustment)'"
                webView.evaluateJavaScript(javascript, completionHandler: nil)
            }
        }
    #endif

#endif
