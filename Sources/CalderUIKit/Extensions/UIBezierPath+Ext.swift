#if canImport(Darwin)
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst) || os(watchOS) || os(visionOS)
import Foundation
import UIKit

public extension UIBezierPath {
    /// Initializes a `UIBezierPath` with an oval path of a given size.
    /// - Parameters:
    ///   - size: The width and height of the oval.
    ///   - centered: A boolean indicating whether the oval should be centered in its coordinate space.
    convenience init(ovalOf size: CGSize, centered: Bool) {
        let origin = centered ? CGPoint(x: -size.width / 2, y: -size.height / 2) : .zero
        self.init(ovalIn: CGRect(origin: origin, size: size))
    }

    /// Initializes a `UIBezierPath` with a rectangular path of a given size.
    /// - Parameters:
    ///   - size: The width and height of the rectangle.
    ///   - centered: A boolean indicating whether the rectangle should be centered in its coordinate space.
    convenience init(rectOf size: CGSize, centered: Bool) {
        let origin = centered ? CGPoint(x: -size.width / 2, y: -size.height / 2) : .zero
        self.init(rect: CGRect(origin: origin, size: size))
    }
}
#endif

#endif
