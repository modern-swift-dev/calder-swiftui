#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
@testable import CalderSwiftUI
@testable import CalderUIKit
import Foundation
import SwiftUI
import Testing

@Suite(.serialized) struct ColorNSColorTests {

    // MARK: - Helpers

    private static let testWhite = Color(red: 1, green: 1, blue: 1)
    private static let testBlack = Color(red: 0, green: 0, blue: 0)
    private static let testGray = Color(red: 0.5, green: 0.5, blue: 0.5)
    private static let testRed = Color(red: 1, green: 0, blue: 0)

    private func getRGBComponents(_ color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        nsColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    // MARK: - NSColor textColor

    @Test func `ns color text color for white`() {
        let color = NSColor(Self.testWhite)
        let textColor = color.textColor
        let srgb = textColor.usingColorSpace(.sRGB) ?? textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        // White background should return dark text (black)
        #expect(r == 0)
        #expect(g == 0)
        #expect(b == 0)
    }

    @Test func `ns color text color for black`() {
        let color = NSColor(Self.testBlack)
        let textColor = color.textColor
        let srgb = textColor.usingColorSpace(.sRGB) ?? textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        // Black background should return light text (white)
        #expect(r == 1)
        #expect(g == 1)
        #expect(b == 1)
    }

    @Test func `ns color contrasting text color custom colors`() {
        let nsYellow = NSColor(red: 1, green: 1, blue: 0, alpha: 1)
        let nsBlue = NSColor(red: 0, green: 0, blue: 1, alpha: 1)
        let color = NSColor(Self.testRed)
        let textColor = color.contrastingTextColor(light: nsYellow, dark: nsBlue)
        // Red has luma ~0.299, which is < 0.5, so should return light color (yellow)
        let srgb = textColor.usingColorSpace(.sRGB) ?? textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1)
        #expect(g == 1)
        #expect(b == 0)
    }

    // MARK: - NSColor asSwiftUIColor

    @Test func `ns color as swift UI color`() {
        let nsColor = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
        let swiftUIColor = nsColor.asSwiftUIColor
        let components = getRGBComponents(swiftUIColor)
        #expect(abs(components.red - 1) < 0.01)
        #expect(abs(components.green - 0) < 0.01)
        #expect(abs(components.blue - 0) < 0.01)
    }

    // MARK: - Color rgb property

    @Test func `color RGB property for black`() {
        let color = Color(red: 0, green: 0, blue: 0)
        let rgb = color.rgb
        #expect(rgb == "#000000")
    }

    @Test func `color RGB property for white`() {
        let color = Color(red: 1, green: 1, blue: 1)
        let rgb = color.rgb
        #expect(rgb == "#FFFFFF")
    }

    @Test func `color RGB property for red`() {
        let color = Color(red: 1, green: 0, blue: 0)
        let rgb = color.rgb
        #expect(rgb == "#FF0000")
    }

    // MARK: - Color rgba property

    @Test func `color RGBA property for black opaque`() {
        let color = Color(red: 0, green: 0, blue: 0)
        let rgba = color.rgba
        #expect(rgba == "#000000FF")
    }

    @Test func `color RGBA property for white opaque`() {
        let color = Color(red: 1, green: 1, blue: 1)
        let rgba = color.rgba
        #expect(rgba == "#FFFFFFFF")
    }

    // MARK: - Color textColor

    @Test func `color text color for white`() {
        let color = Self.testWhite
        let textColor = color.textColor
        let components = getRGBComponents(textColor)
        // White should return black text
        #expect(components.red == 0)
        #expect(components.green == 0)
        #expect(components.blue == 0)
    }

    @Test func `color text color for black`() {
        let color = Self.testBlack
        let textColor = color.textColor
        let components = getRGBComponents(textColor)
        // Black should return white text
        #expect(components.red == 1)
        #expect(components.green == 1)
        #expect(components.blue == 1)
    }

    // MARK: - Color darken

