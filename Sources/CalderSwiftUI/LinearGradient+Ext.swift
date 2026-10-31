#if canImport(SwiftUI)
    import Foundation
    import SwiftUI

    public extension LinearGradient {

        /// Creates a gradient from a color to a darker version of it.
        /// - Parameters:
        ///   - color: The color at the start of the gradient.
        ///   - amount: How far the end color is blended towards black; see ``SwiftUICore/Color/darken(amount:)``.
        ///     Defaults to `0.125`.
        ///   - start: The point where the gradient starts. Defaults to `.top`.
        ///   - end: The point where the gradient ends. Defaults to `.bottom`.
        init(
            darken color: Color,
            amount: CGFloat = 0.125,
            start: UnitPoint = .top,
            end: UnitPoint = .bottom
        ) {
            self = LinearGradient(
                colors: [
                    color,
                    color.darken(amount: amount)
                ],
                startPoint: start,
                endPoint: end
            )
        }

        /// Creates a gradient from a color to a lighter version of it.
        /// - Parameters:
        ///   - color: The color at the start of the gradient.
        ///   - amount: How far the end color is blended towards white; see ``SwiftUICore/Color/lighten(amount:)``.
        ///     Defaults to `0.125`.
        ///   - start: The point where the gradient starts. Defaults to `.top`.
        ///   - end: The point where the gradient ends. Defaults to `.bottom`.
        init(
            lighten color: Color,
            amount: CGFloat = 0.125,
            start: UnitPoint = .top,
            end: UnitPoint = .bottom
        ) {
            self = LinearGradient(
                colors: [
                    color,
                    color.lighten(amount: amount)
                ],
                startPoint: start,
                endPoint: end
            )
        }

    }

#endif
