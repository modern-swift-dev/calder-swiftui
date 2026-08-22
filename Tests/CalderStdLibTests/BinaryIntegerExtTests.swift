@testable import CalderStdLib
#if canImport(CoreGraphics)
import CoreGraphics
#endif
import Testing

struct BinaryIntegerExtTests {
    #if canImport(CoreGraphics)
    @Test func `CGFloat conversion`() {
        #expect(42.cgf == 42)
    }
    #endif
}
