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
            ///
            /// The center is the spherical mean of the locations' coordinates, so centers are correct across
            /// the antimeridian. See `Sequence<CLLocationCoordinate2D>.center()` for details.
            ///
            /// - Returns: A `CLLocation` at the spherical mean of the locations. Its coordinate is
            ///   `kCLLocationCoordinate2DInvalid` when the sequence is empty or the mean is undefined.
            func center() -> CLLocation {
                CLLocation(map(\.coordinate).center())
            }
        }
    #endif

#endif
