#if canImport(SwiftUI)
    @testable import CalderTheme
    import Testing

    struct PaginatedListGroupedSectionTests {
        @Test func `sections sort with localized standard comparison`() {
            let groups = ["Zebra", "apple", "Éclair", "item 10", "item 2", "Banana"].groupedBy { $0 }

            #expect(groups.map(\.discriminator) == ["apple", "Banana", "Éclair", "item 2", "item 10", "Zebra"])
        }

        @Test func `items keep their order within a section`() {
            let groups = [(1, "b"), (2, "a"), (3, "b"), (4, "a")].groupedBy { $0.1 }

            #expect(groups.map { $0.values.map(\.0) } == [[2, 4], [1, 3]])
        }
    }
#endif
