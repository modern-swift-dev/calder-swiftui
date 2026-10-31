#if canImport(SwiftUI)
    import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @MainActor struct PaginatedListNonCodableTests {

        @Test func `a non-Codable item type works with the data source`() async {
            let source = PaginatedList.DataSource<NonCodableItem>(items: [])
            await source.configureAndLoad {
                PaginatedList.Results(next: URL(string: "https://example.com/2"), hasNext: true, results: [NonCodableItem(id: 1)])
            } nextPageLoader: { _ in
                PaginatedList.Results(results: [NonCodableItem(id: 2)])
            }
            await source.next()

            #expect(source.items.map(\.id) == [1, 2])
        }

        @Test func `a non-Codable item type works with every list view`() {
            let source = PaginatedList.DataSource(items: [NonCodableItem(id: 1)])
            var selection: [NonCodableItem] = []
            var isPresented = true

            let continuous = PaginatedList.Continuous(dataSource: source) { item in
                Text(verbatim: "\(item.wrappedValue.id)")
            }
            let grouped = PaginatedList.Grouped(dataSource: source, groupBy: { _ in "A" }, viewFactory: { item in
                Text(verbatim: "\(item.wrappedValue.id)")
            })
            let picker = PaginatedList.Selection(
                isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
                selection: Binding(get: { selection }, set: { selection = $0 }),
                mode: .single,
                model: source
            ) { item in
                Text(verbatim: "\(item.id)")
            }

            _ = continuous.body
            _ = grouped.body
            _ = picker.body
        }

        private struct NonCodableItem: Identifiable, Sendable {
            let id: Int
            let payload: NonCodablePayload = .init()
        }

        private final class NonCodablePayload: Sendable {}
    }
#endif
