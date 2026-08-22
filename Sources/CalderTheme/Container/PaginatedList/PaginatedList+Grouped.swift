#if canImport(SwiftUI)
import CalderStdLib
import CalderSwiftUI
import CalderUIKit
import Observation
import OrderedCollections
import SFSafeSymbols
import SnapshotPreviews
import SwiftUI

public extension PaginatedList {

    /// A SwiftUI view that displays a paginated list with items grouped into sections based on a discriminator.
    ///
    /// Each group of items with the same discriminator will be laid out in a `SwiftUI.Section`.
    struct Grouped<DataType: Identifiable & Codable & Sendable, Content: View>: View {
        @Environment(\.theme) var theme
        /// The data source responsible for fetching and managing the paginated data.
        @Bindable var dataSource: DataSource<DataType>

        /// A closure that provides the grouping key (discriminator) for each data item.
        /// The return `String` value is used to create sections.
        let groupBy: (Binding<DataType>) -> String
        /// A `ViewBuilder` closure that creates a view for each data item. It receives a `Binding` to the `DataType` item.
        let viewFactory: (Binding<DataType>) -> Content

        /// Computes the sections for the list by grouping the data source's items.
        fileprivate var sections: [CollectionGroup<Binding<DataType>>] {
            $dataSource.items.groupedBy(groupBy)
        }

        /// Initializes a new `Grouped` paginated list.
        ///
        /// - Parameters:
        ///   - dataSource: The data source that provides and manages the paginated data.
        ///   - groupBy: A closure that returns a `String` discriminator for each item, used for grouping into sections.
        ///   - viewFactory: A closure that generates a `View` for each data item within a section.
        public init(dataSource: DataSource<DataType>, groupBy: @escaping (Binding<DataType>) -> String, @ViewBuilder viewFactory: @escaping (Binding<DataType>) -> Content) {
            self.dataSource = dataSource
            self.groupBy = groupBy
            self.viewFactory = viewFactory
        }

        public var body: some View {
            List {
                ForEach(sections, id: \.discriminator) { section in
                    Section(content: {
                        ForEach(section.values) { item in
                            viewFactory(item)
                                .listRowInsets(.zero)
                            #if !os(macOS) && !os(watchOS) && !os(tvOS)
                                .listRowSpacing(0)
                            #endif

                            if dataSource.hasNext,
                               let lastSection = sections.last,
                               lastSection.discriminator == section.discriminator,
                               let lastItem = lastSection.values.last,
                               lastItem.id == item.id {
                                LoadingState()
                                    .task {
                                        await dataSource.next()
                                    }
                            }
                        }
                    }, header: {
                        Text(verbatim: section.discriminator)
                            .font(.headline)
                            .foregroundStyle(theme.text1)
                            .textCase(.none)
                    })
                }

                Color.clear.frame(height: .xxxl)
                    .listRowInsets(.zero)
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
                .task {
                    await dataSource.load()
                }
            }
        }
    }
}

private extension String {

    /// Generates a lexical grouping character for the string.
    ///
    /// This property transforms the string by stripping diacritics, trimming whitespace,
    /// uppercasing the first character, and then returning that character. If the character
    /// is a number or symbol, it defaults to "#".
    var lexicalGrouping: Character {
        let character: Character = applyingTransform(.stripDiacritics, reverse: false)?
            .trimmingCharacters(in: .whitespacesAndNewlines.union(.controlCharacters).union(.illegalCharacters))
            .uppercased()
            .first ?? "#"

        return !character.isNumber && !character.isSymbol ? character : Character("#")
    }
}

/// A simple struct for collection group, that are groupedBy a discriminator
/// A structure to hold a group of items, identified by a discriminator.
private struct CollectionGroup<DataType> {
    /// The string discriminator used to group the values.
    let discriminator: String
    /// An array of data items belonging to this group.
    var values: [DataType]
}

private extension Collection {

    /// Groups the elements of a collection into `CollectionGroup` instances based on a provided callback.
    ///
    /// This method allows for easy organization of data into sections, suitable for display in `SwiftUI.List` or `SwiftUI.Section`.
    /// The groups are returned sorted by their discriminator.
    /// - Parameter callback: A closure that takes an element of the collection and returns a `String` to be used as the discriminator for grouping.
    /// - Returns: An array of `CollectionGroup` instances, each containing items that share the same discriminator.
    func groupedBy(_ callback: (Self.Element) -> String) -> [CollectionGroup<Self.Element>] {
        var results = OrderedDictionary<String, CollectionGroup<Self.Element>>()
        for item in self {
            let discriminator = callback(item)
            var currentGroup = results[discriminator] ?? .init(discriminator: discriminator, values: [])
            if currentGroup.discriminator != discriminator {
                currentGroup = .init(discriminator: discriminator, values: [])
            }
            currentGroup.values.append(item)
            results[discriminator] = currentGroup
        }

        return Array(results.values).sorted { lhs, rhs in
            lhs.discriminator < rhs.discriminator
        }
    }
}

#endif

#if DEBUG
@MainActor enum PaginatedListGroupedPreviews: PreviewProvider, SnapshotProvider {
    static let defaultLayout: PreviewSnapshotLayout = .device
    static var snapshots: [PreviewSnapshot] {
        PreviewSnapshot("default") { Content() }
    }

    private struct Item: Identifiable, Codable, Sendable { var id: Int; var title: String; var subtitle: String }
    private struct Content: View {
        private let model = PaginatedList.DataSource(items: [
            Item(id: 1, title: "Alpha", subtitle: .lorem(50)), Item(id: 2, title: "Beta", subtitle: .lorem(50)),
            Item(id: 3, title: "Circadia", subtitle: .lorem(50)), Item(id: 4, title: "Delta", subtitle: .lorem(50)),
            Item(id: 5, title: "Epsilon", subtitle: .lorem(50))
        ])
        var body: some View {
            NavigationStack {
                PaginatedList.Grouped(
                    dataSource: model,
                    groupBy: { $0.wrappedValue.title },
                    viewFactory: { data in
                        ListRow<ListRowBody, Never, Never>(content: {
                            ListRowBody(
                                title: data.title.wrappedValue,
                                subtitle: data.subtitle.wrappedValue,
                                caption: nil
                            )
                        }, accessory: Image(systemSymbol: .chevronRight))
                    }
                )
                #if !os(macOS) && !os(watchOS) && !os(tvOS)
                .listStyle(.insetGrouped)
                #endif
            }
        }
    }
}
#endif
