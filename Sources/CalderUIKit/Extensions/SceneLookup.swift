#if canImport(Darwin)
    #if !os(macOS) && !os(watchOS)
        import UIKit

        /// The rules `UIApplication` uses to pick scenes and windows out of all connected scenes.
        ///
        /// Every scene in the requested activation state is considered, and the scene that holds a key window comes first.
        @MainActor enum SceneLookup {

            static func scenes<Scene: SceneWindowing>(in scenes: [Scene], for state: UIScene.ActivationState) -> [Scene] {
                let matching = scenes.filter { $0.activationState == state }
                return matching.filter { $0.keyWindow != nil } + matching.filter { $0.keyWindow == nil }
            }

            /// The scene to read state such as the interface orientation from: the first foreground-active scene, otherwise any scene.
            static func foregroundActiveOrAny<Scene: SceneWindowing>(in scenes: [Scene]) -> Scene? {
                self.scenes(in: scenes, for: .foregroundActive).first ?? scenes.first
            }

            static func keyWindow(in scenes: [some SceneWindowing], for state: UIScene.ActivationState) -> UIWindow? {
                self.scenes(in: scenes, for: state).lazy.compactMap(\.keyWindow).first
            }

            static func window(in scenes: [some SceneWindowing], for state: UIScene.ActivationState) -> UIWindow? {
                keyWindow(in: scenes, for: state) ?? self.scenes(in: scenes, for: state).lazy.compactMap(\.windows.last).first
            }

            static func windows(in scenes: [some SceneWindowing], for state: UIScene.ActivationState) -> [UIWindow] {
                self.scenes(in: scenes, for: state).flatMap(\.windows)
            }

            static func keyWindows(in scenes: [some SceneWindowing], for state: UIScene.ActivationState) -> [UIWindow] {
                windows(in: scenes, for: state).filter(\.isKeyWindow)
            }
        }
    #endif

#endif
