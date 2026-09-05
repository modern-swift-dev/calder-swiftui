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

    @Test func `missing delegate completes callback`() async {
        let service = UserNotificationService(delegate: nil)
        await withCheckedContinuation { continuation in
            service.deliverToDelegate(orComplete: { continuation.resume() }, delivery: { _ in
                Issue.record("A missing delegate must complete without delivery")
                continuation.resume()
            })
        }
    }

    @Test func `released weak delegate completes callback`() async {
        let service = UserNotificationService(delegate: nil)
        var delegate: Delegate? = Delegate()
        service.delegate = delegate
        delegate = nil
        #expect(service.delegate == nil)

        await withCheckedContinuation { continuation in
            service.deliverToDelegate(orComplete: { continuation.resume() }, delivery: { _ in
                Issue.record("The service must not retain its delegate")
                continuation.resume()
            })
        }
    }

    @Test func `background callbacks deliver delegate and state on main actor`() async {
        let service = UserNotificationService(delegate: nil)
        let delegate = Delegate()
        service.delegate = delegate

        await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                service.deliverToDelegate(orComplete: {
                    Issue.record("A live delegate must receive delivery")
                    continuation.resume()
                }, delivery: { receivedDelegate in
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
