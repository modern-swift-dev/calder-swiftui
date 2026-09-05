#if canImport(SwiftUI)
import Collections
import Combine
import Foundation
import Observation
import os
import SwiftUI

public extension PaginatedList {

    /// A paging data source that used the paged results api to
    /// lazy load new pages of data into the data-source, and publish
    /// mutate the states accordingly
    ///
    /// This class manages the loading, storing, and state of paginated data.
    @Observable class DataSource<DataType: Identifiable & Codable & Sendable>: @unchecked Sendable {

        /// A unique identifier for debugging purposes.
        let debugId: UUID = .init()

        /// The current state of the data source, indicating whether it's pristine, loading, displaying, or in an error state.
        ///
        /// When the state changes, a debug log message is emitted.
        public private(set) var state: GenericState = .pristine() {
            didSet {
                os_log(
                    "%{public}@",
                    log: .default,
                    type: .debug,
                    "ListDataSource<\(String(describing: DataType.self))>#\(debugId.uuidString) changed to \(String(describing: state)) (count=\(items.count))"
                )
            }
        }

        /// The total count of items available, if known.
        public private(set) var count: Int?
        /// The array of currently loaded data items.
        public internal(set) var items: [DataType]

        /// The most recently loaded page of data.
        private var currentPage: Results<DataType>?
        /// The ID of the current data loading request, used to cancel outdated requests.
        private var currentRequestId: UUID = .init()

        /// A closure responsible for loading the first page of data.
        private var firstPageLoader: @MainActor @Sendable () async throws -> Results<DataType> = {
            Results<DataType>(results: [])
        }

        /// A closure responsible for loading subsequent pages of data.
        private var nextPageLoader: @MainActor @Sendable (Results<DataType>) async throws -> Results<DataType> = { _ in
            Results<DataType>(results: [])
        }

        /// Initializes a new `DataSource` with a given array of items.
        ///
        /// This initializer sets the initial state to `.displaying` and populates the `items` array.
        /// - Parameter items: The initial array of data items.
        public init(
            items: [DataType]
        ) {
            self.items = items
            state = .displaying
            currentPage = .init(results: items)
            count = items.count
            self.firstPageLoader = {
                .init(results: items)
            }
        }

        /// Configures the data source with custom page loading closures and initiates a reload.
        ///
        /// - Parameters:
        ///   - firstPageLoader: A closure to load the initial page of data.
        ///   - nextPageLoader: A closure to load subsequent pages of data, taking the previous page as input.
        public func configureAndLoad(
            firstPageLoader: @MainActor @Sendable @escaping () async throws -> Results<DataType>,
            nextPageLoader: @MainActor @Sendable @escaping (Results<DataType>) async throws -> Results<DataType>
        ) async {
            self.firstPageLoader = firstPageLoader
            self.nextPageLoader = nextPageLoader
            await reload()
        }

        /// Checks if a given item ID corresponds to the last item currently loaded in the data source.
        /// - Parameter id: The ID of the item to check.
        /// - Returns: `true` if the item is the last one, `false` otherwise.
        public func isLast(_ id: DataType.ID) -> Bool {
            items.last?.id == id
        }

