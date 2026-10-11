#if canImport(SwiftUI)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @Suite(.serialized)
    @MainActor struct SegmentedControlTests {
        @Test func `string identifiers are supported`() {
            let control = SegmentedControl<String>(
                items: [.init(id: "day", title: "Day"), .init(id: "week", title: "Week")],
                selectedItem: .constant("week")
            )

            #expect(control.items.map(\.id) == ["day", "week"])
            #expect(control.selectedItem == "week")
        }

        @Test func `integer identifiers are supported`() {
            let control = SegmentedControl<Int>(
                items: [.init(id: 1, title: "One"), .init(id: 2, title: "Two")],
                selectedItem: .constant(1)
            )

            #expect(control.items.map(\.id) == [1, 2])
            #expect(control.selectedItem == 1)
        }

        #if os(iOS)
            @Test func `only the selected segment has the selected trait`() throws {
                let control = SegmentedControl<String>(
                    items: [.init(id: "day", title: "Day"), .init(id: "week", title: "Week")],
                    selectedItem: .constant("week")
                )

                let elements = AccessibilityTree.elements(of: control)
                let day = try #require(elements.first { $0.label == "Day" })
                let week = try #require(elements.first { $0.label == "Week" })

                #expect(week.traits.contains(.selected))
                #expect(!day.traits.contains(.selected))
            }
        #endif
    }
#endif
