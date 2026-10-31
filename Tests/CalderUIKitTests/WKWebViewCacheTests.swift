#if canImport(WebKit) && (os(iOS) || os(macOS) || targetEnvironment(macCatalyst) || os(visionOS))
    import CalderUIKit
    import Foundation
    import Testing
    import WebKit

    @Suite(.serialized, .timeLimit(.minutes(1)))
    @MainActor struct WKWebViewCacheTests {

        private func makeCookie() throws -> HTTPCookie {
            try #require(HTTPCookie(properties: [
                .name: "calder-test",
                .value: "1",
                .domain: "example.com",
                .path: "/",
                .expires: Date(timeIntervalSinceNow: 3600)
            ]))
        }

        @Test func `clear caches on a web view clears its own data store`() async throws {
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = .nonPersistent()
            let webView = WKWebView(frame: .zero, configuration: configuration)
            await webView.configuration.websiteDataStore.httpCookieStore.setCookie(try makeCookie())
            #expect(await webView.configuration.websiteDataStore.httpCookieStore.getAllCookies().count == 1)

            await webView.clearCaches()

            #expect(await webView.configuration.websiteDataStore.httpCookieStore.getAllCookies().isEmpty)
        }

        @Test func `static clear caches clears the default data store`() async throws {
            let store = WKWebsiteDataStore.default()
            await store.httpCookieStore.setCookie(try makeCookie())
            #expect(await store.httpCookieStore.getAllCookies().contains { $0.name == "calder-test" })

            await WKWebView.clearCaches()

            #expect(await store.httpCookieStore.getAllCookies().isEmpty)
        }
    }
#endif
