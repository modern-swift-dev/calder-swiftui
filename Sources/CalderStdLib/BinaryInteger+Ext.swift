#if canImport(CoreGraphics)
import CoreGraphics
#endif

public extension BinaryInteger {
    #if canImport(CoreGraphics)
    /// Converts the integer value to `CGFloat`.
    var cgf: CGFloat {
        CGFloat(Double(self))
    }
    #endif
}
