#if canImport(SwiftUI)
@testable import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct PaginatedListSelectionTests {
    private struct Item: Identifiable, Codable, Sendable {
        let id: Int
    }

    @MainActor private final class State {
        var selection: [Item] = []
        var isPresented = true

        func view(mode: PaginatedList.Selection<Item, EmptyView, EmptyView, EmptyView>.Mode) -> PaginatedList.Selection<Item, EmptyView, EmptyView, EmptyView> {
            PaginatedList.Selection(
                isPresented: Binding(get: { self.isPresented }, set: { self.isPresented = $0 }),
                selection: Binding(get: { self.selection }, set: { self.selection = $0 }),
                mode: mode,
                model: .init(items: [Item(id: 1), Item(id: 2)])
            ) { _ in EmptyView() }
        }
    }

    @Test func `multi selection publishes every toggle without dismissing`() {
        let state = State()
        let view = state.view(mode: .multi(max: nil))
        view.onSelection(item: Item(id: 1))
        #expect(state.selection.map(\.id) == [1])
        view.onSelection(item: Item(id: 2))
        #expect(state.selection.map(\.id) == [1, 2])
        view.onSelection(item: Item(id: 1))
        #expect(state.selection.map(\.id) == [2])
        #expect(state.isPresented)
    }

    @Test func `single selection publishes and dismisses`() {
        let state = State()
        let view = state.view(mode: .single)
        view.onSelection(item: Item(id: 2))
        #expect(state.selection.map(\.id) == [2])
        #expect(!state.isPresented)
    }

    @Test func `deselecting the current single selection clears the binding`() {
        let state = State()
        state.selection = [Item(id: 1)]
        let view = state.view(mode: .single)
        view.onSelection(item: Item(id: 1))
        #expect(state.selection.isEmpty)
        #expect(state.isPresented)
    }

    @Test func `selection limit permits deselection and subsequent selection`() {
        let state = State()
        state.selection = [Item(id: 1)]
        let view = state.view(mode: .multi(max: 1))
        #expect(view.isMaxReached)
        view.onSelection(item: Item(id: 2))
        #expect(state.selection.map(\.id) == [1])
        view.onSelection(item: Item(id: 1))
        #expect(!view.isMaxReached)
        view.onSelection(item: Item(id: 2))
        #expect(state.selection.map(\.id) == [2])
    }

    @Test func `selection reflects external binding changes`() {
        let state = State()
        let view = state.view(mode: .multi(max: nil))
        state.selection = [Item(id: 2)]
        view.onSelection(item: Item(id: 2))
        #expect(state.selection.isEmpty)
    }
}
#endif
