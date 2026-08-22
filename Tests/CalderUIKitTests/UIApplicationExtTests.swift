#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if !os(macOS) && !os(watchOS) && canImport(UIKit)
import CalderUIKit
import Foundation
import Testing
import UIKit

@Suite(.serialized)
@MainActor struct UIApplicationExtTests {

    // MARK: - bundleId Tests

    @Test func `bundle id reads the main bundle`() {
        #expect(UIApplication.shared.bundleId == Bundle.main.bundleIdentifier ?? "")
    }

    // MARK: - displayName Tests

    @Test func `display name reads the main bundle`() {
        let expected = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
        #expect(UIApplication.shared.displayName == expected)
    }

    // MARK: - buildNumber Tests

    @Test func `build number is non negative`() {
        let buildNumber = UIApplication.shared.buildNumber
        #expect(buildNumber >= 0)
    }

    // MARK: - version Tests

    @Test func `version reads the main bundle`() {
        let expected = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        #expect(UIApplication.shared.version == expected)
    }

    @Test func `version is not empty`() {
        let version = UIApplication.shared.version
        // Version may be "0.0.0" if not set in bundle
        #expect(!version.isEmpty)
    }

    // MARK: - isRunningTests Tests

    @Test func `is running tests is true when running tests`() {
        let isRunning = UIApplication.shared.isRunningTests
        #expect(isRunning == true)
    }

    // MARK: - isSimulator Tests

    #if targetEnvironment(simulator)
    @Test func `is simulator is true on simulator`() {
        #expect(UIApplication.shared.isSimulator == true)
    }
    #endif

    // MARK: - isMacCatalyst Tests

    #if targetEnvironment(macCatalyst)
    @Test func `is mac catalyst is true on mac catalyst`() {
        #expect(UIApplication.shared.isMacCatalyst == true)
    }
    #else
    @Test func `is mac catalyst is false not on mac catalyst`() {
        #expect(UIApplication.shared.isMacCatalyst == false)
    }
    #endif
}
#endif

#endif
