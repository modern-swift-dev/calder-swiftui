#if canImport(Darwin)
#if !os(watchOS)
#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
import UIKit
#endif

#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Protocol that can be implemented by anything that can be layed out.
@MainActor public protocol MultiConstrainable {

    /// Pins the current view to the specified pinnable guide, aligning it perfectly both vertically, horizontally, and with the exact same size.
    /// - Parameter guide: The layout guide (conforming to `Pinnable`) to pin to.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func pinned(to guide: any Pinnable) -> any LayoutConstraintGroup

    /// Pins the current view to the specified pinnable guide, aligning it perfectly both vertically, horizontally, and with the exact same size minus the specified padding.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
    ///   - margin: The margin to apply to the constraints. Defaults to `zero`.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func pinned(to guide: any Pinnable, margin: LayoutConstraintMargin) -> any LayoutConstraintGroup

    #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
    /// Pins the current view to the specified pinnable guide, aligning it perfectly both vertically, horizontally, and with the exact same size minus the specified padding.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
    ///   - margin: The margin to apply to the constraints. Defaults to `zero`.
    ///   - trailingConstraintPriority: Priority for the `trailingAnchor` / `bottomAnchor` constraint, potentially allowing them to break in case encapsulated width is lower than required.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func pinned(to guide: any Pinnable, margin: LayoutConstraintMargin, trailingConstraintPriority: UILayoutPriority) -> any LayoutConstraintGroup
    #endif

    /// Sets the view to the specified fixed size.
    /// - Parameter size: The `CGSize` for the width and height of the view.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func size(equals size: CGSize) -> any LayoutConstraintGroup

    /// Sets the view to a square size with the specified side length.
    /// - Parameter size: The `CGFloat` value for both width and height.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func size(equals size: CGFloat) -> any LayoutConstraintGroup

    /// Sets the view's size to be equal to another pinnable guide's size.
    /// - Parameter guide: The layout guide (conforming to `Pinnable`) whose size to match.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func size(equals guide: any Pinnable) -> any LayoutConstraintGroup

    /// Centers the view using its `centerXAnchor` and `centerYAnchor` relative to another pinnable guide.
    /// - Parameter guide: The layout guide (conforming to `Pinnable`) to center on.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func centered(on guide: any Pinnable) -> any LayoutConstraintGroup

    /// Centers the view using its `centerXAnchor` and `centerYAnchor` relative to another pinnable guide,
    /// and optionally enforces a specified size.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to center on.
    ///   - size: The `CGSize` to apply to the view. If `nil`, no constraints are applied to `widthAnchor` / `heightAnchor`.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func centered(on guide: any Pinnable, size: CGSize?) -> any LayoutConstraintGroup

    /// Vertically centers this view to another view using `topAnchor` and `bottomAnchor`. Useful for self-sizing views cells.
    /// - Parameter guide: The layout guide (conforming to `Pinnable`) to center on.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func verticallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup

    /// Vertically centers this view to another view using `topAnchor` and `bottomAnchor`, applying a uniform margin. Useful for self-sizing views cells.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to center on.
    ///   - margin: The top and bottom margin to be applied to the `constant` of the constraints.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func verticallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup

    /// Vertically centers this view to another view using `topAnchor` and `bottomAnchor`, applying distinct top and bottom margins. Useful for self-sizing views cells.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to center on.
    ///   - topMargin: The top margin to be applied to the `constant` of the top constraint.
    ///   - bottomMargin: The bottom margin to be applied to the `constant` of the bottom constraint.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func verticallyCentered(on guide: any Pinnable, topMargin: CGFloat, bottomMargin: CGFloat) -> any LayoutConstraintGroup

    /// Horizontally centers this view to another view using `leadingAnchor` and `trailingAnchor`. Useful for self-sizing views cells.
    /// - Parameter guide: The layout guide (conforming to `Pinnable`) to center on.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func horizontallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup

    /// Horizontally centers this view to another view using `leadingAnchor` and `trailingAnchor`, applying a uniform margin. Useful for self-sizing views cells.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to center on.
    ///   - margin: The leading and trailing margin to be applied to the `constant` of the constraints.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func horizontallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup

    /// Horizontally centers this view to another view using `leadingAnchor` and `trailingAnchor`, applying distinct leading and trailing margins. Useful for self-sizing views cells.
    /// - Parameters:
    ///   - guide: The layout guide (conforming to `Pinnable`) to center on.
    ///   - leadingMargin: The leading margin to be applied to the `constant` of the leading constraint.
    ///   - trailingMargin: The trailing margin to be applied to the `constant` of the trailing constraint.
    /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
    func horizontallyCentered(on guide: any Pinnable, leadingMargin: CGFloat, trailingMargin: CGFloat) -> any LayoutConstraintGroup
}

