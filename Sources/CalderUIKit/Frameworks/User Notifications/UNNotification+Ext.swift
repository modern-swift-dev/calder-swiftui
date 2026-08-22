#if canImport(Darwin)
#if canImport(UserNotifications)
import Foundation
import UserNotifications

/// Extension for `UNNotification` providing convenience properties.
public extension UNNotification {

    /// A boolean indicating whether the notification is a remote push notification.
    var isRemotePush: Bool {
        request.trigger is UNPushNotificationTrigger
    }
}
#endif

#endif
