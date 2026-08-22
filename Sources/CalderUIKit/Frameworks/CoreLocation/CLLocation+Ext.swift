#if canImport(Darwin)
#if canImport(CoreLocation)
import CoreLocation
import Foundation

// MARK: - Initializers
public extension CLLocation {
    /// Initializes a `CLLocation` object with specified latitude and longitude.
    /// - Parameters:
    ///   - latitude: The latitude of the location in degrees.
    ///   - longitude: The longitude of the location in degrees.
    convenience init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        self.init(latitude: latitude, longitude: longitude)
    }

    /// Initializes a `CLLocation` object with a `CLLocationCoordinate2D`.
    /// - Parameter coordinate: The `CLLocationCoordinate2D` containing the latitude and longitude.
    convenience init(_ coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// MARK: - Computed Properties
public extension CLLocation {
    /// The latitude of the location in degrees.
    var latitude: CLLocationDegrees {
        coordinate.latitude
    }

    /// The longitude of the location in degrees.
    var longitude: CLLocationDegrees {
        coordinate.longitude
    }
}

// MARK: - Utilities
public extension Sequence where Element: CLLocation {
    /// Calculates the geographical center of a sequence of `CLLocation` objects.
    /// This method determines the bounding box (furthest north, south, east, and west points)
    /// and returns a `CLLocation` object at the midpoint of that bounding box.
    /// - Returns: A `CLLocation` representing the approximate center of the locations.
    func center() -> CLLocation {
        var furthestNorth = -90.0
        var furthestSouth = 90.0
        var furthestEast = -180.0
        var furthestWest = 180.0

        for arg in self {
            if arg.latitude > furthestNorth {
                furthestNorth = arg.latitude
            }

            if arg.latitude < furthestSouth {
                furthestSouth = arg.latitude
            }

            if arg.longitude > furthestEast {
                furthestEast = arg.longitude
            }

            if arg.longitude < furthestWest {
                furthestWest = arg.longitude
            }
        }

        let lat = (furthestNorth + furthestSouth) / 2.0
        let lon = (furthestWest + furthestEast) / 2.0
        return CLLocation(lat, lon)
    }
}
#endif

#endif
