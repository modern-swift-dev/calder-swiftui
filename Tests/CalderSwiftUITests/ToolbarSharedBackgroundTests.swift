#if os(iOS)
    @testable import CalderSwiftUI
    import SwiftUI
    import Testing
    import UIKit

    /// Hosts toolbars in a key window, so the tests must not overlap.
    @Suite(.serialized)
    @MainActor struct ToolbarSharedBackgroundTests {

        @available(iOS 26, *)
        @Test(arguments: [true, false])
        func `disable shared background hides the bar button background`(disable: Bool) async throws {
            let root = NavigationStack {
                Text("Content")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Action") {}
                        }
                        .disableSharedBackground(disable)
                    }
            }

            let item = try await #require(Self.hostedTrailingBarButtonItem(for: root))

            #expect(item.hidesSharedBackground == disable)
        }

        @available(iOS 26, *)
        @available(*, deprecated)
        @Test func `deprecated disableSharedbackground forwards to disableSharedBackground`() async throws {
            let root = NavigationStack {
                Text("Content")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Action") {}
                        }
                        .disableSharedbackground(disable: true)
                    }
            }

            let item = try await #require(Self.hostedTrailingBarButtonItem(for: root))

            #expect(item.hidesSharedBackground)
        }

        /// Hosts `root` in a key window and returns its trailing bar button item.
        private static func hostedTrailingBarButtonItem(for root: some View) async -> UIBarButtonItem? {
            let controller = UIHostingController(rootView: root)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
            window.rootViewController = controller
            window.makeKeyAndVisible()
            defer { window.isHidden = true }

            return await trailingBarButtonItem(in: controller)
        }

        /// Waits for SwiftUI to install the toolbar item in the hosted navigation bar.
        private static func trailingBarButtonItem(in controller: UIViewController) async -> UIBarButtonItem? {
            for _ in 0 ..< 250 {
                controller.view.layoutIfNeeded()
                let items = navigationControllers(in: controller).flatMap { navigation -> [UIBarButtonItem] in
                    guard let item = navigation.topViewController?.navigationItem else {
                        return []
                    }
                    return (item.rightBarButtonItems ?? []) + item.trailingItemGroups.flatMap(\.barButtonItems)
                }
                if let item = items.first {
                    return item
                }
                try? await Task.sleep(for: .milliseconds(20))
            }
            return nil
        }

        private static func navigationControllers(in controller: UIViewController) -> [UINavigationController] {
            let own = (controller as? UINavigationController).map { [$0] } ?? []
            return own + controller.children.flatMap(navigationControllers(in:))
        }
    }
#endif
