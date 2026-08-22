#if canImport(SwiftUI)
import Foundation
import SwiftUI

public extension LinearGradient {

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
