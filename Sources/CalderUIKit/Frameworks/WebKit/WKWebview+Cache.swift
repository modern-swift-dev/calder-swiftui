#if canImport(Darwin)
    #if canImport(WebKit)
        import Combine
        import Foundation
        import WebKit

        public extension WKWebView {

            /// Clears the default website data store, the shared cookie storage, and the shared URL cache.
            ///
            /// Web views that use their own data store, such as a non-persistent one, keep their data; call
            /// ``clearCaches()`` on such a web view instead.
            static func clearCaches() async {
                await WKWebsiteDataStore.default().clear()
                clearSharedCaches()
            }

            /// Clears the data store this web view uses, the shared cookie storage, and the shared URL cache.
            ///
            /// The data store is the one in the web view's `configuration.websiteDataStore`, which is the default
            /// store unless the configuration supplied another one.
            @MainActor func clearCaches() async {
                await configuration.websiteDataStore.clear()
                Self.clearSharedCaches()
            }

            private static func clearSharedCaches() {
                let date = Date(timeIntervalSince1970: 0.0)
                HTTPCookieStorage.shared.removeCookies(since: date)
                URLCache.shared.removeCachedResponses(since: date)
            }
        }

        public extension WKWebsiteDataStore {

            /// Clear the DataStore
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
            func deleteAllCookies() async {
                let cookies = await getAllCookies()
                for cookie in cookies {
                    await deleteCookie(cookie)
                }
            }
        }

    #endif

#endif
