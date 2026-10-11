public extension String {
    /// Returns a substring starting at an integer offset with the requested length.
    ///
    /// Offsets count characters, including extended grapheme clusters. A range that runs past the end of
    /// the string returns only its in-range part, which is empty when `start` is at or beyond the end.
    /// - Parameters:
    ///   - start: The offset from the beginning of the string.
    ///   - len: The maximum number of characters to include.
    /// - Returns: The in-range part of the substring, or the original string when `start` or `len` is negative.
    func substr(start: Int = 0, len: Int) -> String {
        guard start >= 0, len >= 0 else {
            return self
        }
        guard let lowerBoundary = index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return ""
        }
        let upperBoundary = index(lowerBoundary, offsetBy: len, limitedBy: endIndex) ?? endIndex
        return String(self[lowerBoundary ..< upperBoundary])
    }
}
