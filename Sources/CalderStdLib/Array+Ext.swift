public extension Array {
    /// Creates a dictionary by transforming each element into a key and value pair.
    /// - Parameter predicate: A transform that returns the dictionary key and value.
    /// - Returns: A dictionary containing each successfully transformed element.
    func hashMap<Key: Hashable>(predicate: (Element) throws -> (Key, Element)) -> [Key: Element] {
        var results = [Key: Element]()
        forEach {
            if let result = try? predicate($0) {
                results[result.0] = result.1
            }
        }
        return results
    }
}
