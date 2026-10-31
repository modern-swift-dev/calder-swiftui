#if canImport(Darwin)
    #if canImport(UIKit)
        import Foundation
        import UIKit

        /// Extension methods for `UIColor` providing additional utilities.
        public extension UIColor {
            /// The alpha component of the color, from 0.0 to 1.0.
            ///
            /// This matches `NSColor.alphaComponent`.
            var alphaComponent: CGFloat {
                var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return alpha
            }
        }
    #endif

#endif
