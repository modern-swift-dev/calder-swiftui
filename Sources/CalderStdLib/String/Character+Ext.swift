public extension Character {
    /// The character's integer value, or `nil` when it does not represent an integer.
    var int: Int? {
        Int(String(self))
    }
}
