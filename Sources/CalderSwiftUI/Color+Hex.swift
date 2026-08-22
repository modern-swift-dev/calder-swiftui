#if canImport(SwiftUI)
import CalderStdLib
import Foundation
import SwiftUI

// MARK: Hex
public extension Color {

    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCC or #AABBCC
    ///
    /// - parameter rgb The RGB string in Hexadecimal notation
    /// - parameter the alpha channel (default to 1)
    init(rgb: String) {
        var value = rgb

        if rgb.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if rgb.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 6 {
            self = .white
            return
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

        self = .init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0)
    }

    /// Initialize the color from an hexadecimal string. Ex: 0xAABBCC or #AABBCC
    ///
    /// - parameter rgb The RGB string in Hexadecimal notation
    /// - parameter the alpha channel (default to 1)
    init?(rgba: String) {
        var value = rgba

        if rgba.startingWith("0x") {
            value = value.substr(start: 2, len: value.count - 2)
        }

        if rgba.startingWith("#") {
            value = value.substr(start: 1, len: value.count - 1)
        }

        if value.count != 8 {
            self = .white
            return
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

        self = .init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, opacity: alpha / 255.0)
    }

}

#endif
