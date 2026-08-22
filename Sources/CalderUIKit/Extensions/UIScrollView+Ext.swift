#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Combine
import Foundation
import UIKit

public extension UIScrollView {
    /// Scrolls the scroll view to make a specific subview visible.
    /// If the subview has an `inputAccessoryView`, its height is also accounted for in the scroll.
    /// - Parameter view: The subview to scroll to.
    func scrollToSubview(_ view: UIView) {
        var rect = view.convert(view.bounds, to: self)
        #if !os(visionOS)
        if let accessoryView = view.inputAccessoryView {
            rect = CGRect(
                x: rect.origin.x,
                y: rect.origin.y + accessoryView.frame.size.height,
                width: rect.size.width,
                height: rect.size.height + accessoryView.frame.size.height
            )
        }
        #endif
        scrollRectToVisible(rect, animated: true)
    }

    /// Sets up automatic adjustment of the scroll view's content inset to accommodate the keyboard.
    /// - Parameter keepCentered: A boolean indicating whether the scroll view's content should try to remain vertically centered when the keyboard appears.
    /// - Returns: An `AnyCancellable` object to manage the notification subscription lifecycle.
    func setupKeyboardAutoAdjustment(keepCentered: Bool) -> AnyCancellable? {
        #if os(tvOS)
        return nil
        #else
        let bottomInset = contentInset.bottom
        return NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            .subscribe(on: RunLoop.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self else {
                    return
                }
                let keyboard = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
                let keyboardFrame = keyboard?.cgRectValue
                guard let keyboardFrame else {
                    return
                }
                let convertedKeyboard = self.convert(keyboardFrame, from: nil)
                let intersection = self.bounds.intersection(convertedKeyboard)

                var insets = self.contentInset
                insets.bottom = intersection.size.height + bottomInset
                self.contentInset = insets
                if keepCentered {
                    self.adjustInset(toCenterVertically: intersection.size.height)
                }
            }
        #endif
    }

    /// Adjusts the scroll view's content inset to vertically center its content.
    /// - Parameter bottomDelta: The height of the area (e.g., keyboard) that needs to be accommodated at the bottom.
    func adjustInset(toCenterVertically bottomDelta: CGFloat) {
        layoutIfNeeded()
        let offsetY = CGFloat(max((bounds.size.height - contentSize.height - bottomDelta) * 0.5, 0.0))
        var insets = contentInset
        insets.top = offsetY
        contentInset = insets
    }
}
#endif

#endif
