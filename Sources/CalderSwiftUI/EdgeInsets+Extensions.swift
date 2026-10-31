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

        init(vertical: CGFloat) {
            self.init(top: vertical, leading: 0, bottom: vertical, trailing: 0)
        }

        init(vertical: CGFloat, horizontal: CGFloat) {
            self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
        }

        init(horizontal: CGFloat) {
            self.init(top: 0, leading: horizontal, bottom: 0, trailing: horizontal)
        }

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

        func padding(vertical: CGFloat) -> some View {
            padding(.init(vertical: vertical))
        }

        func padding(horizontal: CGFloat) -> some View {
            padding(.init(horizontal: horizontal))
        }

        func padding(vertical: CGFloat, horizontal: CGFloat) -> some View {
            padding(.init(vertical: vertical, horizontal: horizontal))
        }
    }

#endif
