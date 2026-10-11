public extension Array {
    /// Creates a dictionary by transforming each element into a key and value pair.
    ///
    /// When several elements produce the same key, the dictionary keeps the value from the last of them.
    /// - Parameter predicate: A transform that returns the dictionary key and value.
    /// - Returns: A dictionary containing every transformed element.
    /// - Throws: Rethrows the first error thrown by `predicate`.
    func hashMap<Key: Hashable>(predicate: (Element) throws -> (Key, Element)) rethrows -> [Key: Element] {
        var results = [Key: Element]()
        for element in self {
            let (key, value) = try predicate(element)
            results[key] = value
        }
        return results
    }
}
