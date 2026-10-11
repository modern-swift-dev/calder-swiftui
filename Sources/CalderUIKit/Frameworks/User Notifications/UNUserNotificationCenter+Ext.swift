#if canImport(Darwin)
    import Foundation
    import UserNotifications

    public extension UNUserNotificationCenter {

        /// Asynchronously retrieves the current notification settings for the application.
        ///
        /// Equivalent to `notificationSettings()`.
        var settings: UNNotificationSettings {
            get async {
                await notificationSettings()
            }
        }
    }

#endif
