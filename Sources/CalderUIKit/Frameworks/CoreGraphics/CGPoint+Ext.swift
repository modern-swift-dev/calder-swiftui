#if canImport(Darwin)
#if canImport(CoreGraphics)
import CoreGraphics
import Foundation

// MARK: - Initializers
public extension CGPoint {

    /// Initializes a `CGPoint` with specified x and y coordinates.
    /// - Parameters:
    ///   - x: The x-coordinate.
    ///   - y: The y-coordinate.
    init(_ x: CGFloat, _ y: CGFloat) {
        self.init(x: x, y: y)
    }

    /// Initializes a `CGPoint` with a specified x-coordinate and a y-coordinate of 0.
    /// - Parameter x: The x-coordinate.
    init(x: CGFloat) {
        self.init(x: x, y: 0)
    }

    /// Initializes a `CGPoint` with a specified y-coordinate and an x-coordinate of 0.
    /// - Parameter y: The y-coordinate.
    init(y: CGFloat) {
        self.init(x: 0, y: y)
    }
}

// MARK: - Utilities
public extension CGPoint {

    /// Checks if the current point is near another point within a given tolerance.
    /// - Parameters:
    ///   - point: The other `CGPoint` to compare against.
    ///   - tolerance: The maximum allowed difference in x and y coordinates for the points to be considered "near". Defaults to 15.0.
    /// - Returns: `true` if the points are within the specified tolerance, `false` otherwise.
    func isNear(other point: CGPoint, tolerance: CGFloat = 15.0) -> Bool {
        let diffX = abs(x - point.x)
        let diffY = abs(y - point.y)
        guard diffX < tolerance, diffY < tolerance else {
            return false
        }
        return true
    }
}

// MARK: - Debugging
public extension CGPoint {

    /// A debug description of the `CGPoint` value.
    var debugDescription: String {
        "CGPoint(x: \(x), y: \(y)"
    }
}
#endif

#endif
