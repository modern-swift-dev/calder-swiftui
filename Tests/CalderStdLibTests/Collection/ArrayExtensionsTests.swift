@testable import CalderStdLib
import Testing

struct ArrayExtensionsTests {
    @Test func `hash map`() {
        let mapped = ["a", "b", "c"].hashMap { ($0.uppercased(), $0) }

        #expect(mapped == ["A": "a", "B": "b", "C": "c"])
    }
}
