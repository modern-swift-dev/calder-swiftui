#if canImport(Darwin)
#if canImport(MapKit)
import CoreLocation
import Foundation
import MapKit

public extension MKAnnotation {
    /// The latitude of the annotation's coordinate.
    var latitude: CLLocationDegrees {
        coordinate.latitude
    }

    /// The longitude of the annotation's coordinate.
    var longitude: CLLocationDegrees {
        coordinate.longitude
    }
}

public extension Sequence<MKAnnotation> {
    /// Calculates the geographical center of a sequence of `MKAnnotation` objects.
    /// This method determines the bounding box (furthest north, south, east, and west points)
    /// and returns a `CLLocationCoordinate2D` at the midpoint of that bounding box.
    /// - Returns: A `CLLocationCoordinate2D` representing the approximate center of the annotations.
    func center() -> CLLocationCoordinate2D {
        var furthestNorth = -90.0
        var furthestSouth = 90.0
        var furthestEast = -180.0
        var furthestWest = 180.0

        for location in self {
            if location.latitude > furthestNorth {
                furthestNorth = location.latitude
            }

            if location.latitude < furthestSouth {
                furthestSouth = location.latitude
            }

            if location.longitude > furthestEast {
                furthestEast = location.longitude
            }

            if location.longitude < furthestWest {
                furthestWest = location.longitude
            }
        }

        let lat = (furthestNorth + furthestSouth) / 2.0
        let lon = (furthestWest + furthestEast) / 2.0
        return CLLocationCoordinate2D(lat, lon)
    }
}
#endif

#endif