        /// Removes a specific item from the data source.
        /// After removal, the view state is recalculated.
        /// - Parameter item: The item to remove.
        public func remove(_ item: DataType) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items.remove(at: index)
            }
            calculateViewState()
        }

        /// Removes an item from the data source by its ID.
        /// After removal, the view state is recalculated.
        /// - Parameter id: The ID of the item to remove.
        public func remove(id: DataType.ID) {
            if let index = items.firstIndex(where: { $0.id == id }) {
                items.remove(at: index)
            }
            calculateViewState()
        }

        /// Inserts or updates an item in the data source.
        ///
        /// If an item with the same ID already exists, it is updated; otherwise, it is appended or inserted.
        /// - Parameters:
        ///   - item: The item to upsert.
        ///   - append: If `true`, the item is appended if it doesn't exist. If `false`, it's inserted at the beginning. Defaults to `true`.
        ///   - computeState: If `true`, the view state is recalculated after the operation. Defaults to `true`.
        public func upsert(_ item: DataType, append: Bool = true, computeState: Bool = true) {
            if let index = items.firstIndex(where: { $0.id == item.id }) {
                items[index] = item
            } else if append {
                items.append(item)
            } else {
                items.insert(item, at: 0)
            }

            if computeState {
                calculateViewState()
            }
        }

        /// Appends a new item after a specified existing item.
        /// - Parameters:
        ///   - item: The new item to append.
        ///   - after: The existing item after which the new item should be appended.
        public func append(item: DataType, after: DataType) {
            if let index = items.firstIndex(where: { $0.id == after.id }) {
                if index == items.endIndex {
                    upsert(item, computeState: false)
                } else {
                    items.insert(item, at: items.index(after: index))
                }
            }
            calculateViewState()

        }

        /// Appends a new item after an item identified by its ID.
        /// - Parameters:
        ///   - item: The new item to append.
        ///   - after id: The ID of the existing item after which the new item should be appended.
        public func append(item: DataType, after id: DataType.ID) {
            if let index = items.firstIndex(where: { $0.id == id }) {
                if index == items.endIndex {
                    upsert(item, computeState: false)
                } else {
                    items.insert(item, at: items.index(after: index))
                    calculateViewState()
                }
            }
        }

        /// Appends all items from a `Results` page to the current list of items.
        /// After appending, the view state is recalculated.
        /// - Parameter page: The `Results` page containing items to append.
        public func appendAll(_ page: Results<DataType>) {
            for value in page.results {
                upsert(value, computeState: false)
            }
            calculateViewState()
        }

        /// Replaces all existing items with the items from a `Results` page.
        /// - Parameter page: The `Results` page containing items to replace all current items.
        public func replaceAll(_ page: Results<DataType>) {
            replaceAll(values: page.results)
        }

        /// Replaces all existing items with a new array of values.
        /// - Parameter values: The new array of items to replace all current items.
        public func replaceAll(values: [DataType]) {
            items = []
            for value in values {
                upsert(value, computeState: false)
            }
            calculateViewState()
        }

        /// Removes all items from the data source and recalculates the view state.
        public func removeAll() {
            currentPage = nil
            items = []
            calculateViewState()
        }

        /// Checks if a given item is the last item currently loaded in the data source.
        /// - Parameter item: The item to check.
        /// - Returns: `true` if the item is the last one, `false` otherwise.
        public func isLast(_ item: DataType) -> Bool {
            items.last?.id == item.id
        }

        /// Reloads the data from the first page in a non-async context.
        public func reload() {
            Task { @MainActor [weak self] in
                await self?.reload()
            }
        }

        /// Reloads the data from the first page, clearing the current page and initiating a new load.
        public func reload() async {
            currentPage = nil
            await load()
        }

        /// Loads the first page of data if no page is currently loaded.
        ///
        /// Sets the state to `.loading`, performs the `firstPageLoader` operation,
        /// and updates the `items` and `state` based on the result. Handles cancellation.
        @MainActor public func load() async {
            do {
                guard currentPage == nil else {
                    return
                }
                state = .loading
                let requestId = UUID()
                currentRequestId = requestId
                let response = try await firstPageLoader()

                guard !Task.isCancelled, requestId == currentRequestId else {
                    calculateViewState()
                    return
                }

                currentPage = response
                count = response.count
                replaceAll(response)
                calculateViewState()
            } catch {
                os_log("%{public}@", log: .default, type: .error, String(describing: error))
                count = nil
                currentPage = nil
                removeAll()
                state = .error(nil)
            }
        }

        /// Recalculates the current view state based on the number of loaded items.
        ///
        /// If `items` is empty, the state is set to `.empty()`; otherwise, it's set to `.displaying`.
        func calculateViewState() {
            if items.isEmpty {
                state = .empty()
                return
            }

            state = .displaying
            os_log(
                "%{public}@",
                log: .default,
                type: .debug,
                "ListDataSource<\(String(describing: DataType.self))>#\(debugId.uuidString) changed to \(String(describing: state)) (count=\(items.count))"
            )
        }

        /// Loads the next page of data if available.
        ///
        /// This method checks if there's a next page and uses the `nextPageLoader` to fetch it.
        /// The new items are then appended to the existing `items`. Error handling is included.
        @MainActor public func next() async {
            do {
                guard let page = currentPage, page.hasNext else {
                    return
                }
                let newPage = try await nextPageLoader(page)
                currentPage = newPage
                appendAll(newPage)
            } catch {
                currentPage = nil
                os_log("%{public}@", log: .default, type: .error, String(describing: error))
            }
        }

        /// A boolean indicating whether there are more pages of data to load.
        public var hasNext: Bool {
            currentPage?.hasNext == true
        }
    }

}

#endif
