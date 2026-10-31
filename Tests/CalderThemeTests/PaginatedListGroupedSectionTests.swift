#if canImport(SwiftUI)
    @testable import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct PaginatedListGroupedSectionTests {
        @Test func `sections sort with localized standard comparison`() {
            let groups = ["Zebra", "apple", "Éclair", "item 10", "item 2", "Banana"].groupedBy { $0 }

            #expect(groups.map(\.discriminator) == ["apple", "Banana", "Éclair", "item 2", "item 10", "Zebra"])
        }

        @Test func `items keep their order within a section`() {
            let groups = [(1, "b"), (2, "a"), (3, "b"), (4, "a")].groupedBy { $0.1 }

            #expect(groups.map { $0.values.map(\.0) } == [[2, 4], [1, 3]])
        }

        @Test func `grouped list sorts sections with localized standard comparison by default`() {
            let view = grouped(sectionOrder: nil)

            #expect(view.sections.map(\.discriminator) == ["apple", "Banana", "Éclair", "item 2", "item 10", "Zebra"])
        }

        @Test func `grouped list honours a reverse section order`() {
            let view = grouped(sectionOrder: String.StandardComparator(.localizedStandard, order: .reverse))

            #expect(view.sections.map(\.discriminator) == ["Zebra", "item 10", "item 2", "Éclair", "Banana", "apple"])
        }

        @Test func `grouped list honours a custom section comparator`() {
            let view = grouped(sectionOrder: LengthComparator())

            #expect(view.sections.map(\.discriminator) == ["Zebra", "apple", "Éclair", "item 2", "Banana", "item 10"])
        }

        @Test func `grouped list honours a reversed custom section comparator`() {
            let view = grouped(sectionOrder: LengthComparator(order: .reverse))

            #expect(view.sections.map(\.discriminator) == ["item 10", "Éclair", "item 2", "Banana", "Zebra", "apple"])
        }

        private func grouped(
            sectionOrder: (any SortComparator<String>)?
        ) -> PaginatedList.Grouped<SectionItem, Text> {
            let keys = ["Zebra", "apple", "Éclair", "item 10", "item 2", "Banana"]
            let source = PaginatedList.DataSource(items: keys.enumerated().map { SectionItem(id: $0.offset, key: $0.element) })
            let groupBy: (Binding<SectionItem>) -> String = { $0.wrappedValue.key }
            let viewFactory: (Binding<SectionItem>) -> Text = { Text($0.wrappedValue.key) }
            guard let sectionOrder else {
                return PaginatedList.Grouped(dataSource: source, groupBy: groupBy, viewFactory: viewFactory)
            }
            return PaginatedList.Grouped(dataSource: source, groupBy: groupBy, sectionOrder: sectionOrder, viewFactory: viewFactory)
        }

        private struct SectionItem: Identifiable, Sendable {
            let id: Int
            let key: String
        }

        /// Orders keys by length; the stable sort keeps the input order of keys with the same length.
        private struct LengthComparator: SortComparator {
            var order: SortOrder = .forward

            func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
                let result: ComparisonResult = if lhs.count == rhs.count {
                    .orderedSame
                } else if lhs.count < rhs.count {
                    .orderedAscending
                } else {
                    .orderedDescending
                }
                guard order == .reverse else {
                    return result
                }
                return switch result {
                    case .orderedAscending: .orderedDescending
                    case .orderedDescending: .orderedAscending
                    case .orderedSame: .orderedSame
                }
            }
        }
    }
#endif
