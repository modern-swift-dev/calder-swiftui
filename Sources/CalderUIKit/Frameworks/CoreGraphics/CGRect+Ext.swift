#if canImport(Darwin)
    #if canImport(CoreGraphics)
        import CoreGraphics
        import Foundation

        // MARK: - Constants
        public extension CGRect {

            /// A `CGRect` with origin at `.zero` and width/height of 1.0.
            static let one = CGRect(origin: .zero, size: .one)
        }

        // MARK: - Initializer
        public extension CGRect {

            /// Initializes a `CGRect` with specified x, y, width, and height.
            /// - Parameters:
            ///   - x: The x-coordinate of the rectangle's origin.
            ///   - y: The y-coordinate of the rectangle's origin.
            ///   - w: The width of the rectangle.
            ///   - h: The height of the rectangle.
            init(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
                self.init(x: x, y: y, width: w, height: h)
            }

            /// Initializes a `CGRect` with origin at `(0,0)` and specified width and height.
            /// - Parameters:
            ///   - w: The width of the rectangle.
            ///   - h: The height of the rectangle.
            init(w: CGFloat, h: CGFloat) {
                self.init(x: 0, y: 0, width: w, height: h)
            }

            /// Initializes a `CGRect` with origin at `(0,0)`, specified width, and height of 0.
            /// - Parameter w: The width of the rectangle.
            init(w: CGFloat) {
                self.init(x: 0, y: 0, width: w, height: 0)
            }

            /// Initializes a `CGRect` with origin at `(0,0)`, specified height, and width of 0.
            /// - Parameter h: The height of the rectangle.
            init(h: CGFloat) {
                self.init(x: 0, y: 0, width: 0, height: h)
            }

            /// Initializes a `CGRect` with origin at `.zero` and a specified size.
            /// - Parameter size: The `CGSize` of the rectangle.
            init(size: CGSize) {
                self.init(origin: .zero, size: size)
            }
        }

        // MARK: - computed properties
        public extension CGRect {

            /// The top-left corner point of the rectangle, `(minX, minY)`.
            ///
            /// "Top" follows the UIKit coordinate system, where y grows downward.
            var topLeft: CGPoint {
                .init(minX, minY)
            }

            /// The top-right corner point of the rectangle, `(maxX, minY)`.
            var topRight: CGPoint {
                .init(maxX, minY)
            }

            /// The bottom-left corner point of the rectangle, `(minX, maxY)`.
            var bottomLeft: CGPoint {
                .init(minX, maxY)
            }

            /// The bottom-right corner point of the rectangle, `(maxX, maxY)`.
            var bottomRight: CGPoint {
                .init(maxX, maxY)
            }

            /// The middle-left point of the rectangle, `(minX, midY)`.
            var midLeft: CGPoint {
                .init(minX, midY)
            }

            /// The middle-right point of the rectangle, `(maxX, midY)`.
            var midRight: CGPoint {
                .init(maxX, midY)
            }

            /// The center point of the rectangle, `(midX, midY)`.
            var center: CGPoint {
                .init(midX, midY)
            }
        }

        // MARK: - debugging
        public extension CGRect {

            /// A debug description of the `CGRect` value.
            var debugDescription: String {
                "CGRect(x: \(origin.x), y: \(origin.y), w: \(size.width), h: \(size.height)"
            }
        }
    #endif

#endif
