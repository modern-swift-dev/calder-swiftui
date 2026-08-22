#if canImport(Darwin)
#if canImport(MapKit) && !os(watchOS)
import Foundation
import MapKit

public extension Sequence<MKOverlay> {

    /// Calculates the bounding `MKMapRect` that encloses all overlays in the sequence.
    /// - Returns: An optional `MKMapRect` representing the smallest rectangle that contains all overlays, or `nil` if the sequence is empty.
    func boundingRect() -> MKMapRect? {
        var rect: MKMapRect?
        for overlay in self {
            rect = rect?.union(overlay.boundingMapRect) ?? overlay.boundingMapRect
        }
        return rect
    }
}
#endif

#endif
