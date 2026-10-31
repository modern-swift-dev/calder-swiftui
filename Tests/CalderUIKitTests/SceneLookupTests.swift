#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
    @testable import CalderUIKit
    import Testing
    import UIKit

    @MainActor struct SceneLookupTests {

        private struct FakeScene: SceneWindowing {
            var activationState: UIScene.ActivationState
            var windows: [UIWindow]
        }

        private final class KeyWindow: UIWindow {
            override var isKeyWindow: Bool {
                true
            }
        }

        @Test func `lookups consider every scene in the state`() {
            let background = FakeScene(activationState: .background, windows: [UIWindow()])
            let firstActive = FakeScene(activationState: .foregroundActive, windows: [])
            let key = KeyWindow()
            let secondActive = FakeScene(activationState: .foregroundActive, windows: [UIWindow(), key])
            let scenes = [background, firstActive, secondActive]

            #expect(SceneLookup.keyWindow(in: scenes, for: .foregroundActive) === key)
            #expect(SceneLookup.keyWindows(in: scenes, for: .foregroundActive) == [key])
            #expect(SceneLookup.scenes(in: scenes, for: .foregroundActive).count == 2)
        }

        @Test func `scenes holding a key window come first`() {
            let plain = UIWindow()
            let key = KeyWindow()
            let first = FakeScene(activationState: .foregroundActive, windows: [plain])
            let second = FakeScene(activationState: .foregroundActive, windows: [key])

            let scenes = SceneLookup.scenes(in: [first, second], for: .foregroundActive)

            #expect(scenes.first?.windows == [key])
            #expect(SceneLookup.windows(in: [first, second], for: .foregroundActive) == [key, plain])
            #expect(SceneLookup.window(in: [first, second], for: .foregroundActive) === key)
        }

        @Test func `window falls back to the last window of the first scene that has windows`() {
            let empty = FakeScene(activationState: .foregroundInactive, windows: [])
            let firstWindow = UIWindow()
            let lastWindow = UIWindow()
            let populated = FakeScene(activationState: .foregroundInactive, windows: [firstWindow, lastWindow])

            #expect(SceneLookup.window(in: [empty, populated], for: .foregroundInactive) === lastWindow)
            #expect(SceneLookup.keyWindow(in: [empty, populated], for: .foregroundInactive) == nil)
        }

        @Test func `lookups return nothing when no scene matches`() {
            let scene = FakeScene(activationState: .background, windows: [KeyWindow()])

            #expect(SceneLookup.keyWindow(in: [scene], for: .foregroundActive) == nil)
            #expect(SceneLookup.window(in: [scene], for: .foregroundActive) == nil)
            #expect(SceneLookup.windows(in: [scene], for: .foregroundActive).isEmpty)
        }

        @Test func `foreground active or any prefers the active scene`() {
            let background = FakeScene(activationState: .background, windows: [])
            let active = FakeScene(activationState: .foregroundActive, windows: [UIWindow()])

            #expect(SceneLookup.foregroundActiveOrAny(in: [background, active])?.activationState == .foregroundActive)
        }

        @Test func `foreground active or any falls back to any scene`() {
            let background = FakeScene(activationState: .background, windows: [])
            let inactive = FakeScene(activationState: .foregroundInactive, windows: [])

            #expect(SceneLookup.foregroundActiveOrAny(in: [background, inactive])?.activationState == .background)
            #expect(SceneLookup.foregroundActiveOrAny(in: [FakeScene]()) == nil)
        }
    }
#endif
