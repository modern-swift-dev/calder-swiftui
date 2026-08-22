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
