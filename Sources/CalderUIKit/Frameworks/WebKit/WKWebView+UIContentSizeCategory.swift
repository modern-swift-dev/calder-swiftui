#if canImport(Darwin)
#if canImport(UIKit) && canImport(WebKit)
import CalderStdLib
import Foundation
import UIKit
import WebKit

public extension UIContentSizeCategory {

    /// Calculate Base Text Size Adjustments in percent
    private func textSizeAdjustmentInPercent() -> String {
        let traits = UITraitCollection(preferredContentSizeCategory: self)
        let scaledFont = UIFont.scaledSystemFont(ofSize: 14.0, compatibleWith: traits)
        let ratio: Double = scaledFont.pointSize.double / scaledFont.pointSize.double

        let numberFormat = NumberFormatter()
        numberFormat.locale = .posix
        numberFormat.numberStyle = .percent
        return numberFormat.string(for: ratio.asNumber) ?? "auto"
    }

    /// Update the webview text-size based on the content-size category
    /// - parameter webView: The Webview to customize
    @MainActor func adjust(webView: WKWebView) {

        var value = "auto"
        switch self {
            case .unspecified:
                value = "auto"
            default:
                value = textSizeAdjustmentInPercent()
        }
        let javascript = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='\(value)'"
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
}
#endif

#endif
