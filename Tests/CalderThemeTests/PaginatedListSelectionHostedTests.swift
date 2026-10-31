#if os(macOS)
    import AppKit
    import CalderTheme
    import Foundation
    import SwiftUI
    import Testing

    @Suite(.serialized, .timeLimit(.minutes(1)))
    @MainActor struct PaginatedListSelectionHostedTests {
        private struct Entry: Identifiable, Codable, Sendable {
            let id: Int
            var title: String
        }

        @MainActor private final class SelectionState {
            var selection: [Entry]

            init(selection: [Entry]) {
                self.selection = selection
            }
        }

        @Test func `removing a selected item drops it from the selection and frees the limit`() async throws {
            let source = PaginatedList.DataSource(items: [Entry(id: 1, title: "1"), Entry(id: 2, title: "2"), Entry(id: 3, title: "3")])
            let state = SelectionState(selection: [Entry(id: 1, title: "1"), Entry(id: 2, title: "2")])
            let window = makeWindow(source: source, state: state, mode: .multi(max: 2))
            defer { window.close() }
            let content = try #require(window.contentView)
            _ = await settles(content) { false }

            source.remove(id: 1)
            #expect(await settles(content) { state.selection.map(\.id) == [2] })
        }

        @Test func `reloading drops items that are gone and refreshes stored values`() async throws {
            let source = PaginatedList.DataSource(items: [Entry(id: 1, title: "1"), Entry(id: 2, title: "2")])
            let state = SelectionState(selection: [Entry(id: 1, title: "1"), Entry(id: 2, title: "2")])
            let window = makeWindow(source: source, state: state, mode: .multi(max: nil))
            defer { window.close() }
            let content = try #require(window.contentView)
            _ = await settles(content) { false }

            await source.configureAndLoad {
                PaginatedList.Results(results: [Entry(id: 2, title: "two"), Entry(id: 3, title: "3")])
            } nextPageLoader: { _ in
                PaginatedList.Results(results: [])
            }
            #expect(await settles(content) { state.selection.map(\.title) == ["two"] })

            await source.configureAndLoad {
                PaginatedList.Results(results: [Entry(id: 2, title: "updated"), Entry(id: 3, title: "3")])
            } nextPageLoader: { _ in
                PaginatedList.Results(results: [])
            }
            #expect(await settles(content) { state.selection.map(\.title) == ["updated"] })
        }

        @Test func `selected items that were never loaded stay selected`() async throws {
            let source = PaginatedList.DataSource<Entry>(items: [])
            let state = SelectionState(selection: [Entry(id: 9, title: "9")])
            let window = makeWindow(source: source, state: state, mode: .multi(max: nil))
            defer { window.close() }
            let content = try #require(window.contentView)

            await source.configureAndLoad {
                PaginatedList.Results(next: nil, hasNext: true, results: [Entry(id: 1, title: "1")])
            } nextPageLoader: { _ in
                PaginatedList.Results(results: [Entry(id: 9, title: "nine")])
            }
            #expect(await settles(content) { state.selection.map(\.title) == ["nine"] })
        }

        private func makeWindow(source: PaginatedList.DataSource<Entry>, state: SelectionState, mode: PaginatedList.Selection<Entry, Text, EmptyView, EmptyView>.Mode) -> NSWindow {
            _ = NSApplication.shared
            let window = NSWindow(contentRect: CGRect(x: 0, y: 0, width: 320, height: 800), styleMask: .borderless, backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: PaginatedList.Selection(
                isPresented: .constant(true),
                selection: Binding(get: { state.selection }, set: { state.selection = $0 }),
                mode: mode,
                model: source
            ) { entry in
                Text(verbatim: entry.title)
            })
            window.contentView?.layoutSubtreeIfNeeded()
            return window
        }

        private func settles(_ content: NSView, until condition: () -> Bool) async -> Bool {
            for _ in 0 ..< 100 {
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
