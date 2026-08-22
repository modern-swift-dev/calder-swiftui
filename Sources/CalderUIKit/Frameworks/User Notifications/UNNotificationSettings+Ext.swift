#if canImport(Darwin)
#if canImport(UserNotifications) && !os(tvOS)
import Foundation
import UserNotifications

/// Extension for `UNNotificationSettings` providing convenience properties.
public extension UNNotificationSettings {

    /// Returns `true` if the user has granted permission and at least one of the notification center,
    /// alert banner, or lock screen settings are enabled.
    var isEnabled: Bool {
        switch authorizationStatus {
            case .authorized,
                 .ephemeral,
                 .provisional:
                break
            default:
                return false
        }
        #if os(watchOS)
        return notificationCenterSetting == .enabled || alertSetting == .enabled
        #else
        return notificationCenterSetting == .enabled || alertSetting == .enabled || lockScreenSetting == .enabled
        #endif
    }

}
#endif

#endif
