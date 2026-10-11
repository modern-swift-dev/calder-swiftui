#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct PercentWidgetTests {
        private static let english = Locale(identifier: "en_US")
        private static let french = Locale(identifier: "fr_FR")

        @Test(arguments: [(-0.5, 0.0), (0.0, 0.0), (0.25, 0.25), (1.0, 1.0), (1.5, 1.0), (50.0, 1.0)])
        func `percent view clamps its value to the documented 0 to 1 range`(value: Double, expected: Double) {
            #expect(PercentView(value: value).clampedValue == expected)
        }

        @Test func `percent view exposes a localised percentage`() {
            #expect(PercentView(value: 0.25).accessibilityPercent(locale: Self.english) == "25%")
            #expect(PercentView(value: 3).accessibilityPercent(locale: Self.english) == "100%")
            #expect(PercentView(value: 0.25).accessibilityPercent(locale: Self.french) == "25\u{00A0}%")
        }

        @Test func `percentage circle exposes zero as a percentage instead of a dash`() {
            #expect(PercentageCircle(percent: 0).accessibilityPercent(locale: Self.english) == "0%")
            #expect(PercentageCircle(percent: -0.3).accessibilityPercent(locale: Self.english) == "0%")
            #expect(PercentageCircle(percent: 0.25).accessibilityPercent(locale: Self.french) == "25\u{00A0}%")
        }

        #if os(iOS)
            @Test func `percent view is announced with its percentage`() throws {
                let elements = AccessibilityTree.elements(of: PercentView(value: 0.4).environment(\.locale, Self.english))

                let element = try #require(elements.first)
                #expect(elements.count == 1)
                #expect(element.value == "40%")
            }

            @Test func `percentage circle is announced with its percentage`() throws {
                let elements = AccessibilityTree.elements(of: PercentageCircle(percent: 0).environment(\.locale, Self.english))

                let element = try #require(elements.first)
                #expect(elements.count == 1)
                #expect(element.label != "-")
                #expect(element.value == "0%")
            }
        #endif
    }
#endif
