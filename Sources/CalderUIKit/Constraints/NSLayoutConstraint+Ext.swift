#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Sugar syntax for layout constraint
public extension NSLayoutConstraint {

    #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
    /// Returns the constraint with the specified priority.
    /// - Parameter priority: The new layout priority.
    /// - Returns: The modified constraint.
    @discardableResult func with(priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
    #endif

    /// Returns the constraint with the specified identifier. Useful for debugging constraints.
    /// - Parameter identifier: The identifier of the constraint.
    /// - Returns: The modified constraint.
    @discardableResult func with(identifier: String) -> Self {
        self.identifier = identifier
        return self
    }

    /// Returns the constraint with the changed constant. Useful for animations.
    /// - Parameter value: The constant value to apply.
    /// - Returns: The modified constraint.
    @discardableResult func with(constant value: CGFloat) -> Self {
        constant = value
        return self
    }

    /// Assigns the constraint to a local field or property. Useful for chaining changes to constraints, such as for animations.
    /// - Parameter constraint: The in-out variable to which the constraint will be assigned.
    /// - Returns: The constraint itself.
    @discardableResult func assign(to constraint: inout NSLayoutConstraint?) -> Self {
        constraint = self
        return self
    }

    /// Activates the constraint and returns its reference.
    /// - Returns: The activated constraint.
    @discardableResult func activate() -> NSLayoutConstraint {
        isActive = true
        return self
    }

    /// Deactivates the constraint and returns its reference.
    /// - Returns: The deactivated constraint.
    @discardableResult func deactivate() -> NSLayoutConstraint {
        isActive = false
        return self
    }
}

/// Sugar syntax to activate or deactivate an array of constraints.
public extension [NSLayoutConstraint] {

    /// Activates all constraints in the array.
    @MainActor func activate() {
        NSLayoutConstraint.activate(self)
    }

    /// Deactivates all constraints in the array.
    @MainActor func deactivate() {
        NSLayoutConstraint.deactivate(self)
    }
}
#endif

#endif
