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
        let points = corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) }
        let minX = points.min { param1, param2 in param1.x < param2.x }.map(\.x) ?? 0.cgf
        let minY = points.min { param1, param2 in param1.y < param2.y }.map(\.y) ?? 0.cgf
        let maxX = points.min { param1, param2 in param1.x > param2.x }.map(\.x) ?? 0.cgf
        let maxY = points.min { param1, param2 in param1.x > param2.y }.map(\.y) ?? 0.cgf
        return CGRect(minX, minY, maxX - minX, maxY - minY)
    }

    /// Return a UI Bezier Path for specified object.
    /// - parameter layer: The video layer
    /// - returns: The bezier path of the detected object
    func path(for layer: AVCaptureVideoPreviewLayer) -> UIBezierPath {
        let points = corners.map { layer.layerPointConverted(fromCaptureDevicePoint: $0) }
        let path = UIBezierPath(rect: layer.bounds)
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