#if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
extension UIView: MultiConstrainable {

    public func pinned(to guide: any Pinnable) -> any LayoutConstraintGroup {
        // Implementation of `pinned(to:)` for `UIView`.
        pinned(to: guide, margin: .zero, trailingConstraintPriority: .required)
    }

    public func pinned(
        to guide: any Pinnable,
        margin: LayoutConstraintMargin
    ) -> any LayoutConstraintGroup {
        // Implementation of `pinned(to:margin:)` for `UIView`.
        pinned(to: guide, margin: margin, trailingConstraintPriority: .required)
    }

    public func pinned(
        to guide: any Pinnable,
        margin: LayoutConstraintMargin = .zero,
        trailingConstraintPriority: UILayoutPriority
    ) -> any LayoutConstraintGroup {
        // Implementation of `pinned(to:margin:trailingConstraintPriority:)` for `UIView`.
        [
            topAnchor.eq(
                guide.topAnchor,
                constant: margin.top
            ),
            bottomAnchor.eq(
                guide.bottomAnchor,
                constant: -margin.bottom
            ).with(priority: trailingConstraintPriority),
            leadingAnchor.eq(
                guide.leadingAnchor,
                constant: margin.leading
            ),
            trailingAnchor.eq(
                guide.trailingAnchor,
                constant: -margin.trailing
            ).with(priority: trailingConstraintPriority)
        ]
    }

    public func centered(on guide: any Pinnable) -> any LayoutConstraintGroup {
        // Implementation of `centered(on:)` for `UIView`.
        centered(on: guide, size: nil)
    }

    public func centered(on guide: any Pinnable, size: CGSize?) -> any LayoutConstraintGroup {
        // Implementation of `centered(on:size:)` for `UIView`.
        var constraints = [
            centerXAnchor.eq(guide.centerXAnchor),
            centerYAnchor.eq(guide.centerYAnchor)
        ]
        if let size {
            constraints += self.size(equals: size).asConstraints
        }
        return constraints
    }

    public func size(equals guide: any Pinnable) -> any LayoutConstraintGroup {
        // Implementation of `size(equals:)` for `UIView`.
        [
            widthAnchor.eq(guide.widthAnchor),
            heightAnchor.eq(guide.heightAnchor)
        ]
    }

    public func size(equals size: CGSize) -> any LayoutConstraintGroup {
        // Implementation of `size(equals:)` for `UIView`.
        [
            widthAnchor.eq(size.width),
            heightAnchor.eq(size.height)
        ]
    }

    public func size(equals size: CGFloat) -> any LayoutConstraintGroup {
        // Implementation of `size(equals:)` for `UIView`.
        self.size(equals: CGSize(width: size, height: size))
    }

    public func verticallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
        // Implementation of `verticallyCentered(on:margin:)` for `UIView`.
        verticallyCentered(on: guide, topMargin: margin, bottomMargin: margin)
    }

    public func verticallyCentered(on guide: any Pinnable, topMargin: CGFloat, bottomMargin: CGFloat) -> any LayoutConstraintGroup {
        // Implementation of `verticallyCentered(on:topMargin:bottomMargin:)` for `UIView`.
        [
            topAnchor.eq(guide.topAnchor, constant: topMargin),
            bottomAnchor.eq(guide.bottomAnchor, constant: -bottomMargin)
        ]
    }

    public func verticallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup {
        // Implementation of `verticallyCentered(on:)` for `UIView`.
        verticallyCentered(on: guide, margin: 0)
    }

    public func horizontallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
        // Implementation of `horizontallyCentered(on:margin:)` for `UIView`.
        [
            leadingAnchor.eq(guide.leadingAnchor, constant: margin),
            trailingAnchor.eq(guide.trailingAnchor, constant: -margin)
        ]
    }

    public func horizontallyCentered(on guide: any Pinnable, leadingMargin: CGFloat, trailingMargin: CGFloat) -> any LayoutConstraintGroup {
        // Implementation of `horizontallyCentered(on:leadingMargin:trailingMargin:)` for `UIView`.
        [
            leadingAnchor.eq(guide.leadingAnchor, constant: leadingMargin),
            trailingAnchor.eq(guide.trailingAnchor, constant: -trailingMargin)
        ]
    }

    public func horizontallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup {
        // Implementation of `horizontallyCentered(on:)` for `UIView`.
        horizontallyCentered(on: guide, margin: 0)
    }
}
#endif
#endif

#endif
