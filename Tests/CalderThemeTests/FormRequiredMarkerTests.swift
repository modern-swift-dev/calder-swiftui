#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct FormRequiredMarkerTests {
        @Test func `mandatory form header reads as required`() {
            let labels = AccessibilityTree.elements(of: FormHeader(title: "Name", mandatory: true)).compactMap(\.label)

            #expect(labels.contains("required"))
            #expect(!labels.contains("*"))
        }

        @Test func `mandatory form field reads as required`() {
            let labels = AccessibilityTree.elements(of: FormField(name: "Name", mandatory: true) { Text("Value") }).compactMap(\.label)

            #expect(labels.contains("required"))
            #expect(!labels.contains("*"))
        }

        @Test func `mandatory responsive form field reads as required`() {
            let labels = AccessibilityTree.elements(of: FormFieldResponsive(name: "Name", mandatory: true) { _ in Text("Value") }).compactMap(\.label)

            #expect(labels.contains("required"))
            #expect(!labels.contains("*"))
        }

        @Test func `optional form components do not read as required`() {
            #expect(!AccessibilityTree.elements(of: FormHeader(title: "Name")).compactMap(\.label).contains("required"))
            #expect(!AccessibilityTree.elements(of: FormField(name: "Name") { Text("Value") }).compactMap(\.label).contains("required"))
        }
    }
#endif
