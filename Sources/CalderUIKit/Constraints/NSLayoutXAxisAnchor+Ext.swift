#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Sugar syntax for layout dimensions such as `leadingAnchor`, `trailingAnchor`, and `centerXAnchor`.
public extension NSLayoutXAxisAnchor {

    /// Creates a constraint that sets the anchor equal to another X-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to equate to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func eq(_ anchor: some NSLayoutXAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor less than or equal to another X-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to compare to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func leq(_ anchor: some NSLayoutXAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor greater than or equal to another X-axis anchor with an optional constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to compare to.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func geq(_ anchor: some NSLayoutXAxisAnchor, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, constant: constant)
    }

    /// Creates a constraint that sets the anchor equal to system spacing after another X-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func eqAfter(_ anchor: some NSLayoutXAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalToSystemSpacingAfter: anchor, multiplier: multiplier)
    }

    /// Creates a constraint that sets the anchor less than or equal to system spacing after another X-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func leqAfter(_ anchor: some NSLayoutXAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier)
    }

    /// Creates a constraint that sets the anchor greater than or equal to system spacing after another X-axis anchor with an optional multiplier.
    /// - Parameters:
    ///   - anchor: The `NSLayoutXAxisAnchor` to apply system spacing relative to.
    ///   - multiplier: The multiplier for the system spacing. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func geqAfter(_ anchor: some NSLayoutXAxisAnchor, multiplier: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToSystemSpacingAfter: anchor, multiplier: multiplier)
    }
}
#endif

#endif
