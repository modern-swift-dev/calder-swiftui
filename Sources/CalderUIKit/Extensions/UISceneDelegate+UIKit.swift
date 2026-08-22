#if canImport(Darwin)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import Foundation
import UIKit

/// A basic `UISceneDelegate` implementation that can be subclassed to provide a custom root view controller for a `UIWindowScene`.
open class UIKitSceneDelegate: NSObject, UISceneDelegate {

    /// The main window for the scene.
    public var window: UIWindow?

    /// Creates the root view controller for the window, optionally based on a user activity.
    /// Subclasses should override this method to provide their specific root view controller.
    /// - Parameter userActivity: An optional `NSUserActivity` that initiated the scene connection.
    /// - Returns: A `UIViewController` instance to be set as the `rootViewController` of the window.
    open func createRootViewController(_: NSUserActivity?) -> UIViewController {
        UIViewController()
    }

    /// Called when a scene session is about to be connected to the scene.
    /// This method sets up the `UIWindow` and its `rootViewController`.
    /// - Parameters:
    ///   - scene: The scene that is being connected.
    ///   - session: The session that is connecting to the scene.
    ///   - options: Options for the connection, including user activities.
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        let activity = options.userActivities.first ?? session.stateRestorationActivity
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = createRootViewController(activity)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI

/// An empty SwiftUI `View` used as a placeholder.
struct EmptyView: View {
    var body: some View {
        Text("")
    }
}

/// A basic `UISceneDelegate` implementation for SwiftUI apps that can be subclassed
/// to provide a custom root SwiftUI `View` for a `UIWindowScene`.
open class SwiftUISceneDelegate: NSObject, UISceneDelegate {

    /// The main window for the scene.
    public var window: UIWindow?

    /// Creates the root SwiftUI view for the window, optionally based on a user activity.
    /// Subclasses should override this method to provide their specific root SwiftUI view.
    /// - Parameter userActivity: An optional `NSUserActivity` that initiated the scene connection.
    /// - Returns: A `View` instance to be hosted in a `UIHostingController` as the `rootViewController` of the window.
    open func createRootView(_: NSUserActivity?) -> some View {
        EmptyView()
    }

    /// Called when a scene session is about to be connected to the scene.
    /// This method sets up the `UIWindow` and its `rootViewController` (as a `UIHostingController`).
    /// - Parameters:
    ///   - scene: The scene that is being connected.
    ///   - session: The session that is connecting to the scene.
    ///   - options: Options for the connection, including user activities.
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        let activity = options.userActivities.first ?? session.stateRestorationActivity
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: createRootView(activity))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
#endif
#endif

#endif
