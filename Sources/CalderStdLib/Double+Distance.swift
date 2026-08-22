/// Distance and angle conversions used by Calder's drawing and location helpers.
public extension BinaryFloatingPoint {
    /// Converts degrees to meters using an approximate latitude distance.
    var degreesToMeters: Self {
        self * 111.12000071117 * 1000
    }

    /// Converts meters to degrees using an approximate latitude distance.
    var metersToDegrees: Self {
        self / 1000 / 111.12000071117
    }

    /// Converts degrees to radians.
    var degreesToRadians: Self {
        .pi * self / 180.0
    }

    /// Converts radians to degrees.
    var radiansToDegrees: Self {
        self * 180.0 / .pi
    }
}
