@testable import CalderStdLib
#if canImport(CoreGraphics)
import CoreGraphics
#endif
import Testing

struct BinaryFloatingPointExtTests {
    @Test func `Double conversion`() {
        #expect(Float(42.5).double == 42.5)
    }

    #if canImport(CoreGraphics)
    @Test func `CGFloat conversion`() {
        let value = 42.5

        #expect(value.cgf == 42.5)
    }
    #endif
}
