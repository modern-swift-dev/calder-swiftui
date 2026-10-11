#if canImport(SwiftUI)
    import CalderTheme
    import Foundation
    import Testing

    struct PaginatedListResultsTests {
        private struct Item: Codable, Sendable, Equatable {
            let id: Int
        }

        @Test func `explicit has next survives a round trip without a next URL`() throws {
            let page = PaginatedList.Results(count: 2, next: nil, hasNext: true, results: [Item(id: 1)])

            let data = try JSONEncoder().encode(page)
            let decoded = try JSONDecoder().decode(PaginatedList.Results<Item>.self, from: data)

            #expect(decoded.hasNext)
            #expect(decoded.next == nil)
            #expect(decoded.count == 2)
            #expect(decoded.results == [Item(id: 1)])
        }

        @Test func `explicit no next page survives a round trip with a next URL`() throws {
            let page = PaginatedList.Results(next: URL(string: "https://example.com/page-2"), hasNext: false, results: [Item(id: 1)])

            let data = try JSONEncoder().encode(page)
            let decoded = try JSONDecoder().decode(PaginatedList.Results<Item>.self, from: data)

            #expect(!decoded.hasNext)
            #expect(decoded.next == URL(string: "https://example.com/page-2"))
        }

        @Test(arguments: [
            (#"{"next": "https://example.com/page-2", "results": [{"id": 1}]}"#, true),
            (#"{"next": "https://example.com/page-2", "results": []}"#, false),
            (#"{"results": [{"id": 1}]}"#, false)
        ])
        func `missing has next falls back to the next URL`(json: String, hasNext: Bool) throws {
            let decoded = try JSONDecoder().decode(PaginatedList.Results<Item>.self, from: Data(json.utf8))

            #expect(decoded.hasNext == hasNext)
        }
    }
#endif
