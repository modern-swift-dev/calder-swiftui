#if canImport(Darwin)
    #if !os(macOS) && !os(watchOS)
        import Foundation
        import UIKit

        public extension UIApplication {

            /// The application's bundle identifier.
            var bundleId: String {
                Bundle.main.bundleIdentifier ?? ""
            }

            /// The application's display name.
            var displayName: String {
                Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
            }

            /// The application's current build number.
            var buildNumber: Int64 {
                let value = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
                return value.flatMap(Int64.init) ?? 0
            }

            /// The application's current version number.
            var version: String {
                Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
            }

            /// A boolean indicating whether the application is running tests.
            var isRunningTests: Bool {
                NSClassFromString("XCTestCase") != nil
            }

            /// A boolean indicating whether the application is running on a simulator.
            var isSimulator: Bool {
                #if targetEnvironment(simulator)
                    return true
                #else
                    return false
                #endif
            }

            /// A boolean indicating whether the application is running as a Mac Catalyst app.
            var isMacCatalyst: Bool {
                #if targetEnvironment(macCatalyst)
                    return true
                #else
                    return false
                #endif
            }
        }

        #if !os(tvOS)
            public extension UIApplication {
                /// Returns the current user interface orientation of the application.
                func appInterfaceOrientation() -> UIInterfaceOrientation {
                    UIApplication.shared.windowScene(for: .foregroundActive)?.interfaceOrientation ?? .portrait
                }
            }
        #endif

        public extension UIApplication {
            /// Formerly suspended the current application through a private `UIApplication` selector.
            ///
            /// UIKit has no public API to suspend an app, and private selectors risk App Review rejection.
            /// This method now does nothing. Let the user leave the app instead.
            @available(*, deprecated, message: "UIKit has no public API to suspend an app. This method does nothing; let the user leave the app instead.")
            func suspendApplication() {}

            /// Exits the application after a specified delay with an optional exit code.
            ///
            /// The delay no longer blocks the main thread, and the application is no longer suspended first.
            /// Apple's guidelines discourage apps from terminating themselves.
            /// - Parameters:
            ///   - value: The time in seconds to wait before exiting. Defaults to 1.0 seconds.
            ///   - code: The exit code to use. Defaults to 0.
            @available(*, deprecated, message: "Apps shouldn't terminate themselves. Present an explanation and let the user leave the app instead.")
            func exitApplication(_ value: TimeInterval = 1.0, code: Int32 = 0) {
                Task {
                    try? await Task.sleep(for: .seconds(max(0, value)))
                    exit(code)
                }
            }
        }

    #endif

#endif
