#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
@testable import CalderTheme
import SwiftUI
import Testing

@Suite(.serialized)
@MainActor struct PaginatedListViewConstructionTests {

    @Test func `continuous constructs body with default header and footer`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha"),
            item(2, title: "Beta")
        ])
        let view = PaginatedList.Continuous(dataSource: source) { item in
            Text(item.wrappedValue.title)
        }

        _ = view.body
    }

    @Test func `continuous constructs body with header only`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Continuous(dataSource: source, viewFactory: { item in
            Text(item.wrappedValue.title)
        }, header: {
            Text("Header")
        })

        _ = view.body
    }

    @Test func `continuous constructs body with footer only`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Continuous(dataSource: source, viewFactory: { item in
            Text(item.wrappedValue.title)
        }, footer: {
            Text("Footer")
        })

        _ = view.body
    }

    @Test func `continuous constructs body with header and footer`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Continuous(dataSource: source, viewFactory: { item in
            Text(item.wrappedValue.title)
        }, header: {
            Text("Header")
        }, footer: {
            Text("Footer")
        })

        _ = view.body
    }

    @Test func `grouped constructs body and groups by discriminator`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Beta"),
            item(2, title: "Alpha"),
            item(3, title: "Beta")
        ])
        let view = PaginatedList.Grouped(dataSource: source, groupBy: { item in
            String(item.wrappedValue.title.prefix(1))
        }, viewFactory: { item in
            Text(item.wrappedValue.title)
        })

        _ = view.body
    }

    @Test func `grouped constructs body with next page`() async {
        let source = PaginatedList.DataSource<PaginatedListViewTestItem>(items: [])
        await source.configureAndLoad {
            PaginatedList.Results(
                next: URL(string: "https://example.com/next"),
                hasNext: true,
                results: [
                    item(1, title: "Beta"),
                    item(2, title: "Alpha")
                ]
            )
        } nextPageLoader: { _ in
            PaginatedList.Results(results: [
                item(3, title: "Gamma")
            ])
        }
        let view = PaginatedList.Grouped(dataSource: source, groupBy: { item in
            String(item.wrappedValue.title.prefix(1))
        }, viewFactory: { item in
            Text(item.wrappedValue.title)
        })

        _ = view.body
    }

    @Test func `selection constructs body with default header and footer`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha"),
            item(2, title: "Beta")
        ])
        let view = PaginatedList.Selection(
            isPresented: .constant(true),
            selection: .constant([item(1, title: "Alpha")]),
            mode: .single,
            model: source,
            viewFactory: { item in
                Text(item.title)
            }
        )

        _ = view.body
    }

    @Test func `selection constructs body with header only`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Selection(
            isPresented: .constant(true),
            selection: .constant([]),
            mode: .multi(max: 1),
            model: source,
            viewFactory: { item in
                Text(item.title)
            },
            header: {
                Text("Header")
            }
        )

        _ = view.body
    }

    @Test func `selection constructs body with footer only`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Selection(
            isPresented: .constant(true),
            selection: .constant([]),
            mode: .multi(max: nil),
            model: source,
            viewFactory: { item in
                Text(item.title)
            },
            footer: {
                Text("Footer")
            }
        )

        _ = view.body
    }

    @Test func `selection constructs body with header and footer`() {
        let source = PaginatedList.DataSource(items: [
            item(1, title: "Alpha")
        ])
        let view = PaginatedList.Selection(
            isPresented: .constant(true),
            selection: .constant([]),
            mode: .multi(max: 2),
            model: source,
            viewFactory: { item in
                Text(item.title)
            },
            header: {
                Text("Header")
            },
            footer: {
                Text("Footer")
            }
        )

        _ = view.body
    }

    private func item(_ id: Int, title: String) -> PaginatedListViewTestItem {
        PaginatedListViewTestItem(id: id, title: title)
    }
}

private struct PaginatedListViewTestItem: Codable, Identifiable, Sendable {
    let id: Int
    let title: String
}

#endif
