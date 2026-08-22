#if canImport(SwiftUI)
#if canImport(UIKit) && !os(watchOS) && !os(tvOS)
import Combine
import Foundation
import SwiftUI

public class KeyboardObserver: ObservableObject, @unchecked Sendable {

    @Published public private(set) var visible: Bool = false
    @Published public private(set) var isHardwardKeyboard: Bool = false
    @Published public private(set) var keyboardSize: CGSize = .zero
    private var cancellables = Set<AnyCancellable>()

    public init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let isLocal = notification.userInfo?[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber, isLocal.boolValue {
                    self?.visible = true
                    if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                        self?.updateKeyboardSize(value: value)
                    }
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidChangeFrameNotification)
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    self?.updateKeyboardSize(value: value)
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.visible = false
                self?.isHardwardKeyboard = false
                self?.keyboardSize = .zero
            }
            .store(in: &cancellables)
    }

    private func updateKeyboardSize(value: NSValue) {
        let size = value.cgRectValue.size
        keyboardSize = size
        isHardwardKeyboard = size.height <= 75 // typical keyboard height when a hardware keyboard is connected is around 55px. So using 75px has a safety value.
    }
}

/// Environment Key for the flag evaluator
private struct KeyboardObserverEnv: EnvironmentKey {
    static let defaultValue: KeyboardObserver = .init()

    typealias Value = KeyboardObserver
}

/// Environments values integration for custom values
public extension EnvironmentValues {
    var keyboardObserver: KeyboardObserver {
        get { self[KeyboardObserverEnv.self] }
        set { self[KeyboardObserverEnv.self] = newValue }
    }
}
#endif

#endif
