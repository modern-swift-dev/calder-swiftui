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
            #elseif os(macOS)
                /// Pins the current view to the specified pinnable guide, aligning it perfectly both vertically, horizontally, and with the exact same size minus the specified padding.
                /// - Parameters:
                ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
                ///   - margin: The margin to apply to the constraints. Defaults to `zero`.
                ///   - trailingConstraintPriority: Priority for the `trailingAnchor` / `bottomAnchor` constraint, potentially allowing them to break in case encapsulated width is lower than required.
                /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
                func pinned(to guide: any Pinnable, margin: LayoutConstraintMargin, trailingConstraintPriority: NSLayoutConstraint.Priority) -> any LayoutConstraintGroup
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

            /// Pins this view's `topAnchor` and `bottomAnchor` to another view's, without constraining the other axis.
            /// The view fills the guide's height; it isn't centred. Useful for self-sizing views cells.
            /// - Parameter guide: The layout guide (conforming to `Pinnable`) to pin to.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedVertically(to guide: any Pinnable) -> any LayoutConstraintGroup

            /// Pins this view's `topAnchor` and `bottomAnchor` to another view's, applying a uniform margin, without
            /// constraining the other axis. The view fills the guide's height; it isn't centred. Useful for self-sizing views cells.
            /// - Parameters:
            ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
            ///   - margin: The top and bottom margin to be applied to the `constant` of the constraints.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedVertically(to guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup

            /// Pins this view's `topAnchor` and `bottomAnchor` to another view's, applying distinct top and bottom margins,
            /// without constraining the other axis. The view fills the guide's height; it isn't centred. Useful for self-sizing views cells.
            /// - Parameters:
            ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
            ///   - topMargin: The top margin to be applied to the `constant` of the top constraint.
            ///   - bottomMargin: The bottom margin to be applied to the `constant` of the bottom constraint.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedVertically(to guide: any Pinnable, topMargin: CGFloat, bottomMargin: CGFloat) -> any LayoutConstraintGroup

            /// Pins this view's `leadingAnchor` and `trailingAnchor` to another view's, without constraining the other
            /// axis. The view fills the guide's width; it isn't centred. Useful for self-sizing views cells.
            /// - Parameter guide: The layout guide (conforming to `Pinnable`) to pin to.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedHorizontally(to guide: any Pinnable) -> any LayoutConstraintGroup

            /// Pins this view's `leadingAnchor` and `trailingAnchor` to another view's, applying a uniform margin, without
            /// constraining the other axis. The view fills the guide's width; it isn't centred. Useful for self-sizing views cells.
            /// - Parameters:
            ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
            ///   - margin: The leading and trailing margin to be applied to the `constant` of the constraints.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedHorizontally(to guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup

            /// Pins this view's `leadingAnchor` and `trailingAnchor` to another view's, applying distinct leading and
            /// trailing margins, without constraining the other axis. The view fills the guide's width; it isn't centred.
            /// Useful for self-sizing views cells.
            /// - Parameters:
            ///   - guide: The layout guide (conforming to `Pinnable`) to pin to.
            ///   - leadingMargin: The leading margin to be applied to the `constant` of the leading constraint.
            ///   - trailingMargin: The trailing margin to be applied to the `constant` of the trailing constraint.
            /// - Returns: A `LayoutConstraintGroup` representing the created constraints.
            func pinnedHorizontally(to guide: any Pinnable, leadingMargin: CGFloat, trailingMargin: CGFloat) -> any LayoutConstraintGroup
        }

        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
            extension UIView: MultiConstrainable {}
        #endif

        #if os(macOS) && !targetEnvironment(macCatalyst)
            extension NSView: MultiConstrainable {}
        #endif

        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS) || os(macOS)
            public extension MultiConstrainable where Self: Pinnable {

                func pinned(to guide: any Pinnable) -> any LayoutConstraintGroup {
                    pinned(to: guide, margin: .zero, trailingConstraintPriority: .required)
                }

                func pinned(
                    to guide: any Pinnable,
                    margin: LayoutConstraintMargin
                ) -> any LayoutConstraintGroup {
                    pinned(to: guide, margin: margin, trailingConstraintPriority: .required)
                }

                #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(visionOS)
                    func pinned(
                        to guide: any Pinnable,
                        margin: LayoutConstraintMargin = .zero,
                        trailingConstraintPriority: UILayoutPriority
                    ) -> any LayoutConstraintGroup {
                        let constraints = edgeConstraints(to: guide, margin: margin)
                        constraints[1].with(priority: trailingConstraintPriority)
                        constraints[3].with(priority: trailingConstraintPriority)
                        return constraints
                    }
                #else
                    func pinned(
                        to guide: any Pinnable,
                        margin: LayoutConstraintMargin = .zero,
                        trailingConstraintPriority: NSLayoutConstraint.Priority
                    ) -> any LayoutConstraintGroup {
                        let constraints = edgeConstraints(to: guide, margin: margin)
                        constraints[1].with(priority: trailingConstraintPriority)
                        constraints[3].with(priority: trailingConstraintPriority)
                        return constraints
                    }
                #endif

                func centered(on guide: any Pinnable) -> any LayoutConstraintGroup {
                    centered(on: guide, size: nil)
                }

                func centered(on guide: any Pinnable, size: CGSize?) -> any LayoutConstraintGroup {
                    var constraints = [
                        centerXAnchor.eq(guide.centerXAnchor),
                        centerYAnchor.eq(guide.centerYAnchor)
                    ]
                    if let size {
                        constraints += self.size(equals: size).asConstraints
                    }
                    return constraints
                }

                func size(equals guide: any Pinnable) -> any LayoutConstraintGroup {
                    [
                        widthAnchor.eq(guide.widthAnchor),
                        heightAnchor.eq(guide.heightAnchor)
                    ]
                }

                func size(equals size: CGSize) -> any LayoutConstraintGroup {
                    [
                        widthAnchor.eq(size.width),
                        heightAnchor.eq(size.height)
                    ]
                }

                func size(equals size: CGFloat) -> any LayoutConstraintGroup {
                    self.size(equals: CGSize(width: size, height: size))
                }

                func pinnedVertically(to guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedVertically(to: guide, topMargin: margin, bottomMargin: margin)
                }

                func pinnedVertically(to guide: any Pinnable, topMargin: CGFloat, bottomMargin: CGFloat) -> any LayoutConstraintGroup {
                    [
                        topAnchor.eq(guide.topAnchor, constant: topMargin),
                        bottomAnchor.eq(guide.bottomAnchor, constant: -bottomMargin)
                    ]
                }

                func pinnedVertically(to guide: any Pinnable) -> any LayoutConstraintGroup {
                    pinnedVertically(to: guide, margin: 0)
                }

                func pinnedHorizontally(to guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedHorizontally(to: guide, leadingMargin: margin, trailingMargin: margin)
                }

                func pinnedHorizontally(to guide: any Pinnable, leadingMargin: CGFloat, trailingMargin: CGFloat) -> any LayoutConstraintGroup {
                    [
                        leadingAnchor.eq(guide.leadingAnchor, constant: leadingMargin),
                        trailingAnchor.eq(guide.trailingAnchor, constant: -trailingMargin)
                    ]
                }

                func pinnedHorizontally(to guide: any Pinnable) -> any LayoutConstraintGroup {
                    pinnedHorizontally(to: guide, margin: 0)
                }

                /// Deprecated because the constraints pin the top and bottom edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedVertically(to:)")
                func verticallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup {
                    pinnedVertically(to: guide)
                }

                /// Deprecated because the constraints pin the top and bottom edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedVertically(to:margin:)")
                func verticallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedVertically(to: guide, margin: margin)
                }

                /// Deprecated because the constraints pin the top and bottom edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedVertically(to:topMargin:bottomMargin:)")
                func verticallyCentered(on guide: any Pinnable, topMargin: CGFloat, bottomMargin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedVertically(to: guide, topMargin: topMargin, bottomMargin: bottomMargin)
                }

                /// Deprecated because the constraints pin the leading and trailing edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedHorizontally(to:)")
                func horizontallyCentered(on guide: any Pinnable) -> any LayoutConstraintGroup {
                    pinnedHorizontally(to: guide)
                }

                /// Deprecated because the constraints pin the leading and trailing edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedHorizontally(to:margin:)")
                func horizontallyCentered(on guide: any Pinnable, margin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedHorizontally(to: guide, margin: margin)
                }

                /// Deprecated because the constraints pin the leading and trailing edges; they don't centre the view.
                @available(*, deprecated, renamed: "pinnedHorizontally(to:leadingMargin:trailingMargin:)")
                func horizontallyCentered(on guide: any Pinnable, leadingMargin: CGFloat, trailingMargin: CGFloat) -> any LayoutConstraintGroup {
                    pinnedHorizontally(to: guide, leadingMargin: leadingMargin, trailingMargin: trailingMargin)
                }
            }

            private extension MultiConstrainable where Self: Pinnable {

                /// The top, bottom, leading, and trailing constraints that pin the receiver to `guide`, in that order.
                func edgeConstraints(to guide: any Pinnable, margin: LayoutConstraintMargin) -> [NSLayoutConstraint] {
                    [
                        topAnchor.eq(guide.topAnchor, constant: margin.top),
                        bottomAnchor.eq(guide.bottomAnchor, constant: -margin.bottom),
                        leadingAnchor.eq(guide.leadingAnchor, constant: margin.leading),
                        trailingAnchor.eq(guide.trailingAnchor, constant: -margin.trailing)
                    ]
                }
            }
        #endif
    #endif

#endif
