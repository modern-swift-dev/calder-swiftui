#if canImport(Darwin)
    #if canImport(CoreLocation)
        import CalderStdLib
        import CoreLocation
        import Foundation

        /// A type alias for `Double` representing radians.
        public typealias Radians = Double

        public extension CLLocationCoordinate2D {
            /// Initializes a `CLLocationCoordinate2D` object with specified latitude and longitude.
            /// - Parameters:
            ///   - latitude: The latitude of the coordinate in degrees.
            ///   - longitude: The longitude of the coordinate in degrees.
            init(_ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
                self.init(latitude: latitude, longitude: longitude)
            }

            /// Converts the `CLLocationCoordinate2D` to a `CLLocation` object.
            /// - Returns: A `CLLocation` object representing the same geographical point.
            func toCLLocation() -> CLLocation {
                CLLocation(latitude, longitude)
            }
        }

        public extension CLLocationCoordinate2D {
            /// Calculates the less precise planar distance in degrees between two coordinates.
            /// This method is computationally less intensive and suitable for rough estimates.
            /// - Parameter otherLocation: The other `CLLocationCoordinate2D` to calculate the distance to.
            /// - Returns: The distance in degrees.
            func distance(from otherLocation: CLLocationCoordinate2D) -> CLLocationDegrees {
                let deltaLat: CLLocationDegrees = latitude - otherLocation.latitude
                let deltaLon: CLLocationDegrees = longitude - otherLocation.longitude
                return sqrt(deltaLat * deltaLat + deltaLon * deltaLon) as CLLocationDegrees
            }

            /// Calculates the less precise planar distance in meters between two coordinates.
            ///
            /// This method uses an equirectangular approximation: the longitude difference is measured the shorter
            /// way around the globe, including across the antimeridian, and scaled by the cosine of the mean
            /// latitude, so east-west distances shrink toward the poles. It is computationally
            /// less intensive than `CLLocation.distance(from:)` and suitable for rough estimates over short distances.
            /// - Parameter otherLocation: The other `CLLocationCoordinate2D` to calculate the distance to.
            /// - Returns: The distance in meters.
            func distanceInMeters(from otherLocation: CLLocationCoordinate2D) -> CLLocationDistance {
                let meanLatitude = ((latitude + otherLocation.latitude) / 2).degreesToRadians
                let deltaLat: CLLocationDegrees = latitude - otherLocation.latitude
                // Take the shorter way around so coordinates either side of the antimeridian are close.
                let deltaLon: CLLocationDegrees = remainder(longitude - otherLocation.longitude, 360) * cos(meanLatitude)
                return sqrt(deltaLat * deltaLat + deltaLon * deltaLon).degreesToMeters
            }
        }

        public extension CLLocationCoordinate2D {
            /// Checks if the current coordinate is near another coordinate within a specified degree threshold.
            /// - Parameters:
            ///   - otherLocation: The other `CLLocationCoordinate2D` to compare against.
            ///   - threshold: The maximum allowed distance in degrees for the coordinates to be considered "near".
            /// - Returns: `true` if the coordinates are within the specified threshold, `false` otherwise.
            func isNear(_ otherLocation: CLLocationCoordinate2D, threshold: CLLocationDegrees) -> Bool {
                let distance = distance(from: otherLocation)
                if distance > threshold {
                    return false
                }
                return true
            }

            /// Checks if the current coordinate is near another coordinate within a specified meter threshold.
            /// - Parameters:
            ///   - otherLocation: The other `CLLocationCoordinate2D` to compare against.
            ///   - thresholdInMeters: The maximum allowed distance in meters for the coordinates to be considered "near".
            /// - Returns: `true` if the coordinates are within the specified threshold, `false` otherwise.
            func isNear(_ otherLocation: CLLocationCoordinate2D, thresholdInMeters: CLLocationDistance) -> Bool {
                let distance = distanceInMeters(from: otherLocation)
                if distance > thresholdInMeters {
                    return false
                }
                return true
            }
        }

        public extension CLLocationCoordinate2D {
            /// Calculates the heading in radians from the current coordinate to a target coordinate.
            /// - Parameter to: The target `CLLocationCoordinate2D`.
            /// - Returns: The heading in radians.
            func getHeadingInRadians(fromHere to: CLLocationCoordinate2D) -> Radians {
                let fLat = latitude.degreesToRadians
                let fLng = longitude.degreesToRadians
                let tLat = to.latitude.degreesToRadians
                let tLng = to.longitude.degreesToRadians
                return atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))
            }

            /// Calculates the heading in degrees from the current coordinate to a target coordinate.
            /// The result is normalized to a range of 0 to 360 degrees.
            /// - Parameter to: The target `CLLocationCoordinate2D`.
            /// - Returns: The heading in degrees.
            func getHeadingInDegrees(fromHere to: CLLocationCoordinate2D) -> CLLocationDegrees {
                let degree = getHeadingInRadians(fromHere: to).radiansToDegrees
                if degree >= 0.0 {
                    return degree
                } else {
                    return 360.0 + degree
                }
            }
        }

        public extension Sequence<CLLocationCoordinate2D> {
            /// Calculates the geographical center of a sequence of `CLLocationCoordinate2D` values.
            ///
            /// The center is the spherical mean of the coordinates: each coordinate is converted to a unit
            /// vector, the vectors are averaged, and the average is converted back to a coordinate.
            /// Centers are therefore correct across the antimeridian; for example, `179°` and `-179°`
            /// center on `180°` rather than `0°`.
            ///
            /// - Returns: The spherical mean of the coordinates, or `kCLLocationCoordinate2DInvalid` when the
            ///   sequence is empty or the mean is undefined because the coordinates cancel out, such as two
            ///   antipodal points. Use `CLLocationCoordinate2DIsValid(_:)` to detect these cases.
            func center() -> CLLocationCoordinate2D {
                var x = 0.0
                var y = 0.0
                var z = 0.0
                for coordinate in self {
                    let latitude = coordinate.latitude.degreesToRadians
                    let longitude = coordinate.longitude.degreesToRadians
                    x += cos(latitude) * cos(longitude)
                    y += cos(latitude) * sin(longitude)
                    z += sin(latitude)
                }

                let horizontal = hypot(x, y)
                guard hypot(horizontal, z) > 1e-9 else {
                    return kCLLocationCoordinate2DInvalid
                }
                return CLLocationCoordinate2D(atan2(z, horizontal).radiansToDegrees, atan2(y, x).radiansToDegrees)
            }
        }

    #endif

#endif
