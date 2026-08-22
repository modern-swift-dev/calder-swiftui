#if canImport(Darwin)
#if !os(macOS) && !os(watchOS)
import Foundation
import UIKit

/// Extensions for `UIApplication` related to opening URLs.
public extension UIApplication {

    /// Opens the application's settings in the Settings app.
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            self.open(url, options: [:], completionHandler: nil)
        }
    }

    /// Opens the App Store page for a specific application.
    /// - Parameters:
    ///   - country: The country code for the App Store (e.g., "us", "gb").
    ///   - appName: The app name as defined in App Store Connect.
    ///   - storeId: The App Store identifier for the application.
    func openAppStore(country: String, appName: String, storeId: String) {
        if let url = URL(string: "https://itunes.apple.com/\(country)/app/\(appName)/id\(storeId)") {
            self.open(url, options: [:], completionHandler: nil)
        }
    }

    /// Opens the App Store page directly to the "write a review" section for a specific application.
    /// - Parameters:
    ///   - country: The country code for the App Store (e.g., "us", "gb").
    ///   - appName: The app name as defined in App Store Connect.
    ///   - storeId: The App Store identifier for the application.
    func openAppStoreWriteReview(country: String, appName: String, storeId: String) {
        if let url = URL(string: "https://itunes.apple.com/\(country)/app/\(appName)/id\(storeId)?action=write-review") {
            self.open(url, options: [:], completionHandler: nil)
        }
    }
}

#endif

#endif
