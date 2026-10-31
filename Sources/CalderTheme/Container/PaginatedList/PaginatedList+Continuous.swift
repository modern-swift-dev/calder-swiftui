#if canImport(SwiftUI)
    import CalderStdLib
    import CalderSwiftUI
    import CalderUIKit
    import Observation
    import SFSafeSymbols
    import SwiftUI

    public extension PaginatedList {

        /// A SwiftUI view that displays a continuous, non-grouped list of paginated data.
        ///
        /// This view works with a `PaginatedList.DataSource` to load and display data incrementally,
        /// showing a loading indicator after the last item when more data is available. The indicator
        /// requests the next page again after every loaded page, including pages that add no new items.
        /// When a next-page request fails, the indicator is replaced by a row that retries the failed page.
        /// When the data source has no current page, the list requests the first page as soon as it
        /// appears, whatever the height of its header.
        struct Continuous<DataType: Identifiable & Codable & Sendable, Content: View, HeaderContent: View, FooterView: View>: View {
            /// The data source responsible for fetching and managing the paginated data.
            @Bindable var dataSource: DataSource<DataType>

            /// A `ViewBuilder` closure that provides the content for the table header.
            var tableHeader: () -> HeaderContent
            /// A `ViewBuilder` closure that provides the content for the table footer.
            var tableFooter: () -> FooterView
            /// A `ViewBuilder` closure that creates a view for each data item. It receives a `Binding` to the `DataType` item.
            let viewFactory: (Binding<DataType>) -> Content

            /// Initializes a new `Continuous` paginated list.
            ///
            /// - Parameters:
            ///   - dataSource: The data source that provides and manages the paginated data.
            ///   - viewFactory: A closure that generates a `View` for each data item.
            ///   - header: A `ViewBuilder` for the header content of the list.
            ///   - footer: A `ViewBuilder` for the footer content of the list.
            public init(
                dataSource: DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (Binding<DataType>) -> Content,
                @ViewBuilder header: @escaping @MainActor @Sendable () -> HeaderContent,
                @ViewBuilder footer: @escaping @MainActor @Sendable () -> FooterView
            ) {
                self.dataSource = dataSource
                self.tableHeader = header
                self.tableFooter = footer
                self.viewFactory = viewFactory
            }

            /// Initializes a new `Continuous` paginated list with no header or footer.
            /// - Parameters:
            ///   - dataSource: The data source that provides and manages the paginated data.
            ///   - viewFactory: A closure that generates a `View` for each data item.
            public init(
                dataSource: DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (Binding<DataType>) -> Content
            ) where HeaderContent == EmptyView, FooterView == EmptyView {
                self.init(
                    dataSource: dataSource,
                    viewFactory: viewFactory,
                    header: { EmptyView() },
                    footer: { EmptyView() }
                )
            }

            /// Initializes a new `Continuous` paginated list with a custom header and no footer.
            /// - Parameters:
            ///   - dataSource: The data source that provides and manages the paginated data.
            ///   - viewFactory: A closure that generates a `View` for each data item.
            ///   - header: A `ViewBuilder` for the header content of the list.
            public init(
                dataSource: DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (Binding<DataType>) -> Content,
                @ViewBuilder header: @escaping @MainActor @Sendable () -> HeaderContent
            ) where FooterView == EmptyView {
                self.init(
                    dataSource: dataSource,
                    viewFactory: viewFactory,
                    header: header,
                    footer: { EmptyView() }
                )
            }

            /// Initializes a new `Continuous` paginated list with a custom footer and no header.
            /// - Parameters:
            ///   - dataSource: The data source that provides and manages the paginated data.
            ///   - viewFactory: A closure that generates a `View` for each data item.
            ///   - footer: A `ViewBuilder` for the footer content of the list.
            public init(
                dataSource: DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (Binding<DataType>) -> Content,
                @ViewBuilder footer: @escaping @MainActor @Sendable () -> FooterView
            ) where HeaderContent == EmptyView {
                self.init(
                    dataSource: dataSource,
                    viewFactory: viewFactory,
                    header: { EmptyView() },
                    footer: footer
                )
            }

            public var body: some View {
                List {
                    tableHeader()
                        .listRowInsets(EdgeInsets())
                    #if !os(macOS)

                        #if !os(watchOS) && !os(tvOS)
                            .listRowSpacing(0)
                        #endif
                        #if !os(tvOS)
                        .listSectionSpacing(0)
                        #endif
                    #endif
                    #if !os(watchOS) && !os(tvOS)
                    .listRowSeparator(.hidden)
                    #endif
                    .listRowBackground(Color.clear)

                    Section {
                        ForEach($dataSource.items) { item in
                            viewFactory(item)
                                .listRowInsets(EdgeInsets())
                            #if !os(macOS) && !os(watchOS) && !os(tvOS)
                                .listRowSpacing(0)
                            #endif
                        }

                        // A page can add no new items, so the trigger follows all items and
                        // restarts after every loaded page.
                        if dataSource.hasNext {
                            Group {
                                if dataSource.nextPageError != nil {
                                    RetryState {
                                        Task { @MainActor in
                                            await dataSource.next()
                                        }
                                    }
                                } else {
                                    LoadingState()
                                        .task(id: dataSource.loadedNextPageCount) { @MainActor in
                                            await dataSource.next()
                                        }
                                }
                            }
                            .listRowInsets(EdgeInsets())
                            #if !os(macOS) && !os(watchOS) && !os(tvOS)
                                .listRowSpacing(0)
                            #endif
                            #if !os(watchOS) && !os(tvOS)
                            .listRowSeparator(.hidden)
                            #endif
                        }
                    }

                    tableFooter()
                        .listRowInsets(EdgeInsets())
                    #if !os(macOS) && !os(watchOS) && !os(tvOS)
                        .listRowSpacing(0)
                    #endif
                    #if !os(watchOS) && !os(tvOS)
                    .listRowSeparator(.hidden)
                    #endif
                    .listRowBackground(Color.clear)

                    Color.clear.frame(height: .xxxl)
                        .listRowInsets(EdgeInsets())

                    #if !os(macOS)
                        #if !os(watchOS) && !os(tvOS)
                            .listRowSpacing(0)
                        #endif
                        #if !os(tvOS)
                        .listSectionSpacing(0)
                        #endif
                    #endif

                    #if !os(watchOS) && !os(tvOS)
                    .listRowSeparator(.hidden)
                    #endif
                    .listRowBackground(Color.clear)
                }
                // The list loads a missing first page when it appears, not when its lazy last row does.
                .task {
                    await dataSource.load()
                }
            }
        }
    }

#endif

#if DEBUG
    import SnapshotPreviews

    @MainActor enum PaginatedListContinuousPreviews: PreviewProvider, SnapshotProvider {
        static let defaultLayout: PreviewSnapshotLayout = .device
        static var snapshots: [PreviewSnapshot] {
            PreviewSnapshot("default") { Content() }
        }

        private struct Item: Identifiable, Codable, Sendable {
            var id: Int
            var title: String
            var subtitle: String
        }

        private struct Content: View {
            private let model = PaginatedList.DataSource(items: [
                Item(id: 1, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 2, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 3, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 4, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 5, title: .lorem(25), subtitle: .lorem(50))
            ])

            var body: some View {
                NavigationStack {
                    PaginatedList.Continuous(dataSource: model) { data in
                        ListRow<ListRowBody, Never, Never>(content: {
                            ListRowBody(title: data.title.wrappedValue, subtitle: data.subtitle.wrappedValue, caption: nil)
                        }, accessory: Image(systemSymbol: .chevronRight))
                    }
                    #if !os(macOS) && !os(watchOS) && !os(tvOS)
                    .listStyle(.insetGrouped)
                    #endif
                }
            }
        }
    }
#endif
