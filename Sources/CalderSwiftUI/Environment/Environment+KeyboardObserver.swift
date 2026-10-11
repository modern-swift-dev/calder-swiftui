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
        /// Observation continues for the lifetime of this object. Notifications are applied on the main actor in the order they are posted.
        @MainActor @Observable public class KeyboardObserver: ObservableObject {

            /// Whether a local keyboard has been shown and has not subsequently been hidden.
            public private(set) var visible: Bool = false
            /// Whether the reported keyboard height suggests a connected hardware keyboard.
            public private(set) var isHardwareKeyboard: Bool = false
            /// Whether the reported keyboard height suggests a connected hardware keyboard.
            ///
            /// - Note: Deprecated misspelling of ``isHardwareKeyboard``.
            @available(*, deprecated, renamed: "isHardwareKeyboard")
            public var isHardwardKeyboard: Bool {
                isHardwareKeyboard
            }

            /// The size reported by the most recent keyboard frame notification, or zero after hiding.
            public private(set) var keyboardSize: CGSize = .zero
            private let events: AsyncStream<KeyboardEvent>.Continuation
            private let subscription: AnyCancellable

            /// Starts observing keyboard notifications. Create and access the observer on the main actor.
            ///
            /// Keyboard show, frame-change, and hide notifications are applied on the main actor one at a time,
            /// in the order they are posted.
            public init() {
                let (stream, continuation) = AsyncStream.makeStream(of: KeyboardEvent.self)
                events = continuation
                let center = NotificationCenter.default
                subscription = Publishers.Merge3(
                    center.publisher(for: UIResponder.keyboardDidShowNotification),
                    center.publisher(for: UIResponder.keyboardDidChangeFrameNotification),
                    center.publisher(for: UIResponder.keyboardDidHideNotification)
                )
                .compactMap { @Sendable notification in KeyboardEvent(notification) }
                .sink { @Sendable event in continuation.yield(event) }

                Task { [weak self] in
                    for await event in stream {
                        self?.apply(event)
                    }
                }
            }

            deinit {
                events.finish()
            }

            private func apply(_ event: KeyboardEvent) {
                objectWillChange.send()
                switch event {
                    case let .show(size):
                        visible = true
                        if let size {
                            updateKeyboardSize(size)
                        }
                    case let .frameChange(size):
                        updateKeyboardSize(size)
                    case .hide:
                        visible = false
                        isHardwareKeyboard = false
                        keyboardSize = .zero
                }
            }

            private func updateKeyboardSize(_ size: CGSize) {
                keyboardSize = size
                isHardwareKeyboard = size.height <= 75 // typical keyboard height when a hardware keyboard is connected is around 55px. So using 75px has a safety value.
            }

            /// A keyboard notification reduced to the values the observer applies.
            private enum KeyboardEvent: Sendable {
                case show(size: CGSize?)
                case frameChange(size: CGSize)
                case hide

                init?(_ notification: Notification) {
                    let userInfo = notification.userInfo
                    let isLocal = (userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue ?? false
                    let size = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
                    switch notification.name {
                        case UIResponder.keyboardDidShowNotification:
                            guard isLocal else {
                                return nil
                            }
                            self = .show(size: size)
                        case UIResponder.keyboardDidChangeFrameNotification:
                            guard let size else {
                                return nil
                            }
                            self = .frameChange(size: size)
                        case UIResponder.keyboardDidHideNotification:
                            self = .hide
                        default:
                            return nil
                    }
                }
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
