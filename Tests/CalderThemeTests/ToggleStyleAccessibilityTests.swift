#if os(iOS)
    @testable import CalderTheme
    import SwiftUI
    import Testing
    import UIKit

    @Suite(.serialized)
    @MainActor struct ToggleStyleAccessibilityTests {
        enum Style: CaseIterable {
            case checkbox
            case radio
            case themed
        }

        private static func toggle(_ style: Style, isOn: Bool) -> some View {
            let toggle = Toggle("Notifications", isOn: .constant(isOn))
            return Group {
                switch style {
                    case .checkbox:
                        toggle.applyCheckboxToggleStyle()
                    case .radio:
                        toggle.applyRadioButtonToggleStyle()
                    case .themed:
                        toggle.applyThemedToggleStyle()
                }
            }
        }

        @Test(arguments: Style.allCases, [true, false])
        func `styled toggle is announced as a toggle with its value`(style: Style, isOn: Bool) throws {
            let elements = AccessibilityTree.elements(of: Self.toggle(style, isOn: isOn))
            let element = try #require(elements.first { $0.label == "Notifications" })

            #expect(elements.count(where: { $0.label == "Notifications" }) == 1)
            #expect(element.traits.contains(.toggleButton))
            #expect(element.value == (isOn ? "1" : "0"))
        }
    }
#endif
