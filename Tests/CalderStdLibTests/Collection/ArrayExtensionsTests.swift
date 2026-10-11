@testable import CalderStdLib
import Testing

struct ArrayExtensionsTests {
    private struct TransformError: Error, Equatable {}

    @Test func `hash map`() {
        let mapped = ["a", "b", "c"].hashMap { ($0.uppercased(), $0) }

        #expect(mapped == ["A": "a", "B": "b", "C": "c"])
    }

    @Test func `hash map propagates errors from the transform`() {
        #expect(throws: TransformError()) {
            try ["a", "b", "c"].hashMap { element in
                guard element != "b" else {
                    throw TransformError()
                }
                return (element.uppercased(), element)
            }
        }
    }

    @Test func `hash map keeps the last element for duplicate keys`() {
        let mapped = ["apple", "avocado", "banana"].hashMap { (String($0.prefix(1)), $0) }

        #expect(mapped == ["a": "avocado", "b": "banana"])
    }
}
