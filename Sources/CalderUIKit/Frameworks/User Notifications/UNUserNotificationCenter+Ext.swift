#if canImport(Darwin)
import Foundation
import UserNotifications

// MARK: - Sendable Conformance for UserNotifications Types
// These extensions declare conformance to `Sendable` for UserNotifications types
// to ensure safe concurrent access.
extension UNNotificationSettings: @retroactive @unchecked Sendable {}
extension UNUserNotificationCenter: @retroactive @unchecked Sendable {}

public extension UNUserNotificationCenter {

    /// Asynchronously retrieves the current notification settings for the application.
    var settings: UNNotificationSettings {
        get async {
            await withCheckedContinuation { continuation in
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    continuation.resume(returning: settings)
                }
            }
        }
    }
}

#endif
