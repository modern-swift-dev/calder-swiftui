#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct ThemedDisclosureGroupAccessibilityTests {
        private static func group(isExpanded: Bool) -> some View {
            DisclosureGroup("Details", isExpanded: .constant(isExpanded)) {
                Text(verbatim: "Body")
            }
            .disclosureGroupStyle(ThemedDisclosureGroupStyle())
        }

        @Test(arguments: [(true, UIAccessibility.ExpandedStatus.expanded), (false, .collapsed)])
        func `header exposes its expanded state`(isExpanded: Bool, expected: UIAccessibility.ExpandedStatus) throws {
            let elements = AccessibilityTree.elements(of: Self.group(isExpanded: isExpanded))
            let header = try #require(elements.first)

            #expect(header.expandedStatus == expected)
            #expect(header.traits.contains(.button))
        }

        @Test func `header reads only its label, not the chevron`() throws {
            let elements = AccessibilityTree.elements(of: Self.group(isExpanded: false))
            let header = try #require(elements.first)

            #expect(elements.count == 1)
            #expect(header.label == "Details")
        }
    }
#endif
