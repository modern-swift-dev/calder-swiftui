#if canImport(MapKit) && canImport(UIKit) && !os(watchOS)
import MapKit
import UIKit

/// The map state and operations needed by the clustering controller.
@MainActor protocol MapClusteringMap: AnyObject {
    var annotations: [any MKAnnotation] { get }
    var region: MKCoordinateRegion { get }
    var superview: UIView? { get }
    func addAnnotations(_ annotations: [any MKAnnotation])
    func removeAnnotations(_ annotations: [any MKAnnotation])
}

extension MKMapView: MapClusteringMap {}
#endif
