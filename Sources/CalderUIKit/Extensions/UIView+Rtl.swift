#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import UIKit

public extension UIView {

    /// A boolean indicating if the current view's layout direction is Right-to-Left (RTL).
    var isLayoutRtL: Bool {
        UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft || traitCollection.layoutDirection == .rightToLeft
    }
}
#endif

#endif
