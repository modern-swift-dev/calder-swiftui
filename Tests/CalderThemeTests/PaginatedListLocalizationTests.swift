#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct PaginatedListLocalizationTests {
        @Test func `retry row text resolves from the package catalog`() {
            #expect(String(localized: PaginatedList.RetryState.message) == "Couldn't load more results.")
            #expect(String(localized: PaginatedList.RetryState.retryTitle) == "Retry")
        }

        #if os(iOS)
            @Test func `retry row is announced with its catalog text`() {
                let labels = AccessibilityTree.elements(of: PaginatedList.RetryState {}).compactMap(\.label)

                #expect(labels.contains("Couldn't load more results."))
                #expect(labels.contains("Retry"))
            }
        #endif
    }
#endif
