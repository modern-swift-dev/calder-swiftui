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

            @Test func `build number reads the main bundle`() {
                let version = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
                let expected = version.flatMap(Int64.init) ?? 0
                #expect(UIApplication.shared.buildNumber == expected)
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

            // MARK: - Deprecated environment checks

            @available(*, deprecated)
            @Test func `deprecated is simulator and is mac catalyst forward to UIDevice`() {
                #expect(UIApplication.shared.isSimulator == UIDevice.isSimulator)
                #expect(UIApplication.shared.isMacCatalyst == UIDevice.isCatalyst)
            }

            // MARK: - appInterfaceOrientation Tests

            #if !os(tvOS)
                @Test func `app interface orientation is unknown without a window scene`() {
                    let application = UIApplication.shared
                    let hasWindowScene = application.connectedScenes.contains { $0 is UIWindowScene }
                    if !hasWindowScene {
                        #expect(application.appInterfaceOrientation() == .unknown)
                    }
                }
            #endif
        }
    #endif

#endif
