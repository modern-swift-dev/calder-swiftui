import Foundation

/// Parses and formats hexadecimal color strings for the `Color`, `UIColor`, and `NSColor` extensions.
///
/// A valid string has an optional `#`, `0x`, or `0X` prefix followed by exactly two hexadecimal
/// digits per channel. Whitespace, signs, and any other characters make the string invalid.
package enum HexColorChannels {

    /// Parses `string` into channel values in `0...1`.
    ///
    /// - Parameters:
    ///   - string: The hexadecimal string, such as `#AABBCC`, `0xAABBCC`, or `AABBCC`.
    ///   - count: The number of two-digit channels the string must contain.
    /// - Returns: The channel values divided by 255, or `nil` if the string is invalid.
    package static func parse(_ string: String, count: Int) -> [Double]? {
        var digits = Substring(string)
        if let prefix = ["#", "0x", "0X"].first(where: { digits.hasPrefix($0) }) {
            digits = digits.dropFirst(prefix.count)
        }

        let characters = Array(digits)
        guard characters.count == count * 2, characters.allSatisfy({ $0.isASCII && $0.isHexDigit }) else {
            return nil
        }

        return stride(from: 0, to: characters.count, by: 2).compactMap { index in
            UInt8(String(characters[index ... index + 1]), radix: 16).map { Double($0) / 255 }
        }
    }

    /// Formats channel values as two uppercase hexadecimal digits each, rounding to the nearest step.
    ///
    /// - Parameters:
    ///   - channels: The channel values, from `0` to `1`.
    ///   - prefix: The string placed before the digits, such as `#` or `0x`.
    /// - Returns: The prefix followed by two digits per channel.
    package static func format(_ channels: [Double], prefix: String) -> String {
        prefix + channels.map { String(format: "%02X", min(255, Int(($0 * 255).rounded()))) }.joined()
    }
}
