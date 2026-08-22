#if canImport(Darwin)
#if canImport(UserNotifications) && !os(tvOS)
import Foundation
import UserNotifications

/// Extension for `UNNotificationResponse` providing convenience properties.
public extension UNNotificationResponse {

    /// A boolean indicating whether the response is for a remote push notification.
    var isRemotePush: Bool {
        notification.isRemotePush
    }

    /// A boolean indicating whether the user dismissed the notification.
    var isCancelAction: Bool {
        actionIdentifier == UNNotificationDismissActionIdentifier
    }
}
#endif

#endif
