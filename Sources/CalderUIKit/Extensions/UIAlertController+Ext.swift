#if canImport(Darwin)
#if !os(watchOS)
#if canImport(UIKit)
import UIKit

public extension UIAlertController {

    /// Creates a generic alert action and adds it to the alert controller.
    /// - Parameters:
    ///   - title: The title of the action.
    ///   - style: The style of the action (`.default`, `.cancel`, `.destructive`). Defaults to `.default`.
    ///   - action: An optional block to execute when the user taps the action button. Defaults to `nil`.
    func addAlertAction(title: String, style: UIAlertAction.Style = .default, action: ((UIAlertAction) -> Void)? = nil) {
        addAction(UIAlertAction(title: title, style: style, handler: action))
    }
}

#endif
#endif

#endif
