import CalderStdLib
import Testing

struct RangeExtTests {
    @Test func `closed range clamps values`() {
        let range = 0 ... 10

        #expect(range.clampedValue(-1) == 0)
        #expect(range.clampedValue(5) == 5)
        #expect(range.clampedValue(11) == 10)
    }

    @Test func `closed range clamps nan to the lower bound`() {
        #expect((0.0 ... 1.0).clampedValue(.nan) == 0.0)
        #expect((-5.0 ... 5.0).clampedValue(.nan) == -5.0)
    }

    @Test func `closed range clamps infinities`() {
        #expect((0.0 ... 1.0).clampedValue(.infinity) == 1.0)
        #expect((0.0 ... 1.0).clampedValue(-.infinity) == 0.0)
    }
}
