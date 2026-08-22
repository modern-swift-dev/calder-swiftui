#if canImport(CoreGraphics)
import CoreGraphics

public extension BinaryFloatingPoint {
    /// Converts the floating-point value to `Double`.
    var double: Double {
        Double(self)
    }

    /// Converts the floating-point value to `CGFloat`.
    var cgf: CGFloat {
        CGFloat(double)
    }
}
#endif
