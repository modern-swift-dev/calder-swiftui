public extension ClosedRange {
    /// Clamps a value to the bounds of this range.
    /// - Parameter value: The value to clamp.
    /// - Returns: The closest value contained in the range.
    func clampedValue(_ value: Bound) -> Bound {
        if value < lowerBound {
            return lowerBound
        }
        if value > upperBound {
            return upperBound
        }
        return value
    }
}
