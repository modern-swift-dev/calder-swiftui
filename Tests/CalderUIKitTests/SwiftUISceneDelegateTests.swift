#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
    @testable import CalderUIKit
    import Foundation
    import SwiftUI
    import Testing
    import UIKit

    @MainActor struct SwiftUISceneDelegateTests {
        private final class GreetingSceneDelegate: SwiftUISceneDelegate {
            private(set) var receivedActivityType: String?

            override func createRootView(_ userActivity: NSUserActivity?) -> AnyView {
                receivedActivityType = userActivity?.activityType
                return AnyView(Text("Hello"))
            }
        }

        @Test func `subclass supplies the hosted root view`() {
            let delegate = GreetingSceneDelegate()
            let activity = NSUserActivity(activityType: "com.example.greeting")

            let rootViewController = delegate.rootViewController(for: activity)

            #expect(rootViewController is UIHostingController<AnyView>)
            #expect(delegate.receivedActivityType == "com.example.greeting")
        }
    }
#endif
