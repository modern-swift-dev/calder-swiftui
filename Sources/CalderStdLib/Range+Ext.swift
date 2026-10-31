public extension ClosedRange {
    /// Clamps a value to the bounds of this range.
    ///
    /// A value that isn't ordered with respect to the bounds, such as a floating-point `nan`, clamps to
    /// `lowerBound`.
    /// - Parameter value: The value to clamp.
    /// - Returns: The closest value contained in the range.
    func clampedValue(_ value: Bound) -> Bound {
        // `!(value >= lowerBound)` is true for values below the lower bound and for unordered values such as nan.
        if !(value >= lowerBound) {
            return lowerBound
        }
        if value > upperBound {
            return upperBound
        }
        return value
    }
}
