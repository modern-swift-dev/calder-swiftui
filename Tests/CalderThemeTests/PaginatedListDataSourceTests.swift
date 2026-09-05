#if canImport(SwiftUI)
import CalderTheme
import Foundation
import Testing

@Suite(.serialized)
@MainActor struct PaginatedListDataSourceTests {

    @Test func `init items count state and is last overloads`() {
        let source = PaginatedList.DataSource(items: [
            item(1),
            item(2)
        ])

        #expect(ids(source) == [1, 2])
        #expect(source.count == 2)
        expectDisplaying(source.state)
        #expect(source.isLast(item(2)))
        #expect(source.isLast(2))
        #expect(!source.isLast(item(1)))
        #expect(!source.isLast(1))
    }

    @Test func `remove by item and id updates items and state`() {
        let source = PaginatedList.DataSource(items: [
            item(1),
            item(2),
            item(3)
        ])

        source.remove(item(2))
        #expect(ids(source) == [1, 3])
        expectDisplaying(source.state)

        source.remove(id: 1)
        #expect(ids(source) == [3])
        expectDisplaying(source.state)

        source.remove(id: 3)
        #expect(source.items.isEmpty)
        expectEmpty(source.state)
    }

    @Test func `upsert appends prepends and updates existing item`() {
        let source = PaginatedList.DataSource(items: [
            item(2)
        ])

        source.upsert(item(3))
        source.upsert(item(1), append: false)
        source.upsert(item(2, title: "two updated"))

        #expect(ids(source) == [1, 2, 3])
        #expect(source.items[1].title == "two updated")
        expectDisplaying(source.state)
    }

    @Test func `append after item and id insert after match and ignore missing id`() {
        let source = PaginatedList.DataSource(items: [
            item(1),
            item(3)
        ])

        source.append(item: item(2), after: item(1))
        source.append(item: item(4), after: 3)
        source.append(item: item(99), after: 404)

        #expect(ids(source) == [1, 2, 3, 4])
        expectDisplaying(source.state)
    }

    @Test func `append all replace all and remove all update items and state`() {
        let source = PaginatedList.DataSource(items: [
            item(1)
        ])

        source.appendAll(PaginatedList.Results(results: [
            item(2),
            item(1, title: "one updated")
        ]))
        #expect(ids(source) == [1, 2])
        #expect(source.items[0].title == "one updated")
        expectDisplaying(source.state)

        source.replaceAll(PaginatedList.Results(results: [
            item(3),
            item(4)
        ]))
        #expect(ids(source) == [3, 4])
        expectDisplaying(source.state)

        source.removeAll()
        #expect(source.items.isEmpty)
        #expect(!source.hasNext)
        expectEmpty(source.state)
    }

    @Test func `configure and load reload and load success`() async {
        let loader = FirstPageLoader()
        let source = PaginatedList.DataSource<PaginatedListTestItem>(items: [])

        await source.configureAndLoad {
            await loader.next()
        } nextPageLoader: { _ in
            PaginatedList.Results(results: [item(9)])
        }

        #expect(await loader.loadCount() == 1)
        #expect(ids(source) == [1, 2])
        #expect(source.count == 10)
        #expect(source.hasNext)
        expectDisplaying(source.state)

        await source.reload()

        #expect(await loader.loadCount() == 2)
        #expect(ids(source) == [3])
        #expect(source.count == 11)
        #expect(!source.hasNext)
        expectDisplaying(source.state)

        await source.load()

        #expect(await loader.loadCount() == 2)
        #expect(ids(source) == [3])
    }

    @Test func `next success no next and error paths`() async throws {
        let nextURL = try #require(URL(string: "https://example.com/next"))
        let success = PaginatedList.DataSource<PaginatedListTestItem>(items: [])

        await success.configureAndLoad {
            PaginatedList.Results(count: 2, next: nextURL, hasNext: true, results: [item(1)])
        } nextPageLoader: { _ in
            PaginatedList.Results(count: 2, next: nil, hasNext: false, results: [item(2)])
        }

        #expect(success.hasNext)
        await success.next()
        #expect(ids(success) == [1, 2])
        #expect(!success.hasNext)
        expectDisplaying(success.state)

        let noNext = PaginatedList.DataSource(items: [
            item(1)
        ])
        await noNext.next()
        #expect(ids(noNext) == [1])
        #expect(!noNext.hasNext)
        expectDisplaying(noNext.state)

        let failing = PaginatedList.DataSource<PaginatedListTestItem>(items: [])
        await failing.configureAndLoad {
            PaginatedList.Results(count: 2, next: nextURL, hasNext: true, results: [item(1)])
        } nextPageLoader: { _ in
            throw PaginatedListDataSourceTestError.failed
        }

        await failing.next()
        #expect(ids(failing) == [1])
        #expect(!failing.hasNext)
        expectDisplaying(failing.state)
    }

    @Test func `loader error clears items count and sets error state`() async {
        let source = PaginatedList.DataSource(items: [
            item(1)
        ])

        await source.configureAndLoad {
            throw PaginatedListDataSourceTestError.failed
        } nextPageLoader: { _ in
            PaginatedList.Results(results: [item(2)])
        }

        #expect(source.items.isEmpty)
        #expect(source.count == nil)
        #expect(!source.hasNext)
        expectError(source.state)
    }

    private func item(_ id: Int, title: String? = nil) -> PaginatedListTestItem {
        PaginatedListTestItem(id: id, title: title ?? "\(id)")
    }

    private func ids(_ source: PaginatedList.DataSource<PaginatedListTestItem>) -> [Int] {
        source.items.map(\.id)
    }

    private func expectDisplaying(_ state: GenericState) {
        switch state {
            case .displaying:
                break
            default:
                Issue.record("Expected .displaying, got \(state)")
        }
    }

    private func expectEmpty(_ state: GenericState) {
        switch state {
            case .empty:
                break
            default:
                Issue.record("Expected .empty, got \(state)")
        }
    }

    private func expectError(_ state: GenericState) {
        switch state {
            case .error:
                break
            default:
                Issue.record("Expected .error, got \(state)")
        }
    }
}

private struct PaginatedListTestItem: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
}

private enum PaginatedListDataSourceTestError: Error {
    case failed
}

private actor FirstPageLoader {
    private var loads = 0

    func next() -> PaginatedList.Results<PaginatedListTestItem> {
        loads += 1

        if loads == 1 {
            return PaginatedList.Results(
                count: 10,
                next: URL(string: "https://example.com/next"),
                hasNext: true,
                results: [
                    PaginatedListTestItem(id: 1, title: "1"),
                    PaginatedListTestItem(id: 2, title: "2")
                ]
            )
        }

        return PaginatedList.Results(
            count: 11,
            next: nil,
            hasNext: false,
            results: [
                PaginatedListTestItem(id: 3, title: "3")
            ]
        )
    }

    func loadCount() -> Int {
        loads
    }
}
#endif
