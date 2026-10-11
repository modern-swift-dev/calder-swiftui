#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
    #if canImport(UIKit)
        import CalderUIKit
        import Foundation
        import Testing
        import UIKit

        @Suite(.serialized) struct UIColorHexTests {

            // MARK: - RGB Init Tests

            @Test func `init rgb valid hex with hash`() {
                let color = UIColor(rgb: "#FF0000")
                #expect(color != nil)
            }

            @Test func `init rgb valid hex with ox prefix`() {
                let color = UIColor(rgb: "0xFF0000")
                #expect(color != nil)
            }

            @Test func `init rgb valid hex without prefix`() {
                let color = UIColor(rgb: "00FF00")
                #expect(color != nil)
            }

            @Test func `init rgb invalid hex too short`() {
                let color = UIColor(rgb: "FF00")
                #expect(color == nil)
            }

            @Test func `init rgb invalid hex too long`() {
                let color = UIColor(rgb: "FF00FF00FF")
                #expect(color == nil)
            }

            @Test func `init rgb with custom alpha`() {
                let color = UIColor(rgb: "FFFFFF", alpha: 0.5)
                #expect(color != nil)
            }

            @Test func `init rgb black`() {
                let color = UIColor(rgb: "000000")
                #expect(color != nil)
            }

            @Test func `init rgb white`() {
                let color = UIColor(rgb: "FFFFFF")
                #expect(color != nil)
            }

            // MARK: - HSV Init Tests

            @Test func `init hsv valid hex with hash`() {
                let color = UIColor(hsv: "#FF8080")
                #expect(color != nil)
            }

            @Test func `init hsv valid hex with ox prefix`() {
                let color = UIColor(hsv: "0xFF8080")
                #expect(color != nil)
            }

            @Test func `init hsv valid hex without prefix`() {
                let color = UIColor(hsv: "808080")
                #expect(color != nil)
            }

            @Test func `init hsv invalid hex too short`() {
                let color = UIColor(hsv: "FF80")
                #expect(color == nil)
            }

            @Test func `init hsv with custom alpha`() {
                let color = UIColor(hsv: "FFFFFF", alpha: 0.75)
                #expect(color != nil)
            }

            // MARK: - RGBA Init Tests

            @Test func `init rgba valid hex with hash`() {
                let color = UIColor(rgba: "#FF0000FF")
                #expect(color != nil)
            }

            @Test func `init rgba valid hex with ox prefix`() {
                let color = UIColor(rgba: "0xFF0000FF")
                #expect(color != nil)
            }

            @Test func `init rgba valid hex without prefix`() {
                let color = UIColor(rgba: "00FF0080")
                #expect(color != nil)
            }

            @Test func `init rgba invalid hex too short`() {
                let color = UIColor(rgba: "FF00FF")
                #expect(color == nil)
            }

            @Test func `init rgba invalid hex too long`() {
                let color = UIColor(rgba: "FF00FF00FF00")
                #expect(color == nil)
            }

            @Test func `init rgba fully transparent`() {
                let color = UIColor(rgba: "FFFFFF00")
                #expect(color != nil)
            }

            @Test func `init rgba fully opaque`() {
                let color = UIColor(rgba: "000000FF")
                #expect(color != nil)
            }

            // MARK: - HSVA Init Tests

            @Test func `init hsva valid hex with hash`() {
                let color = UIColor(hsva: "#FF8080FF")
                #expect(color != nil)
            }

            @Test func `init hsva valid hex with ox prefix`() {
                let color = UIColor(hsva: "0xFF8080FF")
                #expect(color != nil)
            }

            @Test func `init hsva valid hex without prefix`() {
                let color = UIColor(hsva: "80808080")
                #expect(color != nil)
            }

            @Test func `init hsva invalid hex too short`() {
                let color = UIColor(hsva: "FF8080")
                #expect(color == nil)
            }

            // MARK: - Round trips

            @Test(arguments: 0 ... 255)
            func `rgb round trips every grey level`(_ level: Int) throws {
                let hex = String(format: "%02X%02X%02X", level, level, level)
                #expect(try #require(UIColor(rgb: hex)).toRGB("") == hex)
            }

            @Test(arguments: ["000000", "FFFFFF", "090909", "336699", "AB12CD", "FF5500", "0055FF", "7F8081", "123456", "FEDCBA"])
            func `rgb round trips sample colors`(_ hex: String) throws {
                #expect(try #require(UIColor(rgb: hex)).toRGB("") == hex)
            }

            @Test(arguments: 0 ... 255)
            func `rgba round trips every alpha level`(_ level: Int) throws {
                let hex = String(format: "336699%02X", level)
                #expect(try #require(UIColor(rgba: hex)).toRGBA("") == hex)
            }

            // MARK: - Wide gamut

            @Test func `to RGB clamps display P3 colors to sRGB`() {
                #expect(UIColor(displayP3Red: 0, green: 1, blue: 0, alpha: 1).toRGB("") == "00FF00")
                #expect(UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1).toRGB("") == "FF0000")
            }

            @Test func `to RGBA clamps display P3 colors to sRGB`() {
                #expect(UIColor(displayP3Red: 0, green: 0, blue: 1, alpha: 0.5).toRGBA("") == "0000FF80")
            }

            // MARK: - Invalid input

            @Test(arguments: ["#GGHHII", "#12345G", "0x12345Z", "+12345", "-12345", "#+1234F", "#0x1234", "##123456"])
            func `init rgb and hsv reject invalid digits`(_ hex: String) {
                #expect(UIColor(rgb: hex) == nil)
                #expect(UIColor(hsv: hex) == nil)
            }

            @Test(arguments: ["#GGHHIIJJ", "#1234567G", "0x1234567Z", "+1234567", "-1234567", "#0x123456", "##1234567"])
            func `init rgba and hsva reject invalid digits`(_ hex: String) {
                #expect(UIColor(rgba: hex) == nil)
                #expect(UIColor(hsva: hex) == nil)
            }

            @Test(arguments: ["", "#", "0x", "0X"])
            func `init rejects empty values`(_ hex: String) {
                #expect(UIColor(rgb: hex) == nil)
                #expect(UIColor(hsv: hex) == nil)
                #expect(UIColor(rgba: hex) == nil)
                #expect(UIColor(hsva: hex) == nil)
            }

            @Test(arguments: [" #336699", "#336699 ", "#336699\n", "#33 6699", "\t0x336699"])
            func `init rgb and hsv reject whitespace`(_ hex: String) {
                #expect(UIColor(rgb: hex) == nil)
                #expect(UIColor(hsv: hex) == nil)
            }

            @Test(arguments: [" #336699CC", "#336699CC ", "#3366 99CC"])
            func `init rgba and hsva reject whitespace`(_ hex: String) {
                #expect(UIColor(rgba: hex) == nil)
                #expect(UIColor(hsva: hex) == nil)
            }

            @Test func `init accepts uppercase 0 X prefix`() {
                #expect(UIColor(rgb: "0X336699") != nil)
                #expect(UIColor(hsv: "0X8040C0") != nil)
                #expect(UIColor(rgba: "0X336699CC") != nil)
                #expect(UIColor(hsva: "0X8040C0CC") != nil)
            }

            // MARK: - toRGB Tests

            @Test func `to RGB red default prefix`() {
                let color = UIColor.red
                let hex = color.toRGB()
                #expect(hex.hasPrefix("0x"))
                #expect(hex.count == 8)
            }

            @Test func `to RGB custom prefix`() {
                let color = UIColor.green
                let hex = color.toRGB("#")
                #expect(hex.hasPrefix("#"))
            }

            @Test func `to RGB empty prefix`() {
                let color = UIColor.blue
                let hex = color.toRGB("")
                #expect(hex.count == 6)
            }

            @Test func `to RGB white`() {
                let color = UIColor.white
                let hex = color.toRGB("")
                #expect(hex == "FFFFFF")
            }

            @Test func `to RGB black`() {
                let color = UIColor.black
                let hex = color.toRGB("")
                #expect(hex == "000000")
            }

            // MARK: - toRGBA Tests

            @Test func `to RGBA opaque color`() {
                let color = UIColor.red
                let hex = color.toRGBA("")
                #expect(hex.count == 8)
                #expect(hex.hasSuffix("FF"))
            }

            @Test func `to RGBA semi transparent color`() {
                let color = UIColor.blue.withAlphaComponent(0.5)
                let hex = color.toRGBA("")
                #expect(hex.count == 8)
            }

            @Test func `to RGBA fully transparent color`() {
                let color = UIColor.green.withAlphaComponent(0.0)
                let hex = color.toRGBA("")
                #expect(hex.hasSuffix("00"))
            }

            // MARK: - toHSV Tests

            @Test func `to HSV default prefix`() {
                let color = UIColor.red
                let hex = color.toHSV()
                #expect(hex.hasPrefix("0x"))
                #expect(hex.count == 8)
            }

            @Test func `to HSV custom prefix`() {
                let color = UIColor.orange
                let hex = color.toHSV("#")
                #expect(hex.hasPrefix("#"))
            }

            // MARK: - toHSVA Tests

            @Test func `to HSVA opaque color`() {
                let color = UIColor.cyan
                let hex = color.toHSVA("")
                #expect(hex.count == 8)
            }

            @Test func `to HSVA semi transparent`() {
                let color = UIColor.magenta.withAlphaComponent(0.5)
                let hex = color.toHSVA("")
                #expect(hex.count == 8)
            }

            // MARK: - Round-trip Tests

            @Test func `round trip rgb`() {
                let originalHex = "AB12CD"
                guard let color = UIColor(rgb: originalHex) else {
                    Issue.record("Failed to create color from hex")
                    return
                }
                let resultHex = color.toRGB("")
                #expect(resultHex == originalHex)
            }

            @Test func `round trip rgba`() {
                let originalHex = "12345680"
                guard let color = UIColor(rgba: originalHex) else {
                    Issue.record("Failed to create color from hex")
                    return
                }
                let resultHex = color.toRGBA("")
                #expect(resultHex == originalHex)
            }
        }
    #endif

#endif
