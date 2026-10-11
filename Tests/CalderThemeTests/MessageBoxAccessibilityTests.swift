#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct MessageBoxAccessibilityTests {
        /// A sendable stand-in for the built-in `MessageBox.Variant` cases used as test arguments.
        enum Severity: Sendable {
            case success
            case info
            case warn
            case error

            @MainActor var variant: MessageBox.Variant {
                switch self {
                    case .success: .success
                    case .info: .info
                    case .warn: .warn
                    case .error: .error
                }
            }
        }

        @Test(arguments: [
            (Severity.success, "Success"),
            (.info, "Information"),
            (.warn, "Warning"),
            (.error, "Error")
        ])
        func `message box announces its severity before its text`(severity: Severity, expected: String) throws {
            let elements = AccessibilityTree.elements(of: MessageBox(variant: severity.variant, title: "Disk full", message: "Free some space"))

            let element = try #require(elements.first)
            #expect(elements.count == 1)
            #expect(element.label == "\(expected), Disk full, Free some space")
        }

        @Test func `custom message box hides its decorative icon`() throws {
            let variant = MessageBox.Variant.custom(icon: Image(systemName: "flame.fill"), background: Color.gray, foreground: Color.black)
            let elements = AccessibilityTree.elements(of: MessageBox(variant: variant, title: "Disk full", message: "Free some space"))

            let element = try #require(elements.first)
            #expect(elements.count == 1)
            #expect(element.label == "Disk full, Free some space")
        }
    }
#endif
