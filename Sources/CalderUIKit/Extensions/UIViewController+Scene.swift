#if canImport(Darwin)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import Foundation
import UIKit

public extension UIViewController {

    /// Returns the `UIWindowScene` that the view controller's view is currently in.
    /// - Returns: The `UIWindowScene` instance, or `nil` if the view is not part of a window scene.
    func currentWindowScene() -> UIWindowScene? {
        view.window?.windowScene
    }

    /// Returns the `UISceneSession` associated with the view controller's current window scene.
    /// - Returns: The `UISceneSession` instance, or `nil` if there is no associated scene session.
    func currentWindowSceneSession() -> UISceneSession? {
        currentWindowScene()?.session
    }

}
#endif

#endif
