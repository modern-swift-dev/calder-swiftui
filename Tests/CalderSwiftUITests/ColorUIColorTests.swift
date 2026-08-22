#if canImport(SwiftUI) || canImport(UIKit) || canImport(AppKit)
#if canImport(UIKit)
@testable import CalderSwiftUI
@testable import CalderUIKit
import Foundation
import SwiftUI
import Testing
import UIKit

@Suite(.serialized) struct ColorUIColorTests {

    // MARK: - Helper to extract RGB components

    private func getRGBComponents(_ color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }

    // MARK: - UIColor textColor

    @Test func `ui color text color for white`() {
        let color = UIColor.white
        let textColor = color.textColor
        // White background should return dark text
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        textColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 0 && g == 0 && b == 0) // Black
    }

    @Test func `ui color text color for black`() {
        let color = UIColor.black
        let textColor = color.textColor
        // Black background should return light text
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        textColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1 && g == 1 && b == 1) // White
    }

    @Test func `ui color contrasting text color custom colors`() {
        let color = UIColor.red
        let textColor = color.contrastingTextColor(light: .yellow, dark: .blue)
        // Red has luma ~0.299, which is < 0.5, so should return light color (yellow)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        textColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1 && g == 1 && b == 0) // Yellow
    }

    // MARK: - UIColor asSwiftUIColor

    @Test func `ui color as swift UI color`() {
        let uiColor = UIColor.red
        let swiftUIColor = uiColor.asSwiftUIColor
        let components = getRGBComponents(swiftUIColor)
        #expect(components.red == 1)
        #expect(components.green == 0)
        #expect(components.blue == 0)
    }

    // MARK: - Color rgb property

    @Test func `color RGB property for red`() {
        let color = Color.red
        let rgb = color.rgb
        #expect(rgb.hasPrefix("#"))
        #expect(rgb.count == 7)
    }

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

    // MARK: - Color rgba property

    @Test func `color RGBA property for red`() {
        let color = Color.red
        let rgba = color.rgba
        #expect(rgba.hasPrefix("#"))
        #expect(rgba.count == 9)
    }

    @Test func `color RGBA property for black opaque`() {
        let color = Color(red: 0, green: 0, blue: 0).opacity(1)
        let rgba = color.rgba
        #expect(rgba == "#000000FF")
    }

    // MARK: - Color textColor

    @Test func `color text color for white`() {
        let color = Color.white
        let textColor = color.textColor
        let components = getRGBComponents(textColor)
        // White should return black text
        #expect(components.red == 0)
        #expect(components.green == 0)
        #expect(components.blue == 0)
    }

    @Test func `color text color for black`() {
        let color = Color.black
        let textColor = color.textColor
        let components = getRGBComponents(textColor)
        // Black should return white text
        #expect(components.red == 1)
        #expect(components.green == 1)
        #expect(components.blue == 1)
    }

    // MARK: - Color darken

    @Test func `color darken`() {
        let color = Color.white
        let darkened = color.darken()
        let components = getRGBComponents(darkened)
        // Darkened white should be less than 1
        #expect(components.red < 1)
        #expect(components.green < 1)
        #expect(components.blue < 1)
    }

    @Test func `color darken with amount`() {
        let color = Color.white
        let darkened = color.darken(amount: 0.5)
        let components = getRGBComponents(darkened)
        #expect(components.red < 0.6)
        #expect(components.green < 0.6)
        #expect(components.blue < 0.6)
    }

    // MARK: - Color lighten

    @Test func `color lighten`() {
        let color = Color.black
        let lightened = color.lighten()
        let components = getRGBComponents(lightened)
        // Lightened black should be greater than 0
        #expect(components.red > 0)
        #expect(components.green > 0)
        #expect(components.blue > 0)
    }

    @Test func `color lighten with amount`() {
        let color = Color.black
        let lightened = color.lighten(amount: 0.5)
        let components = getRGBComponents(lightened)
        #expect(components.red > 0.4)
        #expect(components.green > 0.4)
        #expect(components.blue > 0.4)
    }

    // MARK: - Color brighten

    @Test func `color brighten`() {
        let color = Color(red: 0.5, green: 0.5, blue: 0.5)
        let brightened = color.brighten()
        let components = getRGBComponents(brightened)
        #expect(components.red > 0.5)
        #expect(components.green > 0.5)
        #expect(components.blue > 0.5)
    }

    @Test func `color brighten with amount`() {
        let color = Color(red: 0.5, green: 0.5, blue: 0.5)
        let brightened = color.brighten(amount: 0.3)
        let components = getRGBComponents(brightened)
        #expect(components.red > 0.6)
        #expect(components.green > 0.6)
        #expect(components.blue > 0.6)
    }

    // MARK: - Color dim

    @Test func `color dim`() {
        let color = Color(red: 0.5, green: 0.5, blue: 0.5)
        let dimmed = color.dim()
        let components = getRGBComponents(dimmed)
        #expect(components.red < 0.5)
        #expect(components.green < 0.5)
        #expect(components.blue < 0.5)
    }

    @Test func `color dim with amount`() {
        let color = Color(red: 0.5, green: 0.5, blue: 0.5)
        let dimmed = color.dim(amount: 0.3)
        let components = getRGBComponents(dimmed)
        #expect(components.red < 0.4)
        #expect(components.green < 0.4)
        #expect(components.blue < 0.4)
    }

    // MARK: - Color contrastingTextColor

    @Test func `color contrasting text color for light`() {
        let color = Color.white
        let textColor = color.contrastingTextColor(light: .white, dark: .black)
        // White background should return dark (black)
        let uiTextColor = textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiTextColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 0 && g == 0 && b == 0)
    }

    @Test func `color contrasting text color for dark`() {
        let color = Color.black
        let textColor = color.contrastingTextColor(light: .white, dark: .black)
        // Black background should return light (white)
        let uiTextColor = textColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiTextColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1 && g == 1 && b == 1)
    }

    // MARK: - Color uiColor property

    @Test func `color UI color property`() {
        // Use explicit RGB color instead of Color.red (which is a system color with non-standard RGB values)
        let swiftUIColor = Color(red: 1, green: 0, blue: 0)
        let uiColor = swiftUIColor.uiColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(r == 1)
        #expect(g == 0)
        #expect(b == 0)
    }

    @Test func `color UI color property for custom color`() {
        let swiftUIColor = Color(red: 0.5, green: 0.3, blue: 0.7)
        let uiColor = swiftUIColor.uiColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.5) < 0.01)
        #expect(abs(g - 0.3) < 0.01)
        #expect(abs(b - 0.7) < 0.01)
    }
}
#endif

#endif
