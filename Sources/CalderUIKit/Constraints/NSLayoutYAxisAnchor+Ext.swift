#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Sugar syntax for layout dimensions such as `topAnchor`, `bottomAnchor`, and `centerYAnchor`.
public extension NSLayoutYAxisAnchor {

    /// Creates a constraint that sets the anchor equal to another Y-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to equate to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func eq(_ anchor: some NSLayoutYAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor less than or equal to another Y-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to compare to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func leq(_ anchor: some NSLayoutYAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor greater than or equal to another Y-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to compare to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func geq(_ anchor: some NSLayoutYAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor equal to system spacing below another Y-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func eqBelow(_ anchor: some NSLayoutYAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingBelow: anchor, multiplier: multiplier)
    }

    /// Creates a constraint that sets the anchor less than or equal to system spacing below another Y-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func leqBelow(_ anchor: some NSLayoutYAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier)
    }

    /// Creates a constraint that sets the anchor greater than or equal to system spacing below another Y-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutYAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func geqBelow(_ anchor: some NSLayoutYAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingBelow: anchor, multiplier: multiplier)
    }
}
#endif

#endif
