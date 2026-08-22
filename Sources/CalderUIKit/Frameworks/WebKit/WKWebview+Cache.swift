#if canImport(Darwin)
#if canImport(WebKit)
import Combine
import Foundation
import WebKit

public extension WKWebView {

    /// Clear the cache for the webview:
    /// - DataStore
    /// - Cookies
    /// - Cached Response
    static func clearCaches() async {
        await WKWebsiteDataStore.default().clear()
        await WKWebsiteDataStore.nonPersistent().clear()
        let date = Date(timeIntervalSince1970: 0.0)
        HTTPCookieStorage.shared.removeCookies(since: date)
        URLCache.shared.removeCachedResponses(since: date)
    }
}

public extension WKWebsiteDataStore {

    /// Clear the DataStore
    /// - returns: A Publisher
    func clear() async {
        await removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date(timeIntervalSince1970: 0.0))
        await httpCookieStore.deleteAllCookies()
    }
}

public extension WKHTTPCookieStore {

    func getAllCookies() async -> [HTTPCookie] {
        await withCheckedContinuation { continuation in
            self.getAllCookies { cookies in
                continuation.resume(returning: cookies)
            }
        }
    }

    /// Clear the Cookie Store
    /// - returns: A Future
    func deleteAllCookies() async {
        let cookies = await getAllCookies()
        for cookie in cookies {
            await deleteCookie(cookie)
        }
    }
}

extension WKWebsiteDataStore: @unchecked @retroactive Sendable {}
extension WKHTTPCookieStore: @unchecked @retroactive Sendable {}

#endif

#endif