    @Test func `color darken`() {
        let color = Self.testWhite
        let darkened = color.darken()
        let components = getRGBComponents(darkened)
        // Darkened white should be less than 1
        #expect(components.red < 1)
        #expect(components.green < 1)
        #expect(components.blue < 1)
    }

    @Test func `color darken with amount`() {
        let color = Self.testWhite
        let darkened = color.darken(amount: 0.5)
        let components = getRGBComponents(darkened)
        #expect(components.red < 0.6)
        #expect(components.green < 0.6)
        #expect(components.blue < 0.6)
    }

    // MARK: - Color lighten

    @Test func `color lighten`() {
        let color = Self.testBlack
        let lightened = color.lighten()
        let components = getRGBComponents(lightened)
        // Lightened black should be greater than 0
        #expect(components.red > 0)
        #expect(components.green > 0)
        #expect(components.blue > 0)
    }

    @Test func `color lighten with amount`() {
        let color = Self.testBlack
        let lightened = color.lighten(amount: 0.5)
        let components = getRGBComponents(lightened)
        #expect(components.red > 0.4)
        #expect(components.green > 0.4)
        #expect(components.blue > 0.4)
    }

    // MARK: - Color brighten

    @Test func `color brighten`() {
        let color = Self.testGray
        let brightened = color.brighten()
        let components = getRGBComponents(brightened)
        #expect(components.red > 0.5)
        #expect(components.green > 0.5)
        #expect(components.blue > 0.5)
    }

    @Test func `color brighten with amount`() {
        let color = Self.testGray
        let brightened = color.brighten(amount: 0.3)
        let components = getRGBComponents(brightened)
        #expect(components.red > 0.6)
        #expect(components.green > 0.6)
        #expect(components.blue > 0.6)
    }

    // MARK: - Color dim

    @Test func `color dim`() {
        let color = Self.testGray
        let dimmed = color.dim()
        let components = getRGBComponents(dimmed)
        #expect(components.red < 0.5)
        #expect(components.green < 0.5)
        #expect(components.blue < 0.5)
    }

    @Test func `color dim with amount`() {
        let color = Self.testGray
        let dimmed = color.dim(amount: 0.3)
        let components = getRGBComponents(dimmed)
        #expect(components.red < 0.4)
        #expect(components.green < 0.4)
        #expect(components.blue < 0.4)
    }

    // MARK: - Color contrastingTextColor

    @Test func `color contrasting text color for light`() {
        let color = Self.testWhite
        let textColor = color.contrastingTextColor(light: Self.testWhite, dark: Self.testBlack)
        // White background should return dark (black)
        let srgb = textColor.usingColorSpace(.sRGB) ?? textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 0)
        #expect(g == 0)
        #expect(b == 0)
    }

    @Test func `color contrasting text color for dark`() {
        let color = Self.testBlack
        let textColor = color.contrastingTextColor(light: Self.testWhite, dark: Self.testBlack)
        // Black background should return light (white)
        let srgb = textColor.usingColorSpace(.sRGB) ?? textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1)
        #expect(g == 1)
        #expect(b == 1)
    }

    // MARK: - Color nsColor property

    @Test func `color NS color property`() {
        let swiftUIColor = Color(red: 1, green: 0, blue: 0)
        let nsColor = swiftUIColor.nsColor
        let srgb = nsColor.usingColorSpace(.sRGB) ?? nsColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 1) < 0.01)
        #expect(abs(g - 0) < 0.01)
        #expect(abs(b - 0) < 0.01)
    }

    @Test func `color NS color property for custom color`() {
        let swiftUIColor = Color(red: 0.5, green: 0.3, blue: 0.7)
        let nsColor = swiftUIColor.nsColor
        let srgb = nsColor.usingColorSpace(.sRGB) ?? nsColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        srgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.5) < 0.01)
        #expect(abs(g - 0.3) < 0.01)
        #expect(abs(b - 0.7) < 0.01)
    }
}
#endif

#endif
