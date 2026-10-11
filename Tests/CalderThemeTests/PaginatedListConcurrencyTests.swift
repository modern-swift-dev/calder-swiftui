#if canImport(SwiftUI)
    import CalderTheme
    import Foundation
    import Testing

    @Suite(.timeLimit(.minutes(1)))
    @MainActor struct PaginatedListConcurrencyTests {
        private struct Item: Identifiable, Codable, Sendable {
            let id: Int
        }

        private enum Failure: Error {
            case request
        }

        @MainActor private final class Loader {
            var calls = 0
            private var pending: CheckedContinuation<PaginatedList.Results<Item>, any Error>?
            private var started: CheckedContinuation<Void, Never>?

            func load() async throws -> PaginatedList.Results<Item> {
                calls += 1
                return try await withCheckedThrowingContinuation { continuation in
                    pending = continuation
                    started?.resume()
                    started = nil
                }
            }

            func waitUntilStarted() async {
                if pending == nil {
                    await withCheckedContinuation { started = $0 }
                }
            }

            func finish(failing: Bool = false, id: Int = 1) {
                let result: Result<PaginatedList.Results<Item>, any Error> = failing
                    ? .failure(Failure.request)
                    : .success(.init(results: [Item(id: id)]))
                pending?.resume(with: result)
                pending = nil
            }
        }

        @Test(arguments: [false, true]) func `already cancelled reload or configuration preserves an active request`(reconfigure: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            let active = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await loader.waitUntilStarted()
            let cancelled = Task {
                if reconfigure {
                    await source.configureAndLoad(firstPageLoader: { .init(results: [Item(id: 999)]) }, nextPageLoader: { _ in .init(results: []) })
                } else {
                    await source.reload()
                }
            }
            cancelled.cancel()
            await cancelled.value
            loader.finish(id: 100)
            await active.value
            #expect(source.items.map(\.id) == [100])
            guard case .displaying = source.state else {
                Issue.record("An already cancelled caller invalidated the active request")
                return
            }
        }

        @Test(arguments: [false, true]) func `old first page cannot overwrite a newer result`(failing: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            let old = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await loader.waitUntilStarted()
            await source.configureAndLoad(firstPageLoader: { .init(results: [Item(id: 100)]) }, nextPageLoader: { _ in .init(results: []) })
            loader.finish(failing: failing)
            await old.value

            #expect(source.items.map(\.id) == [100])
            #expect(source.count == 1)
            guard case .displaying = source.state else {
                Issue.record("An old request changed the current display state")
                return
            }
        }

        @Test(arguments: [false, true]) func `old first page cannot dismiss a newer loading state`(failing: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let first = Loader()
            let second = Loader()
            let old = Task {
                await source.configureAndLoad(firstPageLoader: { try await first.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await first.waitUntilStarted()
            let latest = Task {
                await source.configureAndLoad(firstPageLoader: { try await second.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await second.waitUntilStarted()
            first.finish(failing: failing)
            await old.value
            if case .loading = source.state {} else {
                Issue.record("An old request dismissed the active loading state")
            }
            second.finish(id: 100)
            await latest.value
            #expect(source.items.map(\.id) == [100])
        }

        @Test(arguments: [false, true]) func `old next page cannot alter a reconfigured source`(failing: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in try await loader.load() })
            let old = Task { await source.next() }
            await loader.waitUntilStarted()
            await source.configureAndLoad(firstPageLoader: { .init(count: 20, next: nil, hasNext: true, results: [Item(id: 100)]) }, nextPageLoader: { _ in .init(results: []) })
            loader.finish(failing: failing, id: 2)
            await old.value

            #expect(source.items.map(\.id) == [100])
            #expect(source.count == 20)
            #expect(source.hasNext)
        }

        @Test func `overlapping next calls load a page only once`() async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in try await loader.load() })
            let next = Task { await source.next() }
            await loader.waitUntilStarted()
            await source.next()
            #expect(loader.calls == 1)
            loader.finish(id: 2)
            await next.value
            #expect(source.items.map(\.id) == [1, 2])
        }

        @Test func `overlapping initial loads call the loader only once`() async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            let first = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await loader.waitUntilStarted()
            await source.load()
            #expect(loader.calls == 1)
            loader.finish()
            await first.value
            #expect(source.items.map(\.id) == [1])
        }

        @Test(arguments: [false, true]) func `clearing invalidates outstanding first and next pages`(nextPage: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            if nextPage {
                await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in try await loader.load() })
            }
            let pending = Task {
                if nextPage {
                    await source.next()
                } else {
                    await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
                }
            }
            await loader.waitUntilStarted()
            source.removeAll()
            loader.finish()
            await pending.value
            #expect(source.items.isEmpty)
            #expect(source.count == nil)
            #expect(!source.hasNext)
        }

        @Test(arguments: [false, true]) func `replacing invalidates outstanding first and next pages`(nextPage: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            if nextPage {
                await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in try await loader.load() })
            }
            let pending = Task {
                if nextPage {
                    await source.next()
                } else {
                    await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
                }
            }
            await loader.waitUntilStarted()
            source.replaceAll(.init(next: nil, hasNext: true, results: [Item(id: 50)]))
            loader.finish(id: 2)
            await pending.value
            #expect(source.items.map(\.id) == [50])
            #expect(source.hasNext)
            guard case .displaying = source.state else {
                Issue.record("A request started before replaceAll changed the state to \(source.state)")
                return
            }
        }

        @Test func `replacing with values ends pagination`() async {
            let source = PaginatedList.DataSource<Item>(items: [])
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in .init(results: [Item(id: 2)]) })
            source.replaceAll(values: [Item(id: 50)])
            #expect(!source.hasNext)
            await source.next()
            await source.load()
            #expect(source.items.map(\.id) == [50])
        }

        @Test(arguments: [false, true]) func `cancelled first page preserves existing items`(failing: Bool) async {
            let source = PaginatedList.DataSource(items: [Item(id: 100)])
            let loader = Loader()
            let pending = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await loader.waitUntilStarted()
            pending.cancel()
            loader.finish(failing: failing)
            await pending.value
            #expect(source.items.map(\.id) == [100])
            guard case .displaying = source.state else {
                Issue.record("Cancellation must not turn existing content into an error")
                return
            }
        }

        @Test(arguments: [false, true]) func `cancelled first load restores the prior state and can be retried`(failing: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            await source.configureAndLoad(firstPageLoader: { throw Failure.request }, nextPageLoader: { _ in .init(results: []) })
            let loader = Loader()
            let pending = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await loader.waitUntilStarted()
            pending.cancel()
            loader.finish(failing: failing)
            await pending.value
            #expect(source.items.isEmpty)
            if case .error = source.state {} else {
                Issue.record("Cancelling the first load must restore the prior state, got \(source.state)")
            }

            let retry = Task { await source.load() }
            await loader.waitUntilStarted()
            loader.finish(id: 1)
            await retry.value
            #expect(source.items.map(\.id) == [1])
        }

        @Test(arguments: [false, true]) func `cancelled reload keeps pagination and can be retried`(failing: Bool) async {
            let source = PaginatedList.DataSource<Item>(items: [])
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in .init(results: []) })
            let loader = Loader()
            let pending = Task {
                await source.configureAndLoad(firstPageLoader: { try await loader.load() }, nextPageLoader: { _ in .init(results: [Item(id: 2)]) })
            }
            await loader.waitUntilStarted()
            pending.cancel()
            loader.finish(failing: failing)
            await pending.value
            #expect(source.items.map(\.id) == [1])
            #expect(source.hasNext)
            if case .displaying = source.state {} else {
                Issue.record("Cancelling a reload must restore the prior state, got \(source.state)")
            }

            await source.next()
            #expect(source.items.map(\.id) == [1, 2])

            let retry = Task { await source.reload() }
            await loader.waitUntilStarted()
            loader.finish(id: 3)
            await retry.value
            #expect(source.items.map(\.id) == [3])
        }

        @Test func `cancelled reload that superseded another reload restores the original page`() async {
            let source = PaginatedList.DataSource<Item>(items: [])
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in .init(results: []) })
            let first = Loader()
            let second = Loader()
            let superseded = Task {
                await source.configureAndLoad(firstPageLoader: { try await first.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await first.waitUntilStarted()
            let cancelled = Task {
                await source.configureAndLoad(firstPageLoader: { try await second.load() }, nextPageLoader: { _ in .init(results: []) })
            }
            await second.waitUntilStarted()
            cancelled.cancel()
            second.finish(failing: true)
            await cancelled.value
            first.finish(id: 50)
            await superseded.value

            #expect(source.items.map(\.id) == [1])
            #expect(source.hasNext)
            if case .displaying = source.state {} else {
                Issue.record("Cancelling a reload must restore the state before loading, got \(source.state)")
            }
        }

        @Test func `cancelled next page preserves cursor for retry`() async {
            let source = PaginatedList.DataSource<Item>(items: [])
            let loader = Loader()
            await source.configureAndLoad(firstPageLoader: { .init(next: nil, hasNext: true, results: [Item(id: 1)]) }, nextPageLoader: { _ in try await loader.load() })
            let pending = Task { await source.next() }
            await loader.waitUntilStarted()
            pending.cancel()
            loader.finish(failing: true)
            await pending.value
            #expect(source.items.map(\.id) == [1])
            #expect(source.hasNext)
            let retry = Task { await source.next() }
            await loader.waitUntilStarted()
            loader.finish(id: 2)
            await retry.value
            #expect(loader.calls == 2)
            #expect(source.items.map(\.id) == [1, 2])
        }
    }
#endif
