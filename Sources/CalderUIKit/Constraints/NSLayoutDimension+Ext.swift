#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Sugar syntax for layout dimensions such as `widthAnchor` and `heightAnchor`.
public extension NSLayoutDimension {

    /// Creates a constraint that sets the dimension equal to a constant value.
    /// - Parameter value: The constant value for the dimension.
    /// - Returns: A new `NSLayoutConstraint`.
    func eq(_ value: CGFloat) -> NSLayoutConstraint {
        constraint(equalToConstant: value)
    }

    /// Creates a constraint that sets the dimension equal to another dimension with an optional multiplier and constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutDimension` to equate to.
    ///   - multiplier: The multiplier for the constraint. Defaults to 1.0.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func eq(_ anchor: some NSLayoutDimension, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(equalTo: anchor, multiplier: multiplier, constant: constant)
    }

    /// Creates a constraint that sets the dimension less than or equal to another dimension with an optional multiplier and constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutDimension` to compare to.
    ///   - multiplier: The multiplier for the constraint. Defaults to 1.0.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func leq(_ anchor: some NSLayoutDimension, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(lessThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
    }

    /// Creates a constraint that sets the dimension less than or equal to a constant value.
    /// - Parameter value: The constant value for the dimension.
    /// - Returns: A new `NSLayoutConstraint`.
    func leq(_ value: CGFloat) -> NSLayoutConstraint {
        constraint(lessThanOrEqualToConstant: value)
    }

    /// Creates a constraint that sets the dimension greater than or equal to a constant value.
    /// - Parameter value: The constant value for the dimension.
    /// - Returns: A new `NSLayoutConstraint`.
    func geq(_ value: CGFloat) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualToConstant: value)
    }

    /// Creates a constraint that sets the dimension greater than or equal to another dimension with an optional multiplier and constant.
    /// - Parameters:
    ///   - anchor: The `NSLayoutDimension` to compare to.
    ///   - multiplier: The multiplier for the constraint. Defaults to 1.0.
    ///   - constant: The constant offset for the constraint. Defaults to 0.0.
    /// - Returns: A new `NSLayoutConstraint`.
    func geq(_ anchor: some NSLayoutDimension, multiplier: CGFloat = 1.0, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        constraint(greaterThanOrEqualTo: anchor, multiplier: multiplier, constant: constant)
    }

}
#endif

#endif
