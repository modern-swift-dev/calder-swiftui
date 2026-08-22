#if canImport(Darwin)
#if os(iOS) || targetEnvironment(macCatalyst)

import Combine
import Foundation
import os
import UIKit

/// A protocol for delegating user notification service events.
public protocol UserNotificationServiceDelegate: AnyObject {

    /// Called when a notification is about to be presented to the user.
    /// - Parameters:
    ///   - notification: The `UNNotification` that is about to be presented.
    ///   - completionHandler: A closure to call with the desired presentation options.
    func willPresent(notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)

    /// Called when the user responds to a notification.
    /// - Parameters:
    ///   - response: The `UNNotificationResponse` representing the user's action.
    ///   - completionHandler: A closure to call when processing of the response is complete.
    func didReceiveNotification(response: UNNotificationResponse, completionHandler: @escaping () -> Void)

    /// Called when a new APNS device token is received.
    /// - Parameter data: The device token as `Data`.
    func didReceiveNewToken(_ data: Data)

    /// Asks the delegate if the service should support provisional notification state.
    /// - Returns: `true` if provisional notifications are supported, `false` otherwise.
    func supportProvisionalNotificationState() -> Bool

    /// Provides the trigger for a provisional notification request.
    /// - Returns: An optional `UNTimeIntervalNotificationTrigger` for the provisional notification.
    func provisionalNotificationTrigger() -> UNTimeIntervalNotificationTrigger?

    /// Provides the content for a provisional notification request.
    /// - Returns: An optional `UNNotificationContent` for the provisional notification.
    func provisionalNotificationContent() -> UNNotificationContent?
}

/// A service class for managing user notifications, including authorization, remote notifications, and local notifications.
open class UserNotificationService: NSObject, @unchecked Sendable {

    /// The delegate for handling notification-related events.
    public weak var delegate: (any UserNotificationServiceDelegate)?

    /// A boolean indicating whether the app has requested notification authorization from the user.
    public private(set) var hasRequestedAuthorization: Bool = false

    /// A boolean indicating whether the app currently has notification permissions enabled by the user.
    public private(set) var isEnabled: Bool = false

    /// A set of `AnyCancellable` objects to manage Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Updates the application's notification enablement status.
    /// If `newValue` is `false` and notifications were previously enabled, it will open app settings.
    /// If `newValue` is `true` and notifications were not previously enabled, it will request authorization.
    /// - Parameter newValue: The desired notification enablement status.
    /// - Throws: An error if notification authorization request fails.
    public func updateNotificationEnabled(_ newValue: Bool) async throws {
        let oldValue = isEnabled
        switch (oldValue, newValue) {
            case (true, true):
                break
            case (false, false):
                break
            case (true, false):
                await UIApplication.shared.openAppSettings()
            case (false, true):

                let settings = await UNUserNotificationCenter.current().settings
                switch settings.authorizationStatus {
                    case .authorized,
                         .ephemeral,
                         .provisional:
                        hasRequestedAuthorization = true
                        isEnabled = true
                    case .notDetermined:
                        hasRequestedAuthorization = false
                        isEnabled = false
                        if delegate?.supportProvisionalNotificationState() == true {
                            let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .provisional])

                            if authorized {
                                hasRequestedAuthorization = true
                                isEnabled = true
                                sendProvisionalNotificationRequest()
                            }
                        } else {
                            let authorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                            if authorized {
                                hasRequestedAuthorization = true
                                isEnabled = true
                            }
                        }
                    case .denied:
                        hasRequestedAuthorization = true
                        isEnabled = false
                        await UIApplication.shared.openAppSettings()
                    @unknown default:
                        break
                }
        }
    }

    /// Initializes a new `UserNotificationService` instance.
    /// - Parameter delegate: The delegate to handle notification events.
    @MainActor public init(delegate: any UserNotificationServiceDelegate) {
        self.delegate = delegate
        super.init()
        willRegisterForRemoteNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        didRegisterForRemoteNotifications()
    }

    /// Hook for setting up the notifications subsystem *before* calling `UIApplication.shared.registerForRemoteNotifications()`.
    /// Sets the `UNUserNotificationCenter` delegate to `self`.
    open func willRegisterForRemoteNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    /// Hook for setting up the notifications subsystem *after* calling `UIApplication.shared.registerForRemoteNotifications()`.
    /// Sets up observers for app foreground and active states to check notification permissions.
    open func didRegisterForRemoteNotifications() {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.checkPermissions()
                }.store(in: &self.cancellables)

            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.checkPermissions()
                }.store(in: &self.cancellables)
        }

        checkPermissions()
    }

    /// Checks the current notification permissions status and updates `hasRequestedAuthorization` and `isEnabled` accordingly.
    private func checkPermissions() {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            let settings = await UNUserNotificationCenter.current().settings
            switch settings.authorizationStatus {
                case .authorized,
                     .ephemeral,
                     .provisional:
                    self.hasRequestedAuthorization = true
                    self.isEnabled = true
                case .denied:
                    self.hasRequestedAuthorization = true
                    self.isEnabled = false
                case .notDetermined:
                    self.hasRequestedAuthorization = false
                    self.isEnabled = false
                @unknown default:
                    self.hasRequestedAuthorization = true
                    self.isEnabled = false
            }
        }
    }

    /// Sends a local notification to prompt the user about provisional notifications, if supported by the delegate.
    private func sendProvisionalNotificationRequest() {
        guard let delegate,
              delegate.supportProvisionalNotificationState(),
              let content = delegate.provisionalNotificationContent() else {
            return
        }
        let trigger = delegate.provisionalNotificationTrigger() ?? UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        let request = UNNotificationRequest(identifier: "Initial", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    /// Called by the `UIApplicationDelegate` when a new APNS device token is available.
    /// - Parameter token: The new APNS token as `Data`.
    open func onNewApnsToken(token: Data) {
        delegate?.didReceiveNewToken(token)
    }

    /// Called by the `UIApplicationDelegate` when remote notification registration fails.
    /// - Parameter error: The error that occurred during registration.
    public func onRegisterFail(error: any Error) {
        os_log("%{public}@", log: .default, type: .error, String(describing: error))
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension UserNotificationService: UNUserNotificationCenterDelegate {

    /// Implements `UNUserNotificationCenterDelegate` method to handle notifications that are about to be presented.
    /// - Parameters:
    ///   - center: The notification center.
    ///   - notification: The notification that is about to be presented.
    ///   - completionHandler: The handler to call to specify presentation options.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        delegate?.willPresent(notification: notification, completionHandler: completionHandler)
    }

    /// Implements `UNUserNotificationCenterDelegate` method to handle user responses to notifications.
    /// - Parameters:
    ///   - center: The notification center.
    ///   - response: The response object indicating the user's action.
    ///   - completionHandler: The handler to call when processing of the response is complete.
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        delegate?.didReceiveNotification(response: response, completionHandler: completionHandler)
    }
}

#endif

#endif
