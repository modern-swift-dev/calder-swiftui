import Foundation

/// Extends `Double` to provide an `NSNumber` representation.
public extension Double {
    /// Converts the value to an `NSNumber`.
    var asNumber: NSNumber {
        NSNumber(value: self)
    }
}

#if canImport(CoreGraphics)
import CoreGraphics

/// Extends `CGFloat` to provide an `NSNumber` representation.
public extension CGFloat {
    /// Converts the value to an `NSNumber`.
    var asNumber: NSNumber {
        NSNumber(value: Double(self))
    }
}
#endif
