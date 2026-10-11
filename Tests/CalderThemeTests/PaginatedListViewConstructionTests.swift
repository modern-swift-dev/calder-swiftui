#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    @testable import CalderTheme
    import SwiftUI
    import Testing

    @MainActor struct PaginatedListViewConstructionTests {

        @Test func `continuous places header content in the header`() {
            let source = PaginatedList.DataSource(items: [
                item(1, title: "Alpha")
            ])
            let view = PaginatedList.Continuous(dataSource: source, viewFactory: { item in
                Text(item.wrappedValue.title)
            }, header: {
                Text("Header")
            })

            #expect(view.tableHeader() == Text("Header"))
        }

        @Test func `continuous places footer content in the footer`() {
            let source = PaginatedList.DataSource(items: [
                item(1, title: "Alpha")
            ])
            let view = PaginatedList.Continuous(dataSource: source, viewFactory: { item in
                Text(item.wrappedValue.title)
            }, footer: {
                Text("Footer")
            })

            #expect(view.tableFooter() == Text("Footer"))
        }

        @Test func `continuous places header and footer content`() {
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

            #expect(view.tableHeader() == Text("Header"))
            #expect(view.tableFooter() == Text("Footer"))
        }

        @Test func `continuous and grouped construct body after a failed next page`() async {
            let source = PaginatedList.DataSource<PaginatedListViewTestItem>(items: [])
            await source.configureAndLoad {
                PaginatedList.Results(
                    next: URL(string: "https://example.com/next"),
                    hasNext: true,
                    results: [item(1, title: "Alpha")]
                )
            } nextPageLoader: { _ in
                throw URLError(.notConnectedToInternet)
            }
            await source.next()
            #expect(source.nextPageError != nil)

            let continuous = PaginatedList.Continuous(dataSource: source) { item in
                Text(item.wrappedValue.title)
            }
            let grouped = PaginatedList.Grouped(dataSource: source, groupBy: { item in
                String(item.wrappedValue.title.prefix(1))
            }, viewFactory: { item in
                Text(item.wrappedValue.title)
            })

            _ = continuous.body
            _ = grouped.body
        }

        @Test func `selection places header content in the header`() {
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

            #expect(view.tableHeader() == Text("Header"))
        }

        @Test func `selection places footer content in the footer`() {
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

            #expect(view.tableFooter() == Text("Footer"))
        }

        @Test func `selection places header and footer content`() {
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

            #expect(view.tableHeader() == Text("Header"))
            #expect(view.tableFooter() == Text("Footer"))
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
