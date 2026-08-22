import CalderStdLib
import Foundation
import Testing

struct NSNumberExtTests {
    @Test func `Double conversion`() {
        #expect(123.456.asNumber.doubleValue == 123.456)
    }

    #if canImport(CoreGraphics)
    @Test func `CGFloat conversion`() {
        let value: CGFloat = 123.456

        #expect(value.asNumber.doubleValue == 123.456)
    }
    #endif
}
