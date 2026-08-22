import Foundation

extension URL {
    /// The application-specific cache directory used by Calder's image utilities.
    ///
    /// The directory is created when needed and excluded from backups.
    static var applicativeCacheDirectory: URL {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "app-cache"
        let url = URL.cachesDirectory.appendingPathComponent("\(bundleIdentifier)-cache")

        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        try? (url as NSURL).setResourceValue(true, forKey: .isExcludedFromBackupKey)
        return url
    }
}
