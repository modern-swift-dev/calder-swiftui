#if canImport(Darwin)
    #if canImport(CoreGraphics)
        import CoreGraphics
        import Foundation

        // MARK: - Constants
        public extension CGSize {
            /// A `CGSize` with both width and height equal to 1.0.
            static let one = CGSize(1.0, 1.0)
        }

        // MARK: - Initializers
        public extension CGSize {

            /// Initializes a `CGSize` with specified width and height.
            /// - Parameters:
            ///   - w: The width.
            ///   - h: The height.
            init(_ w: CGFloat, _ h: CGFloat) {
                self.init(width: w, height: h)
            }

            /// Initializes a `CGSize` with a specified width and a height of 0.
            /// - Parameter w: The width.
            init(w: CGFloat) {
                self.init(w, 0)
            }

            /// Initializes a `CGSize` with a specified height and a width of 0.
            /// - Parameter h: The height.
            init(h: CGFloat) {
                self.init(0, h)
            }
        }

        // MARK: - Computed Properties
        public extension CGSize {

            /// Returns a `CGSize` with half the width and half the height of the original size.
            var half: CGSize {
                CGSize(width: width / 2.0, height: height / 2.0)
            }

            /// Returns a `CGSize` with a quarter of the width and a quarter of the height of the original size.
            var quarter: CGSize {
                CGSize(width: width / 4.0, height: height / 4.0)
            }

            /// Returns a `CGRect` with origin at `.zero` and the current `CGSize`.
            var rect: CGRect {
                CGRect(origin: .zero, size: self)
            }
        }

        // MARK: - Debugging
        public extension CGSize {

            /// A debugging description that names the type and labels its components, such as `CGSize(w: 3.0, h: 4.0)`.
            var labeledDebugDescription: String {
                "CGSize(w: \(width), h: \(height))"
            }

            /// The previous name of ``labeledDebugDescription``.
            ///
            /// Renamed because it collides with Apple's `debugDescription`: while this deprecated member exists,
            /// direct `debugDescription` calls are ambiguous in code that also imports Core Graphics. It will be
            /// removed in the next major version.
            @available(*, deprecated, renamed: "labeledDebugDescription")
            var debugDescription: String {
                labeledDebugDescription
            }
        }
    #endif

#endif
