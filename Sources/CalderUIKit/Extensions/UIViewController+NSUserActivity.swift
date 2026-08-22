#if canImport(Darwin)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import Foundation
import UIKit

public extension UIViewController {

    /// Saves the provided `NSUserActivity` to the current window scene, enabling state restoration.
    /// - Parameter userActivity: The `NSUserActivity` to save. If `nil`, the current user activity will be cleared.
    func saveState(_ userActivity: NSUserActivity?) {
        currentWindowScene()?.userActivity = userActivity
    }

    /// Flushes (clears) the user activity from the current window scene.
    func flushState() {
        currentWindowScene()?.userActivity = nil
    }

}
#endif

#endif
