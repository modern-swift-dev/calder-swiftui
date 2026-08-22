public extension String {
    /// Returns whether the string begins with the given value.
    /// - Parameter value: The prefix to test.
    func startingWith(_ value: String) -> Bool {
        hasPrefix(value)
    }
}
