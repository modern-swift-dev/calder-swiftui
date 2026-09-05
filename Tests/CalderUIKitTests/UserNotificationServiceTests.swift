#if os(iOS) || targetEnvironment(macCatalyst)
@testable import CalderUIKit
import Foundation
import Testing
import UserNotifications

@Suite(.serialized, .timeLimit(.minutes(1)))
@MainActor struct UserNotificationServiceTests {
    private final class Delegate: UserNotificationServiceDelegate {
        func willPresent(notification: UNNotification, completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([])
        }

        func didReceiveNotification(response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
            completionHandler()
        }

        func didReceiveNewToken(_ data: Data) {}
        func supportProvisionalNotificationState() -> Bool {
            false
        }

        func provisionalNotificationTrigger() -> UNTimeIntervalNotificationTrigger? {
            nil
        }

        func provisionalNotificationContent() -> UNNotificationContent? {
            nil
        }
    }

    @Test func `background callbacks deliver delegate and state on main actor`() async {
        let service = UserNotificationService(delegate: nil)
        let delegate = Delegate()
        service.delegate = delegate

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                service.deliverToDelegate(delivery: { receivedDelegate in
                    MainActor.assertIsolated()
                    #expect(receivedDelegate === delegate)
                    #expect(!service.hasRequestedAuthorization)
                    #expect(!service.isEnabled)
                    continuation.resume()
                })
            }
        }
    }
}
#endif
