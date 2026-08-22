#if canImport(SwiftUI)
import Foundation

public extension PaginatedList {

    /// A generic structure to wrap a list of objects in an API paginated response.
    ///
    /// This structure typically represents a single page of results from a paginated API endpoint,
    /// including the total count of items, a URL for the next page, and the actual results.
    struct Results<T: Codable & Sendable>: Codable, Sendable {
        /// The total count of all items available across all pages, if provided by the API.
        public let count: Int?
        /// The URL for the next page of results. If `nil`, there are no more pages.
        public let next: URL?
        /// The array of data items for the current page.
        public let results: [T]

        /// A boolean indicating whether there is a next page of results.
        ///
        /// Note that the `next` URL may sometimes be populated even when there are no more
        /// actual results (e.g., if the backend always returns a `next` URL to reduce count queries).
        /// Therefore, `hasNext` is determined by both the presence of a `next` URL and
        /// whether the `results` array for the current page is empty.
        public let hasNext: Bool

        /// Initializes a new `Results` instance with explicit properties for a paginated response.
        ///
        /// - Parameters:
        ///   - count: The total count of items. Defaults to `nil`.
        ///   - next: The URL for the next page.
        ///   - hasNext: Explicitly set whether there's a next page. If `nil`, it's derived from `next` and `results.isEmpty`.
        ///   - results: The array of items for the current page.
        public init(count: Int? = nil, next: URL?, hasNext: Bool? = nil, results: [T]) {
            self.count = count
            self.next = next
            self.results = results

            if let hasNext {
                self.hasNext = hasNext
            } else {
                self.hasNext = (next != nil) && !results.isEmpty
            }
        }

        /// Initializes a new `Results` instance with only a list of results, implying no further pagination.
        ///
        /// - Parameter results: The array of items for this single page.
        public init(results: [T]) {
            count = results.count
            next = nil
            hasNext = false
            self.results = results
        }

        /// Coding keys for encoding and decoding the `Results` structure.
        public enum CodingKeys: String, CodingKey {
            case count
            case next
            case results
            case hasNext
        }

        /// Encodes the `Results` instance into the given encoder.
        ///
        /// - Parameter encoder: The encoder to write data to.
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Results<T>.CodingKeys.self)
            try container.encodeIfPresent(count, forKey: .count)
            try container.encodeIfPresent(next, forKey: .next)
            try container.encode(results, forKey: .results)
        }

        /// Initializes a new `Results` instance from the given decoder.
        ///
        /// - Parameter decoder: The decoder to read data from.
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Results<T>.CodingKeys> = try decoder.container(keyedBy: Results<T>.CodingKeys.self)
            count = try container.decodeIfPresent(Int.self, forKey: Results<T>.CodingKeys.count)
            next = try container.decodeIfPresent(URL.self, forKey: Results<T>.CodingKeys.next)
            results = try container.decode([T].self, forKey: Results<T>.CodingKeys.results)
            // hasNext is derived during decoding to correctly reflect if there are more pages.
            // It's true only if a 'next' URL is present and the current 'results' are not empty.
            hasNext = (next != nil) && !results.isEmpty
        }
    }
}

#endif
