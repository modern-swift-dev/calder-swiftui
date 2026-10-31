#if canImport(SwiftUI)
    import CalderUIKit
    import Foundation
    import SwiftUI

    public extension EdgeInsets {

        /// Edge insets of zero on every edge.
        ///
        /// Deprecated because `zero` is a common static member name that's likely to collide with a
        /// future SwiftUI or third-party declaration. SwiftUI's `EdgeInsets()` already creates zero insets.
        @available(*, deprecated, message: "Use EdgeInsets() instead.")
        static let zero = EdgeInsets(all: 0)

        /// Creates insets with the same value on the top and bottom edges and none on the sides.
        /// - Parameter vertical: The top and bottom inset.
        init(vertical: CGFloat) {
            self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
        }

        /// Creates insets with one value for the top and bottom edges and one for the leading and trailing edges.
        /// - Parameters:
        ///   - vertical: The top and bottom inset.
        ///   - horizontal: The leading and trailing inset.
        init(vertical: CGFloat, horizontal: CGFloat) {
            self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
        }

        /// Creates insets with the same value on the leading and trailing edges and none at the top and bottom.
        /// - Parameter horizontal: The leading and trailing inset.
        init(horizontal: CGFloat) {
            self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
        }

        /// Creates insets with the same value on every edge.
        /// - Parameter all: The inset for the top, leading, bottom, and trailing edges.
        init(all: CGFloat) {
            self.init(top: all, leading: all, bottom: all, trailing: all)
        }
    }

    @available(*, deprecated, renamed: "edgeInset")
    public extension CGFloat {

        /// Edge insets with this value on every edge.
        ///
        /// Deprecated because CalderUIKit's `CGFloat.edgeInset` does the same, next to `uiEdgeInset` and
        /// `directionalEdgeInset`.
        var asEdgeInsets: EdgeInsets {
            edgeInset
        }
    }

    public extension View {

        /// Adds padding to the top and bottom edges of this view.
        /// - Parameter vertical: The padding, in points, for the top and bottom edges.
        /// - Returns: A view with the padding applied.
        func padding(vertical: CGFloat) -> some View {
            padding(.init(vertical: vertical))
        }

        /// Adds padding to the leading and trailing edges of this view.
        /// - Parameter horizontal: The padding, in points, for the leading and trailing edges.
        /// - Returns: A view with the padding applied.
        func padding(horizontal: CGFloat) -> some View {
            padding(.init(horizontal: horizontal))
        }

        /// Adds padding to all four edges of this view, with separate values for the vertical and horizontal edges.
        /// - Parameters:
        ///   - vertical: The padding, in points, for the top and bottom edges.
        ///   - horizontal: The padding, in points, for the leading and trailing edges.
        /// - Returns: A view with the padding applied.
        func padding(vertical: CGFloat, horizontal: CGFloat) -> some View {
            padding(.init(vertical: vertical, horizontal: horizontal))
        }
    }

#endif
