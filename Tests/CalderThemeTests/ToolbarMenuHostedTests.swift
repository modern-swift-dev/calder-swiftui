#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @MainActor struct ToolbarMenuHostedTests {

        @Test func `toolbar menu exposes its label text to VoiceOver`() {
            let view = NavigationStack {
                Text("Body").toolbar {
                    ToolbarMenu(placement: .primaryAction, content: { Button("Act", action: {}) }, text: "Menu")
                }
            }

            let buttons = AccessibilityTree.elements(of: view).filter { $0.traits.contains(.button) }

            #expect(!buttons.isEmpty)
            #expect(buttons.allSatisfy { $0.label == "Menu" })
        }
    }
#endif
