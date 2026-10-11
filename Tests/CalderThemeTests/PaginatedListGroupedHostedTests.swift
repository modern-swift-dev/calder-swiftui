#if os(macOS)
    import AppKit
    import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized, .timeLimit(.minutes(1)))
    @MainActor struct PaginatedListGroupedHostedTests {
        private struct Entry: Identifiable, Codable, Sendable {
            let id: Int
            let day: String
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

        @Test func `next pages load when a page only fills earlier sections`() async throws {
            // Newest-first data: sections sort ascending, so every later page fills an earlier section
            // and the last item of the last section never changes.
            let server = PageServer(pages: [
                [Entry(id: 1, day: "2026-10-11"), Entry(id: 2, day: "2026-10-10")],
                [Entry(id: 3, day: "2026-10-09")],
                [Entry(id: 4, day: "2026-10-08")]
            ])
            let source = try await loadUntilLastPage(from: server)

            #expect(!source.hasNext)
            #expect(server.requests == 2)
            #expect(source.items.map(\.id) == [1, 2, 3, 4])
        }

        @Test func `next pages load after pages that add no new items`() async throws {
            let server = PageServer(pages: [
                [Entry(id: 1, day: "2026-10-11"), Entry(id: 2, day: "2026-10-10")],
                [],
                [Entry(id: 2, day: "2026-10-10")],
                [Entry(id: 3, day: "2026-10-09")]
            ])
            let source = try await loadUntilLastPage(from: server)

            #expect(!source.hasNext)
            #expect(server.requests == 3)
            #expect(source.items.map(\.id) == [1, 2, 3])
        }

        private func loadUntilLastPage(from server: PageServer) async throws -> PaginatedList.DataSource<Entry> {
            let source = PaginatedList.DataSource<Entry>(items: [])
            await source.configureAndLoad {
                server.page(0)
            } nextPageLoader: { _ in
                server.requests += 1
                return server.page(server.requests)
            }

            let window = makeWindow(rootView: PaginatedList.Grouped(dataSource: source, groupBy: { $0.wrappedValue.day }, viewFactory: { entry in
                Text(verbatim: "\(entry.wrappedValue.id)")
            }))
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
