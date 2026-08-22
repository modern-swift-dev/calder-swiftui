@testable import CalderStdLib
import Foundation
import Testing

@Suite(.serialized) struct StringLoremTests {
    // MARK: - Lorem Ipsum Constant

    @Test func `lorem ipsum exists`() {
        #expect(String.loremIpsum.isEmpty == false)
        #expect(String.loremIpsum.hasPrefix("Lorem ipsum"))
    }

    // MARK: - Lorem Function

    @Test func `lorem with length`() {
        let result = String.lorem(10)
        #expect(result.count == 10)
        #expect(result == "Lorem ipsu")
    }

    @Test func `lorem with zero length`() {
        #expect(String.lorem(0) == "")
    }

    @Test func `lorem with negative length`() {
        #expect(String.lorem(-5) == "")
    }

    @Test func `lorem with large length`() {
        // When length exceeds loremIpsum, return full loremIpsum
        let fullLength = String.loremIpsum.count
        let result = String.lorem(fullLength + 1000)
        #expect(result == String.loremIpsum)
    }

    @Test func `lorem with exact length`() {
        let fullLength = String.loremIpsum.count
        let result = String.lorem(fullLength)
        #expect(result == String.loremIpsum)
    }
}
