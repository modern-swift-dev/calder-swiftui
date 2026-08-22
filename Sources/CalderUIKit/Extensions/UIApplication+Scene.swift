#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

public extension UIApplication {

    /// Finds any key window available in the application, prioritizing active foreground scenes.
    /// - Returns: The first key window found, or `nil` if no key window is available.
    func anyKeyWindow() -> UIWindow? {
        keyWindow(for: .foregroundActive) ?? keyWindow(for: .foregroundInactive) ?? keyWindow(for: .background)
    }

    /// Finds the `UISceneSession` for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the scene session to find. Defaults to `.foregroundActive`.
    /// - Returns: The first `UISceneSession` matching the state, or `nil` if none is found.
    func session(for state: UIScene.ActivationState = .foregroundActive) -> UISceneSession? {
        UIApplication.shared.openSessions.first(where: { session in session.scene?.activationState == state })
    }

    /// Finds all `UISceneSession`s for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the scene sessions to find. Defaults to `.foregroundActive`.
    /// - Returns: An array of `UISceneSession`s matching the state.
    func sessions(for state: UIScene.ActivationState = .foregroundActive) -> [UISceneSession] {
        UIApplication.shared.openSessions.filter { session in session.scene?.activationState == state }
    }

    /// Finds the `UIScene` for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the scene to find. Defaults to `.foregroundActive`.
    /// - Returns: The first `UIScene` matching the state, or `nil` if none is found.
    func scene(for state: UIScene.ActivationState = .foregroundActive) -> UIScene? {
        session(for: state)?.scene
    }

    /// Finds all `UIScene`s for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the scenes to find. Defaults to `.foregroundActive`.
    /// - Returns: An array of `UIScene`s matching the state.
    func scenes(for state: UIScene.ActivationState = .foregroundActive) -> [UIScene] {
        sessions(for: state).compactMap(\.scene)
    }

    /// Finds the `UIWindowScene` for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the window scene to find. Defaults to `.foregroundActive`.
    /// - Returns: The first `UIWindowScene` matching the state, or `nil` if none is found.
    func windowScene(for state: UIScene.ActivationState = .foregroundActive) -> UIWindowScene? {
        scene(for: state) as? UIWindowScene
    }

    /// Finds all `UIWindowScene`s for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the window scenes to find. Defaults to `.foregroundActive`.
    /// - Returns: An array of `UIWindowScene`s matching the state.
    func windowScenes(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindowScene] {
        scenes(for: state).compactMap { $0 as? UIWindowScene }
    }

    /// Finds the `UIWindow` for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the window to find. Defaults to `.foregroundActive`.
    /// - Returns: The last `UIWindow` in the scene matching the state, or `nil` if none is found.
    func window(for state: UIScene.ActivationState = .foregroundActive) -> UIWindow? {
        windowScene(for: state)?.windows.last
    }

    /// Finds all `UIWindow`s for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the windows to find. Defaults to `.foregroundActive`.
    /// - Returns: An array of `UIWindow`s matching the state.
    func windows(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindow] {
        windowScene(for: state)?.windows ?? []
    }

    /// Finds the key `UIWindow` for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the key window to find. Defaults to `.foregroundActive`.
    /// - Returns: The first key `UIWindow` in the scene matching the state, or `nil` if none is found.
    func keyWindow(for state: UIScene.ActivationState = .foregroundActive) -> UIWindow? {
        windowScene(for: state)?.windows.first { $0.isKeyWindow }
    }

    /// Finds all key `UIWindow`s for a specified `UIScene.ActivationState`.
    /// - Parameter state: The activation state of the key windows to find. Defaults to `.foregroundActive`.
    /// - Returns: An array of key `UIWindow`s matching the state.
    func keyWindows(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindow] {
        windowScene(for: state)?.windows.filter(\.isKeyWindow) ?? []
    }

    /// Returns the topmost presented root view controller for the foreground active window (in case of a multi-window app).
    /// - Parameter state: The activation state of the scene to check. Defaults to `.foregroundActive`.
    /// - Returns: The topmost view controller for the foreground active window, or `nil` if no such controller is found.
    func topMostPresentedViewController(for state: UIScene.ActivationState = .foregroundActive) -> UIViewController? {
        if var topController: UIViewController = keyWindow(for: state)?.rootViewController {
            while let newest = topController.presentedViewController {
                topController = newest
            }
            return topController
        }
        return nil
    }
}
#endif

#endif
