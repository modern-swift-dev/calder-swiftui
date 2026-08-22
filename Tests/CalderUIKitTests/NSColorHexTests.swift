#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
@testable import CalderUIKit
import Testing

@Suite(.serialized) struct NSColorHexTests {
    private let tolerance: CGFloat = 0.01

    @Test func `init rgb accepts supported prefixes`() throws {
        #expect(try #require(NSColor(rgb: "#336699")).toRGB("") == "336699")
        #expect(try #require(NSColor(rgb: "0x336699")).toRGB("") == "336699")
        #expect(try #require(NSColor(rgb: "336699")).toRGB("") == "336699")
    }

    @Test func `init hsv accepts supported prefixes`() throws {
        #expect(try #require(NSColor(hsv: "#8040C0")).toHSV("") == "8040C0")
        #expect(try #require(NSColor(hsv: "0x8040C0")).toHSV("") == "8040C0")
        #expect(try #require(NSColor(hsv: "8040C0")).toHSV("") == "8040C0")
    }

    @Test func `init rgba accepts supported prefixes`() throws {
        #expect(try #require(NSColor(rgba: "#336699CC")).toRGBA("") == "336699CC")
        #expect(try #require(NSColor(rgba: "0x336699CC")).toRGBA("") == "336699CC")
        #expect(try #require(NSColor(rgba: "336699CC")).toRGBA("") == "336699CC")
    }

    @Test func `init hsva accepts supported prefixes`() throws {
        #expect(try #require(NSColor(hsva: "#8040C0CC")).toHSVA("") == "8040C0CC")
        #expect(try #require(NSColor(hsva: "0x8040C0CC")).toHSVA("") == "8040C0CC")
        #expect(try #require(NSColor(hsva: "8040C0CC")).toHSVA("") == "8040C0CC")
    }

    @Test func `init rgb and hsv reject invalid lengths`() {
        #expect(NSColor(rgb: "12345") == nil)
        #expect(NSColor(rgb: "1234567") == nil)
        #expect(NSColor(hsv: "12345") == nil)
        #expect(NSColor(hsv: "1234567") == nil)
    }

    @Test func `init rgba and hsva reject invalid lengths`() {
        #expect(NSColor(rgba: "1234567") == nil)
        #expect(NSColor(rgba: "123456789") == nil)
        #expect(NSColor(hsva: "1234567") == nil)
        #expect(NSColor(hsva: "123456789") == nil)
    }

    @Test func `init rgb extracts components`() throws {
        let color = try #require(NSColor(rgb: "336699", alpha: 0.75))
        let components = rgbComponents(color)

        #expect(abs(components.red - byte(0x33)) < tolerance)
        #expect(abs(components.green - byte(0x66)) < tolerance)
        #expect(abs(components.blue - byte(0x99)) < tolerance)
        #expect(abs(components.alpha - 0.75) < tolerance)
    }

    @Test func `init hsva extracts components`() throws {
        let color = try #require(NSColor(hsva: "8040C0CC"))
        let components = hsbaComponents(color)

        #expect(abs(components.hue - byte(0x80)) < tolerance)
        #expect(abs(components.saturation - byte(0x40)) < tolerance)
        #expect(abs(components.brightness - byte(0xC0)) < tolerance)
        #expect(abs(components.alpha - byte(0xCC)) < tolerance)
    }

    @Test func `to RGB uses default and custom prefixes`() {
        let color = NSColor(red: byte(0x33), green: byte(0x66), blue: byte(0x99), alpha: 1)

        #expect(color.toRGB() == "0x336699")
        #expect(color.toRGB("#") == "#336699")
        #expect(color.toRGB("") == "336699")
    }

    @Test func `to RGBA uses default and custom prefixes`() {
        let color = NSColor(red: byte(0x33), green: byte(0x66), blue: byte(0x99), alpha: byte(0xCC))

        #expect(color.toRGBA() == "0x336699CC")
        #expect(color.toRGBA("#") == "#336699CC")
        #expect(color.toRGBA("") == "336699CC")
    }

    @Test func `to HSV uses default and custom prefixes`() {
        let color = NSColor(hue: byte(0x80), saturation: byte(0x40), brightness: byte(0xC0), alpha: 1)

        #expect(color.toHSV() == "0x8040C0")
        #expect(color.toHSV("#") == "#8040C0")
        #expect(color.toHSV("") == "8040C0")
    }

    @Test func `to HSVA uses default and custom prefixes`() {
        let color = NSColor(hue: byte(0x80), saturation: byte(0x40), brightness: byte(0xC0), alpha: byte(0xCC))

        #expect(color.toHSVA() == "0x8040C0CC")
        #expect(color.toHSVA("#") == "#8040C0CC")
        #expect(color.toHSVA("") == "8040C0CC")
    }

    @Test func `rgb and rgba round trip`() throws {
        let rgb = "336699"
        let rgba = "336699CC"

        #expect(try #require(NSColor(rgb: rgb)).toRGB("") == rgb)
        #expect(try #require(NSColor(rgba: rgba)).toRGBA("") == rgba)
    }

    @Test func `hsv and hsva round trip`() throws {
        let hsv = "8040C0"
        let hsva = "8040C0CC"

        #expect(try #require(NSColor(hsv: hsv)).toHSV("") == hsv)
        #expect(try #require(NSColor(hsva: hsva)).toHSVA("") == hsva)
    }

    private func rgbComponents(_ color: NSColor) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = color.usingColorSpace(.sRGB) ?? color
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }

    private func hsbaComponents(_ color: NSColor) -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        let color = color.usingColorSpace(.sRGB) ?? color
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }

    private func byte(_ value: Int) -> CGFloat {
        CGFloat(value) / 255
    }
}
#endif

#endif
