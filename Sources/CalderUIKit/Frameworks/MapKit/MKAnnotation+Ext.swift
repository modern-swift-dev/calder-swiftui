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
            ///
            /// The center is the spherical mean of the annotations' coordinates, so centers are correct across
            /// the antimeridian. See `Sequence<CLLocationCoordinate2D>.center()` for details.
            ///
            /// - Returns: The spherical mean of the annotations' coordinates, or `kCLLocationCoordinate2DInvalid`
            ///   when the sequence is empty or the mean is undefined.
            func center() -> CLLocationCoordinate2D {
                map(\.coordinate).center()
            }
        }
    #endif

#endif
