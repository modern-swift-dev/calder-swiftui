#if os(iOS)
    @testable import CalderTheme
    import Foundation
    import SFSafeSymbols
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct GenericStateViewTests {
        /// A catalog entry whose English value differs from its key, so a lookup is observable.
        private static let warning = LocalizedStringResource("messageBox.severity.warning", bundle: .module)

        private func labels(of state: GenericState) -> [String] {
            AccessibilityTree.elements(of: GenericStateView(state: state) { Text("Displaying") }).compactMap(\.label)
        }

        @Test func `string messages are shown verbatim`() {
            #expect(labels(of: .pristine("messageBox.severity.warning")).contains("messageBox.severity.warning"))
            #expect(labels(of: .empty("messageBox.severity.warning")).contains("messageBox.severity.warning"))
            #expect(labels(of: .error("messageBox.severity.warning")).contains("messageBox.severity.warning"))
        }

        @Test func `localized messages are looked up in the catalog`() {
            #expect(labels(of: .localizedPristine(Self.warning)).contains("Warning"))
            #expect(labels(of: .localizedEmpty(Self.warning)).contains("Warning"))
            #expect(labels(of: .localizedError(Self.warning)).contains("Warning"))
        }

        @Test func `localized messages are optional`() {
            #expect(!labels(of: .localizedPristine(nil)).contains("Information"))
            #expect(!labels(of: .localizedEmpty(nil)).contains("Information"))
            #expect(!labels(of: .localizedError(nil)).contains("Information"))
        }
    }
#endif
