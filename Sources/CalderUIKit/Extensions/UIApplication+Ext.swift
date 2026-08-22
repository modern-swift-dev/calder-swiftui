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
    /// Suspends the current application.
    /// WARNING: This method uses an undocumented selector on `UIApplication` and should be used with caution.
    func suspendApplication() {
        UIApplication.shared.perform(#selector(URLSessionTask.suspend))
    }

    /// Exits the application after a specified delay with an optional exit code.
    /// - Parameters:
    ///   - value: The time in seconds to wait before exiting. Defaults to 1.0 seconds.
    ///   - code: The exit code to use. Defaults to 0.
    func exitApplication(_ value: TimeInterval = 1.0, code: Int32 = 0) {
        suspendApplication()
        Thread.sleep(until: Date.now.addingTimeInterval(max(0, value)))
        exit(code)
    }
}

#endif

#endif
