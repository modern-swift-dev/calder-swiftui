#if canImport(SwiftUI)
    import CalderStdLib
    import Foundation
    import SwiftUI

    public extension PaginatedList {
        /// A SwiftUI view for selecting items from a paginated list, supporting single or multiple selections.
        ///
        /// This view integrates with a `PaginatedList.DataSource` to display selectable items
        /// and writes each selection change to the supplied binding. Multi-selection
        /// leaves the view presented; selecting a single item dismisses it. Selected rows
        /// carry the `isSelected` accessibility trait.
        ///
        /// When the data source's items change, the view keeps the binding in sync: selected
        /// items that were loaded and are no longer in the data source, such as after
        /// `remove(_:)` or a reload, leave the selection, and the other selected items are
        /// replaced with their loaded values. Selected items that haven't been loaded stay selected.
        struct Selection<DataType: Identifiable & Codable & Sendable, Content: View, Header: View, Footer: View>: View {

            /// Defines the selection mode for the list.
            public enum Mode: Equatable {
                /// Allows only a single item to be selected.
                case single
                /// Allows multiple items to be selected, with an optional maximum limit.
                ///
                /// Selected items can always be deselected. Once the limit is reached, unselected
                /// items are disabled.
                /// - Parameter max: The maximum number of items that can be selected, or `nil` for no limit.
                ///   A maximum of `0` permits no new selections; it does not mean unlimited.
                case multi(max: UInt?)
            }

            /// A binding to control the presentation state of the selection view (e.g., as a sheet).
            @Binding var isPresented: Bool
            /// A binding to an array that stores the selected data items.
            @Binding var selection: [DataType]
            /// The selection mode (single or multiple).
            let mode: Mode
            /// The data source providing the paginated items.
            var model: PaginatedList.DataSource<DataType>

            /// A `ViewBuilder` closure that provides the content for the table header.
            var tableHeader: @MainActor @Sendable () -> Header
            /// A `ViewBuilder` closure that provides the content for the table footer.
            var tableFooter: @MainActor @Sendable () -> Footer
            /// A `ViewBuilder` closure that creates a view for each data item.
            var viewFactory: @MainActor @Sendable (DataType) -> Content

            /// A boolean indicating whether the maximum selection limit has been reached in multi-selection mode.
            var isMaxReached: Bool {
                if case let .multi(max) = mode, let max {
                    return selection.count >= max
                }
                return false
            }

            /// Initializes a new `Selection` view.
            ///
            /// - Parameters:
            ///   - isPresented: A binding to a boolean that controls the presentation of this view.
            ///   - selection: A binding to an array that will hold the selected items.
            ///   - mode: The selection mode (`.single` or `.multi`).
            ///   - model: The `PaginatedList.DataSource` to fetch items from.
            ///   - viewFactory: A closure that creates the content view for each item.
            ///   - header: A `ViewBuilder` for the list's header.
            ///   - footer: A `ViewBuilder` for the list's footer.
            public init(
                isPresented: Binding<Bool>,
                selection: Binding<[DataType]>,
                mode: Mode,
                model: PaginatedList.DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (DataType) -> Content,
                @ViewBuilder header: @escaping @MainActor @Sendable () -> Header,
                @ViewBuilder footer: @escaping @MainActor @Sendable () -> Footer
            ) {
                _isPresented = isPresented
                _selection = selection
                self.mode = mode
                self.model = model
                self.tableHeader = header
                self.tableFooter = footer
                self.viewFactory = viewFactory
            }

            /// Initializes a new `Selection` view with no header or footer.
            /// - Parameters:
            ///   - isPresented: A binding to a boolean that controls the presentation of this view.
            ///   - selection: A binding to an array that will hold the selected items.
            ///   - mode: The selection mode (`.single` or `.multi`).
            ///   - model: The `PaginatedList.DataSource` to fetch items from.
            ///   - viewFactory: A closure that creates the content view for each item.
            public init(
                isPresented: Binding<Bool>,
                selection: Binding<[DataType]>,
                mode: Mode,
                model: PaginatedList.DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (DataType) -> Content
            ) where Header == EmptyView, Footer == EmptyView {
                self.init(
                    isPresented: isPresented,
                    selection: selection,
                    mode: mode,
                    model: model,
                    viewFactory: viewFactory,
                    header: { EmptyView() },
                    footer: { EmptyView() }
                )
            }

            /// Initializes a new `Selection` view with a custom header and no footer.
            /// - Parameters:
            ///   - isPresented: A binding to a boolean that controls the presentation of this view.
            ///   - selection: A binding to an array that will hold the selected items.
            ///   - mode: The selection mode (`.single` or `.multi`).
            ///   - model: The `PaginatedList.DataSource` to fetch items from.
            ///   - viewFactory: A closure that creates the content view for each item.
            ///   - header: A `ViewBuilder` for the list's header.
            public init(
                isPresented: Binding<Bool>,
                selection: Binding<[DataType]>,
                mode: Mode,
                model: PaginatedList.DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (DataType) -> Content,
                @ViewBuilder header: @escaping @MainActor @Sendable () -> Header
            ) where Footer == EmptyView {
                self.init(
                    isPresented: isPresented,
                    selection: selection,
                    mode: mode,
                    model: model,
                    viewFactory: viewFactory,
                    header: header,
                    footer: { EmptyView() }
                )
            }

            /// Initializes a new `Selection` view with a custom footer and no header.
            /// - Parameters:
            ///   - isPresented: A binding to a boolean that controls the presentation of this view.
            ///   - selection: A binding to an array that will hold the selected items.
            ///   - mode: The selection mode (`.single` or `.multi`).
            ///   - model: The `PaginatedList.DataSource` to fetch items from.
            ///   - viewFactory: A closure that creates the content view for each item.
            ///   - footer: A `ViewBuilder` for the list's footer.
            public init(
                isPresented: Binding<Bool>,
                selection: Binding<[DataType]>,
                mode: Mode,
                model: PaginatedList.DataSource<DataType>,
                @ViewBuilder viewFactory: @escaping @MainActor @Sendable (DataType) -> Content,
                @ViewBuilder footer: @escaping @MainActor @Sendable () -> Footer
            ) where Header == EmptyView {
                self.init(
                    isPresented: isPresented,
                    selection: selection,
                    mode: mode,
                    model: model,
                    viewFactory: viewFactory,
                    header: { EmptyView() },
                    footer: footer
                )
            }

            /// Checks if a given item is currently selected.
            /// - Parameter item: The item to check.
            /// - Returns: `true` if the item is selected, `false` otherwise.
            private func isSelected(item: DataType) -> Bool {
                selection.contains(where: { $0.id == item.id })
            }

            /// Creates a `PaginatedList.SelectionItem` for a given item, wrapping the custom content and selection indicator.
            /// - Parameter item: A `Binding` to the data item.
            /// - Returns: A `PaginatedList.SelectionItem` view.
            private func createItemView(item: Binding<DataType>) -> PaginatedList.SelectionItem<Content> {
                PaginatedList.SelectionItem(selected: isSelected(item: item.wrappedValue)) {
                    viewFactory(item.wrappedValue)
                }
            }

            /// The loaded item IDs and the revision of the data source's items, used to observe item changes.
            private struct LoadedItems: Equatable {
                let ids: [DataType.ID]
                let revision: Int
            }

            /// Removes selected items that were loaded before an item change and are no longer
            /// loaded, and replaces the other selected items with their loaded values.
            /// - Parameter previousIDs: The IDs of the items loaded before the change.
            private func reconcileSelection(previousIDs: [DataType.ID]) {
                guard !selection.isEmpty else {
                    return
                }
                let loaded = Dictionary(model.items.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last })
                let removed = Set(previousIDs).subtracting(loaded.keys)
                selection = selection.compactMap { selected in
                    removed.contains(selected.id) ? nil : loaded[selected.id] ?? selected
                }
            }

            /// Handles the selection/deselection of an item based on the current selection mode.
            /// - Parameter item: The item that was tapped.
            func onSelection(item: DataType) {
                if let index = selection.firstIndex(where: { $0.id == item.id }) {
                    selection.remove(at: index)
                } else {
                    guard !isMaxReached else {
                        return
                    }
                    switch mode {
                        case .single:
                            selection = [item]
                        case .multi:
                            selection.append(item)
                    }
                }

                if mode == .single, !selection.isEmpty {
                    isPresented = false
                }
            }

            public var body: some View {
                PaginatedList.Continuous(
                    dataSource: model,
                    viewFactory: { item in
                        Button(action: {
                            onSelection(item: item.wrappedValue)
                        }, label: {
                            createItemView(item: item)
                        })
                        .buttonStyle(.plain)
                        .disabled(!isSelected(item: item.wrappedValue) && isMaxReached)
                        .accessibilityAddTraits(isSelected(item: item.wrappedValue) ? .isSelected : [])
                    },
                    header: tableHeader,
                    footer: tableFooter
                )
                .onChange(of: LoadedItems(ids: model.items.map(\.id), revision: model.itemsRevision)) { previous, _ in
                    reconcileSelection(previousIDs: previous.ids)
                }
            }
        }
    }

