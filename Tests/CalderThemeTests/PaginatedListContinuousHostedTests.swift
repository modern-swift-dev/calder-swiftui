#if os(macOS)
    import AppKit
    import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized, .timeLimit(.minutes(1)))
    @MainActor struct PaginatedListContinuousHostedTests {
        private struct Entry: Identifiable, Codable, Sendable {
            let id: Int
        }

        private enum ListKind: CaseIterable {
            case continuous
            case selection
        }

        @MainActor private final class PageServer {
            var requests = 0
            private let pages: [[Entry]]

            init(pages: [[Entry]]) {
                self.pages = pages
            }

            func page(_ index: Int) -> PaginatedList.Results<Entry> {
                PaginatedList.Results(next: nil, hasNext: index < pages.count - 1, results: pages[index])
            }
        }

        @Test(arguments: ListKind.allCases)
        private func `next pages load page after page`(kind: ListKind) async throws {
            let server = PageServer(pages: [[Entry(id: 1)], [Entry(id: 2)], [Entry(id: 3)]])
            let source = try await loadUntilLastPage(from: server, in: kind)

            #expect(!source.hasNext)
            #expect(server.requests == 2)
            #expect(source.items.map(\.id) == [1, 2, 3])
        }

        @Test(arguments: ListKind.allCases)
        private func `next pages load after pages that add no new items`(kind: ListKind) async throws {
            let server = PageServer(pages: [
                [Entry(id: 1), Entry(id: 2)],
                [],
                [Entry(id: 2)],
                [Entry(id: 3)]
            ])
            let source = try await loadUntilLastPage(from: server, in: kind)

            #expect(!source.hasNext)
            #expect(server.requests == 3)
            #expect(source.items.map(\.id) == [1, 2, 3])
        }

        @Test(arguments: ListKind.allCases)
        private func `an empty first page with a next page requests it`(kind: ListKind) async throws {
            let server = PageServer(pages: [[], [Entry(id: 1)]])
            let source = try await loadUntilLastPage(from: server, in: kind)

            #expect(!source.hasNext)
            #expect(server.requests == 1)
            #expect(source.items.map(\.id) == [1])
        }

        private func loadUntilLastPage(from server: PageServer, in kind: ListKind) async throws -> PaginatedList.DataSource<Entry> {
            let source = PaginatedList.DataSource<Entry>(items: [])
            await source.configureAndLoad {
                server.page(0)
            } nextPageLoader: { _ in
                server.requests += 1
                return server.page(server.requests)
            }

            let window = switch kind {
                case .continuous:
                    makeWindow(rootView: PaginatedList.Continuous(dataSource: source) { entry in
                        Text(verbatim: "\(entry.wrappedValue.id)")
                    })
                case .selection:
                    makeWindow(rootView: PaginatedList.Selection(
                        isPresented: .constant(true),
                        selection: .constant([]),
                        mode: .multi(max: nil),
                        model: source
                    ) { entry in
                        Text(verbatim: "\(entry.id)")
                    })
            }
            defer { window.close() }
            let content = try #require(window.contentView)
            _ = await settles(content) { !source.hasNext }
            return source
        }

        private func makeWindow(rootView: some View) -> NSWindow {
            _ = NSApplication.shared
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 800), styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: rootView)
            window.contentView?.layoutSubtreeIfNeeded()
            return window
        }

        private func settles(_ content: NSView, until condition: () -> Bool) async -> Bool {
            for _ in 0 ..< 300 {
                content.layoutSubtreeIfNeeded()
                if condition() {
                    return true
                }
                try? await Task.sleep(for: .milliseconds(10))
            }
            return condition()
        }
    }
#endif
