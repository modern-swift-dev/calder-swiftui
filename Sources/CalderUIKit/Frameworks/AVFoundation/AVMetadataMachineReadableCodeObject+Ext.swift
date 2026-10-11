#if canImport(Darwin)
    #if os(iOS) || targetEnvironment(macCatalyst)
        import AVFoundation
        import CalderStdLib
        import CoreGraphics
        import Foundation
        import UIKit

        public extension AVMetadataMachineReadableCodeObject {

            /// Return the rect for the specified metadata object in preview layer
            /// - parameter layer: The video layer
            /// - returns: The rect of the detected object
            func rect(in layer: AVCaptureVideoPreviewLayer) -> CGRect {
                Self.boundingRect(of: corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) })
            }

            /// Returns a cut-out path for the specified object.
            ///
            /// The path starts with the full bounds of `layer` and then adds the object's outline. Filled with the even-odd
            /// rule (`usesEvenOddFillRule` or `CAShapeLayerFillRule.evenOdd`), it covers the preview everywhere except the
            /// detected object, which makes it suitable for a dimming overlay that leaves the code visible.
            /// - parameter layer: The video layer
            /// - returns: The full-preview path with the object's outline cut out.
            func path(for layer: AVCaptureVideoPreviewLayer) -> UIBezierPath {
                Self.cutOutPath(in: layer.bounds, around: corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) })
            }

            /// Returns the smallest rectangle that contains `points`, or `.zero` when there are none.
            /// - Parameter points: The corners of a detected code in layer coordinates.
            /// - Returns: The bounding rectangle of `points`.
            internal static func boundingRect(of points: [CGPoint]) -> CGRect {
                let xs = points.map(\.x)
                let ys = points.map(\.y)
                let minX = xs.min() ?? 0.cgf
                let minY = ys.min() ?? 0.cgf
                let maxX = xs.max() ?? 0.cgf
                let maxY = ys.max() ?? 0.cgf
                return CGRect(minX, minY, maxX - minX, maxY - minY)
            }

            /// Returns a path made of `bounds` followed by the closed polygon through `points`.
            ///
            /// Filled with the even-odd rule, the path covers `bounds` except the polygon: an intentional cut-out.
            /// - Parameters:
            ///   - bounds: The bounds of the preview layer.
            ///   - points: The corners of a detected code in layer coordinates.
            /// - Returns: The combined path.
            internal static func cutOutPath(in bounds: CGRect, around points: [CGPoint]) -> UIBezierPath {
                let path = UIBezierPath(rect: bounds)
                for (x, point) in points.enumerated() {
                    if x == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                }
                path.close()
                return path
            }
        }
    #endif

#endif
