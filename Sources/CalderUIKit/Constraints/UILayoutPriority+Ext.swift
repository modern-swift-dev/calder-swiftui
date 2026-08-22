#if canImport(Darwin)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit

/// Useful priorities that can be used.
public extension UILayoutPriority {

    /// A priority that is almost required, allowing for constraints to break if necessary while still being strong.
    static let almostRequired = UILayoutPriority(999)

}

#endif

#endif
