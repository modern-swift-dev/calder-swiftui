#if canImport(Darwin)
    #if canImport(MapKit)
        import Foundation
        import MapKit

        public extension MKCoordinateRegion {
            /// Initializes an `MKCoordinateRegion` with a specified center coordinate and a distance.
            /// The region will form a square with the given distance for both latitudinal and longitudinal meters.
            /// - Parameters:
            ///   - center: The `CLLocationCoordinate2D` representing the center of the region.
            ///   - distance: The distance in meters, used for both latitudinal and longitudinal span.
            init(center: CLLocationCoordinate2D, distance: CLLocationDistance) {
                self = MKCoordinateRegion(center: center, latitudinalMeters: distance, longitudinalMeters: distance)
            }
        }

        public extension Sequence<CLLocationCoordinate2D> {

            /// Calculates an `MKCoordinateRegion` that encompasses all coordinates in the sequence,
            /// with an optional padding.
            ///
            /// The region is centered on the midpoint of the coordinates' bounding box. Its latitude delta
            /// spans the coordinates' latitudes and its longitude delta spans their longitudes.
            ///
            /// - Parameter padding: The additional distance in meters to add to each axis of the calculated span,
            ///   ensuring content fits with a margin. Defaults to 0.
            /// - Returns: An `MKCoordinateRegion` covering all coordinates, or `MKCoordinateRegion()`, which has a
            ///   zero center and a zero span, if the sequence is empty.
            func coordinateRegion(padding: CLLocationDistance = 0) -> MKCoordinateRegion {
                var furthestNorth = -90.0
                var furthestSouth = 90.0
                var furthestEast = -180.0
                var furthestWest = 180.0
                var hasCoordinates = false

                // Calculate center position
                for location in self {
                    hasCoordinates = true
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

                guard hasCoordinates else {
                    return MKCoordinateRegion()
                }

                let centerLocation = CLLocationCoordinate2D(
                    (furthestNorth + furthestSouth) / 2.0,
                    (furthestWest + furthestEast) / 2.0
                )
                let paddingSpan = MKCoordinateRegion(center: centerLocation, distance: padding).span
                let span = MKCoordinateSpan(
                    latitudeDelta: furthestNorth - furthestSouth + paddingSpan.latitudeDelta,
                    longitudeDelta: furthestEast - furthestWest + paddingSpan.longitudeDelta
                )
                return MKCoordinateRegion(center: centerLocation, span: span)
            }
        }

        public extension Sequence<CLLocation> {

            /// Calculates an `MKCoordinateRegion` that encompasses all `CLLocation` objects in the sequence,
            /// with an optional padding.
            /// - Parameter padding: The additional distance in meters to add to each axis of the calculated span,
            ///   ensuring content fits with a margin. Defaults to 0.
            /// - Returns: An `MKCoordinateRegion` covering all locations, or `MKCoordinateRegion()` if the sequence is empty.
            func coordinateRegion(padding: CLLocationDistance = 0) -> MKCoordinateRegion {
                map(\.coordinate).coordinateRegion(padding: padding)
            }
        }

        public extension Sequence<MKAnnotation> {

            /// Calculates an `MKCoordinateRegion` that encompasses all `MKAnnotation` objects in the sequence,
            /// with an optional padding.
            /// - Parameter padding: The additional distance in meters to add to each axis of the calculated span,
            ///   ensuring content fits with a margin. Defaults to 0.
            /// - Returns: An `MKCoordinateRegion` covering all annotations, or `MKCoordinateRegion()` if the sequence is empty.
            func coordinateRegion(padding: CLLocationDistance = 0) -> MKCoordinateRegion {
                map(\.coordinate).coordinateRegion(padding: padding)
            }
        }
    #endif

#endif
