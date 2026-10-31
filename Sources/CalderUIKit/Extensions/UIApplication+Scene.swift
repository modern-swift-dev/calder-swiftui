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
            /// - Returns: The first `UISceneSession` matching the state, preferring the session whose scene holds a key window, or `nil` if none is found.
            func session(for state: UIScene.ActivationState = .foregroundActive) -> UISceneSession? {
                sessions(for: state).first
            }

            /// Finds all `UISceneSession`s for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the scene sessions to find. Defaults to `.foregroundActive`.
            /// - Returns: An array of `UISceneSession`s matching the state. Sessions whose scene holds a key window come first.
            func sessions(for state: UIScene.ActivationState = .foregroundActive) -> [UISceneSession] {
                scenes(for: state).map(\.session)
            }

            /// Finds the `UIScene` for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the scene to find. Defaults to `.foregroundActive`.
            /// - Returns: The first `UIScene` matching the state, preferring a scene that holds a key window, or `nil` if none is found.
            func scene(for state: UIScene.ActivationState = .foregroundActive) -> UIScene? {
                scenes(for: state).first
            }

            /// Finds all `UIScene`s for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the scenes to find. Defaults to `.foregroundActive`.
            /// - Returns: An array of `UIScene`s matching the state. Window scenes that hold a key window come first.
            func scenes(for state: UIScene.ActivationState = .foregroundActive) -> [UIScene] {
                windowScenes(for: state).map { $0 as UIScene } + connectedScenes.filter { !($0 is UIWindowScene) && $0.activationState == state }
            }

            /// Finds the `UIWindowScene` for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the window scene to find. Defaults to `.foregroundActive`.
            /// - Returns: The first `UIWindowScene` matching the state, preferring a scene that holds a key window, or `nil` if none is found.
            func windowScene(for state: UIScene.ActivationState = .foregroundActive) -> UIWindowScene? {
                windowScenes(for: state).first
            }

            /// Finds all `UIWindowScene`s for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the window scenes to find. Defaults to `.foregroundActive`.
            /// - Returns: An array of `UIWindowScene`s matching the state. Scenes that hold a key window come first.
            func windowScenes(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindowScene] {
                SceneLookup.scenes(in: connectedScenes.compactMap { $0 as? UIWindowScene }, for: state)
            }

            /// Finds the `UIWindow` for a specified `UIScene.ActivationState`.
            ///
            /// The search covers every scene in that state.
            /// - Parameter state: The activation state of the window to find. Defaults to `.foregroundActive`.
            /// - Returns: The key window if one exists, otherwise the last window of the first scene that has windows, or `nil` if none is found.
            func window(for state: UIScene.ActivationState = .foregroundActive) -> UIWindow? {
                SceneLookup.window(in: windowScenes(for: state), for: state)
            }

            /// Finds all `UIWindow`s for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the windows to find. Defaults to `.foregroundActive`.
            /// - Returns: The windows of every scene in that state. Windows of a scene that holds a key window come first.
            func windows(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindow] {
                SceneLookup.windows(in: windowScenes(for: state), for: state)
            }

            /// Finds the key `UIWindow` for a specified `UIScene.ActivationState`.
            ///
            /// The search covers every scene in that state.
            /// - Parameter state: The activation state of the key window to find. Defaults to `.foregroundActive`.
            /// - Returns: The first key `UIWindow` found in a scene matching the state, or `nil` if none is found.
            func keyWindow(for state: UIScene.ActivationState = .foregroundActive) -> UIWindow? {
                SceneLookup.keyWindow(in: windowScenes(for: state), for: state)
            }

            /// Finds all key `UIWindow`s for a specified `UIScene.ActivationState`.
            /// - Parameter state: The activation state of the key windows to find. Defaults to `.foregroundActive`.
            /// - Returns: An array of key `UIWindow`s from every scene matching the state.
            func keyWindows(for state: UIScene.ActivationState = .foregroundActive) -> [UIWindow] {
                SceneLookup.keyWindows(in: windowScenes(for: state), for: state)
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
