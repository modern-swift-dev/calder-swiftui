import CalderStdLib
import Testing

struct RangeExtTests {
    @Test func `closed range clamps values`() {
        let range = 0 ... 10

        #expect(range.clampedValue(-1) == 0)
        #expect(range.clampedValue(5) == 5)
        #expect(range.clampedValue(11) == 10)
    }
}
