#if canImport(Darwin)
    import CalderStdLib
    import Foundation

    #if canImport(UIKit)
        import UIKit

        // MARK: Initializers
        public extension UIColor {
            /// Creates a color from a hexadecimal RGB string, such as `#AABBCC`, `0xAABBCC`, or `AABBCC`.
            ///
            /// The string may start with `#`, `0x`, or `0X`, followed by exactly six hexadecimal digits
            /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
            ///
            /// - Parameters:
            ///   - rgb: The red, green, and blue channels in hexadecimal notation.
            ///   - alpha: The opacity, from `0` to `1`. Defaults to `1`.
            /// - Returns: `nil` if `rgb` has the wrong number of digits or contains a non-hexadecimal character.
            convenience init?(rgb: String, alpha: CGFloat = 1) {
                guard let channels = HexColorChannels.parse(rgb, count: 3) else {
                    return nil
                }
                self.init(red: channels[0].cgf, green: channels[1].cgf, blue: channels[2].cgf, alpha: alpha)
            }

            /// Creates a color from a hexadecimal HSV string, such as `#AABBCC`, `0xAABBCC`, or `AABBCC`.
            ///
            /// The string may start with `#`, `0x`, or `0X`, followed by exactly six hexadecimal digits
            /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
            ///
            /// - Parameters:
            ///   - hsv: The hue, saturation, and brightness channels in hexadecimal notation.
            ///   - alpha: The opacity, from `0` to `1`. Defaults to `1`.
            /// - Returns: `nil` if `hsv` has the wrong number of digits or contains a non-hexadecimal character.
            convenience init?(hsv: String, alpha: CGFloat = 1) {
                guard let channels = HexColorChannels.parse(hsv, count: 3) else {
                    return nil
                }
                self.init(hue: channels[0].cgf, saturation: channels[1].cgf, brightness: channels[2].cgf, alpha: alpha)
            }

            /// Creates a color from a hexadecimal RGBA string, such as `#AABBCCDD`, `0xAABBCCDD`, or `AABBCCDD`.
            ///
            /// The string may start with `#`, `0x`, or `0X`, followed by exactly eight hexadecimal digits
            /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
            ///
            /// - Parameter rgba: The red, green, blue, and alpha channels in hexadecimal notation.
            /// - Returns: `nil` if `rgba` has the wrong number of digits or contains a non-hexadecimal character.
            convenience init?(rgba: String) {
                guard let channels = HexColorChannels.parse(rgba, count: 4) else {
                    return nil
                }
                self.init(red: channels[0].cgf, green: channels[1].cgf, blue: channels[2].cgf, alpha: channels[3].cgf)
            }

            /// Creates a color from a hexadecimal HSVA string, such as `#AABBCCDD`, `0xAABBCCDD`, or `AABBCCDD`.
            ///
            /// The string may start with `#`, `0x`, or `0X`, followed by exactly eight hexadecimal digits
            /// in either case. Whitespace, including leading and trailing whitespace, isn't accepted.
            ///
            /// - Parameter hsva: The hue, saturation, brightness, and alpha channels in hexadecimal notation.
            /// - Returns: `nil` if `hsva` has the wrong number of digits or contains a non-hexadecimal character.
            convenience init?(hsva: String) {
                guard let channels = HexColorChannels.parse(hsva, count: 4) else {
                    return nil
                }
                self.init(hue: channels[0].cgf, saturation: channels[1].cgf, brightness: channels[2].cgf, alpha: channels[3].cgf)
            }
        }

        // MARK: String

        public extension UIColor {
            /// Formats the color as a hexadecimal RGB string, such as `0xAABBCC`.
            ///
            /// Each sRGB channel is rounded to the nearest of 256 steps, so a color created with
            /// `init(rgb:)` formats back to the same digits.
            ///
            /// - Parameter prefix: The string placed before the digits. Defaults to `0x`.
            /// - Returns: The prefix followed by six uppercase hexadecimal digits.
            func toRGB(_ prefix: String = "0x") -> String {
                var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return HexColorChannels.format([red, green, blue].map(\.double), prefix: prefix)
            }

            /// Format a color to it's string representation HSV
            ///
            /// - parameter prefix for the string representation. Defaults to 0x
            func toHSV(_ prefix: String = "0x") -> String {
                var (hue, sat, bri, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                let hex = String(
                    format: "%02X%02X%02X",
                    min(255, Int(255 * hue)),
                    min(255, Int(255 * sat)),
                    min(255, Int(255 * bri))
                )
                return "\(prefix)\(hex)"
            }

            /// Format a color to it's string representation HSVA
            ///
            /// - parameter prefix for the string representation. Defaults to 0x
            func toHSVA(_ prefix: String = "0x") -> String {
                var (hue, sat, bri, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
                let hex = String(
                    format: "%02X%02X%02X%02X",
                    min(255, Int(255 * hue)),
                    min(255, Int(255 * sat)),
                    min(255, Int(255 * bri)),
                    min(255, Int(255 * alpha))
                )
                return "\(prefix)\(hex)"
            }

            /// Formats the color as a hexadecimal RGBA string, such as `0xAABBCCDD`.
            ///
            /// Each sRGB channel is rounded to the nearest of 256 steps, so a color created with
            /// `init(rgba:)` formats back to the same digits.
            ///
            /// - Parameter prefix: The string placed before the digits. Defaults to `0x`.
            /// - Returns: The prefix followed by eight uppercase hexadecimal digits.
            func toRGBA(_ prefix: String = "0x") -> String {
                var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
                getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                return HexColorChannels.format([red, green, blue, alpha].map(\.double), prefix: prefix)
            }
        }
    #endif

#endif
