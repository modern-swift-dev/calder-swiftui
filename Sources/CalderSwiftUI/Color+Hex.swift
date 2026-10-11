#if canImport(SwiftUI)
    import CalderStdLib
    import Foundation
    import SwiftUI

    // MARK: Hex
    public extension Color {

        /// Creates an opaque sRGB color from a hexadecimal string, such as `#AABBCC`, `0xAABBCC`, or `AABBCC`.
        ///
        /// The string may start with `#`, `0x`, or `0X`, followed by exactly six hexadecimal digits
        /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
        ///
        /// - Parameter rgb: The red, green, and blue channels in hexadecimal notation.
        /// - Returns: `nil` if `rgb` has the wrong number of digits or contains a non-hexadecimal character.
        init?(rgb: String) {
            guard let channels = HexColorChannels.parse(rgb, count: 3) else {
                return nil
            }
            self.init(red: channels[0], green: channels[1], blue: channels[2])
        }

        /// Creates an sRGB color from a hexadecimal string with an alpha channel, such as `#AABBCCDD`,
        /// `0xAABBCCDD`, or `AABBCCDD`.
        ///
        /// The string may start with `#`, `0x`, or `0X`, followed by exactly eight hexadecimal digits
        /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
        ///
        /// - Parameter rgba: The red, green, blue, and alpha channels in hexadecimal notation.
        /// - Returns: `nil` if `rgba` has the wrong number of digits or contains a non-hexadecimal character.
        init?(rgba: String) {
            guard let channels = HexColorChannels.parse(rgba, count: 4) else {
                return nil
            }
            self.init(red: channels[0], green: channels[1], blue: channels[2], opacity: channels[3])
        }

    }

#endif
