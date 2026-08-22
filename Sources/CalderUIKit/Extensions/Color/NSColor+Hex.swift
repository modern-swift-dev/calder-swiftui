#if canImport(Darwin)
import CalderStdLib
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: Initializers
public extension NSColor {
    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCC or #AABBCC
    ///
    /// - parameter rgb The RGB string in Hexadecimal notation
    /// - parameter the alpha channel (default to 1)
    convenience init?(rgb: String, alpha: CGFloat = 1) {
        var value = rgb

        if rgb.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if rgb.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 6 {
            return nil
        }

        var scanner = Scanner(string: "0x\(value.substr(start: 0, len: 2))")
        var red: Double = 0
        scanner.scanHexDouble(&red)

        scanner = Scanner(string: "0x\(value.substr(start: 2, len: 2))")
        var green: Double = 0
        scanner.scanHexDouble(&green)

        scanner = Scanner(string: "0x\(value.substr(start: 4, len: 2))")
        var blue: Double = 0
        scanner.scanHexDouble(&blue)

        self.init(
            red: (red / 255).cgf,
            green: (green / 255).cgf,
            blue: (blue / 255).cgf,
            alpha: alpha
        )
    }

    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCC or #AABBCC
    ///
    /// - parameter rgb The HSV string in Hexadecimal notation
    /// - parameter the alpha channel (default to 1)
    convenience init?(hsv: String, alpha: CGFloat = 1) {
        var value = hsv

        if hsv.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if hsv.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 6 {
            return nil
        }

        var scanner = Scanner(string: "0x\(value.substr(start: 0, len: 2))")
        var h: Double = 0
        scanner.scanHexDouble(&h)

        scanner = Scanner(string: "0x\(value.substr(start: 2, len: 2))")
        var s: Double = 0
        scanner.scanHexDouble(&s)

        scanner = Scanner(string: "0x\(value.substr(start: 4, len: 2))")
        var v: Double = 0
        scanner.scanHexDouble(&v)

        self.init(
            hue: (h / 255).cgf,
            saturation: (s / 255).cgf,
            brightness: (v / 255).cgf,
            alpha: alpha
        )
    }

    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCCDD or #AABBCCDD
    ///
    /// - parameter rgb The RGBA string in Hexadecimal notation
    convenience init?(rgba: String) {
        var value = rgba

        if rgba.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if rgba.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 8 {
            return nil
        }

        var scanner = Scanner(string: "0x\(value.substr(start: 0, len: 2))")
        var red: Double = 0
        scanner.scanHexDouble(&red)

        scanner = Scanner(string: "0x\(value.substr(start: 2, len: 2))")
        var green: Double = 0
        scanner.scanHexDouble(&green)

        scanner = Scanner(string: "0x\(value.substr(start: 4, len: 2))")
        var blue: Double = 0
        scanner.scanHexDouble(&blue)

        scanner = Scanner(string: "0x\(value.substr(start: 6, len: 2))")
        var alpha: Double = 0
        scanner.scanHexDouble(&alpha)

        self.init(
            red: (red / 255).cgf,
            green: (green / 255).cgf,
            blue: (blue / 255).cgf,
            alpha: (alpha / 255).cgf
        )
    }

    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCCDD or #AABBCCDD
    ///
    /// - parameter rgb The HSVA string in Hexadecimal notation
    convenience init?(hsva: String) {
        var value = hsva

        if hsva.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if hsva.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 8 {
            return nil
        }

        var scanner = Scanner(string: "0x\(value.substr(start: 0, len: 2))")
        var h: Double = 0
        scanner.scanHexDouble(&h)

        scanner = Scanner(string: "0x\(value.substr(start: 2, len: 2))")
        var s: Double = 0
        scanner.scanHexDouble(&s)

        scanner = Scanner(string: "0x\(value.substr(start: 4, len: 2))")
        var v: Double = 0
        scanner.scanHexDouble(&v)

        scanner = Scanner(string: "0x\(value.substr(start: 6, len: 2))")
        var alpha: Double = 0
        scanner.scanHexDouble(&alpha)

        self.init(
            hue: (h / 255).cgf,
            saturation: (s / 255).cgf,
            brightness: (v / 255).cgf,
            alpha: (alpha / 255).cgf
        )
    }
}

// MARK: String

public extension NSColor {
    /// Format a color to it's string representation RGB
    ///
    /// - parameter prefix for the string representation. Defaults to 0x
    func toRGB(_ prefix: String = "0x") -> String {
        // Convert to sRGB color space to safely extract RGB components
        let srgbColor = usingColorSpace(.sRGB) ?? self
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let hex = String(
            format: "%02X%02X%02X",
            min(255, Int(255 * red)),
            min(255, Int(255 * green)),
            min(255, Int(255 * blue))
        )
        return "\(prefix)\(hex)"
    }

    /// Format a color to it's string representation HSV
    ///
    /// - parameter prefix for the string representation. Defaults to 0x
    func toHSV(_ prefix: String = "0x") -> String {
        // Convert to sRGB color space to safely extract HSB components
        let srgbColor = usingColorSpace(.sRGB) ?? self
        var (hue, sat, bri, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        srgbColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
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
        // Convert to sRGB color space to safely extract HSB components
        let srgbColor = usingColorSpace(.sRGB) ?? self
        var (hue, sat, bri, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        srgbColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        let hex = String(
            format: "%02X%02X%02X%02X",
            min(255, Int(255 * hue)),
            min(255, Int(255 * sat)),
            min(255, Int(255 * bri)),
            min(255, Int(255 * alpha))
        )
        return "\(prefix)\(hex)"
    }

    /// Format a color to it's string representation RGBA
    ///
    /// - parameter prefix for the string representation. Defaults to 0x
    func toRGBA(_ prefix: String = "0x") -> String {
        // Convert to sRGB color space to safely extract RGB components
        let srgbColor = usingColorSpace(.sRGB) ?? self
        var (red, green, blue, alpha): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        srgbColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let hex = String(
            format: "%02X%02X%02X%02X",
            min(255, Int(255 * red)),
            min(255, Int(255 * green)),
            min(255, Int(255 * blue)),
            min(255, Int(255 * alpha))
        )
        return "\(prefix)\(hex)"
    }
}
#endif

#endif
