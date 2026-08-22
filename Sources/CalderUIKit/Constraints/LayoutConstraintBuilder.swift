#if canImport(Darwin)
#if !os(watchOS)
import Foundation

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// A marker protocol that allows to convert to a set of NSLayoutConstraints.
@MainActor public protocol LayoutConstraintGroup {
    /// Returns the array of `NSLayoutConstraint`s represented by this group.
    var asConstraints: [NSLayoutConstraint] { get }
}

/// An extension for an array, to make it compatible with the `NSLayoutConstraint`.
extension NSLayoutConstraint: LayoutConstraintGroup {
    public var asConstraints: [NSLayoutConstraint] {
        [self]
    }
}

/// An extension for an array, to make it compatible with the `LayoutConstraintBuilder`.
extension [NSLayoutConstraint]: LayoutConstraintGroup {
    public var asConstraints: [NSLayoutConstraint] {
        self
    }
}

public extension NSLayoutConstraint {

    /// Activates a `LayoutConstraintBuilder` block, creating and activating constraints.
    /// - Parameter builder: A `@LayoutConstraintBuilder` closure that returns an array of `LayoutConstraintGroup`s.
    /// - Returns: An array of the activated `NSLayoutConstraint`s.
    @MainActor @discardableResult static func activate(@LayoutConstraintBuilder _ builder: () -> [any LayoutConstraintGroup]) -> [NSLayoutConstraint] {
        let constraints = builder().flatMap(\.asConstraints)
        constraints.activate()
        return constraints
    }
}

extension Swift.Optional: LayoutConstraintGroup where Wrapped: NSLayoutConstraint {
    public var asConstraints: [NSLayoutConstraint] {
        if self == nil {
            return []
        }
        return [unsafelyUnwrapped]
    }
}

/// A result builder for creating arrays of `NSLayoutConstraint`s.
@MainActor @resultBuilder public struct LayoutConstraintBuilder {

    /// Builds a block of multiple `LayoutConstraintGroup` components into a single array of `NSLayoutConstraint`s.
    public static func buildBlock(_ components: any LayoutConstraintGroup...) -> [NSLayoutConstraint] {
        components.map(\.asConstraints).flatMap(\.self)
    }

    /// Builds a single `LayoutConstraintGroup` component into an array of `NSLayoutConstraint`s.
    public static func buildBlock(_ component: any LayoutConstraintGroup) -> [NSLayoutConstraint] {
        component.asConstraints
    }

    /// Builds a conditional block, returning the first component's constraints.
    public static func buildEither(first component: any LayoutConstraintGroup) -> [NSLayoutConstraint] {
        component.asConstraints
    }

    /// Builds a conditional block, returning the second component's constraints.
    public static func buildEither(second component: any LayoutConstraintGroup) -> [NSLayoutConstraint] {
        component.asConstraints
    }

    /// Builds an expression into an array of `NSLayoutConstraint`s.
    public static func buildExpression(_ expression: any LayoutConstraintGroup) -> [NSLayoutConstraint] {
        expression.asConstraints
    }

    /// Builds the final result from a `LayoutConstraintGroup`.
    public static func buildFinalResult(_ component: any LayoutConstraintGroup) -> [NSLayoutConstraint] {
        component.asConstraints
    }
}
#endif

#endif