#endif

#if DEBUG
    import SnapshotPreviews

    @MainActor enum PaginatedListSelectionPreviews: PreviewProvider, SnapshotProvider {
        static let defaultLayout: PreviewSnapshotLayout = .device

        static var snapshots: [PreviewSnapshot] {
            PreviewSnapshot("single") { Content(isMulti: false) }
            PreviewSnapshot("multi") { Content(isMulti: true) }
        }

        private struct Item: Identifiable, Codable, Sendable { var id: Int; var title: String; var subtitle: String }

        private struct Content: View {
            let isMulti: Bool
            @State private var selection: [Item] = []
            private let model = PaginatedList.DataSource(items: [
                Item(id: 1, title: .lorem(25), subtitle: .lorem(50)), Item(id: 2, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 3, title: .lorem(25), subtitle: .lorem(50)), Item(id: 4, title: .lorem(25), subtitle: .lorem(50)),
                Item(id: 5, title: .lorem(25), subtitle: .lorem(50))
            ])

            var body: some View {
                NavigationStack {
                    PaginatedList.Selection(
                        isPresented: .constant(true),
                        selection: $selection,
                        mode: isMulti ? .multi(max: 5) : .single,
                        model: model
                    ) { data in
                        ListRow<_, Never, Never>(content: {
                            ListRowBody(title: data.title, subtitle: data.subtitle, caption: nil)
                        })
                    }
                    #if !os(watchOS) && !os(tvOS)
                    .listStyle(.inset)
                    #endif
                }
            }
        }
    }
#endif
