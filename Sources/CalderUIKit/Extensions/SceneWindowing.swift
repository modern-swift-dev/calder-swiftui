#if canImport(Darwin)
    #if !os(macOS) && !os(watchOS)
        import UIKit

        /// The scene state the window lookups in `UIApplication` read, so the selection rules can be tested without real scenes.
        @MainActor protocol SceneWindowing {
            var activationState: UIScene.ActivationState { get }
            var windows: [UIWindow] { get }
        }

        extension UIWindowScene: SceneWindowing {}

        extension SceneWindowing {
            var keyWindow: UIWindow? {
                windows.first(where: \.isKeyWindow)
            }
        }
    #endif

#endif
