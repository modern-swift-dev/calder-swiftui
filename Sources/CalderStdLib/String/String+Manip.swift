public extension String {
    /// Returns a substring starting at an integer offset with the requested length.
    /// - Parameters:
    ///   - start: The offset from the beginning of the string.
    ///   - len: The number of characters to include.
    /// - Returns: The substring, or the original string when either offset is invalid.
    func substr(start: Int = 0, len: Int) -> String {
        guard let lowerBoundary = index(startIndex, offsetBy: start, limitedBy: endIndex),
              let upperBoundary = index(lowerBoundary, offsetBy: len, limitedBy: endIndex) else {
            return self
        }
        return String(self[lowerBoundary ..< upperBoundary])
    }
}
