#if canImport(SwiftUI)
    #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        import Combine
        import Foundation
        import SwiftUI

        /// Observes keyboard notifications and publishes keyboard state on the main actor.
        ///
        /// `KeyboardObserver` uses the Observation framework, so SwiftUI views that read its properties, including
        /// views that obtain it through `@Environment(\.keyboardObserver)`, update when keyboard state changes.
        /// It also conforms to `ObservableObject` for source compatibility with `@StateObject` and `@ObservedObject`
        /// call sites; prefer `@State` or `@Environment` in new code.
        ///
        /// Observation continues for the lifetime of this object. Notifications are debounced by 150 milliseconds.
        @MainActor @Observable public class KeyboardObserver: ObservableObject {

            /// Whether a local keyboard has been shown and has not subsequently been hidden.
            public private(set) var visible: Bool = false
            /// Whether the reported keyboard height suggests a connected hardware keyboard.
            public private(set) var isHardwardKeyboard: Bool = false
            /// The size reported by the most recent keyboard frame notification, or zero after hiding.
            public private(set) var keyboardSize: CGSize = .zero
            @ObservationIgnored
            private var cancellables = Set<AnyCancellable>()

            /// Starts observing keyboard notifications. Create and access the observer on the main actor.
            public init() {
                NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
                    .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] notification in
                        guard let isLocal = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber, isLocal.boolValue else {
                            return
                        }
                        let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
                        Task { @MainActor [weak self] in
                            self?.objectWillChange.send()
                            self?.visible = true
                            if let size {
                                self?.updateKeyboardSize(size)
                            }
                        }
                    }
                    .store(in: &cancellables)

                NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification)
                    .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] notification in
                        guard let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size else {
                            return
                        }
                        Task { @MainActor [weak self] in
                            self?.objectWillChange.send()
                            self?.updateKeyboardSize(size)
                        }
                    }
                    .store(in: &cancellables)

                NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
                    .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] _ in
                        Task { @MainActor [weak self] in
                            self?.objectWillChange.send()
                            self?.visible = false
                            self?.isHardwardKeyboard = false
                            self?.keyboardSize = .zero
                        }
                    }
                    .store(in: &cancellables)
            }

            private func updateKeyboardSize(_ size: CGSize) {
                keyboardSize = size
                isHardwardKeyboard = size.height <= 75 // typical keyboard height when a hardware keyboard is connected is around 55px. So using 75px has a safety value.
            }
        }

        /// Stores an optional override and retains the shared main-actor fallback observer.
        private struct KeyboardObserverEnv: EnvironmentKey {
            static let defaultValue: KeyboardObserver? = nil
            @MainActor static let sharedObserver = KeyboardObserver()
        }

        public extension EnvironmentValues {
            /// The main-actor keyboard observer, using a shared observer when no override is supplied.
            @MainActor var keyboardObserver: KeyboardObserver {
                get { self[KeyboardObserverEnv.self] ?? KeyboardObserverEnv.sharedObserver }
                set { self[KeyboardObserverEnv.self] = newValue }
            }
        }
    #endif

#endif
