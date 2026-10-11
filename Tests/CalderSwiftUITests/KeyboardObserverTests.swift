#if canImport(SwiftUI) && canImport(UIKit) && !os(watchOS) && !os(tvOS)
    import CalderSwiftUI
    import Combine
    import Foundation
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct KeyboardObserverTests {
        @Test func `keyboard notifications update main actor state`() async throws {
            let observer = KeyboardObserver()
            let softwareSize = CGSize(width: 320, height: 300)
            NotificationCenter.default.post(
                name: UIResponder.keyboardDidShowNotification,
                object: nil,
                userInfo: [
                    UIResponder.keyboardIsLocalUserInfoKey: NSNumber(value: true),
                    UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(origin: .zero, size: softwareSize))
                ]
            )
            try await waitUntil { observer.visible && observer.keyboardSize == softwareSize }
            #expect(!observer.isHardwardKeyboard)

            let hardwareSize = CGSize(width: 320, height: 55)
            NotificationCenter.default.post(
                name: UIResponder.keyboardDidChangeFrameNotification,
                object: nil,
                userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(origin: .zero, size: hardwareSize))]
            )
            try await waitUntil { observer.keyboardSize == hardwareSize }
            #expect(observer.isHardwardKeyboard)

            NotificationCenter.default.post(name: UIResponder.keyboardDidHideNotification, object: nil)
            try await waitUntil { !observer.visible }
            #expect(observer.keyboardSize == .zero)
            #expect(!observer.isHardwardKeyboard)
        }

        @Test func `notification subscriptions do not retain observer`() {
            var observer: KeyboardObserver? = KeyboardObserver()
            weak let weakObserver = observer
            #expect(weakObserver != nil)
            observer = nil
            #expect(weakObserver == nil)
        }

        @Test func `environment retains shared default and supports overrides`() {
            var environment = EnvironmentValues()
            let shared = environment.keyboardObserver
            #expect(shared === EnvironmentValues().keyboardObserver)

            let custom = KeyboardObserver()
            environment.keyboardObserver = custom
            #expect(environment.keyboardObserver === custom)
            #expect(EnvironmentValues().keyboardObserver === shared)
            _ = ObserverView().environment(\.keyboardObserver, custom)
        }

        @Test func `views reading the environment observer re-render when visibility changes`() async throws {
            let observer = KeyboardObserver()
            let recorder = RenderRecorder()
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
            window.rootViewController = UIHostingController(
                rootView: RecordingView(recorder: recorder).environment(\.keyboardObserver, observer)
            )
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            window.layoutIfNeeded()
            #expect(recorder.renderedVisibility.last == false)

            NotificationCenter.default.post(
                name: UIResponder.keyboardDidShowNotification,
                object: nil,
                userInfo: [
                    UIResponder.keyboardIsLocalUserInfoKey: NSNumber(value: true),
                    UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 0, width: 320, height: 300))
                ]
            )
            try await waitUntil {
                window.layoutIfNeeded()
                return recorder.renderedVisibility.last == true
            }
        }

        @Test func `object will change still fires for observable object call sites`() async throws {
            let observer = KeyboardObserver()
            var changeCount = 0
            let subscription = observer.objectWillChange.sink { changeCount += 1 }
            NotificationCenter.default.post(
                name: UIResponder.keyboardDidShowNotification,
                object: nil,
                userInfo: [
                    UIResponder.keyboardIsLocalUserInfoKey: NSNumber(value: true),
                    UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: CGRect(x: 0, y: 0, width: 320, height: 300))
                ]
            )
            try await waitUntil { observer.visible }
            #expect(changeCount > 0)
            subscription.cancel()
        }

        private func waitUntil(_ condition: () -> Bool) async throws {
            let deadline = ContinuousClock.now.advanced(by: .seconds(2))
            while !condition(), ContinuousClock.now < deadline {
                try await Task.sleep(for: .milliseconds(10))
            }
            #expect(condition())
        }

        private struct ObserverView: View {
            @Environment(\.keyboardObserver) private var observer

            var body: some View {
                Text(observer.visible ? "Visible" : "Hidden")
            }
        }

        private final class RenderRecorder {
            var renderedVisibility: [Bool] = []
        }

        private struct RecordingView: View {
            @Environment(\.keyboardObserver) private var observer
            let recorder: RenderRecorder

            var body: some View {
                recorder.renderedVisibility.append(observer.visible)
                return Text(observer.visible ? "Visible" : "Hidden")
            }
        }
    }
#endif
