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
            /// The latitude delta spans the coordinates' latitudes. The longitude delta is the smallest arc that
            /// covers every longitude, so coordinates either side of the antimeridian, such as `179°` and `-179°`,
            /// produce a `2°` span centred on `180°` instead of a `358°` span centred on `0°`. The padding extends
            /// both axes, and the result is clamped so its latitudes stay within `-90°...90°` and its spans stay
            /// within MapKit's limits of `180°` and `360°`.
            ///
            /// - Parameter padding: The additional distance in meters to add to each axis of the calculated span,
            ///   ensuring content fits with a margin. Defaults to 0.
            /// - Returns: An `MKCoordinateRegion` covering all coordinates, or `MKCoordinateRegion()`, which has a
            ///   zero center and a zero span, if the sequence is empty.
            func coordinateRegion(padding: CLLocationDistance = 0) -> MKCoordinateRegion {
                var furthestNorth = -90.0
                var furthestSouth = 90.0
                var longitudes: [CLLocationDegrees] = []

                for location in self {
                    furthestNorth = Swift.max(furthestNorth, location.latitude)
                    furthestSouth = Swift.min(furthestSouth, location.latitude)
                    // Wrap into -180..<180 so the longitudes can be ordered around the globe.
                    let offset = (location.longitude + 180).truncatingRemainder(dividingBy: 360)
                    longitudes.append((offset < 0 ? offset + 360 : offset) - 180)
                }

                guard !longitudes.isEmpty else {
                    return MKCoordinateRegion()
                }

                // The smallest arc starts after the largest gap between neighbouring longitudes. The gap across
                // the antimeridian is the starting candidate, so it only wins when it is strictly the largest.
                longitudes.sort()
                var west = longitudes[0]
                var largestGap = longitudes[0] + 360 - longitudes[longitudes.count - 1]
                for index in 1 ..< longitudes.count where longitudes[index] - longitudes[index - 1] > largestGap {
                    largestGap = longitudes[index] - longitudes[index - 1]
                    west = longitudes[index]
                }
                let longitudeSpan = 360 - largestGap
                let centerLongitude = west + longitudeSpan / 2.0

                let centerLocation = CLLocationCoordinate2D(
                    (furthestNorth + furthestSouth) / 2.0,
                    centerLongitude > 180 ? centerLongitude - 360 : centerLongitude
                )
                let paddingSpan = MKCoordinateRegion(center: centerLocation, distance: padding).span
                let paddingLatitude = paddingSpan.latitudeDelta.isFinite ? paddingSpan.latitudeDelta : 0
                let paddingLongitude = paddingSpan.longitudeDelta.isFinite ? paddingSpan.longitudeDelta : 360

                // Clamp the padded latitudes to the poles and re-centre on what is left.
                let paddedNorth = Swift.min(90.0, furthestNorth + paddingLatitude / 2.0)
                let paddedSouth = Swift.max(-90.0, furthestSouth - paddingLatitude / 2.0)
                return MKCoordinateRegion(
                    center: CLLocationCoordinate2D((paddedNorth + paddedSouth) / 2.0, centerLocation.longitude),
                    span: MKCoordinateSpan(
                        latitudeDelta: paddedNorth - paddedSouth,
                        longitudeDelta: Swift.min(360.0, longitudeSpan + paddingLongitude)
                    )
                )
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
